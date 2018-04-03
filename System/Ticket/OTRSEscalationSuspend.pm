# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# $origin: otrs - 32c5efc03455e3f962a9553cf609279e56dbb657 - Kernel/System/Ticket.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::OTRSEscalationSuspend;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::State',
    'Kernel::System::Time',
);

=head1 NAME

Kernel::System::Ticket::TicketEscalationIndexBuild

=head1 SYNOPSIS

Builds escalation index of one ticket with current settings (SLA, Queue, Calendar...)

=head1 PUBLIC INTERFACE

=over 4

=cut

{
    # Disable redefine warnings in this scope.
    no warnings 'redefine';

    # Redefine TicketEscalationIndexBuild() of Kernel::System::Ticket.
    sub Kernel::System::Ticket::TicketEscalationIndexBuild {
        my ( $Self, %Param ) = @_;

        # check needed stuff
        for my $Needed (qw(TicketID UserID)) {
            if ( !defined $Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Need $Needed!",
                );
                return;
            }
        }

        my %Ticket = $Self->TicketGet(
            TicketID      => $Param{TicketID},
            UserID        => $Param{UserID},
            DynamicFields => 0,
        );

# ---
# OTRSEscalationSuspend
# ---
        # get states in which to suspend escalations
        my @SuspendStates      = @{ $Kernel::OM->Get('Kernel::Config')->Get('EscalationSuspendStates') };
        my $SuspendStateActive = 0;
        SUSPENDEDSTATE:
        for my $State (@SuspendStates) {
            if ( $Ticket{State} eq $State ) {
                $SuspendStateActive = 1;
                last SUSPENDEDSTATE;
            }
        }

# ---
        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # do no escalations on (merge|close|remove) tickets
        if ( $Ticket{StateType} && $Ticket{StateType} =~ /^(merge|close|remove)/i ) {

            # update escalation times with 0
            my %EscalationTimes = (
                EscalationTime         => 'escalation_time',
                EscalationResponseTime => 'escalation_response_time',
                EscalationUpdateTime   => 'escalation_update_time',
                EscalationSolutionTime => 'escalation_solution_time',
            );

            TIME:
            for my $Key ( sort keys %EscalationTimes ) {

                # check if table update is needed
                next TIME if !$Ticket{$Key};

                # update ticket table
                $DBObject->Do(
                    SQL =>
                        "UPDATE ticket SET $EscalationTimes{$Key} = 0, change_time = current_timestamp, "
                        . " change_by = ? WHERE id = ?",
                    Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ],
                );
            }

            # clear ticket cache
            $Self->_TicketCacheClear( TicketID => $Param{TicketID} );

            return 1;
        }

        # get escalation properties
        my %Escalation;
        if (%Ticket) {
            %Escalation = $Self->TicketEscalationPreferences(
                Ticket => \%Ticket,
                UserID => $Param{UserID},
            );
        }

        # find escalation times
        my $EscalationTime = 0;

        # update first response (if not responded till now)
        if ( !$Escalation{FirstResponseTime} ) {
            $DBObject->Do(
                SQL =>
                    'UPDATE ticket SET escalation_response_time = 0, change_time = current_timestamp, '
                    . ' change_by = ? WHERE id = ?',
                Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ]
            );
        }
        else {

            # check if first response is already done
            my %FirstResponseDone = $Self->_TicketGetFirstResponse(
                TicketID => $Ticket{TicketID},
                Ticket   => \%Ticket,
            );

            # update first response time to 0
            if (%FirstResponseDone) {
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_response_time = 0, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ]
                );
            }

            # update first response time to expected escalation destination time
            else {

# ---
# OTRSEscalationSuspend
# ---
#                # get time object
#                my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
#
#                my $DestinationTime = $TimeObject->DestinationTime(
#                    StartTime => $TimeObject->TimeStamp2SystemTime(
#                        String => $Ticket{Created}
#                    ),
#                    Time     => $Escalation{FirstResponseTime} * 60,
#                    Calendar => $Escalation{Calendar},
#                );
                my $DestinationTime = $Self->TicketEscalationSuspendCalculate(
                    TicketID     => $Ticket{TicketID},
                    StartTime    => $Ticket{Created},
                    ResponseTime => $Escalation{FirstResponseTime},
                    Calendar     => $Escalation{Calendar},
                    Suspended    => $SuspendStateActive,
                );
# ---

                # update first response time to $DestinationTime
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_response_time = ?, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$DestinationTime, \$Param{UserID}, \$Ticket{TicketID}, ]
                );

                # remember escalation time
                $EscalationTime = $DestinationTime;
            }
        }

        # update update && do not escalate in "pending auto" for escalation update time
        if ( !$Escalation{UpdateTime} || $Ticket{StateType} =~ /^(pending)/i ) {
            $DBObject->Do(
                SQL => 'UPDATE ticket SET escalation_update_time = 0, change_time = current_timestamp, '
                    . ' change_by = ? WHERE id = ?',
                Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ]
            );
        }
        else {

            # check if update escalation should be set
            my @SenderHistory;
            return if !$DBObject->Prepare(
                SQL => 'SELECT article_sender_type_id, article_type_id, create_time FROM '
                    . 'article WHERE ticket_id = ? ORDER BY create_time ASC',
                Bind => [ \$Param{TicketID} ],
            );
            while ( my @Row = $DBObject->FetchrowArray() ) {
                push @SenderHistory, {
                    SenderTypeID  => $Row[0],
                    ArticleTypeID => $Row[1],
                    Created       => $Row[2],
                };
            }

            # fill up lookups
            for my $Row (@SenderHistory) {

                # get sender type
                $Row->{SenderType} = $Self->ArticleSenderTypeLookup(
                    SenderTypeID => $Row->{SenderTypeID},
                );

                # get article type
                $Row->{ArticleType} = $Self->ArticleTypeLookup(
                    ArticleTypeID => $Row->{ArticleTypeID},
                );
            }

            # get latest customer contact time
            my $LastSenderTime;
            my $LastSenderType = '';
            ROW:
            for my $Row ( reverse @SenderHistory ) {

                # fill up latest sender time (as initial value)
                if ( !$LastSenderTime ) {
                    $LastSenderTime = $Row->{Created};
                }

                # do not use locked tickets for calculation
                #last ROW if $Ticket{Lock} eq 'lock';

                # do not use internal article types for calculation
                next ROW if $Row->{ArticleType} =~ /-int/i;

                # only use 'agent' and 'customer' sender types for calculation
                next ROW if $Row->{SenderType} !~ /^(agent|customer)$/;

                # last ROW if latest was customer and the next was not customer
                # otherwise use also next, older customer article as latest
                # customer followup for starting escalation
                if ( $Row->{SenderType} eq 'agent' && $LastSenderType eq 'customer' ) {
                    last ROW;
                }

                # start escalation on latest customer article
                if ( $Row->{SenderType} eq 'customer' ) {
                    $LastSenderType = 'customer';
                    $LastSenderTime = $Row->{Created};
                }

                # start escalation on latest agent article
                if ( $Row->{SenderType} eq 'agent' ) {
                    $LastSenderTime = $Row->{Created};
                    last ROW;
                }
            }
            if ($LastSenderTime) {

# ---
# OTRSEscalationSuspend
# ---
#                # get time object
#                my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
#
#                my $DestinationTime = $TimeObject->DestinationTime(
#                    StartTime => $TimeObject->TimeStamp2SystemTime(
#                        String => $LastSenderTime,
#                    ),
#                    Time     => $Escalation{UpdateTime} * 60,
#                    Calendar => $Escalation{Calendar},
#                );
                my $DestinationTime = $Self->TicketEscalationSuspendCalculate(
                    TicketID     => $Ticket{TicketID},
                    StartTime    => $LastSenderTime,
                    ResponseTime => $Escalation{UpdateTime},
                    Calendar     => $Escalation{Calendar},
                    Suspended    => $SuspendStateActive,
                );
# ---

                # update update time to $DestinationTime
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_update_time = ?, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$DestinationTime, \$Param{UserID}, \$Ticket{TicketID}, ]
                );

                # remember escalation time
                if ( $EscalationTime == 0 || $DestinationTime < $EscalationTime ) {
                    $EscalationTime = $DestinationTime;
                }
            }

            # else, no not escalate, because latest sender was agent
            else {
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_update_time = 0, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ]
                );
            }
        }

        # update solution
        if ( !$Escalation{SolutionTime} ) {
            $DBObject->Do(
                SQL =>
                    'UPDATE ticket SET escalation_solution_time = 0, change_time = current_timestamp, '
                    . ' change_by = ? WHERE id = ?',
                Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ],
            );
        }
        else {

            # find solution time / first close time
            my %SolutionDone = $Self->_TicketGetClosed(
                TicketID => $Ticket{TicketID},
                Ticket   => \%Ticket,
            );

            # update solution time to 0
            if (%SolutionDone) {
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_solution_time = 0, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$Param{UserID}, \$Ticket{TicketID}, ],
                );
            }
            else {

# ---
# OTRSEscalationSuspend
# ---
#                # get time object
#                my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
#
#                my $DestinationTime = $TimeObject->DestinationTime(
#                    StartTime => $TimeObject->TimeStamp2SystemTime(
#                        String => $Ticket{Created}
#                    ),
#                    Time     => $Escalation{SolutionTime} * 60,
#                    Calendar => $Escalation{Calendar},
#                );
                my $DestinationTime = $Self->TicketEscalationSuspendCalculate(
                    TicketID     => $Ticket{TicketID},
                    StartTime    => $Ticket{Created},
                    ResponseTime => $Escalation{SolutionTime},
                    Calendar     => $Escalation{Calendar},
                    Suspended    => $SuspendStateActive,
                );
# ---

                # update solution time to $DestinationTime
                $DBObject->Do(
                    SQL =>
                        'UPDATE ticket SET escalation_solution_time = ?, change_time = current_timestamp, '
                        . ' change_by = ? WHERE id = ?',
                    Bind => [ \$DestinationTime, \$Param{UserID}, \$Ticket{TicketID}, ],
                );

                # remember escalation time
                if ( $EscalationTime == 0 || $DestinationTime < $EscalationTime ) {
                    $EscalationTime = $DestinationTime;
                }
            }
        }

        # update escalation time (< escalation time)
        if ( defined $EscalationTime ) {
            $DBObject->Do(
                SQL => 'UPDATE ticket SET escalation_time = ?, change_time = current_timestamp, '
                    . ' change_by = ? WHERE id = ?',
                Bind => [ \$EscalationTime, \$Param{UserID}, \$Ticket{TicketID}, ],
            );
        }

        # clear ticket cache
        $Self->_TicketCacheClear( TicketID => $Param{TicketID} );

        return 1;
    }

    # Redefine _TicketGetFirstResponse() of Kernel::System::Ticket.
    sub Kernel::System::Ticket::_TicketGetFirstResponse {   ## no critic(Perl::Critic::Policy::OTRS::RequireCamelCase)
        my ( $Self, %Param ) = @_;

        # check needed stuff
        for my $Needed (qw(TicketID Ticket)) {
            if ( !defined $Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Need $Needed!"
                );
                return;
            }
        }

        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # check if first response is already done
        return if !$DBObject->Prepare(
            SQL => 'SELECT a.create_time,a.id FROM article a, article_sender_type ast, article_type art'
                . ' WHERE a.article_sender_type_id = ast.id AND a.article_type_id = art.id AND'
                . ' a.ticket_id = ? AND ast.name = \'agent\' AND'
                . ' (art.name LIKE \'email-ext%\' OR art.name LIKE \'note-ext%\' OR art.name = \'phone\' OR art.name = \'fax\' OR art.name = \'sms\')'
                . ' ORDER BY a.create_time',
            Bind  => [ \$Param{TicketID} ],
            Limit => 1,
        );

        my %Data;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $Data{FirstResponse} = $Row[0];

            # cleanup time stamps (some databases are using e. g. 2008-02-25 22:03:00.000000
            # and 0000-00-00 00:00:00 time stamps)
            $Data{FirstResponse} =~ s/^(\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d)\..+?$/$1/;
        }

        return if !$Data{FirstResponse};

        # get escalation properties
        my %Escalation = $Self->TicketEscalationPreferences(
            Ticket => $Param{Ticket},
            UserID => $Param{UserID} || 1,
        );

        if ( $Escalation{FirstResponseTime} ) {

            # get time object
            my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

            # get unix time stamps
            my $CreateTime = $TimeObject->TimeStamp2SystemTime(
                String => $Param{Ticket}->{Created},
            );
            my $FirstResponseTime = $TimeObject->TimeStamp2SystemTime(
                String => $Data{FirstResponse},
            );

            # get time between creation and first response
            my $WorkingTime = $TimeObject->WorkingTime(
                StartTime => $CreateTime,
                StopTime  => $FirstResponseTime,
                Calendar  => $Escalation{Calendar},
            );

# ---
# OTRSEscalationSuspend
# ---
            # subtract suspended time
            $WorkingTime -= $Self->TicketEscalationSuspendTime(
                TicketID           => $Param{TicketID},
                StartTime          => $CreateTime,
                ResponseTime       => $FirstResponseTime,
                Calendar           => $Escalation{Calendar},
                IsGetFirstResponse => 1,
            );

# ---
            $Data{FirstResponseInMin} = int( $WorkingTime / 60 );
            my $EscalationFirstResponseTime = $Escalation{FirstResponseTime} * 60;
            $Data{FirstResponseDiffInMin} = int( ( $EscalationFirstResponseTime - $WorkingTime ) / 60 );
        }

        return %Data;
    }

    # Redefine _TicketGetClosed() of Kernel::System::Ticket.
    sub Kernel::System::Ticket::_TicketGetClosed {  ## no critic(Perl::Critic::Policy::OTRS::RequireCamelCase)
        my ( $Self, %Param ) = @_;

        # check needed stuff
        for my $Needed (qw(TicketID Ticket)) {
            if ( !defined $Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Need $Needed!"
                );
                return;
            }
        }

        # get close state types
        my @List = $Kernel::OM->Get('Kernel::System::State')->StateGetStatesByType(
            StateType => ['closed'],
            Result    => 'ID',
        );
        return if !@List;

        # Get id for history types
        my @HistoryTypeIDs;
        for my $HistoryType (qw(StateUpdate NewTicket)) {
            push @HistoryTypeIDs, $Self->HistoryTypeLookup( Type => $HistoryType );
        }

        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        return if !$DBObject->Prepare(
            SQL => "
                SELECT MAX(create_time)
                FROM ticket_history
                WHERE ticket_id = ?
                   AND state_id IN (${\(join ', ', sort @List)})
                   AND history_type_id IN  (${\(join ', ', sort @HistoryTypeIDs)})
                ",
            Bind => [ \$Param{TicketID} ],
        );

        my %Data;
        ROW:
        while ( my @Row = $DBObject->FetchrowArray() ) {
            last ROW if !defined $Row[0];
            $Data{Closed} = $Row[0];

            # cleanup time stamps (some databases are using e. g. 2008-02-25 22:03:00.000000
            # and 0000-00-00 00:00:00 time stamps)
            $Data{Closed} =~ s/^(\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d)\..+?$/$1/;
        }

        return if !$Data{Closed};

        # for compat. wording reasons
        $Data{SolutionTime} = $Data{Closed};

        # get escalation properties
        my %Escalation = $Self->TicketEscalationPreferences(
            Ticket => $Param{Ticket},
            UserID => $Param{UserID} || 1,
        );

        # get time object
        my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

        # get unix time stamps
        my $CreateTime = $TimeObject->TimeStamp2SystemTime(
            String => $Param{Ticket}->{Created},
        );
        my $SolutionTime = $TimeObject->TimeStamp2SystemTime(
            String => $Data{Closed},
        );

        # get time between creation and solution
        my $WorkingTime = $TimeObject->WorkingTime(
            StartTime => $CreateTime,
            StopTime  => $SolutionTime,
            Calendar  => $Escalation{Calendar},
        );

# ---
# OTRSEscalationSuspend
# ---
        # subtract suspended time
        $WorkingTime -= $Self->TicketEscalationSuspendTime(
            TicketID     => $Param{TicketID},
            StartTime    => $CreateTime,
            ResponseTime => $SolutionTime,
            Calendar     => $Escalation{Calendar},
        );

# ---
        $Data{SolutionInMin} = int( $WorkingTime / 60 );

        if ( $Escalation{SolutionTime} ) {
            my $EscalationSolutionTime = $Escalation{SolutionTime} * 60;
            $Data{SolutionDiffInMin} = int( ( $EscalationSolutionTime - $WorkingTime ) / 60 );
        }

        return %Data;
    }

# ---
# OTRSEscalationSuspend
# ---
    sub Kernel::System::Ticket::TicketEscalationSuspendCalculate {
        my ( $Self, %Param ) = @_;

        # get config object
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # get states in which to suspend escalations
        my @SuspendStates = @{ $ConfigObject->Get('EscalationSuspendStates') };

        # get StateID->state map
        my %StateList = $Kernel::OM->Get('Kernel::System::State')->StateList(
            UserID => 1,
        );

        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # check for suspend times
        my @StateHistory;
        $DBObject->Prepare(
            SQL => '
                SELECT th.state_id, th.create_time
                FROM ticket_history th, ticket_history_type tht
                WHERE th.history_type_id = tht.id
                    AND tht.name IN (' . "'NewTicket', 'StateUpdate'" . ')
                    AND th.ticket_id = ?
                ORDER BY th.create_time ASC',
            Bind => [ \$Param{TicketID} ],
        );

        # get time object
        my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

        while ( my @Row = $DBObject->FetchrowArray() ) {
            push @StateHistory, {
                StateID     => $Row[0],
                Created     => $Row[1],
                CreatedUnix => $TimeObject->TimeStamp2SystemTime(
                    String => $Row[1],
                ),
                State => $StateList{ $Row[0] },
            };
        }

        # get update time difference in seconds
        my $UpdateDiffTime = $Param{ResponseTime} * 60;

        # add 4 minutes (time between CRON runs) if we are in suspend state to prevent escalation
        if ( $Param{Suspended} ) {
            $UpdateDiffTime += 4 * 60;
        }

        # start time in UNIX format
        my $DestinationTime = $TimeObject->TimeStamp2SystemTime(
            String => $Param{StartTime},
        );

        # loop through state changes
        my $SuspendState = 0;

        ROW:
        for my $Row (@StateHistory) {

            # this could only apply if the ticket was created on a suspend state (for first
            # response or solution ) or on update escalations, since:
            # $Row->{CreatedUnit} is the time form the history entry and
            # $DestinationTime is the Ticket Create time for first response and solution times)
            # and is the LastSendertime on update time
            if ( $Row->{CreatedUnix} <= $DestinationTime ) {

                # old state change, remember if suspend state
                $SuspendState = 0;
                for my $State (@SuspendStates) {
                    if ( $Row->{State} && $Row->{State} eq $State ) {
                        $SuspendState = 1;
                    }
                }
                next ROW;
            }

            # only enters in special cases (look the comment above)
            if ($SuspendState) {

                # move destination time forward if $SuspendState
                $DestinationTime = $Row->{CreatedUnix};
            }
            else {

                # calculate working time if no $SuspendState
                # this does not mean that the current ROW is not a suspend state just mean
                # just mean that the $SuspendState flag is not active
                my $WorkingTime = $TimeObject->WorkingTime(
                    StartTime => $DestinationTime,
                    StopTime  => $Row->{CreatedUnix},
                    Calendar  => $Param{Calendar},
                );
                if ( $WorkingTime < $UpdateDiffTime ) {

                    # move destination time, subtract time difference
                    $DestinationTime = $Row->{CreatedUnix};
                    $UpdateDiffTime -= $WorkingTime;
                }
                else {

                    # target time reached, calculate exact time
                    while ($UpdateDiffTime) {
                        $WorkingTime = $TimeObject->WorkingTime(
                            StartTime => $DestinationTime,
                            StopTime  => $DestinationTime + $UpdateDiffTime,
                            Calendar  => $Param{Calendar},
                        );
                        $DestinationTime += $UpdateDiffTime;
                        $UpdateDiffTime -= $WorkingTime;
                    }
                    last ROW;
                }

            }

            # remember if suspend state
            # this will set the REAL $SuspendState flag of the current ROW, different form the
            # if statement at the beginning
            $SuspendState = 0;
            for my $State (@SuspendStates) {
                if ( $Row->{State} && $Row->{State} eq $State ) {
                    $SuspendState = 1;
                }
            }
        }

        if ($UpdateDiffTime) {
            my $StartTime = $DestinationTime;
            if ($SuspendState) {

                # use current time-stamp if we are suspended
                $StartTime = $TimeObject->SystemTime();
            }

            # some time left? calculate remainder as usual
            # this will calculate the Destination time relatively to the next working our on the
            # calendar, it will not be moved if the start time is not in the calendar, since it
            # the it needs to be relative to the first working hour on the calendar.
            $DestinationTime = $TimeObject->DestinationTime(
                StartTime => $StartTime,
                Time      => $UpdateDiffTime,
                Calendar  => $Param{Calendar},
            );
        }

        # If there is no "UpdateDiffTime" left, the ticket is escalated.
        # calculate exact escalation time and also suspend escalation for escalated tickets!
        # This is a special customer wish and can be activated via config. By default this option
        # is inactive.
        elsif ( !$UpdateDiffTime && $ConfigObject->Get('SuspendEscalatedTickets') ) {

            # start time in UNIX format
            my $InterimDestinationTime = $TimeObject->TimeStamp2SystemTime(
                String => $Param{StartTime},
            );

            # "ResponseTime" (can also be f.e. SolutionTime)
            my $ResponseTime = $Param{ResponseTime} * 60;

            # add CRON job run time
            $ResponseTime += 4 * 60;

            # count escalated time in seconds
            my $EscalatedTime = 0;

            # calculate escalated time
            for my $Row (@StateHistory) {

                # check if current state should be suspended
                $SuspendState = 0;
                for my $State (@SuspendStates) {
                    if ( $Row->{State} && $Row->{State} eq $State ) {
                        $SuspendState = 1;
                    }
                }

                if ( !$SuspendState ) {

                    # move destination time forward, if state is not a suspend state
                    $InterimDestinationTime = $Row->{CreatedUnix};
                }
                else {

                    # calculate working time if state is suspend state
                    my $WorkingTime = $TimeObject->WorkingTime(
                        StartTime => $InterimDestinationTime,
                        StopTime  => $Row->{CreatedUnix},
                        Calendar  => $Param{Calendar},
                    );

                    # count time from unsuspended status
                    $EscalatedTime += $WorkingTime;
                }
            }
            my $StartTime;
            if ( $Param{Suspended} ) {

                # use current time-stamp, because current state should be suspended
                $StartTime = $TimeObject->SystemTime();
            }
            else {
                # use time of last non-suspend state
                $StartTime = $InterimDestinationTime;
            }
            $DestinationTime = $StartTime + $ResponseTime - $EscalatedTime;
        }

        return $DestinationTime;
    }

    sub Kernel::System::Ticket::TicketEscalationSuspendTime {
        my ( $Self, %Param ) = @_;

        # check needed stuff
        for my $Needed (qw(StartTime ResponseTime Calendar)) {
            if ( !defined $Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Need $Needed!"
                );
                return;
            }
        }

        # get time object
        my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

        # check times
        for my $Name (qw(StartTime ResponseTime)) {
            my $TimeStamp = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $Param{$Name},
            );
            if ( !$TimeStamp ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Invalid $Name!",
                );
                return;
            }
        }

        # get states in which to suspend escalations
        my @SuspendStates = @{ $Kernel::OM->Get('Kernel::Config')->Get('EscalationSuspendStates') };

        # get StateID->state map
        my %StateList = $Kernel::OM->Get('Kernel::System::State')->StateList(
            UserID => 1,
        );

        # get database object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # check for suspend times
        my @StateHistory;
        $DBObject->Prepare(
            SQL => "
                SELECT th.state_id, th.create_time
                FROM ticket_history th, ticket_history_type tht
                WHERE th.history_type_id = tht.id
                    AND ( tht.name IN ('NewTicket', 'StateUpdate' ) OR th.article_id IS NOT NULL )
                    AND th.ticket_id = ?
                ORDER BY th.create_time ASC",
            Bind => [ \$Param{TicketID} ],
        );

        while ( my @Row = $DBObject->FetchrowArray() ) {
            push @StateHistory, {
                StateID     => $Row[0],
                Created     => $Row[1],
                CreatedUnix => $TimeObject->TimeStamp2SystemTime(
                    String => $Row[1],
                ),
                State => $StateList{ $Row[0] },
            };
        }

        # start time
        my $StartTime = $Param{StartTime};

        # response time / solution time
        my $ResponseTime = $Param{ResponseTime};

        # count suspended time in seconds
        my $SuspendedTime = 0;

        # loop through state changes
        my $SuspendState = 0;

        ROW:
        for my $Row (@StateHistory) {

            # check if created in suspended state
            if ( $Row->{CreatedUnix} <= $StartTime ) {
                $SuspendState = 0;
                for my $State (@SuspendStates) {
                    if ( $Row->{State} && $Row->{State} eq $State ) {
                        $SuspendState = 1;
                    }
                }
                next ROW;
            }

            # calculate suspended time
            if ($SuspendState) {

                # get working time between start time and state change
                my $WorkingTime = $TimeObject->WorkingTime(
                    StartTime => $StartTime,
                    StopTime  => $Row->{CreatedUnix},
                    Calendar  => $Param{Calendar},
                );

                # if function call is from '_TicketGetFirstResponse'
                # stop if state change occured after supplied response time
                last ROW if $Param{IsGetFirstResponse} && $Row->{CreatedUnix} > $ResponseTime;
                $SuspendedTime += $WorkingTime;

            }

            # move start time forward
            $StartTime = $Row->{CreatedUnix};

            # check if current state should be suspended
            $SuspendState = 0;
            for my $State (@SuspendStates) {
                if ( $Row->{State} && $Row->{State} eq $State ) {
                    $SuspendState = 1;
                }
            }
        }

        return $SuspendedTime;
    }
# ---

    # reset all warnings
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
