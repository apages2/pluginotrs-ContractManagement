# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSCustomContactFields;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Single contact'} = 'Einzelner Kontakt';
    $Self->{Translation}->{'Multiple contacts'} = 'Mehrere Kontakte';
    $Self->{Translation}->{'Input type'} = 'Eingabetyp';
    $Self->{Translation}->{'Choose if the input should support a single contact or multiple contacts per field.'} = 'Auswahl, ob die Eingabe einen einzelnen oder mehrere Kontakte pro Feld unterstützen soll.';

    $Self->{Translation}->{'Navigation customer interface'} = 'Navigationspunkt in Kundeninterface';
    $Self->{Translation}->{'Change this, if you want to display a tab in the customer interface where the customer can see all the Tickets where he is stored in this DynamicField.'} =
        'Ändern Sie diese Einstellung wenn ein Tab im Kundeninterface angezeigt werden soll, in dem alle Tickets zu sehen sind, in dem der Kunde in diesem DynamicField gespeichert wurde.';

    $Self->{Translation}->{'Navigation label'} = 'Navigation Beschriftung';
    $Self->{Translation}->{'Defines the name of the Tab in the customer interface. If no name is set the DynamicField name will be used. for example: Contacts tickets.'} = 'Definiert den Anzeigenamen des Tabs im Kundeninteface. Wenn kein Name gesetzt ist, wird der Name des DynamicFields verwendet. Zum Beispiel: Ansprechpartner-Tickets.';

    $Self->{Translation}->{'Use for communication'} = 'Für Kommunikation vorgesehen';
    $Self->{Translation}->{'Change this to a communication field, if you want to use this contact for communications.'} = 'Definiert ob und in welchem Feld der im DynamicField gespeicherte Kontakt zur Kommunikation verwendet werden soll.';

    $Self->{Translation}->{'Use for notification'} = 'Für Ticket-Benachrichtigungen vorgesehen';
    $Self->{Translation}->{'Change this to a communication field, if you want to use this contact for notifications.'} = 'Definiert ob und in welchem Feld der im DynamicField gespeicherte Kontakt bei Ticket-Benachrichtigungen verwendet werden kann.';

    $Self->{Translation}->{'Filter contact by'} = 'Kontakt einschränken anhand';
    $Self->{Translation}->{'This configuration defines if the contacts should be filtered by one of the available customer attributes.'} = 'Diese Konfigurationseinstellung definiert ob mögliche Kontakte anhand eines der verfügbaren Kundenattribute eingeschränkt werden sollen.';

    $Self->{Translation}->{'Filter criteria'} = 'Filterkriterium';
    $Self->{Translation}->{'This configuration defines the value that the filtered attribute has to match.'} = 'Diese Konfiguration definiert den Wert, dem das konfigurierte Kundenattribut entsprechen muss.';

    $Self->{Translation}->{'Invalid selection. Please choose between yes or no.'} = 'Ungültige Auswahl. Bitte wählen Sie zwischen ja oder nein.';
    $Self->{Translation}->{'Invalid input. Please only use alphanumeric values.'} = 'Ungültige Eingabe. Bitte geben Sie nur alphanumerische Zeichen ein.';
    $Self->{Translation}->{'Invalid selection. Please choose between To, CC or BCC.'} = 'Ungültige Auswahl. Bitte wählen Sie zwischen To, CC oder BCC.';

    $Self->{Translation}->{'Customer User Login (e. g. U5150)'} = 'Anmeldung Kundenkontakt z. B. U5150';

    $Self->{Translation}->{'Contact information'} = 'Ansprechpartner-Info';
    $Self->{Translation}->{'Empty'} = 'Leeren';

    $Self->{Translation}->{'Position of contacts in AgentTicketEmail. Fields will be shown below selected field.'} =
        'Position für Kontakte in AgentTicketEmail. Kontakte werden unter dem ausgewählten Feld angezeigt.';
    $Self->{Translation}->{'Join contact email addresses to send a just single event based notification to all contacts as opposed to sending a notification to each contact.'} =
        'Füge alle E-Mail Adressen der Kontakte zusammen um nur eine einzige ereignisbasierte Benachrichtigung zu versenden. Ansonsten wird eine Benachrichtigung pro Kontakt versendet.';

    return;
}

1;
