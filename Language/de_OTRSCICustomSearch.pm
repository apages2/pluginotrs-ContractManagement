# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSCICustomSearch;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Search (Custom)'} = 'Suche (Benutzerdefiniert)';
    $Self->{Translation}->{'Defines the shown xml search fields for the custom CI search. Example (Owner, NIC::IPAddress, etc.).'} = 'Definiert die angezeigten XML-Suchfelder für die Benutzerdefinierte CI-Suche. Beispiel (Owner, NIC::IPAddress, etc.).';
}

1;
