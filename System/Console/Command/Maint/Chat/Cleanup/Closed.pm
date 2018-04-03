# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Chat::Cleanup::Closed;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::Chat',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Clean up old chat logs.');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Cleaning up closed chat logs...</yellow>\n");

    my $Success = $Kernel::OM->Get('Kernel::System::Chat')->ChatCleanup();

    if ($Success) {
        $Self->Print("<green>Done.</green>\n");
        return $Self->ExitCodeOk();
    }

    $Self->PrintError("Failed.\n");
    return $Self->ExitCodeError();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
