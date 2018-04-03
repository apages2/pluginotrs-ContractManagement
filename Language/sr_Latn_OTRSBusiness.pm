# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::sr_Latn_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Upravljanje kanalima za ćaskanja';
    $Self->{Translation}->{'Add Chat Channel'} = 'Dodaj kanal za ćaskanja';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Uredi kanal za ćaskanja';
    $Self->{Translation}->{'Name invalid'} = 'Neispravan naziv';
    $Self->{Translation}->{'Need Group'} = 'Obavezna grupa';
    $Self->{Translation}->{'Need Valid'} = 'Obavezna važnost';
    $Self->{Translation}->{'Comment invalid'} = 'Neispravan komentar';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Status servisa u oblaku';
    $Self->{Translation}->{'Cloud service availability'} = 'Dostupnost servisa u oblaku';
    $Self->{Translation}->{'Remaining SMS units'} = 'Preostali broj SMS';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Provera statusa ovog servisa u oblaku trenutno nije moguća.';
    $Self->{Translation}->{'Phone field for agent'} = 'Broj telefona operatera';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Polje operatera sa mobilnim telefonskim brojem za slanje SMS poruka. ';
    $Self->{Translation}->{'Phone field for customer'} = 'Broj telefona klijenta';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Polje klijenta sa mobilnim telefonskim brojem za slanje SMS poruka.';
    $Self->{Translation}->{'Sender string'} = 'Pošiljaoc';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Biće prikazano kao naziv pošiljaoca SMS poruke (ne duže od 11 karaktera).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Ovo bolje je obavezno i ne sme biti duže od 11 karaktera.';
    $Self->{Translation}->{'Allowed role members'} = 'Pripadnici uloge';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Ukoliko je omogućeno, samo pripadnici ovih uloga će primiti SMS poruke (opciono).';
    $Self->{Translation}->{'Save configuration'} = 'Sačuvaj konfiguraciju';
    $Self->{Translation}->{'Data Protection Information'} = 'Informacije o zaštiti podataka';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Upravljanje kontakta sa podacima';
    $Self->{Translation}->{'Add contact with data'} = 'Dodaj kontakt sa podacima';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Molimo unesite pojam pretrage dza kontakt sa podacima.';
    $Self->{Translation}->{'Edit contact with data'} = 'Uredi kontakt sa podacima';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Ovo su mogući atributi za kontakte.';
    $Self->{Translation}->{'Mandatory fields'} = 'Obavezna polja';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Lista obaveznih ključeva odvojenih zapetom (opciono). Ključevi \'Name\' i \'ValidID\' su uvek obavezni i ne moraju biti izlistani ovde.';
    $Self->{Translation}->{'Sorted fields'} = 'Sortirana polja';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Lista ključeva za sortiranje odvojenih zapetom (opciono). Ključevi izlistani ovde uvek dolaze na prvom mestu, sva ostala polja su sortirana po abecednom redosledu.';
    $Self->{Translation}->{'Searchable fields'} = 'Polja za pretragu';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Lista ključeva za pretragu odvojenih zapetom (opciono). Ključ \'Name\' je uvek moguće pretražiti i ne mora biti izlistan ovde.';
    $Self->{Translation}->{'Add/Edit'} = 'Dodaj/Uredi';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Tip podataka';
    $Self->{Translation}->{'Searchfield'} = 'Polje za pretragu';
    $Self->{Translation}->{'Listfield'} = 'Polje za prikaz';
    $Self->{Translation}->{'Driver'} = 'Drajver';
    $Self->{Translation}->{'Server'} = 'Server';
    $Self->{Translation}->{'Table / View'} = 'Tabela / Pregled';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = 'Mora da bude jedinstvena kolona u tabeli uneta na pregledu tabela.';
    $Self->{Translation}->{'CacheTTL'} = 'Istek perioda keša';
    $Self->{Translation}->{'Searchprefix'} = 'Prefiks pretrage';
    $Self->{Translation}->{'Searchsuffix'} = 'Sufiks pretrage';
    $Self->{Translation}->{'Result Limit'} = 'Limit rezultata';
    $Self->{Translation}->{'Case Sensitive'} = 'Zavisi od velikih i malih slova';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Brojevi SMS primaoca';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Pregled resursa';
    $Self->{Translation}->{'Manage Calendars'} = 'Upravljanje kalendarima';
    $Self->{Translation}->{'Manage Teams'} = 'Upravljanje timovima';
    $Self->{Translation}->{'Manage Team Agents'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'Add new Appointment'} = 'Dodaj novi termin';
    $Self->{Translation}->{'Add Appointment'} = 'Dodaj termin';
    $Self->{Translation}->{'Calendars'} = 'Kalendari';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter za kalendare';
    $Self->{Translation}->{'URL'} = 'Adresa';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Iskopiraj javnu adresu kalendara (URL)';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ova stranica služi za pregled resursa.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nije pronađen nijedan kalendar. Molimo prvo dodajte kalendar korišćenjem ekrana Upravljanje kalendarima.';
    $Self->{Translation}->{'No teams found.'} = 'Nijedan tim nije pronađen.';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = 'Molimo prvo dodajte tim korišćenjem ekrana Upravljanje timovima.';
    $Self->{Translation}->{'Team'} = 'Tim';
    $Self->{Translation}->{'No team agents found.'} = 'Nijedan operater nije pronađen u timu.';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        'Molimo prvo dodajte operatera u tim korišćenjem ekrana Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'Too many active calendars'} = 'Previše aktivnih kalendara';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Ili prvo isključite prikaz nekog kalendara ili povećajte limit u konfiguraciji.';
    $Self->{Translation}->{'Restore default settings'} = 'Vratite podrazumevana podešavanja';
    $Self->{Translation}->{'Week'} = 'Sedmica';
    $Self->{Translation}->{'Timeline Month'} = 'Mesečna osa';
    $Self->{Translation}->{'Timeline Week'} = 'Sedmična osa';
    $Self->{Translation}->{'Timeline Day'} = 'Dnevna osa';
    $Self->{Translation}->{'Jump'} = 'Skoči';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Ovaj termin se ponavlja';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Da li želite da izmeni samo ovo ili sva ponavljanja?';
    $Self->{Translation}->{'All occurrences'} = 'Sva ponavljanja';
    $Self->{Translation}->{'Just this occurrence'} = 'Samo ovo ponavljanje';
    $Self->{Translation}->{'Dismiss'} = 'Odbaci';
    $Self->{Translation}->{'Resources'} = 'Resursi';
    $Self->{Translation}->{'Shown resources'} = 'Prikazani resursi';
    $Self->{Translation}->{'Available Resources'} = 'Dostupni resursi';
    $Self->{Translation}->{'Filter available resources'} = 'Filter za dostupne resurse';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Vidljivi resursi (redosled prema prevuci i pusti)';
    $Self->{Translation}->{'Basic information'} = 'Osnovne informacije';
    $Self->{Translation}->{'Resource'} = 'Resurs';
    $Self->{Translation}->{'Date/Time'} = 'Datum/vreme';
    $Self->{Translation}->{'End date'} = 'Datum kraja';
    $Self->{Translation}->{'Repeat'} = 'Ponavljanje';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Dodaj tim';
    $Self->{Translation}->{'Team Import'} = 'Uvoz tima';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Ovde možete učitati konfiguracionu datoteku za uvoz tima u vaš sistem. Fajl mora biti u istom .yml formatu koji je moguće dobiti izvozom u ekranu upravljanja timovima.';
    $Self->{Translation}->{'Upload team configuration'} = 'Učitaj konfiguraciju tima';
    $Self->{Translation}->{'Import team'} = 'Uvezi tim';
    $Self->{Translation}->{'Filter for teams'} = 'Filter za timove';
    $Self->{Translation}->{'Export team'} = 'Izvezi tim';
    $Self->{Translation}->{'Edit Team'} = 'Izmeni tim';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Tim sa istim nazivom već postoji.';
    $Self->{Translation}->{'Permission group'} = 'Grupa pristupa';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Filter za operatere';
    $Self->{Translation}->{'Teams'} = 'Timovi';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Izmeni pripadnost operatera timu';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Izmeni pripadnost timu operaterima';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'Upravljanje ćaskanjima';
    $Self->{Translation}->{'Hints'} = 'Saveti';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Napominjemo: ovaj prozor će se koristiti za bilo koji zahtev u vezi ćaskanja. Ukoliko napuštate menadžer ćaskanja (npr. korišćenjem navigacije pri vrhu strane), pokretanje novog ćaskanja ili bilo koje druge funkcije u vezi istog može dovesti do osvežavanja ovog prozora. Preporučljivo je da držite menadžer ćaskanja otvoren u ovom konkretnom prozoru.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Opšti zahtevi za ćaskanja od klijenata';
    $Self->{Translation}->{'My Chat Channels'} = 'Moji kanali za ćaskanja';
    $Self->{Translation}->{'All Chat Channels'} = 'Svi kanali za ćaskanja';
    $Self->{Translation}->{'Channel'} = 'Kanal';
    $Self->{Translation}->{'Requester'} = 'Naručilac';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Zahtevi za ćaskanje se učitavaju, molimo sačekajte...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Opšti zahtevi za ćaskanja od javnih korisnika';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Lični zahtevi za ćaskanja za vas';
    $Self->{Translation}->{'My Active Chats'} = 'Moja aktivna ćaskanja';
    $Self->{Translation}->{'Open ticket'} = 'Otvori tiket';
    $Self->{Translation}->{'Open company'} = 'Otvori firmu';
    $Self->{Translation}->{'Discard & close this chat'} = 'Zatvori i obriši ovo ćaskanje';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Nadgledanje svih aktivnosti u ovom ćaskanju';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Nadgledanje klijentskih aktivnosti u ovom ćaskanju';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Bez nadgledanja aktivnosti u ovom ćaskanju';
    $Self->{Translation}->{'Audio Call'} = 'Audio poziv';
    $Self->{Translation}->{'Video Call'} = 'Video poziv';
    $Self->{Translation}->{'Toggle settings'} = 'Preklopi podešavanja';
    $Self->{Translation}->{'Leave chat'} = 'Napusti ćaskanje';
    $Self->{Translation}->{'Leave'} = 'Napusti';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Kreiraj novi telefonski tiket od ovog ćaskanja i zatvori ga';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Dodaj ovo ćaskanje postojećem tiketu i zatvori ga';
    $Self->{Translation}->{'Append'} = 'Dodaj';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Pozovite dodatnog operatera da se priduži ćaskanju';
    $Self->{Translation}->{'Invite'} = 'Poziv';
    $Self->{Translation}->{'Change chat channel'} = 'Promeni kanal za ćaskanja';
    $Self->{Translation}->{'Channel change'} = 'Promena kanala';
    $Self->{Translation}->{'Switch to participant'} = 'Pređi na učesnika';
    $Self->{Translation}->{'Participant'} = 'Učesnik';
    $Self->{Translation}->{'Switch to an observer'} = 'Pređi na posmatrača';
    $Self->{Translation}->{'Observer'} = 'Posmatrač';
    $Self->{Translation}->{'Download this Chat'} = 'Preuzmi ovo ćaskanje';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Pridruži se ćaskanju kao posmatrač';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Pridruži se ćaskanju kao učesnik';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Otvori ćaskanje u prozoru';
    $Self->{Translation}->{'New window'} = 'Novi prozor';
    $Self->{Translation}->{'New Message'} = 'Nova poruka';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter za prored)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s je napustio ovo ćaskanje.';
    $Self->{Translation}->{'Online agents'} = 'Operateri na vezi';
    $Self->{Translation}->{'Reload online agents'} = 'Osveži operatere na vezi';
    $Self->{Translation}->{'Destination channel'} = 'Kanal odredišta';
    $Self->{Translation}->{'Open chat'} = 'Otvori ćaskanje';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = 'Korisnik je već napustio ćaskanje ili se još nije pridružio.';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Više niste deo ovog ćaskanja. Kliknite na ovu poruku za uklanjanje prozora.';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Trenutno nema zahteva za ćaskanje.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Ovo će trajno ukloniti sadržaj ćaskanja. Da li želite da nastavite?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Ovaj zahtev za ćaskanje je već prihvaćen od strane drugog korisnika.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Nemate dozvolu da prihvatite ovaj zahtev za ćaskanje.';
    $Self->{Translation}->{'Please select a user.'} = 'Molimo da odaberete korisnika.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Molimo da odaberete nivo pristupa.';
    $Self->{Translation}->{'Invite Agent.'} = 'Pozovi operatera.';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Molimo da odaberete kanal odredišta.';
    $Self->{Translation}->{'Please select a channel.'} = 'Molimo da odaberete kanal.';
    $Self->{Translation}->{'Chat preview'} = 'Prikaz ćaskanja';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Molimo da odaberete važeći kanal.';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Ćaskanje izmeću operatera i klijenta.';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Ćaskanje između klijenta i operatera.';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Ćaskanje između operatera.';
    $Self->{Translation}->{'Public to agent chat.'} = 'Ćaskanje između javnih korisnika i operatera.';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Ne možete ostaviti klijenta samog u ćaskanju.';
    $Self->{Translation}->{'You'} = 'Vi';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Vaše ćaskanje nije moglo biti pokrenuto zbog interne greške.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Vaš zahtev za ćaskanje je kreiran.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Trenutno ima %s otvorenih zahteva za ćaskanje.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Korisnik je već pozvan u vaše ćaskanje!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'Nedovoljne dozvole.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'Sistem nije uspeo da snimi vaš redosled ćaskanja.';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Dodajte ćaskanje u tiket';
    $Self->{Translation}->{'Append to'} = 'Dodajte u';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'Ćaskanje će biti dodato kao novi članak u izabranom tiketu.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Ćaskanje sa';
    $Self->{Translation}->{'Leave Chat'} = 'Napusti ćaskanje';
    $Self->{Translation}->{'User is currently in the chat.'} = 'Korisnik je trenutno u ćaskanju.';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Trenutni kanal za ćaskanja';
    $Self->{Translation}->{'Available channels'} = 'Raspoloživi kanali';
    $Self->{Translation}->{'Reload'} = 'Osveži';
    $Self->{Translation}->{'Update Channel'} = 'Promeni kanal';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Detaljna pretraga';
    $Self->{Translation}->{'Add an additional attribute'} = 'Dodaj još jedan atribut';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Detaljni prikaz';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Obaveštenja po strani';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Nisu pronađena obaveštenja.';
    $Self->{Translation}->{'Related To'} = 'Povezano sa';
    $Self->{Translation}->{'Select this notification'} = 'Izaberi ovo obaveštenje';
    $Self->{Translation}->{'Zoom into'} = 'Uvećaj';
    $Self->{Translation}->{'Dismiss this notification'} = 'Odbaci ovo obaveštenje';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Odbaci izabrana obaveštenja';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Da li zaista želite da odbacite izabrana obaveštenja?';
    $Self->{Translation}->{'OTRS Notification'} = 'OTRS obaveštenje';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Izveštaji » Dodaj';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Dodaj novi statistički izveštaj';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Izveštaji » Izmeni — %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Ovde možete iskombinovati više statistika u izveštaj koji možete generisati kao PDF ručno ili automatski u određeno vreme.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Napominjemo da možete izabrati grafikone kao izlazni format statistike ukoliko ste podesili PhantomJS na vašem sistemu.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'Podesi PhantomJS';
    $Self->{Translation}->{'General settings'} = 'Opšta podešavanja';
    $Self->{Translation}->{'Automatic generation settings'} = 'Podešavanje automatskog generisanja';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Vreme automatskog generisanja (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Definišite kada će izveštaj biti automatski generisan u cron formatu, npr. "10 1 * * *" za svaki dan u 01:10 ujutru.';
    $Self->{Translation}->{'Last automatic generation time'} = 'Vreme poslednjeg automatskog generisanja';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Vreme sledećeg planiranog automatskog generisanja';
    $Self->{Translation}->{'Automatic generation language'} = 'Jezik automatskog generisanja';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'Jezik koji će biti korišćen prilikom automatskog generisanja izveštaja.';
    $Self->{Translation}->{'Email subject'} = 'Predmet imejla';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = 'Definiše predmet za automatsko generisan imejl.';
    $Self->{Translation}->{'Email body'} = 'Imejl poruka';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'Definiše tekst automatsko generisanog imejla.';
    $Self->{Translation}->{'Email recipients'} = 'Primaoci imejla';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'Definiše adrese primaca (odvojene zapetom).';
    $Self->{Translation}->{'Output settings'} = 'Podešavanja izlaza';
    $Self->{Translation}->{'Headline'} = 'Naslov';
    $Self->{Translation}->{'Caption for preamble'} = 'Podnaslov uvoda';
    $Self->{Translation}->{'Preamble'} = 'Uvod';
    $Self->{Translation}->{'Caption for epilogue'} = 'Podnaslov zaključka';
    $Self->{Translation}->{'Epilogue'} = 'Zaključak';
    $Self->{Translation}->{'Add statistic to report'} = 'Dodaj statistiku u izveštaj';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Izveštaji » Pregled';
    $Self->{Translation}->{'Statistics Reports'} = 'Statistički izveštaji';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Uredi statistički izveštaj "%s".';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Obriši statistički izveštaj "%s"';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Da li zaista želite da obrišete ovaj izveštaj?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Izveštaji » Pogledaj — %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Ovaj statistički izveštaj sadrži konfiguracione greške i sad se ne može koristiti.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Prilozi uz';
    $Self->{Translation}->{'Attachment Overview'} = 'Pregled priloga';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Ovaj tiket nema priloge.';
    $Self->{Translation}->{'Hide inline attachments'} = 'Sakri neposredne priloge';
    $Self->{Translation}->{'Filter Attachments'} = 'Filtriraj priloge';
    $Self->{Translation}->{'Select All'} = 'Izaberi sve';
    $Self->{Translation}->{'Click to download this file'} = 'Kliknite za preuzimanje datoteke';
    $Self->{Translation}->{'Open article in main window'} = 'Otvori članak u glavnom prozoru';
    $Self->{Translation}->{'Download selected files as archive'} = 'Preuzimanje izabranih datoteka kao arhiv';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = 'Vaš pregledač ne podržava HTML5 video.';
    $Self->{Translation}->{'Close video call'} = 'Prekini video poziv';
    $Self->{Translation}->{'Toggle audio'} = 'Isključi/uključi zvuk';
    $Self->{Translation}->{'Toggle video'} = 'Isključi/uključi video';
    $Self->{Translation}->{'User has declined your invitation.'} = 'Korisnik je odbio vaš poziv.';
    $Self->{Translation}->{'User has left the call.'} = 'Korisnik je napustio poziv.';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = 'Pokušaj uspostavljanja veze nije uspeo. Molimo pokušajte ponovo.';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = 'Pristup medija strimu je odbijen.';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = 'Molimo omogućite ovoj stranici pristup vašem video i audio strimu.';
    $Self->{Translation}->{'Requesting media stream...'} = 'Zahtev za medija strim...';
    $Self->{Translation}->{'Waiting for other party to respond...'} = 'Čekanje na odgovor druge strane...';
    $Self->{Translation}->{'Accepting the invitation...'} = 'Prihvaranje pozivnice...';
    $Self->{Translation}->{'Initializing...'} = 'Inicijalizacija...';
    $Self->{Translation}->{'Connecting, please wait...'} = 'Povezivanje, molimo sačekajte...';
    $Self->{Translation}->{'Connection established!'} = 'Veza uspostavljena!';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s se pridružio ovom ćaskanju.';
    $Self->{Translation}->{'Incoming chat requests'} = 'Dolazni zahtevi za ćaskanje';
    $Self->{Translation}->{'Outgoing chat requests'} = 'Odlazni zahtevi za ćaskanje';
    $Self->{Translation}->{'Active chats'} = 'Aktivna ćaskanja';
    $Self->{Translation}->{'Closed chats'} = 'Zatvorena ćaskanja';
    $Self->{Translation}->{'Chat request description'} = 'Opis zahteva za ćaskanje';
    $Self->{Translation}->{'Create new ticket'} = 'Kreiraj novi tiket';
    $Self->{Translation}->{'Add an article'} = 'Dodaj članak';
    $Self->{Translation}->{'Start a new chat'} = 'Počni novo ćaskanje';
    $Self->{Translation}->{'Select channel'} = 'Izaberi kanal';
    $Self->{Translation}->{'Add to an existing ticket'} = 'Dodaj postojećem tiketu';
    $Self->{Translation}->{'Active Chat'} = 'Aktivno ćaskanje';
    $Self->{Translation}->{'Download Chat'} = 'Preuzmi ćaskanje';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Ćaskanje se učitava...';
    $Self->{Translation}->{'Chat completed'} = 'Ćaskanje završeno';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = 'Ceo ekran';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Molimo potvrdi vaš izbor';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Vaše ime';
    $Self->{Translation}->{'Start a new Chat'} = 'Počni novo ćaskanje';
    $Self->{Translation}->{'Chat complete'} = 'Ćaskanje završeno';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Ukloni statistiku';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Ukoliko ne definišete naslov ovde, biće iskorišćen naziv statistike.';
    $Self->{Translation}->{'Preface'} = 'Predgovor';
    $Self->{Translation}->{'Postface'} = 'Zaključak';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Dodat kanal za ćaskanje %s';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Izmenjen kanal za ćaskanje';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Osvežen servis u oblaku "%s"!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Sačuvana konfiguracija servisa u oblaku "%s"!';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        'Ova funkcija je deo paketa %s. Molimo instalirajte ovaj besplatan dodatni modul pre ponovnog korišćenja.';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Potreban ID tima!';
    $Self->{Translation}->{'Invalid GroupID!'} = 'Neispravan GroupID!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'Ne mogu pribaviti podatke za dati TeamID';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nedodeljeno';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        'Ćaskanje %s je zatvoreno i uspešno je dodato u tiket %s.';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        'Funkcija video poziva je isključena! Molimo proverite da li je %s dostupan za vaš sistem.';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s se pridružio ovom ćaskanju kao posmatrač.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = 'Ukoliko prihvatite, svi aktivni pozivi će biti prekinuti.';
    $Self->{Translation}->{'New request for joining a chat'} = 'Nov zahtev za pridruživanje ćaskanju';
    $Self->{Translation}->{'Agent invited %s.'} = 'Operater je pozvao %s.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s je promenio kanal za ćaskanje na %s';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s je prešao na mod učesnika.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s je prešao na mod posmatrača.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s je odbio zahtev za ćaskanje.';
    $Self->{Translation}->{'Need'} = 'Potreban';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'Sva obaveštenja';
    $Self->{Translation}->{'Seen Notifications'} = 'Viđena obaveštenja';
    $Self->{Translation}->{'Unseen Notifications'} = 'Neviđena obaveštenja';
    $Self->{Translation}->{'Notification Web View'} = 'Veb prikaz obaveštenja';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Ovo ime je već upotrebljeno, molimo izaberite neko drugo.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Molimo da unesete ispravno cron pravilo.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = 'Vi niste učesnik u ovom ćaskanju!';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Niste dostupni za ćaskanja sa klijentima. Da li želite da budete dostupni?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Nemate podešenih eksternih kanala za ćaskanja.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Odbaci izabrano';
    $Self->{Translation}->{'Object Type'} = 'Tip objekta';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        'Nemate pristup kanalima za ćaskanje u sistemu. Molimo kontaktirajte administratora.';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Otvoreni zahtevi za ćaskanja';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s izveštaj';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Greška prilikom generisanja ovog grafikona: %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Sadržaj';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'Podrazumevani kanal za ćaskanja';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Aktivira ćaskanje.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'Registracija modula pristupa u interfejsu operatera (onemogućava vezu za ćaskanja ukoliko se ne koristi ili operater ne pripada odgovarajućoj grupi).';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Grupe operatera koje mogu prihvatiti zahteve za ćaskanje.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Grupe operatera koje mogu kreirati zahteve za ćaskanje.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = 'Grupa operatera koja može da koristi funkciju video poziva.';
    $Self->{Translation}->{'Agent interface availability.'} = 'Dostupnost u interfejsu operatera.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Modul interfejsa operatera za proveru otvorenih zahteva za ćaskanje.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Dozvoli klijentu da izabere samo kanale koji imau dostupne operatere.';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Dozvoli javnom korisniku da izabere samo kanale koji imaju dostupne operatere.';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Dozvoljava pristup umanjenom formatu veb prikaza obaveštenja.';
    $Self->{Translation}->{'Chat Channel'} = 'Kanal za ćaskanja';
    $Self->{Translation}->{'Chat Channel:'} = 'Kanal za ćaskanja:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'Kanal za ćaskanja koji će biti korišćen za komunikaciju u vezi tiketa u ovom redu.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Mapa kanala za ćaskanja i redova.';
    $Self->{Translation}->{'Chat overview'} = 'Pregled ćaskanja';
    $Self->{Translation}->{'Chats'} = 'Ćaskanja';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Čišćenje zastarelih ćaskanja.';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'Filteri kolona za umanjeni veb prikaz obaveštenja.';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Kolone koje mogu biti filtrirane u veb prikazu obaveštenja. Moguća podešavanja: 0 = Onemogučeno, 1 = Dostpuno, 2 = Podrazumevano omogućeno.';
    $Self->{Translation}->{'Contact with data'} = 'Kontakt sa podacima';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Kreiranje i upravljanje kanalima za ćaskanja.';
    $Self->{Translation}->{'Create new chat'} = 'Napravi novo ćaskanje';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'Registracija modula pristupa u interfejsu klijenta (onemogućava vezu za ćaskanja ukoliko se ne koristi ili nema dostupnih operatera).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Podrazumevano ime operatera u interfejsu klijenta i javnom interfejsu. Ukoliko je omogućeno, pravo ime operatera neće biti vidljivo za klijente/javne korisnike za vreme ćaskanja.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Podrazumevani tekst za interfejs klijenta.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Podrazumevani tekst za javni korisnički interfejs.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Definiše listu ključeva podešavanja operatera koja će biti vidljiva u interfejsu klijenta (funkcioniše samo ukoliko je DefaultAgentName onemogućeno). Primer: ukoliko želite da prikažete PreferencesGroups###Language, dodajte Language.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Definiše tekst za podešavanja operatera u interfejsu klijenta (funkcioniše samo ukoliko je DefaultAgentName onemogućeno).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Definiše da li klijenti mogu da izaberu kanal ćaskanja. Ukoliko ne mogu, ćaskanja će biti kreirana u podrazumevanom kanalu.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Definiše da li je zaključavanje tiketa obavezno pre nego što je moguće pokrenuti ćaskanje sa klijentom iz detaljnog pregleda tiketa.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Definiše da li će brojevi biti pridodati DefaultAgentName. Ukoliko je omogućeno, DefaultAgentName će biti prikazano sa brojevima (npr. 1, 2, 3, ...).';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Definiše da li javni korisnici mogu da izaberu kanal ćaskanja. Ukoliko ne mogu, ćaskanja će biti kreirana u podrazumevanom kanalu.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Definiše modul za prikaz upozorenja u interfejsu operatera, ukoliko je operater dostupan za ćaskanja sa klijentima, ali nema podešenih kanala.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Definiše modul za prikaz obaveštenja u interfejsu oepratera, ukoliko oeprater nije dostupan za ćaskanja sa klijentima (samo ako je Ticket::Agent::AvailableForChatsAfterLogin podešeno na Ne).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Definiše broj dana koliko dugo će obaveštenje biti prikazano u veb pregledu (vrednost \'0\' znači da će uvek biti prikazano).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Definiše redosled prozora za ćaskanje.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Definiše putanju do PhantomJS programa. Možete koristiti statičku verziju programa sa http://phantomjs.org/download.html za jednostavnu instalaciju.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Definiše period vremena (u minutima) posle kog će poruka da nema odgovora biti prikazana klijentu.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        'Definiše period vremena (u minutima) posle kog će operater biti označen kao "odsutan".';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        'Definiše period vremena (u minutima) posle kog će korisnik biti označen kao "odsutan".';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = 'Definiše podešavanja za obaveštenja o terminima.';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = 'Definiše podešavanja za obaveštenja o kalendarima.';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Definiše podešavanja za obaveštenja o tiketima.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Definiše izvorno dinamičko polje za čuvanje informacija.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Definiše ciljno dinamičko polje za čuvanje informacija.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'Pozadinski prikaz dinamičkog polja sa kontaktom';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'Pozadinski prikaz dinamičkog polja baze podataka';
    $Self->{Translation}->{'Edit contacts with data'} = 'Uređivanje kontakata sa podacima';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Omogućava masovnu akciju u veb prikazu obaveštenja u interfejsu operatera na više od jedne stavke istovremeno.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Omogućava svojstvo masovne akcije u veb prikazu obaveštenja samo za izlistane grupe.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Omogućava hronološki prikaz u AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'Registracija modula događaja (čuvanje informacija u dinamičkim poljima).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = 'Registracija modula za interfejs klijenta.';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Registracija pristupnog modula za javni interfejs.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'Generiše HTML komentare za odgovarajuće blokove da bi filteri mogli da ih koriste.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Ukoliko je omogućeno, proverava dostupnost operatera po logovanju. Ukoliko je operater dostupan za ćaskanja sa klijentima, ograničiće dostupnost samo na ćaskanja sa operaterima.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Ukoliko je ovo podešeno na Da i operater nije dostupan za ćaskanja, biće prikazano obaveštenje na svakoj strani.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Ukoliko je ovo podešeno na Da, operateri mogu da pokrenu ćaskanje sa klijentom bez tiketa.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Ukoliko je ovo podešeno na Da, klijenti mogu da pokrenu ćaskanje sa operaterom bez tiketa.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Ukoliko je ovo podešeno na Da, samo klijent tiketa može pokrenuti ćaskanje iz detaljnog prikaza.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Ukoliko je ovo podešeno na Da, pokretanje ćaskanja iz detaljnog prikaza tiketa će biti moguće samo ukoliko je klijent na vezi.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'Ukoliko je ovo podešeno na Da, pokretanje ćaskanja iz detaljnog prikaza tiketa će biti moguće samo ukoliko ima dostupnih operatera u odgovarajućem kanalu.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Omogućava pokretanje ćaskanja sa klijentom iz interfejsa operatera.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Omogućava pokretanje ćaskanja sa operaterom iz operaterskog interfejsa.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Omogućava pokretanje ćaskanja sa operaterom iz interfejsa klijenta.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Omogućava pokretanje ćaskanja sa operaterom iz javnog interfejsa.';
    $Self->{Translation}->{'Manage team agents.'} = 'Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'My chats'} = 'Moja ćaskanja';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Naziv podrazumevanog kanala za ćaskanja. Ukoliko ovaj kanal ne postoji, biće kreiran automatski. Molimo vas da ne kreirate kanal sa istim nazivom kao podrazumevani. Podrazumevani kanal neće biti prikazan ukoliko su kanali omogućeni u interfejsu klijenta. Sva ćaskanja izmeću operatera će biti u podrazumevanom kanalu.';
    $Self->{Translation}->{'No agents available message.'} = 'Poruka o nedostupnosti operatera.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'Ograničenje obaveštenja po strani za umanjeni veb prikaz.';
    $Self->{Translation}->{'Notification web view'} = 'Veb prikaz obaveštenja';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'Ograničenje umanjenog veb prikaza obaveštenja';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Neviđena obaveštenja:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'Broj dana posle koga će ćaskanje biti obrisano.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Broj sati posle kog će zatvorena ćaskanja biti obrisana.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Izlazni filter za standarne TT datoteke.';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        'Izlazni filter za ubacivanje neophodnih skrivenih dinamičkih polja.';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Izlazni filter za ubacivanje neophodnog JavaScript u preglede.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = 'Parametri za filtere u veb prikazi obaveštenja.';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'Parametri za podešavanje kanala za ćaskanje u interfejsu operatera.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Parametri stranica (na kojima su obaveštenja prikazana) u umanjenom veb prikazu obaveštenja.';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'Nivo pristupa neophodan za pokretanje ćaskanja sa klijentom iz detaljnog prikaza tiketa u interfejsu operatera.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Molimo sačekajte dok neko od naših operatera ne bude u mogućnosti da obradi vaš zahtev. Hvala na strpljenju.';
    $Self->{Translation}->{'Prepend'} = 'Dodaj';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Uklanja zatvorena ćaskanja starija od ChatEngine::ChatTTL.';
    $Self->{Translation}->{'Remove old chats.'} = 'Uklanja stara ćaskanja.';
    $Self->{Translation}->{'Resource overview page.'} = 'Stranica pregleda resursa.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Ekran pregleda resursa.';
    $Self->{Translation}->{'Resources list.'} = 'Lista resursa.';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Pokreće inicijalnu pretragu za postojećim kontaktima sa podacima prilikom pristupa modulu AdminContactWithData.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Definiše da li zahtev za ćaskanje može biti poslat iz detaljnog pregleda tiketa u interfejsu operatera.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Definiše da li zahtev za ćaskanje može biti poslat iz detaljnog pregleda tiketa u interfejsu klijenta.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Prikaži sve priloge tiketa';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Prikazuje sve raspoložive priloge za tiket.';
    $Self->{Translation}->{'Start new chat'} = 'Počni novo ćaskanje';
    $Self->{Translation}->{'Team agents management screen.'} = 'Ekran upravljanja operaterima u timovima.';
    $Self->{Translation}->{'Team list'} = 'Lista timova';
    $Self->{Translation}->{'Team management screen.'} = 'Ekran upravljanja timovima.';
    $Self->{Translation}->{'Team management.'} = 'Upravljanje timom.';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Tekst koji će biti prikazan prilikom selekcije SLA u CustomerTicketMessage.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Logo prikazan u zaglavlju interfejsa operatera za izgled "business". Pogledajte "AgentLogo" za detaljniji opis.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'U ovom trenutku nema slobodnih operatera. Molimo pokušajte kasnije.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'U ovom trenutku nema dostupnih operatera. Za dodavanje članka postojećem tiketu, molimo kliknite ovde:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'U ovom trenutku nema dostupnih operatera. Za kreiranje novog tiketa, molimo kliknite ovde:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'Ovo ćaskanje je završeno. Možete ga napustiti ili će biti zatvoreno automatski.';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'Ovo ćaskanje je završeno. Možete ga napustiti ili će biti zatvoreno automatski. Možete preuzeti ovo ćaskanje.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'Ovo ćaskanje je završeno. Možete zatvoriti ovaj prozor.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'Ovo ćaskanje je završeno. Možete pokrenuti novo korišćenjem veze pri vrhu ove strane.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Stavka alatne linije za veb prikaz obaveštenja.';
    $Self->{Translation}->{'Video and audio call screen.'} = 'Ekran video i audio poziva.';
    $Self->{Translation}->{'View notifications'} = 'Pregled obaveštenja';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        'Vaš izbor kanala za ćaskanje sa klijentima. Bićete obavešteni o zahtevima za ćaskanja u ovim kanalima.';

}

1;
