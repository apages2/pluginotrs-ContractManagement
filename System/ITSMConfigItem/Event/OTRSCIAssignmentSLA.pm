# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentSLA;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Ticket',
);

=head1 NAME

Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentSLA - Event handler

=head1 SYNOPSIS

This handler assigns and removes service and SLA based on linked config items.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $OTRSCIAssignmentSLAObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentSLA');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item Run()

This method handles the event.

    $OTRSCIAssignmentSLAObject->Run(
        Event => 'LinkAdd', # or 'LinkDelete'
        Data  => {
            Comment      => 'new value: 1',
            ConfigItemID => 123,
        },
        UserID => 1,
    );

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data Event UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }
    for my $Needed (qw(Comment ConfigItemID)) {
        if ( !$Param{Data}->{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed in Data!",
            );
            return;
        }
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # service functionality has to be enabled
    return 1 if !$ConfigObject->Get('Ticket::Service');

    # need config items for Service/SLA
    my $ServiceField = $ConfigObject->Get('ITSMConfigItem::ServiceField');
    if ( !$ServiceField ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need config for ITSMConfigItem::ServiceField!',
        );
        return;
    }
    my $SLAField = $ConfigObject->Get('ITSMConfigItem::SLAField');
    if ( !$SLAField ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need config for ITSMConfigItem::SLAField!',
        );
        return;
    }

    # safety check - only link add/delete events
    return 1 if $Param{Event} !~ m{ \A Link (?: Add | Delete ) \z }xms;

    # only for ticket <-> CI link actions
    return 1 if $Param{Data}->{Comment} !~ m{ \A ( \d+ ) %% Ticket \z }xms;

    my $TicketID = $1;

    # get config item object
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    # check if config item contains Service and SLA (and is therefore to be considered)
    my $ConfigItem = $ConfigItemObject->ConfigItemGet(
        ConfigItemID => $Param{Data}->{ConfigItemID},
    );
    return if !$ConfigItem;

    my $CIVersion = $ConfigItemObject->VersionGet(
        VersionID => $ConfigItem->{LastVersionID},
    );

    return   if !$CIVersion;
    return 1 if !$CIVersion->{XMLData}->[1]->{Version}->[1]->{$ServiceField}->[1]->{Content};
    return 1 if !$CIVersion->{XMLData}->[1]->{Version}->[1]->{$SLAField}->[1]->{Content};

    my $Service = $CIVersion->{XMLData}->[1]->{Version}->[1]->{$ServiceField}->[1]->{Content};
    my $SLA     = $CIVersion->{XMLData}->[1]->{Version}->[1]->{$SLAField}->[1]->{Content};

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    return if !$TicketObject;

    # get ticket for comparison of Service and SLA
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID,
        UserID   => $Param{UserID},
    );
    if ( !%Ticket ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not retrieve ticket for ticket id '$TicketID'",
        );
        return;
    }

    my $ServiceID;
    my $SLAID;

    # check if Service and SLA from CI are usable for the affected ticket
    if ( $Param{Event} eq 'LinkAdd' ) {

        # check if Service is available
        my %Services = $TicketObject->TicketServiceList(
            TicketID => $TicketID,
            UserID   => $Param{UserID},
        );
        %Services = %Services ? reverse %Services : ();
        if ( !$Services{$Service} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Service '$Service' is not available for ticket id '$TicketID'!",
            );
            return 1;
        }

        $ServiceID = $Services{$Service};

        # check if SLA is available
        my %SLAs = $TicketObject->TicketSLAList(
            ServiceID => $Services{$Service},
            TicketID  => $TicketID,
            UserID    => $Param{UserID},
        );

        %SLAs = %SLAs ? reverse %SLAs : ();
        if ( !$SLAs{$SLA} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "SLA '$SLA' is not available for ticket id '$TicketID'!",
            );
            return 1;
        }

        $SLAID = $SLAs{$SLA};

        # check if Service and SLA need to be updated
        if (
            $Ticket{Service}
            && $Ticket{Service} eq $Service
            && $Ticket{SLA}
            && $Ticket{SLA} eq $SLA
            )
        {
            return 1;
        }
    }

    # check if current service and SLA of ticket match the values of the CI
    else {

        # if no Service or SLA is set, nothing is to be done
        return 1 if !$Ticket{Service} || !$Ticket{SLA};

        # if Service or SLA differ from CI, manual changes have occurred -> abort
        return 1 if $Ticket{Service} ne $Service || $Ticket{SLA} ne $SLA;

        # set to empty-string for LinkDelete in order to
        # properly remove data from ticket (undef won't work)
        $ServiceID = '';
        $SLAID     = '';
    }

    # set/unset Service
    my $Type = $Param{Event} eq 'LinkAdd' ? 'set' : 'unset';
    my $ServiceSetSuccess = $TicketObject->TicketServiceSet(
        ServiceID => $ServiceID,
        TicketID  => $TicketID,
        UserID    => $Param{UserID},
    );
    if ( !$ServiceSetSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Couldn't $Type service '$Service' for ticket id '$TicketID'!",
        );
        return;
    }

    # set/clear SLA
    my $SLASetSuccess = $TicketObject->TicketSLASet(
        SLAID    => $SLAID,
        TicketID => $TicketID,
        UserID   => $Param{UserID},
    );
    if ( !$SLASetSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Couldn't $Type SLA '$SLA' for ticket id '$TicketID'!",
        );
        return;
    }

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=head1 VERSION

=cut
