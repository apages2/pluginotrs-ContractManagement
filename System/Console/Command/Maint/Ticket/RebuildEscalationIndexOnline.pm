# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Ticket::RebuildEscalationIndexOnline;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Ticket',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Starting index creation...</yellow>\n");

    # get  needed object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # get all tickets
    my @TicketIDs = $TicketObject->TicketSearch(

        # result (required)
        Result => 'ARRAY',

        States => $ConfigObject->Get('EscalationSuspendStates'),

        # result limit
        Limit      => 100_000_000,
        UserID     => 1,
        Permission => 'ro',
    );
    
    my $Count = 0;
    for my $TicketID (@TicketIDs) {
        $Count++;
        $TicketObject->TicketEscalationIndexBuild(
            TicketID => $TicketID,
            UserID   => 1,
        );
        if ( ( $Count / 2000 ) == int( $Count / 2000 ) ) {
            my $Percent = int( $Count / ( $#TicketIDs / 100 ) );
            $Self->Print("NOTICE: $Count of $#TicketIDs processed ($Percent% done).\n");
        }
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
