# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::NotificationEvent::Transport::NotificationView;

use strict;
use warnings;

use base qw(Kernel::System::Ticket::Event::NotificationEvent::Transport::Base);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::NotificationView',
    'Kernel::System::Ticket',
);

=head1 NAME

Kernel::System::Ticket::Event::NotificationEvent::Transport::NotificationView - notification view transport layer

=head1 SYNOPSIS

Notification event transport layer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a notification transport object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('');
    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::NotificationView');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub SendNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID UserID Notification Recipient)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Needed!',
            );
            return;
        }
    }

    # cleanup event data
    $Self->{EventData} = undef;

    # get recipient data
    my %Recipient = %{ $Param{Recipient} };

    return if $Recipient{Type} eq 'Customer';
    return if !$Recipient{UserID};

    my %Notification = %{ $Param{Notification} };

    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
        TicketID => $Param{TicketID},
    );

    my $NotificationID = $Kernel::OM->Get('Kernel::System::NotificationView')->NotificationAdd(
        Name            => $Notification{Name},
        Comment         => $Notification{Comment} || '',
        Subject         => $Notification{Subject},
        Body            => $Notification{Body},
        ObjectType      => 'Ticket',
        ObjectID        => $Param{TicketID},
        ObjectReference => $Ticket{TicketNumber},
        UserID          => $Recipient{UserID},
    );

    if ( !$NotificationID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "'$Notification{Name}' notification could not be added to agent '$Recipient{UserID}' ",
        );

        return;
    }

    return 1;
}

sub GetTransportRecipients {
    my ( $Self, %Param ) = @_;

    return;
}

sub TransportSettingsDisplayGet {
    my ( $Self, %Param ) = @_;

    return;
}

sub TransportParamSettingsGet {
    my ( $Self, %Param ) = @_;

    return 1;
}

sub IsUsable {
    my ( $Self, %Param ) = @_;

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
