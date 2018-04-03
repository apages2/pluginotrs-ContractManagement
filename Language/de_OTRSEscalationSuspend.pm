# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSEscalationSuspend;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation} = {
        %{$Self->{Translation}},
        'List of states for which escalations should be suspended.' => 'Liste von Status, für welche Eskalationen angehalten werden sollen.',
        'Escalation view - Without Suspend State' => 'Ansicht nach Eskalationen ohne ausg. Status',
        'Overview Escalated Tickets Without Suspend State' => 'Übersicht über eskalierte Tickets ohne ausgesetzte Status',
        'Suspend already escalated tickets.' => 'Aussetzen von bereits eskalierten Tickets.',
        'Ticket Escalation View Without Suspend State' => 'Ansicht nach Ticket-Eskalationen ohne ausgesetzte Status',

        'Overloads (redefines) existing functions in Kernel::System::Ticket. Used to easily add customizations.' => 'Überschreibt eine bestehende Funktion in Kernel::System::Ticket um eine Änderungen präzise einzuspielen.',
        'Frontend module registration for the agent interface.' => 'Frontend Modul zur Registrierung im Agenten-Interface.',
    };

    return 1;
}

1;
