# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::VideoChat;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::CloudService::Backend::Run',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::OTRSBusiness',
    'Kernel::System::Time',
);

=head1 NAME

Kernel::System::VideoChat - real time video communication backend

=head1 SYNOPSIS

WebRTC backend

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $VideoChatObject = $Kernel::OM->Get('Kernel::System::VideoChat');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # cache config
    $Self->{CacheType} = 'VideoChat';
    $Self->{CacheTTL}  = 60 * 60 * 24;    # 1 day

    # signal validity
    $Self->{SignalTTL} = 30;              # 30 seconds

    return $Self;
}

=item SendSignal()

send a signal to user.

    my $Success = $VideoChatObject->SendSignal(
        ChatID        => 1,
        RequesterID   => 2,
        RequesterType => 'User',
        TargetID      => 1,
        TargetType    => 'Customer',
        SignalKey     => 'VideoChatInvite',
        SignalValue   => '1',
        SignalTime    => '2016-01-01 00:00:00',     # (optional) Force signal timestamp
    );

=cut

sub SendSignal {
    my ( $Self, %Param ) = @_;

    for my $Needed (
        qw(ChatID RequesterID RequesterType TargetID TargetType SignalKey SignalValue)
        )
    {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # check signal time
    if ( $Param{SignalTime} ) {
        my $SignalTime = $Kernel::OM->Get('Kernel::System::Time')->TimeStamp2SystemTime(
            String => $Param{SignalTime},
        );
        if ( !$SignalTime ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Invalid SignalTime!',
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # make signal unique
    return if !$DBObject->Do(
        SQL => 'DELETE FROM chat_video
                    WHERE chat_id = ? AND requester_id = ? AND requester_type = ? AND target_id = ?
                    AND target_id = ? AND signal_key = ? AND signal_value = ?',
        Bind => [
            \$Param{ChatID}, \$Param{RequesterID}, \$Param{RequesterType}, \$Param{TargetID},
            \$Param{TargetType}, \$Param{SignalKey}, \$Param{SignalValue},
        ],
    );

    my @Bind;

    push @Bind, \$Param{ChatID}, \$Param{RequesterID}, \$Param{RequesterType}, \$Param{TargetID},
        \$Param{TargetType}, \$Param{SignalKey}, \$Param{SignalValue};

    # include signal time if supplied
    my $SignalTimeVal = 'current_timestamp';
    if ( $Param{SignalTime} ) {
        $SignalTimeVal = '?';
        push @Bind, \$Param{SignalTime};
    }

    # store signal
    return if !$DBObject->Do(
        SQL => "INSERT INTO chat_video
                    (chat_id, requester_id, requester_type, target_id, target_type, signal_key,
                    signal_value, signal_time)
                    VALUES (?, ?, ?, ?, ?, ?, ?, $SignalTimeVal)",
        Bind => \@Bind,
    );

    return 1;
}

=item ReceiveSignals()

receive signals for a user.

    my $Signals = $VideoChatObject->ReceiveSignals(
        ChatID     => 1,                    # (optional)
        TargetID   => 2,
        TargetType => 'User',
        SignalKey  => 'VideoChatInvite',    # (optional)
        IgnoreTTL  => 1,                    # (optional) Set to 1 if you want to receive signals
                                                         that exceed TTL period
    );

returns an array ref with signal data:

    $Signals = [
        {
            ChatID        => 1,
            RequesterID   => 2,
            RequesterType => 'User',
            TargetID      => 1,
            TargetType    => 'Customer',
            SignalKey     => 'VideoChatInvite',
            SignalValue   => '1',
            SignalTime    => '2016-01-01 00:00:00',
        },
        {
            ChatID        => 2,
            RequesterID   => 3,
            RequesterType => 'User',
            TargetID      => 1,
            TargetType    => 'Customer',
            SignalKey     => 'VideoChatInvite',
            SignalValue   => '1',
            SignalTime    => '2016-01-01 00:01:00',
        }
    ];

=cut

sub ReceiveSignals {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(TargetID TargetType)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # select query
    my $SQL = 'SELECT chat_id, requester_id, requester_type, target_id, target_type, signal_key,
        signal_value, signal_time
        FROM chat_video
        WHERE target_id = ? AND target_type = ? ';
    my @Bind = ( \$Param{TargetID}, \$Param{TargetType}, );

    if ( $Param{ChatID} ) {
        $SQL .= 'AND chat_id = ? ';
        push @Bind, \$Param{ChatID};
    }

    if ( $Param{SignalKey} ) {
        $SQL .= 'AND signal_key = ? ';
        push @Bind, \$Param{SignalKey};
    }

    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1500,
    );

    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
    my $SystemTime = $TimeObject->SystemTime();

    my @Signals;

    ROW:
    while ( my @Row = $DBObject->FetchrowArray() ) {

        # skip signals which exceed TTL period
        if ( !$Param{IgnoreTTL} ) {
            my $SignalTime = $TimeObject->TimeStamp2SystemTime(
                String => $Row[7],
            );
            next ROW if $SystemTime - $SignalTime > $Self->{SignalTTL};
        }

        push @Signals, {
            ChatID        => $Row[0],
            RequesterID   => $Row[1],
            RequesterType => $Row[2],
            TargetID      => $Row[3],
            TargetType    => $Row[4],
            SignalKey     => $Row[5],
            SignalValue   => $Row[6],
            SignalTime    => $Row[7],
        };
    }

    # clean up
    $SQL = 'DELETE FROM chat_video WHERE target_id = ? AND target_type = ? ';

    if ( $Param{ChatID} ) {
        $SQL .= 'AND chat_id = ? ';
    }

    if ( $Param{SignalKey} ) {
        $SQL .= 'AND signal_key = ?';
    }

    return if !$DBObject->Do(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1500,
    );

    return \@Signals;
}

=item IsEnabled()

Checks if the system is entitled to use video chat features.

    my $VideoChatEnabled = $VideoChatObject->IsEnabled();

Returns 1 if system has a valid OTRSBusiness contract:

    my $VideoChatEnabled = 1;

=cut

sub IsEnabled {
    my ( $Self, %Param ) = @_;

    # Check entitlement status by first looking into the cache. Registration status check is
    #   performed in OTRSBusinessEntitlementStatus().
    my $EntitlementStatus = 'forbidden';
    $EntitlementStatus = $Kernel::OM->Get('Kernel::System::OTRSBusiness')->OTRSBusinessEntitlementStatus(
        CallCloudService => 0,
    );

    return 0 if $EntitlementStatus eq 'forbidden';

    return 1;
}

=item OTRSBusinessTURNServerGet()

gets TURN server configuration for this system from by cloud.otrs.com and stores it in the cache.

    my $TURNServers = $VideoChatObject->OTRSBusinessTURNServerGet();

returns server array ref if the cloud call was successful:

    my $TURNServers = [
      {
        'url' => 'stun:stun.cloud.otrs.com:5349'
      },
      {
        'credential' => 'apitoken',
        'url'        => 'turn:stun.cloud.otrs.com:3478?transport=udp',
        'username'   => 'apikey'
      },
      {
        'credential' => 'apitoken',
        'url'        => 'turn:stun.cloud.otrs.com:3478?transport=tcp',
        'username'   => 'apikey'
      }
    ];

=cut

sub OTRSBusinessTURNServerGet {
    my ( $Self, %Param ) = @_;

    return if $Kernel::OM->Get('Kernel::Config')->Get('CloudServicesDisabled');

    # check cache
    my $CacheKey = 'OTRSBusinessTURNServerGet';
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return $Cache if $Cache;

    my $CloudServiceObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Run');
    my $RequestResult      = $CloudServiceObject->Request(
        RequestData => {
            OTRSBusiness => [
                {
                    Operation => 'BusinessTURNServerGet',
                    Data      => {},
                },
            ],
        },
    );

    my $OperationResult;
    if ( IsHashRefWithData($RequestResult) ) {
        $OperationResult = $CloudServiceObject->OperationResultGet(
            RequestResult => $RequestResult,
            CloudService  => 'OTRSBusiness',
            Operation     => 'BusinessTURNServerGet',
        );
    }

    # cloud call was successful
    if ( IsHashRefWithData($OperationResult) && $OperationResult->{Success} ) {

        # check if system has permission and TURN servers were returned
        if (
            $OperationResult->{Data}->{BusinessPermission}
            && IsArrayRefWithData( $OperationResult->{Data}->{TURNServers} )
            )
        {
            # set cache
            $Kernel::OM->Get('Kernel::System::Cache')->Set(
                Type  => $Self->{CacheType},
                TTL   => $Self->{CacheTTL},
                Key   => $CacheKey,
                Value => $OperationResult->{Data}->{TURNServers},
            );

            return $OperationResult->{Data}->{TURNServers};
        }
        else {
            my $Message = 'BusinessTURNServerGet - system does not have permission or no servers available';
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => $Message,
            );
        }
    }

    if ( !IsHashRefWithData($RequestResult) ) {
        my $Message = 'BusinessTURNServerGet - can\'t contact cloud.otrs.com server';
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Message,
        );
    }

    if ( !IsHashRefWithData($OperationResult) || !$OperationResult->{Success} ) {
        my $Message = 'BusinessTURNServerGet - could not perform TURN server get ';
        if ( IsHashRefWithData($OperationResult) ) {
            $Message .= $OperationResult->{ErrorMessage};
        }
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Message,
        );
    }

    return 0;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
