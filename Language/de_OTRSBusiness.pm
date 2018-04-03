# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Chat-Kanäle verwalten';
    $Self->{Translation}->{'Add Chat Channel'} = 'Chat-Kanal hinzufügen';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Chat-Kanal bearbeiten';
    $Self->{Translation}->{'Name invalid'} = 'Name ungültig';
    $Self->{Translation}->{'Need Group'} = 'Gruppe wird benötigt';
    $Self->{Translation}->{'Need Valid'} = 'Gültigkeit wird benötigt';
    $Self->{Translation}->{'Comment invalid'} = 'Kommentar ungültig';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Cloudservice-Status';
    $Self->{Translation}->{'Cloud service availability'} = 'Cloudservice-Verfügbarkeit';
    $Self->{Translation}->{'Remaining SMS units'} = 'Verbleibende SMS-Einheiten';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Derzeit kann der Status für diesen Cloud-Service nicht geprüft werden.';
    $Self->{Translation}->{'Phone field for agent'} = 'Mobilfunknummer-Feld für Agent';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Feld aus den Agentendaten, das zum Ermitteln der Mobilfunknummer zum Senden von SMS-Nachrichten verwendet werden soll.';
    $Self->{Translation}->{'Phone field for customer'} = 'Mobilfunknummer-Feld für Kunde';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Feld aus den Kundendaten, das zum Ermitteln der Mobilfunknummer zum Senden von SMS-Nachrichten verwendet werden soll.';
    $Self->{Translation}->{'Sender string'} = 'Absenderbezeichnung';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Wird als Absendername der SMS angezeigt (darf nicht länger als 11 Zeichen sein).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Dieses Feld wird benötigt und darf nicht mehr als 11 Zeichen enthalten.';
    $Self->{Translation}->{'Allowed role members'} = 'Erlaubte Rollen';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Wenn ausgewählt, können nur Nutzer Benachrichtigungen per SMS erhalten, die Mitglied in einer der angegebenen Rollen sind (optional).';
    $Self->{Translation}->{'Save configuration'} = 'Konfiguration speichern';
    $Self->{Translation}->{'Data Protection Information'} = 'Hinweise zum Datenschutz';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Kundenverwaltung';
    $Self->{Translation}->{'Add contact with data'} = 'Einen Kontakt hinzufügen';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Bitte geben Sie einen Suchbegriff ein, um nach Kunden zu suchen.';
    $Self->{Translation}->{'Edit contact with data'} = 'Einen Kontakt bearbeiten';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Die folgenden Attribute sind für Kontakte möglich.';
    $Self->{Translation}->{'Mandatory fields'} = 'Pflichtfelder';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Kommaseparierte Pflichtfelderliste (optional). Die Schlüssel \'Name\' und \'ValidID\' sind immer Pflichtfelder und müssen hier nicht aufgeführt werden.';
    $Self->{Translation}->{'Sorted fields'} = 'Sortierte Felder';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Kommaseparierte Schlüsselliste in Sortierreihenfolge (optional). Die hier aufgeführten Schlüssel werden zuerst angezeigt, alle weiteren Felder danach und in alphabetischer Reihenfolge.';
    $Self->{Translation}->{'Searchable fields'} = 'Durchsuchbare Felder';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Komma getrennte Liste durchsuchbarer Schlüssel (optional). Die Schlüssel \'Name\' ist immer durchsuchbar und muss hier nicht aufgeführt werden.';
    $Self->{Translation}->{'Add/Edit'} = 'Hinzufügen/Bearbeiten';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Datentyp';
    $Self->{Translation}->{'Searchfield'} = 'Suchfeld';
    $Self->{Translation}->{'Listfield'} = 'Listenfeld';
    $Self->{Translation}->{'Driver'} = 'Treiber';
    $Self->{Translation}->{'Server'} = 'Server';
    $Self->{Translation}->{'Table / View'} = 'Tabelle / Ansicht';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = 'Muss eine eindeutige Spalte der in Tabelle/Ansicht eingetragenen Tabelle sein. ';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Suchpräfix';
    $Self->{Translation}->{'Searchsuffix'} = 'Suchsuffix';
    $Self->{Translation}->{'Result Limit'} = 'Ergebnis-Beschränkung';
    $Self->{Translation}->{'Case Sensitive'} = 'Groß-/Kleinschreibung unterscheiden';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Empfänger-SMS-Nummern';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Resourcenübersicht';
    $Self->{Translation}->{'Manage Calendars'} = 'Kalender verwalten';
    $Self->{Translation}->{'Manage Teams'} = 'Teams verwalten';
    $Self->{Translation}->{'Manage Team Agents'} = 'Team-Agenten verwalten';
    $Self->{Translation}->{'Add new Appointment'} = 'Einen neuen Termin anlegen';
    $Self->{Translation}->{'Add Appointment'} = 'Termin hinzufügen';
    $Self->{Translation}->{'Calendars'} = 'Kalender';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter für Kalender';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Öffentliche Kalender-URL kopieren';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Dies ist eine Ressourcen-Übersicht.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Keine Kalender gefunden. Bitte legen Sie zuerst einen Kalender über die Kalenderverwaltung an.';
    $Self->{Translation}->{'No teams found.'} = 'Keine Teams gefunden.';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = 'Bitte erstellen Sie zuerst ein Team über die Teamverwaltungsseite.';
    $Self->{Translation}->{'Team'} = 'Team';
    $Self->{Translation}->{'No team agents found.'} = 'Keine Teamagenten gefunden.';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        'Bitte ordnen Sie zuerst Agenten einem Team über die Teamverwaltungsseite zu.';
    $Self->{Translation}->{'Too many active calendars'} = 'Zuviele aktive Kalender';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Bitte deaktivieren Sie zuerst einige oder erhöhen Sie das Limit in der Konfiguration.';
    $Self->{Translation}->{'Restore default settings'} = 'Standard-Einstellungen wiederherstellen';
    $Self->{Translation}->{'Week'} = 'Woche';
    $Self->{Translation}->{'Timeline Month'} = 'Zeitstrahl Monat';
    $Self->{Translation}->{'Timeline Week'} = 'Zeitstrahl Woche';
    $Self->{Translation}->{'Timeline Day'} = 'Zeitstrahl Tag';
    $Self->{Translation}->{'Jump'} = 'Springen';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Dieser Termin wiederholt sich';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Möchten Sie nur diesen Termin oder alle Vorkommnisse bearbeiten?';
    $Self->{Translation}->{'All occurrences'} = 'Alle Vorkommnisse';
    $Self->{Translation}->{'Just this occurrence'} = 'Nur diesen Termin';
    $Self->{Translation}->{'Dismiss'} = 'Verwerfen';
    $Self->{Translation}->{'Resources'} = 'Ressourcen';
    $Self->{Translation}->{'Shown resources'} = 'Angezeigte Ressourcen';
    $Self->{Translation}->{'Available Resources'} = 'Verfügbare Ressourcen';
    $Self->{Translation}->{'Filter available resources'} = 'Verfügbare Ressourcen filtern';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Sichtbare Ressourcen (mit Drag & Drop sortieren)';
    $Self->{Translation}->{'Basic information'} = 'Grundlegende Informationen';
    $Self->{Translation}->{'Resource'} = 'Resource';
    $Self->{Translation}->{'Date/Time'} = 'Datum/Zeit';
    $Self->{Translation}->{'End date'} = 'Endzeitpunkt';
    $Self->{Translation}->{'Repeat'} = 'Wiederholung';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Team hinzufügen';
    $Self->{Translation}->{'Team Import'} = 'Team-Import';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Hier können Sie eine Konfigurations-Datei zum Importieren eines Teams hochladen. Die Datei muss im .yml-Format vorliegen, so wie sie auch im Team-Verwaltungs-Modul exportiert wird.';
    $Self->{Translation}->{'Upload team configuration'} = 'Team-Konfiguration hochladen.';
    $Self->{Translation}->{'Import team'} = 'Team importieren';
    $Self->{Translation}->{'Filter for teams'} = 'Filter für Teams';
    $Self->{Translation}->{'Export team'} = 'Team exportieren';
    $Self->{Translation}->{'Edit Team'} = 'Team bearbeiten';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Ein Team mit diesem Namen existiert bereits.';
    $Self->{Translation}->{'Permission group'} = 'Berechtigungsgruppe';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Filter für Agenten';
    $Self->{Translation}->{'Teams'} = 'Teams';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Team-Agent-Beziehungen verwalten';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Agenten-Beziehungen für Team verwalten';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Team-Beziehungen für Agent verwalten';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'Chats verwalten';
    $Self->{Translation}->{'Hints'} = 'Hinweise';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Bitte beachten Sie, dass der Tab, in dem der Chat-Manager geöffnet wird, für alle Chat-relevanten Aktionen genutzt wird. Wenn Sie den Chat-Manager verlassen (z. B. indem Sie über das Hauptmenü zu einem anderen Bildschirm wechseln), werden Aktionen wie das Starten eines neuen Chats dieses Tab trotzdem neu laden und den Chat-Manager wieder öffnen. Es wird empfohlen, den Chat-Manager geöffnet zu lassen und das entsprechende Tab nach Abschluss der Chat-Tätigkeit zu schließen.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Generelle Chat-Anfragen von Kunden';
    $Self->{Translation}->{'My Chat Channels'} = 'Meine Chat-Kanäle';
    $Self->{Translation}->{'All Chat Channels'} = 'Alle Chat-Kanäle';
    $Self->{Translation}->{'Channel'} = 'Kanal';
    $Self->{Translation}->{'Requester'} = 'Anfragender';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Chat-Anfragen werden geladen, bitte warten...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Chat-Anfragen von Nutzern des Public-Interface';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Persönliche Chat-Anfragen';
    $Self->{Translation}->{'My Active Chats'} = 'Meine aktiven Chats';
    $Self->{Translation}->{'Open ticket'} = 'Ticket eröffnen';
    $Self->{Translation}->{'Open company'} = 'Kundenfirma anzeigen';
    $Self->{Translation}->{'Discard & close this chat'} = 'Chat verwerfen & schließen';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Alle Aktivitäten in diesem Chat werden beobachtet';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Alle Kundenaktivitäten in diesem Chat werden beobachtet';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Aktivitäten in diesem Chat werden derzeit nicht beobachtet';
    $Self->{Translation}->{'Audio Call'} = 'Audio-Anruf';
    $Self->{Translation}->{'Video Call'} = 'Video-Anruf';
    $Self->{Translation}->{'Toggle settings'} = 'Einstellungen ein-/ausblenden';
    $Self->{Translation}->{'Leave chat'} = 'Chat verlassen';
    $Self->{Translation}->{'Leave'} = 'Verlassen';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Aus dem Chat ein neues Telefon-Ticket erstellen und ihn danach schließen';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Diesen Chat einem bestehenden Ticket hinzufügen und Chat anschließend beenden';
    $Self->{Translation}->{'Append'} = 'Anhängen';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Weiteren Agenten zu diesem Chat einladen';
    $Self->{Translation}->{'Invite'} = 'Einladen';
    $Self->{Translation}->{'Change chat channel'} = 'Chat-Kanal ändern';
    $Self->{Translation}->{'Channel change'} = 'Kanaländerung';
    $Self->{Translation}->{'Switch to participant'} = 'Auf Teilnehmer-Modus wechseln';
    $Self->{Translation}->{'Participant'} = 'Teilnehmer';
    $Self->{Translation}->{'Switch to an observer'} = 'Auf Beobachter-Modus wechseln';
    $Self->{Translation}->{'Observer'} = 'Beobachter';
    $Self->{Translation}->{'Download this Chat'} = 'Diesen Chat herunterladen';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Chat-Einladung als Beobachter annehmen';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Chat-Einladung als Teilnehmer annehmen';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Chat in neuem Fenster öffnen';
    $Self->{Translation}->{'New window'} = 'Neues Fenster';
    $Self->{Translation}->{'New Message'} = 'Neue Nachricht';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter für neue Zeile)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s hat den Chat verlassen.';
    $Self->{Translation}->{'Online agents'} = 'Verfügbare Agenten';
    $Self->{Translation}->{'Reload online agents'} = 'Liste der verfügbaren Agenten neu laden';
    $Self->{Translation}->{'Destination channel'} = 'Zielkanal';
    $Self->{Translation}->{'Open chat'} = 'Chat öffnen';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = 'Benutzer hat den Chat bereits verlassen oder ist diesem nicht beigetreten.';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Sie befinden sich nicht länger in diesem Chat. Klicken Sie auf diese Nachricht, um die Chatbox zu entfernen.';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Zur Zeit gibt es keine Chat-Anfragen.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Diese Aktion wird den Chatinhalt endgültig löschen. Möchten Sie fortfahren?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Diese Chat-Anfrage wurde bereits durch einen anderen Agenten angenommen.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Sie haben nicht die erforderlichen Berechtigungen, um diese Chat-Anfrage anzunehmen.';
    $Self->{Translation}->{'Please select a user.'} = 'Bitte wählen Sie einen Benutzer.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Bitte wählen Sie ein Berechtigungslevel.';
    $Self->{Translation}->{'Invite Agent.'} = 'Agenten einladen.';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Bitte wählen Sie einen Zielkanal.';
    $Self->{Translation}->{'Please select a channel.'} = 'Bitte wählen Sie einen Kanal.';
    $Self->{Translation}->{'Chat preview'} = 'Chat-Vorschau';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Bitte wählen Sie einen gültigen Kanal.';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Agent-zu-Kunde-Chat';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Kunde-zu-Agent-Chat';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Agent-zu-Agent-Chat';
    $Self->{Translation}->{'Public to agent chat.'} = 'Public-zu-Agent-Chat';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Sie können den Kunden nicht alleine im Chat zurücklassen.';
    $Self->{Translation}->{'You'} = 'Sie';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Ihr Chat konnte aufgrund eines internen Fehlers nicht gestartet werden.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Ihre Chat-Anfrage wurde erstellt.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Zur Zeit gibt es %s offene Chat-Anfragen.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Der Benutzer wurde bereits zu Ihrem Chat eingeladen.';
    $Self->{Translation}->{'Insufficient permissions.'} = 'Unzureichende Berechtigungen.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'Das System konnte Ihre Chatreihenfolge nicht speichern.';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Chat an Ticket anhängen';
    $Self->{Translation}->{'Append to'} = 'Anhängen an';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'Dieser Chat wird dem ausgewählten Ticket als neuer Artikel hinzugefügt.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Chat mit';
    $Self->{Translation}->{'Leave Chat'} = 'Chat verlassen';
    $Self->{Translation}->{'User is currently in the chat.'} = 'Benutzer ist zur Zeit im Chat.';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Aktueller Chat-Kanal';
    $Self->{Translation}->{'Available channels'} = 'Verfügbare Kanäle';
    $Self->{Translation}->{'Reload'} = 'Neu laden';
    $Self->{Translation}->{'Update Channel'} = 'Kanal aktualisieren';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Detailsuche';
    $Self->{Translation}->{'Add an additional attribute'} = 'Weiteres Attribut hinzufügen';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Detailansicht';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Benachrichtigungen pro Seite';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Daten nicht gefunden.';
    $Self->{Translation}->{'Related To'} = 'Bezieht sich auf';
    $Self->{Translation}->{'Select this notification'} = 'Diese Benachrichtigung auswählen';
    $Self->{Translation}->{'Zoom into'} = 'Anzeigen';
    $Self->{Translation}->{'Dismiss this notification'} = 'Diese Benachrichtigung verwerfen';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Ausgewählte Benachrichtigungen verwerfen';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Möchten Sie wirklich die ausgewählten Benachrichtigungen verwerfen?';
    $Self->{Translation}->{'OTRS Notification'} = 'OTRS-Benachrichtigung';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Reports » Hinzufügen';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Neuen Statistik-Report hinzufügen';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Reports » Bearbeiten - %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Hier können Sie mehrere Statistiken zu einem Report kombinieren, den Sie dann manuell oder zu festgelegten Zeitpunkten als PDF generieren lassen können.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Bitte bachten Sie, dass Sie Grafiken nur dann als als Ausgabeformat nutzen können, wenn auf Ihrem System PhantomJS konfiguriert ist.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'PhantomJS konfigurieren';
    $Self->{Translation}->{'General settings'} = 'Generelle Einstellungen';
    $Self->{Translation}->{'Automatic generation settings'} = 'Einstellungen zur automatischen Erzeugung';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Zeitpunkte für die automatische Erzeugung (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Geben Sie im Cron-Format an, zu welchen Zeiten der Report automatisch erzeugt werden soll (z. B. "10 1 * * *" für täglich um 1:10 morgens.)';
    $Self->{Translation}->{'Last automatic generation time'} = 'Zuletzt automatisch erzeugt';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Wird als nächstes planmäßig erzeugt';
    $Self->{Translation}->{'Automatic generation language'} = 'Sprache für automatische Erzeugung';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'Die Sprache, die verwendet werden soll, wenn der Report automatisch erzeugt wird.';
    $Self->{Translation}->{'Email subject'} = 'E-Mail-Betreff';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = 'Geben sie den Betreff für die automatisch erzeugte E-Mail an.';
    $Self->{Translation}->{'Email body'} = 'E-Mail-Inhalt';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'Geben Sie den Text für die E-Mail an.';
    $Self->{Translation}->{'Email recipients'} = 'E-Mail-Empfänger';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'Geben Sie Empfänger-Email-Adressen an (durch Komma getrennt).';
    $Self->{Translation}->{'Output settings'} = 'Ausgabe-Einstellungen';
    $Self->{Translation}->{'Headline'} = 'Kopfzeile';
    $Self->{Translation}->{'Caption for preamble'} = 'Überschrift der Einleitung';
    $Self->{Translation}->{'Preamble'} = 'Einleitung';
    $Self->{Translation}->{'Caption for epilogue'} = 'Überschrift des Abschlusstextes';
    $Self->{Translation}->{'Epilogue'} = 'Abschlusstext';
    $Self->{Translation}->{'Add statistic to report'} = 'Statistik zum Report hinzufügen';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Reports » Übersicht';
    $Self->{Translation}->{'Statistics Reports'} = 'Statistik-Reports';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Statistik-Report "%s" bearbeiten.';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Statistik-Report "%s" löschen.';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Möchten Sie diesen Report wirklich löschen?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Reports » Details — %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Dieser Statistik-Report enthält Konfigurationsfehler und kann momentan nicht genutzt werden.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Anlagen von';
    $Self->{Translation}->{'Attachment Overview'} = 'Anlagen-Übersicht';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Dieses Ticket hat keine Anlagen.';
    $Self->{Translation}->{'Hide inline attachments'} = 'Inline-Anhänge ausblenden';
    $Self->{Translation}->{'Filter Attachments'} = 'Anlagen filtern';
    $Self->{Translation}->{'Select All'} = 'Alle auswählen';
    $Self->{Translation}->{'Click to download this file'} = 'Klicken Sie, um die Datei herunterzuladen';
    $Self->{Translation}->{'Open article in main window'} = 'Artikel im Hauptfenster öffnen';
    $Self->{Translation}->{'Download selected files as archive'} = 'Ausgewählte Dateien als Archiv herunterladen';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = 'Ihr Browser unterstützt kein HTML5-Video.';
    $Self->{Translation}->{'Close video call'} = 'Video-Anruf schließen';
    $Self->{Translation}->{'Toggle audio'} = 'Ton umschalten';
    $Self->{Translation}->{'Toggle video'} = 'Video umschalten';
    $Self->{Translation}->{'User has declined your invitation.'} = 'Der Benutzer hat Ihre Einladung abgelehnt.';
    $Self->{Translation}->{'User has left the call.'} = 'Der Benutzer hat den Anruf verlassen.';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = 'Verbindungsversuch fehlgeschlagen. Bitte versuchen Sie es erneut.';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = 'Zugriff auf Mediastream wurde nicht gestattet.';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = 'Bitte erlauben Sie dieser Seite, Ihre Video- und Audiostreams zu nutzen.';
    $Self->{Translation}->{'Requesting media stream...'} = 'Media-Stream wird angefragt...';
    $Self->{Translation}->{'Waiting for other party to respond...'} = 'Warte auf Antwort der anderen Seite...';
    $Self->{Translation}->{'Accepting the invitation...'} = 'Bestätige die Einladung...';
    $Self->{Translation}->{'Initializing...'} = 'Initialisiere...';
    $Self->{Translation}->{'Connecting, please wait...'} = 'Verbinde, bitte warten...';
    $Self->{Translation}->{'Connection established!'} = 'Verbindung hergestellt!';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s hat den Chat betreten.';
    $Self->{Translation}->{'Incoming chat requests'} = 'Eingehende Chat-Anfragen';
    $Self->{Translation}->{'Outgoing chat requests'} = 'Ausgehende Chat-Anfragen';
    $Self->{Translation}->{'Active chats'} = 'Aktive Chats';
    $Self->{Translation}->{'Closed chats'} = 'Geschlossene Chats';
    $Self->{Translation}->{'Chat request description'} = 'Beschreibung der Chat-Anfrage';
    $Self->{Translation}->{'Create new ticket'} = 'Neues Ticket erstellen';
    $Self->{Translation}->{'Add an article'} = 'Artikel hinzufügen';
    $Self->{Translation}->{'Start a new chat'} = 'Einen neuen Chat beginnen';
    $Self->{Translation}->{'Select channel'} = 'Kanal wählen';
    $Self->{Translation}->{'Add to an existing ticket'} = 'An bestehendes Ticket anhängen';
    $Self->{Translation}->{'Active Chat'} = 'Aktiver Chat';
    $Self->{Translation}->{'Download Chat'} = 'Chat herunterladen';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Chat wird geladen...';
    $Self->{Translation}->{'Chat completed'} = 'Chat abgeschlossen';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = 'Vollbild';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Bitte bestätigen Sie Ihre Auswahl';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Ihr Name';
    $Self->{Translation}->{'Start a new Chat'} = 'Einen neuen Chat beginnen';
    $Self->{Translation}->{'Chat complete'} = 'Chat abgeschlossen';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Statistik entfernen';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Wenn Sie hier keinen Titel angeben, wird der Titel der Statistik verwendet.';
    $Self->{Translation}->{'Preface'} = 'Einleitung';
    $Self->{Translation}->{'Postface'} = 'Nachwort';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Chat-Kanal %s hinzugefügt';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Chat-Kanal %s bearbeitet';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Cloudservice "%s" aktualisiert!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Cloudservice-Konfiguration "%s" gespeichert!';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        'Dieses Feature ist Teil des Pakets %s. Bitte installieren Sie diese kostenlose Erweiterung, bevor Sie nochmals versuchen, das Feature zu nutzen.';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Benötige TeamID!';
    $Self->{Translation}->{'Invalid GroupID!'} = 'Ungültige GruppenID!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'Konnte keine Daten für diese TeamID ermitteln';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nicht zugewiesen';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        'Chat %s wurde geschlossen und erfolgreich zu Ticket %s hinzugefügt.';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        'Das Video-Anruf-Feature ist deaktiviert! Bitte prüfen Sie, ob %s für das aktuelle System verfügbar ist.';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s hat den Chat als Beobachter betreten.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = 'Wenn Sie akzeptieren werden alle aktiven Anrufe geschlossen.';
    $Self->{Translation}->{'New request for joining a chat'} = 'Neue Anfrage zum Betreten eines Chats';
    $Self->{Translation}->{'Agent invited %s.'} = 'Agent hat %s eingeladen.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s hat den Chat-Kanal auf %s geändert.';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s ist in den Modus "Teilnehmer" gewechselt.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s ist in den Modus "Beobachter" gewechselt.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s hat die Chat-Anfrage abgelehnt.';
    $Self->{Translation}->{'Need'} = 'Benötige';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'Alle Benachrichtigungen';
    $Self->{Translation}->{'Seen Notifications'} = 'Gelesene Benachrichtigungen';
    $Self->{Translation}->{'Unseen Notifications'} = 'Ungelesene Benachrichtigungen';
    $Self->{Translation}->{'Notification Web View'} = 'Benachrichtigungs-Ansicht';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Dieser Name wird bereits genutzt, bitte verwenden Sie einen anderen.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Bitte geben Sie einen gültigen Cron-Eintrag an.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = 'Sie sind kein Teilnehmer dieses Chats!';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Sie sind derzeit für externe Chats nicht verfügbar. Möchten Sie online gehen?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Sie haben derzeit keine externen Chat-Kanäle zugewiesen.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Ausgewählte verwerfen';
    $Self->{Translation}->{'Object Type'} = 'Objekt-Typ';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        'Sie haben keinen Zugriff auf Chat-Kanäle des Systems. Bitte kontaktieren Sie den Administrator.';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Offene Chat-Anfragen';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s Report';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Fehler: Diese Grafik konnte nicht erzeugt werden: %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Inhaltsübersicht';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'Standard-Chat-Kanal';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Aktiviert Chat-Unterstützung.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'Agenten-Frontend-Modulregistrierung (Chat-Link entfernen wenn das Chat-Feature nicht aktiv ist oder der Agent in keiner Chatgruppe berechtigt ist)';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Agenten-Gruppe, die Chat-Anfragen annehmen und chatten kann.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Agenten-Gruppe, die Chat-Anfragen erstellen kann.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = 'Agenten-Gruppe, die das Video-Anruf-Feature in Chats nutzen darf.';
    $Self->{Translation}->{'Agent interface availability.'} = 'Verfügbarkeit im Agenten-Interface.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Benachrichtigungsmodul im Agenten-Interface, das auf offene Chat-Anfragen hinweist.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Dem Kunden nur die Auswahl von Chat-Kanälen mit verfügbaren Agenten erlauben.';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Dem öffentlichen Benutzer nur die Auswahl von Chat-Kanälen mit verfügbaren Agenten erlauben.';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Aktiviert eine Web-basierte Übersicht über die Benachrichtigungen.';
    $Self->{Translation}->{'Chat Channel'} = 'Chat-Kanal';
    $Self->{Translation}->{'Chat Channel:'} = 'Chat-Kanal:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'Chat-Kanal, der für die Kommunikation zu Tickets in dieser Queue verwendet wird.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Zuordnung von Chat-Kanälen zu Queues.';
    $Self->{Translation}->{'Chat overview'} = 'Chat-Übersicht';
    $Self->{Translation}->{'Chats'} = 'Chats';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Löscht alte Chatprotokolle.';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'Spalten-Filter für Web-Oberfläche für Benachrichtigungen vom Typ "Klein".';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Spalten die in der Web-Ansicht für Benachrichtigungen gefiltert werden können. Mögliche Einstellungen: 0 = deaktiviert, 1 = aktiviert, 2 = aktiviert und benötigt.';
    $Self->{Translation}->{'Contact with data'} = 'Kontaktdaten';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Chat-Kanäle erzeugen und verwalten.';
    $Self->{Translation}->{'Create new chat'} = 'Neuen Chat erstellen';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'Kunden-Frontend-Modulregistrierung (Chat-Link entfernen wenn das Chat-Feature nicht aktiv ist oder keine Agenten für den Chat verfügbar sind).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Standard-Agentenname für Kunden-Interface und Public-Interface. Falls aktiviert, wird der echte Name des Agenten für Kunden im Chat nicht sichtbar sein.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Standardtext für das Kunden-Interface.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Standardtext für das Public-Interface';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Definiert eine Liste von Gruppenschlüsseln für die Benutzereinstellungen die im der Kunden-Oberfläche sichtbar sind (funktioniert nur wenn DefaultAgentName deaktiviert ist).
Beispiel: wenn sie PreferencesGroups###Language anzeigen wollen, fügen sie "Language" hinzu.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Definiert einen Text für die Benutzereinstellungen im der Kunden-Oberfläche (funktioniert nur wenn  DefaultAgentName deaktiviert ist).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Definiert ob Kundenbenutzer den Chat-Kanal auswählen können. Wenn nicht, dann wird der Chat im Standard Chat-Kanal erstellt.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Wenn Schalter aktiviert ist, muss das Ticket vom Agenten gesperrt werden um einen Chat zu starten.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Definiert ob fortlaufende Nummern an DefaultAgentName angefügt werden sollen. Wenn eingeschaltet, werden Zahlen (z.B. 1,2,3..) an den Namen angefügt.';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Definiert ob öffentliche Benutzer den Chat-Kanal auswählen können. Wenn nicht, dann wird der Chat im Standard Chat-Kanal erstellt.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Definiert das Modul um eine Benachrichtigung im Agent-Interface anzuzeigen falls der Agent für externe Chats verfügbar ist aber keine Chat-Kanal (Kanäle) in seinen Benutzereinstellungen eingetragen hat.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Definiert das Modul um eine Benachrichtigung im Agent-Interface anzuzeigen falls der Agent für externe Chats verfügbar ist (nur wenn Ticket::Agent::AvailableForChatsAfterLogin deaktiviert ist).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Definiert wie viele Tage eine Benachrichtigung in der Web-Ansicht für Benachrichtigungen angezeigt werden soll (der Wert \'0\' bedeutet immer anzeigen).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Definiert die Anordnung der Chat-Fenster.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Definiert den Pfad zur PhantomJS Binärdatei. Zur vereinfachten Installation können sie eine statische Version von http://phantomjs.org/download.html herunterladen.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Definiert die Zeitspanne (in Minuten) bis ein Kunde die "Keine Antwort" Meldung angezeigt bekommt';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        'Legt die Zeit (in Minuten) fest, bevor ein Agent aufgrund von Inaktivität als "Abwesend" angezeigt wird.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        'Legt die Zeit (in Minuten) fest, bevor ein Kunde aufgrund von Inaktivität als "Abwesend" angezeigt wird.';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = 'Legt die Einstellungen für Veranstaltungsbenachrichtigungen fest.';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = 'Legt die Einstellungen für Kalenderbenachrichtigungen fest.';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Definiert die Einstellungen für die Ticket Benachrichtigungen.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Definiert das Quell-DynamicField für die Speicherung historischer Daten.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Definiert das Ziel-DynamicField für die Speicherung historischer Daten.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'Backend-GUI für dynamische Felder mit Kontaktdaten';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'Backend-GUI für Dynamic Field Database';
    $Self->{Translation}->{'Edit contacts with data'} = 'Kontaktdaten editieren';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Schaltet die Sammelaktion in der Web-Ansicht für Benachrichtigungen im Agenten-Interface frei.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Aktiviert Sammelaktionen in der Web-Ansicht für Benachrichtigungen nur für die aufgeführten Gruppen.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Aktiviert die Timeline-Ansicht in AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'Ereignismodulregistrierung (Speicherung historischer Daten in dynamischen Feldern).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = 'Frontend-Modul-Registrierung für den Kunden-Bereich.';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Frontendmodul-Registrierung für das Public-Interface.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'Generiert HTML-Kommentar Hooks für die einzelnen Blöcke so dass diese von Filtern genutzt werden können.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Wenn der Schalter aktiviert ist wird die Chat-Verfügbarkeit des Agenten beim Einloggen überprüft und angepasst. Falls die letzte Einstellung "Verfügbar für externe Chats" war, wird diese automatisch auf "Verfügbar für interne Chats" limitiert.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Wenn auf "Ja" gesetzt, zeigt das System in jedem Bildschirm eine Benachrichtigung an falls der Agent nicht für Chats verfügbar ist.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Wenn auf "Ja" gesetzt, können Agenten auch ohne ein bestehendes Ticket einen Chat mit Kunden starten.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Wenn auf "Ja" gesetzt, können Kunden auch ohne ein bestehendes Ticket einen Chat mit einem Agenten starten.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Wenn auf "Ja" gesetzt, kann nur der am Ticket gesetzte Kunde einen Chat aus der Ticketansicht heraus starten.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Wenn auf "Ja" gesetzt, ist das Starten eines Chats aus der Ticketansicht nur möglich, wenn der Kunde gerade online ist.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'Wenn auf "Ja" gesetzt, ist das Starten eines Chats aus der Ticketansicht für Kunden nur möglich, wenn im verlinkten Chat-Kanal Agenten verfügbar sind.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Ermöglicht es, aus dem Agenten-Frontend heraus einen Chat mit einem Kunden zu starten.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Ermöglicht es, aus dem Agenten-Interface heraus einen Chat mit einem Agenten zu starten.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Ermöglicht es, aus dem Kunden-Interface heraus einen Chat mit einem Agenten zu starten.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Ermöglicht es, aus dem Public-Interface heraus einen Chat mit einem Agenten zu starten.';
    $Self->{Translation}->{'Manage team agents.'} = 'Team-Agenten verwalten.';
    $Self->{Translation}->{'My chats'} = 'Meine Chats';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Name des Standard-Chat-Kanals. Existiert der Kanal nicht, wird er automatisch erstellt. Bitte erstellen Sie keinen Kanal mit demselben Namen wie der Standard-Kanal. Ist die Auswahl eines Kanals für Kunden- und Public-Bereich eingeschaltet, wird der Standard-Kanal nicht angezeigt. Alle Agent-zu-Agent-Chats werden im Standard-Kanal angelegt.';
    $Self->{Translation}->{'No agents available message.'} = '"Keine Agenten verfügbar" Nachricht.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'in der "Small" Ansicht: Limit für die Benachrichtigungen pro Seite in der Web-Ansicht für Benachrichtigungen';
    $Self->{Translation}->{'Notification web view'} = 'Web-Ansicht für Benachrichtigungen';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'Limit für die Web-Oberfläche für Benachrichtigungen in der kleinen Ansicht "S"';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Neue Benachrichtigungen:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'Anzahl Tage, nach welchen der Chat gelöscht wird.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Anzahl Stunden, nach denen der geschlossene Chat gelöscht wird.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Der Ausgabefilter für Standard tt Dateien';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        'Ausgabefilter zum Einfügen der erforderlichen DynamicField-Namen in versteckte Felder.';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Ausgabefilter zum Einfügen von notwendigem JavaScript in die Ansichten.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = 'Parameter für Filter in der Web-Ansicht für Benachrichtigungen.';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'Parameter für die Chat-Kanäle in den Benutzereinstellungen im Agenten-Interface.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Parameter (für die Web-Oberfläche für Benachrichtigungen) in der Anzeige-Variante "S".';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'Berechtigung um einen Chat mit einem Kunden aus der Agent Ticket Zoom Ansicht zu starten.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Bitte haben Sie einen Moment Geduld, bis einer unserer Agenten Ihre Chat-Anfrage beantworten kann. Danke für Ihr Verständnis.';
    $Self->{Translation}->{'Prepend'} = 'Voranstellen';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Geschlossene Chats die älter als der unter ChatEngine::ChatTTL eingetragene Wert sind löschen.';
    $Self->{Translation}->{'Remove old chats.'} = 'Alte Chats löschen';
    $Self->{Translation}->{'Resource overview page.'} = 'Ressourcen-Übersichtsseite.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Ressourcen-Übersichtsbildschirm.';
    $Self->{Translation}->{'Resources list.'} = 'Ressourcen-Liste.';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Führt eine initiale Wildcard-Suche für existierende Kontakte aus, wenn das Modul aufgerufen wird.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Definiert ob eine Chat-Anfrage aus der Agent Ticket Zoom Ansicht gesendet werden kann.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Definiert ob eine Chat-Anfrage aus der Kunden Ticket Zoom Ansicht gesendet werden kann.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Alle Ticket-Anlagen anzeigen';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Alle Anlagen anzeigen, die im Ticket verfügbar sind.';
    $Self->{Translation}->{'Start new chat'} = 'Einen Chat beginnen';
    $Self->{Translation}->{'Team agents management screen.'} = 'Team-Agenten-Verwaltungsbildschirm.';
    $Self->{Translation}->{'Team list'} = 'Team-Liste';
    $Self->{Translation}->{'Team management screen.'} = 'Team-Verwaltungsbildschirm.';
    $Self->{Translation}->{'Team management.'} = 'Team-Verwaltung.';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Text, der bei der Auswahl dieses SLA in CustomerTicketMessage angezeigt wird.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Logo, das für den Skin "Business" im Agenten-Interface angezeigt wird. Mehr Informationen finden Sie in der Einstellung "AgentLogo".';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'Im Augenblick sind leider keine Agenten für einen Chat verfügbar. Bitte versuchen Sie es zu einem späteren Zeitpunkt nochmals.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'Im Augenblick sind leider keine Agenten für einen Chat verfügbar. Um einen Artikel zum bestehenden Ticket hinzuzufügen, klicken Sie bitte hier:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'Im Augenblick sind leider keine Agenten für einen Chat verfügbar. Um ein neues Ticket zu erstellen, klicken Sie bitte hier:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'Dieser Chat wurde beendet. Bitte verlassen Sie ihn, ansonsten wird er automatisch geschlossen. ';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'Dieser Chat wurde beendet. Bitte verlassen Sie ihn, ansonsten wird er automatisch geschlossen. Sie können den Chat herunterladen.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'Dieser Chat ist abgeschlossen. Sie können das Chat-Fenster nun schließen.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'Dieser Chat ist abgeschlossen. Sie können jederzeit einen neuen Chat starten, indem Sie den entsprechenden Eintrag im Menü wählen.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Werkzeugleisten Objekt für die Web-Oberfläche für Benachrichtigungen.';
    $Self->{Translation}->{'Video and audio call screen.'} = 'Bildschirm für Video- und Audio-Anrufe.';
    $Self->{Translation}->{'View notifications'} = 'Benachrichtigungen betrachten';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        'Auswahl Ihrer bevorzugten Chat-Kanäle. Für ausgewählte Kanäle erhalten Sie eine Benachrichtigung bei externen Chat-Anfragen.';

}

1;
