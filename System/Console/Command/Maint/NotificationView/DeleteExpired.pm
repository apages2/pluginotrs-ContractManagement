# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::NotificationView::DeleteExpired;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::NotificationView',
    'Kernel::System::Time'
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Delete expired notifications from Notification View screen.');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Deleting expired notifications from Notification View screen...</yellow>\n");

    my $DaysToKeep
        = $Kernel::OM->Get('Kernel::Config')->Get('Notification::Transport::NotificationView::DaysToKeep') || 0;

    # if no DaysToKeep means that notifications should stay forever, nothing to do
    if ( !$DaysToKeep ) {
        $Self->Print("<green>Done.</green>\n");

        return $Self->ExitCodeOk();
    }

    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # get expired system time
    my $ExpiredTime = $TimeObject->SystemTime() - ( $DaysToKeep * 24 * 60 * 60 );

    # get notification view object
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

    my %NotificationList = $NotificationViewObject->NotificationListGet();

    NOTIFICATION:
    for my $NotificationID ( sort keys %NotificationList ) {
        my $Notification = $NotificationList{$NotificationID};

        my $NotificationTime = $TimeObject->TimeStamp2SystemTime(
            String => $Notification->{CreateTime},
        );

        # skip not expired notifications
        next NOTIFICATION if $NotificationTime > $ExpiredTime;

        my $Success = $NotificationViewObject->NotificationDelete(
            NotificationID => $NotificationID,
            UserID         => 1,
        );

        if ( !$Success ) {
            $Self->PrintError("Notification $NotificationID could not be deleted.");
            return $Self->ExitCodeError();
        }

        $Self->Print("  $NotificationID\n");
    }

    $Self->Print("<green>Done.</green>\n");

    return $Self->ExitCodeOk();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
