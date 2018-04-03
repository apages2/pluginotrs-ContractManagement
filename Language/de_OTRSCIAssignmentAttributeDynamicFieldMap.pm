# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSCIAssignmentAttributeDynamicFieldMap;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};
    return if ref $Lang ne 'HASH';

    $Lang->{
        'Config item event module that assigns and removes service and sla to tickets'
        . ' when a config item is linked or unlinked.'
    } =
        'Config Item Eventmodul zum Zuweisen und Entfernen von Service und SLA an Ticket'
        . ' wenn ein Config Item verknüpft oder die Verknüpfung entfernt wird.';
    $Lang->{'Defines the config item field where the service name is stored.'} =
        'Definiert das Config Item-Feld in welchem der Name des Service gespeichert ist.';
    $Lang->{'Defines the config item field where the SLA name is stored.'} =
        'Definiert das Config Item-Feld in welchem der Name des SLA gespeichert ist.';

    return 1;
}

1;
