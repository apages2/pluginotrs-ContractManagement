# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Csevegőcsatornák kezelése';
    $Self->{Translation}->{'Add Chat Channel'} = 'Csevegőcsatorna hozzáadása';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Csevegőcsatorna szerkesztése';
    $Self->{Translation}->{'Name invalid'} = 'A név érvénytelen';
    $Self->{Translation}->{'Need Group'} = 'Csoport szükséges';
    $Self->{Translation}->{'Need Valid'} = 'Érvényes szükséges';
    $Self->{Translation}->{'Comment invalid'} = 'A megjegyzés érvénytelen';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Felhőszolgáltatás állapota';
    $Self->{Translation}->{'Cloud service availability'} = 'Felhőszolgáltatás elérhetősége';
    $Self->{Translation}->{'Remaining SMS units'} = 'Hátralévő SMS egységek';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Jelenleg nem lehetséges a felhőszolgáltatás állapotának az ellenőrzése.';
    $Self->{Translation}->{'Phone field for agent'} = 'Telefonmező az ügyintézőnél';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Ügyintézői adatmező, amelyből az SMS-ben történő üzenetküldésekhez a mobiltelefonszámot ki kell venni.';
    $Self->{Translation}->{'Phone field for customer'} = 'Telefonmező az ügyfélnél';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Ügyfél adatmező, amelyből az SMS-ben történő üzenetküldésekhez a mobiltelefonszámot ki kell venni.';
    $Self->{Translation}->{'Sender string'} = 'Küldő szövege';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Az SMS-küldő neveként fog megjelenni (nem lehet hosszabb 11 karakternél).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Ez a mező kötelező, és nem lehet hosszabb 11 karakternél.';
    $Self->{Translation}->{'Allowed role members'} = 'Engedélyezett szereptagok';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Ha ki van választva, akkor csak az ezekhez a szerephez hozzárendelt felhasználók lesznek képesek SMS-ben üzeneteket fogadni (opcionális).';
    $Self->{Translation}->{'Save configuration'} = 'Beállítások mentése';
    $Self->{Translation}->{'Data Protection Information'} = 'Adatvédelmi információk';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Adatokkal rendelkező partner kezelése';
    $Self->{Translation}->{'Add contact with data'} = 'Adatokkal rendelkező partner hozzáadása';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Adjon meg egy keresési kifejezést az adatokkal rendelkező partnerek kereséséhez.';
    $Self->{Translation}->{'Edit contact with data'} = 'Adatokkal rendelkező partner szerkesztése';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Ezek a lehetséges adatattribútumok a partnereknél.';
    $Self->{Translation}->{'Mandatory fields'} = 'Kötelező mezők';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'A kötelező kulcsok vesszővel elválasztott listája (opcionális). A „Name” és a „ValidID” kulcsok mindig kötelezőek, és nem kell azokat itt felsorolni.';
    $Self->{Translation}->{'Sorted fields'} = 'Rendezett mezők';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'A kulcsok vesszővel elválasztott listája a rendezési sorrendben (opcionális). Az itt felsorolt kulcsok jönnek először, azután az összes hátralévő mező ábécé sorrendbe rendezve.';
    $Self->{Translation}->{'Searchable fields'} = 'Kereshető mezők';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'A kereshető kulcsok vesszővel elválasztott listája (opcionális). A „Name” kulcs mindig kereshető, és nem kell azt itt felsorolni.';
    $Self->{Translation}->{'Add/Edit'} = 'Hozzáadás/szerkesztés';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Adattípus';
    $Self->{Translation}->{'Searchfield'} = 'Keresőmező';
    $Self->{Translation}->{'Listfield'} = 'Listamező';
    $Self->{Translation}->{'Driver'} = 'Illesztőprogram';
    $Self->{Translation}->{'Server'} = 'Kiszolgáló';
    $Self->{Translation}->{'Table / View'} = 'Tábla / nézet';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = 'Egyedi oszlopnak kell lennie a tábla/nézet helyen megadott táblából.';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Keresési előtag';
    $Self->{Translation}->{'Searchsuffix'} = 'Keresési utótag';
    $Self->{Translation}->{'Result Limit'} = 'Találati korlát';
    $Self->{Translation}->{'Case Sensitive'} = 'Kis- és nagybetűk megkülönböztetése';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Címzett SMS számai';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Erőforrás áttekintő';
    $Self->{Translation}->{'Manage Calendars'} = 'Naptárak kezelése';
    $Self->{Translation}->{'Manage Teams'} = 'Csapatok kezelése';
    $Self->{Translation}->{'Manage Team Agents'} = 'Csapatügyintézők kezelése';
    $Self->{Translation}->{'Add new Appointment'} = 'Új értekezlet hozzáadása';
    $Self->{Translation}->{'Add Appointment'} = 'Értekezlet hozzáadása';
    $Self->{Translation}->{'Calendars'} = 'Naptárak';
    $Self->{Translation}->{'Filter for calendars'} = 'Szűrő a naptárakhoz';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Nyilvános naptár URL másolása';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ez egy erőforrás áttekintő oldal.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nem találhatók naptárak. Először adjon hozzá egy naptárat a naptárak kezelése oldal használatával.';
    $Self->{Translation}->{'No teams found.'} = 'Nem találhatók csapatok.';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = 'Először adjon hozzá egy csapatot a csapatok kezelése oldal használatával.';
    $Self->{Translation}->{'Team'} = 'Csapat';
    $Self->{Translation}->{'No team agents found.'} = 'Nem találhatók csapatügyintézők.';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        'Először rendeljen hozzá ügyintézőket egy csapathoz a csapatügyintézők kezelése oldal használatával.';
    $Self->{Translation}->{'Too many active calendars'} = 'Túl sok aktív naptár';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Vagy kapcsoljon ki néhányat először, vagy növelje a korlátot a beállításokban.';
    $Self->{Translation}->{'Restore default settings'} = 'Alapértelmezett beállítások visszaállítása';
    $Self->{Translation}->{'Week'} = 'Hét';
    $Self->{Translation}->{'Timeline Month'} = 'Idővonal hónap';
    $Self->{Translation}->{'Timeline Week'} = 'Idővonal hét';
    $Self->{Translation}->{'Timeline Day'} = 'Idővonal nap';
    $Self->{Translation}->{'Jump'} = 'Ugrás';
    $Self->{Translation}->{'Appointment'} = 'Értekezlet';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Ez egy ismétlődő értekezlet';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Csak ezt az előfordulást szeretné szerkeszteni vagy az összeset?';
    $Self->{Translation}->{'All occurrences'} = 'Összes előfordulás';
    $Self->{Translation}->{'Just this occurrence'} = 'Csak ez az előfordulás';
    $Self->{Translation}->{'Dismiss'} = 'Eltüntetés';
    $Self->{Translation}->{'Resources'} = 'Erőforrások';
    $Self->{Translation}->{'Shown resources'} = 'Megjelenített erőforrások';
    $Self->{Translation}->{'Available Resources'} = 'Elérhető erőforrások';
    $Self->{Translation}->{'Filter available resources'} = 'Elérhető erőforrások szűrése';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Látható erőforrások (rendezés fogd és vidd módon)';
    $Self->{Translation}->{'Basic information'} = 'Alap információk';
    $Self->{Translation}->{'Resource'} = 'Erőforrás';
    $Self->{Translation}->{'Date/Time'} = 'Dátum/idő';
    $Self->{Translation}->{'End date'} = 'Befejezési dátum';
    $Self->{Translation}->{'Repeat'} = 'Ismétlés';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Csapat hozzáadása';
    $Self->{Translation}->{'Team Import'} = 'Csapat importálása';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Itt tölthet fel egy beállítófájlt egy csapat importálásához a rendszerre. A fájlnak .yml formátumban kell lennie, ahogy a csapatkezelő modul exportálta.';
    $Self->{Translation}->{'Upload team configuration'} = 'Csapatbeállítás feltöltése';
    $Self->{Translation}->{'Import team'} = 'Csapat importálása';
    $Self->{Translation}->{'Filter for teams'} = 'Szűrő a csapatokhoz';
    $Self->{Translation}->{'Export team'} = 'Csapat exportálása';
    $Self->{Translation}->{'Edit Team'} = 'Csapat szerkesztése';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Már létezik egy ilyen nevű csapat.';
    $Self->{Translation}->{'Permission group'} = 'Jogosultsági csoport';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Szűrő az ügyintézőkhöz';
    $Self->{Translation}->{'Teams'} = 'Csapatok';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Csapat-ügyintéző kapcsolatok kezelése';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Ügyintéző-kapcsolatok megváltoztatása egy csapatnál';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Csapatkapcsolatok megváltoztatása egy ügyintézőnél';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'Csevegések kezelése';
    $Self->{Translation}->{'Hints'} = 'Tippek';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Ne feledje: ezt a lapot fogja használni minden olyan kérés, amely a csevegésekhez kapcsolódik. Ha elhagyja a csevegéskezelőt (például az oldal tetején lévő navigációs sáv használatával), új csevegést vagy egyéb csevegéssel kapcsolatos műveleteket indít, akkor az esetleg újra fogja tölteni ezt a lapot minden esetben. Ez azt jelenti, hogy ajánlott kilépni azon a bizonyos lapon megnyitott csevegéskezelőből.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Általános csevegéskérések az ügyfelektől';
    $Self->{Translation}->{'My Chat Channels'} = 'Saját csevegőcsatornák';
    $Self->{Translation}->{'All Chat Channels'} = 'Minden csevegőcsatorna';
    $Self->{Translation}->{'Channel'} = 'Csatorna';
    $Self->{Translation}->{'Requester'} = 'Kérelmező';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'A csevegéskérések betöltése folyamatban van, kérem várjon…';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Általános csevegéskérések a nyilvános felhasználóktól';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Személyes csevegéskérések Önnek';
    $Self->{Translation}->{'My Active Chats'} = 'Saját aktív csevegések';
    $Self->{Translation}->{'Open ticket'} = 'Jegy megnyitása';
    $Self->{Translation}->{'Open company'} = 'Vállalat megnyitása';
    $Self->{Translation}->{'Discard & close this chat'} = 'Eldobás és a csevegés bezárása';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Az összes tevékenység megfigyelése ebben a csevegésben';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Az ügyféltevékenység megfigyelése ebben a csevegésben';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Ne figyelje meg ezt a csevegést';
    $Self->{Translation}->{'Audio Call'} = 'Hanghívás';
    $Self->{Translation}->{'Video Call'} = 'Videohívás';
    $Self->{Translation}->{'Toggle settings'} = 'Beállítások átváltása';
    $Self->{Translation}->{'Leave chat'} = 'Csevegés elhagyása';
    $Self->{Translation}->{'Leave'} = 'Kilépés';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Új telefonos jegy létrehozása ebből a csevegésből, és azután bezárás';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Csevegés hozzáfűzése egy meglévő jegyhez, és azután bezárás';
    $Self->{Translation}->{'Append'} = 'Hozzáfűzés';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'További ügyintézők meghívása, hogy csatlakozzanak a csevegéshez';
    $Self->{Translation}->{'Invite'} = 'Meghívás';
    $Self->{Translation}->{'Change chat channel'} = 'Csevegőcsatorna megváltoztatása';
    $Self->{Translation}->{'Channel change'} = 'Csatornaváltoztatás';
    $Self->{Translation}->{'Switch to participant'} = 'Váltás a résztvevőre';
    $Self->{Translation}->{'Participant'} = 'Résztvevő';
    $Self->{Translation}->{'Switch to an observer'} = 'Váltás egy megfigyelőre';
    $Self->{Translation}->{'Observer'} = 'Megfigyelő';
    $Self->{Translation}->{'Download this Chat'} = 'Csevegés letöltése';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Csatlakozás a meghívott csevegéshez megfigyelőként';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Csatlakozás a meghívott csevegéshez résztvevőként';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Csevegés megnyitása felugró ablakban';
    $Self->{Translation}->{'New window'} = 'Új ablak';
    $Self->{Translation}->{'New Message'} = 'Új üzenet';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter az új sorhoz)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s elhagyta ezt a csevegést.';
    $Self->{Translation}->{'Online agents'} = 'Elérhető ügyintézők';
    $Self->{Translation}->{'Reload online agents'} = 'Elérhető ügyintézők újratöltése';
    $Self->{Translation}->{'Destination channel'} = 'Célcsatorna';
    $Self->{Translation}->{'Open chat'} = 'Csevegés megnyitása';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = 'A felhasználó már elhagyta a csevegést, vagy még nem csatlakozott hozzá.';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Ön többé már nincs ebben a csevegésben. Kattintson erre az üzenetre a csevegődoboz eltávolításához.';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Jelenleg nincsenek csevegéskérések.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Ez véglegesen törölni fogja a csevegéstartalmakat. Szeretné folytatni?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'A csevegéskérést már elfogadta egy másik személy.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Nincs jogosultsága elfogadni ezt a csevegéskérést.';
    $Self->{Translation}->{'Please select a user.'} = 'Válasszon egy felhasználót.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Válasszon egy jogosultsági szintet.';
    $Self->{Translation}->{'Invite Agent.'} = 'Ügyintéző meghívása.';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Válasszon cél csevegőcsatornát.';
    $Self->{Translation}->{'Please select a channel.'} = 'Válasszon egy csatornát.';
    $Self->{Translation}->{'Chat preview'} = 'Csevegés előnézet';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Válasszon egy érvényes csatornát.';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Ügyintéző - ügyfél csevegés.';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Ügyfél - ügyintéző csevegés.';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Ügyintéző - ügyintéző csevegés.';
    $Self->{Translation}->{'Public to agent chat.'} = 'Nyilvános felhasználó - ügyintéző csevegés.';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Nem hagyhatja egyedül az ügyfelet a csevegésben.';
    $Self->{Translation}->{'You'} = 'Ön';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'A csevegését nem sikerült elindítani egy belső hiba miatt.';
    $Self->{Translation}->{'Your chat request was created.'} = 'A csevegéskérése létrejött.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Jelenleg %s nyitott csevegéskérés van.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'A felhasználót már meghívták a csevegésbe!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'Nincsenek elegendő jogosultságai.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'A rendszer nem tudta elmenteni a csevegések sorrendjét.';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Csevegés hozzáfűzése egy jegyhez';
    $Self->{Translation}->{'Append to'} = 'Hozzáfűzés ehhez';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'A csevegés egy új bejegyzésként lesz hozzáfűzve a választott jegyhez.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Csevegés vele';
    $Self->{Translation}->{'Leave Chat'} = 'Csevegés elhagyása';
    $Self->{Translation}->{'User is currently in the chat.'} = 'A felhasználó jelenleg a csevegésben van.';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Jelenlegi csevegőcsatorna';
    $Self->{Translation}->{'Available channels'} = 'Elérhető csatornák';
    $Self->{Translation}->{'Reload'} = 'Újratöltés';
    $Self->{Translation}->{'Update Channel'} = 'Csatorna frissítése';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Részletes keresés';
    $Self->{Translation}->{'Add an additional attribute'} = 'Egy további attribútum hozzáadása';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Részletek nézet';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Oldalankénti értesítések';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Nem találhatók értesítési adatok.';
    $Self->{Translation}->{'Related To'} = 'Ehhez kapcsolódva';
    $Self->{Translation}->{'Select this notification'} = 'Értesítés kijelölése';
    $Self->{Translation}->{'Zoom into'} = 'Nagyítás';
    $Self->{Translation}->{'Dismiss this notification'} = 'Értesítés eltüntetése';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Kijelölt értesítések eltüntetése';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Valóban el szeretné tüntetni a kijelölt értesítéseket?';
    $Self->{Translation}->{'OTRS Notification'} = 'OTRS értesítés';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Jelentések » Hozzáadás';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Új statisztikai jelentés hozzáadása';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Jelentések » Szerkesztés — %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Itt állíthat össze számos statisztikát egy olyan jelentésbe, amelyet előállíthat PDF-ként kézzel vagy automatikusan a beállított alkalmakkor.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Ne feledje, hogy csak akkor választhat ki diagramokat a statisztikák kimeneti formátumaként, ha beállította a PhantomJS böngészőt a rendszeren.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'PhantomJS beállítása';
    $Self->{Translation}->{'General settings'} = 'Általános beállítások';
    $Self->{Translation}->{'Automatic generation settings'} = 'Automatikus előállítás beállításai';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Automatikus előállítás időpontjai (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Annak megadása cron formátumban, hogy a jelentést mikor kell automatikusan előállítani, például „10 1 * * *” esetén minden nap éjjel 1:10-kor.';
    $Self->{Translation}->{'Last automatic generation time'} = 'Utolsó automatikus előállítás ideje';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Következő tervezett automatikus előállítás ideje';
    $Self->{Translation}->{'Automatic generation language'} = 'Automatikus előállítás nyelve';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'A jelentés automatikus előállításakor használandó nyelv.';
    $Self->{Translation}->{'Email subject'} = 'E-mail tárgya';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = 'A tárgy megadása az automatikusan előállított e-mailhez.';
    $Self->{Translation}->{'Email body'} = 'E-mail törzse';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'A szöveg megadása az automatikusan előállított e-mailhez.';
    $Self->{Translation}->{'Email recipients'} = 'E-mail címzettjei';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'A címzett e-mail címeinek megadása (vesszővel elválasztva).';
    $Self->{Translation}->{'Output settings'} = 'Kimeneti beállítások';
    $Self->{Translation}->{'Headline'} = 'Főcím';
    $Self->{Translation}->{'Caption for preamble'} = 'Az előszó felirata';
    $Self->{Translation}->{'Preamble'} = 'Előszó';
    $Self->{Translation}->{'Caption for epilogue'} = 'Az utószó felirata';
    $Self->{Translation}->{'Epilogue'} = 'Utószó';
    $Self->{Translation}->{'Add statistic to report'} = 'Statisztika hozzáadása a jelentéshez';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Jelentések » Áttekintő';
    $Self->{Translation}->{'Statistics Reports'} = 'Statisztikai jelentések';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Statisztikai jelentés szerkesztése: „%s”.';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Statisztikai jelentés törlése: „%s”';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Valóban törölni szeretné ezt a jelentést?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Jelentések » Nézet — %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Ez a statisztikai jelentés beállítási hibákat tartalmaz, és jelenleg nem használható.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Melléklete ennek';
    $Self->{Translation}->{'Attachment Overview'} = 'Melléklet áttekintő';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Ennek a jegynek nincs egyetlen melléklete sem.';
    $Self->{Translation}->{'Hide inline attachments'} = 'Beágyazott mellékletek elrejtése';
    $Self->{Translation}->{'Filter Attachments'} = 'Mellékletek szűrése';
    $Self->{Translation}->{'Select All'} = 'Összes kijelölése';
    $Self->{Translation}->{'Click to download this file'} = 'Kattintson a fájl letöltéséhez';
    $Self->{Translation}->{'Open article in main window'} = 'Bejegyzés megnyitása a főablakban';
    $Self->{Translation}->{'Download selected files as archive'} = 'A kijelölt fájlok letöltése archívumként';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = 'A böngészője nem támogatja a HTML5 videót.';
    $Self->{Translation}->{'Close video call'} = 'Videohívás bezárása';
    $Self->{Translation}->{'Toggle audio'} = 'Hang ki- és bekapcsolása';
    $Self->{Translation}->{'Toggle video'} = 'Videó ki- és bekapcsolása';
    $Self->{Translation}->{'User has declined your invitation.'} = 'A felhasználó visszautasította a meghívását.';
    $Self->{Translation}->{'User has left the call.'} = 'A felhasználó elhagyta a hívást.';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = 'A kapcsolódási kísérlet sikertelen volt. Próbálja újra.';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = 'A médiafolyamhoz történő hozzáférés meg lett tagadva.';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = 'Engedélyezze ezt az oldalt a video- és hangadatfolyam használatához.';
    $Self->{Translation}->{'Requesting media stream...'} = 'Médiafolyam kérése…';
    $Self->{Translation}->{'Waiting for other party to respond...'} = 'Várakozás a másik fél válaszára…';
    $Self->{Translation}->{'Accepting the invitation...'} = 'A meghívás elfogadása…';
    $Self->{Translation}->{'Initializing...'} = 'Előkészítés…';
    $Self->{Translation}->{'Connecting, please wait...'} = 'Kapcsolódás, kérem várjon…';
    $Self->{Translation}->{'Connection established!'} = 'A kapcsolat létrejött!';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s csatlakozott a csevegéshez.';
    $Self->{Translation}->{'Incoming chat requests'} = 'Bejövő csevegéskérések';
    $Self->{Translation}->{'Outgoing chat requests'} = 'Kimenő csevegéskérések';
    $Self->{Translation}->{'Active chats'} = 'Aktív csevegések';
    $Self->{Translation}->{'Closed chats'} = 'Bezárt csevegések';
    $Self->{Translation}->{'Chat request description'} = 'Csevegéskérés leírása';
    $Self->{Translation}->{'Create new ticket'} = 'Új jegy létrehozása';
    $Self->{Translation}->{'Add an article'} = 'Bejegyzés hozzáadása';
    $Self->{Translation}->{'Start a new chat'} = 'Új csevegés indítása';
    $Self->{Translation}->{'Select channel'} = 'Csatorna kiválasztása';
    $Self->{Translation}->{'Add to an existing ticket'} = 'Hozzáadás egy meglévő jegyhez';
    $Self->{Translation}->{'Active Chat'} = 'Aktív csevegés';
    $Self->{Translation}->{'Download Chat'} = 'Csevegés letöltése';
    $Self->{Translation}->{'Chat is being loaded...'} = 'A csevegés betöltése folyamatban…';
    $Self->{Translation}->{'Chat completed'} = 'Csevegés befejezve';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = 'Teljes képernyő';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Erősítse meg a választását';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Az Ön neve';
    $Self->{Translation}->{'Start a new Chat'} = 'Új csevegés indítása';
    $Self->{Translation}->{'Chat complete'} = 'Csevegés befejezve';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Statisztika eltávolítása';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Ha nem meg itt egy címet, akkor a statisztika címe lesz használva.';
    $Self->{Translation}->{'Preface'} = 'Előszó';
    $Self->{Translation}->{'Postface'} = 'Utószó';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Csevegőcsatorna hozzáadva: %s';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Csevegőcsatorna szerkesztve: %s';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Felhőszolgáltatás frissítve: „%s”!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Felhőszolgáltatás beállítása elmentve: „%s”!';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        'Ez a szolgáltatás a(z) %s csomag része. Telepítse ezt az ingyenes kiegészítőt, mielőtt ismét megpróbálná használni azt.';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Csapat-azonosító szükséges!';
    $Self->{Translation}->{'Invalid GroupID!'} = 'Érvénytelen csoportazonosító!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'Nem sikerült lekérni az adatokat a megadott csapat-azonosítóhoz';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nincs hozzárendelve';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        'A(z) %s csevegést bezárták, és sikeresen hozzá lett fűzve a következő jegyhez: %s.';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        'A videohívás funkció le lett tiltva! Ellenőrizze, hogy a(z) %s elérhető-e a jelenlegi rendszerhez.';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s csatlakozott a csevegéshez megfigyelőként.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = 'Ha elfogadja, akkor az összes aktív csevegése be lesz zárva.';
    $Self->{Translation}->{'New request for joining a chat'} = 'Új kérés egy csevegéshez való csatlakozásra';
    $Self->{Translation}->{'Agent invited %s.'} = '%s meghívást kapott egy ügyintézőtől.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s megváltoztatta a csevegőcsatornát erre: %s.';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s átváltott résztvevő módra.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s átváltott megfigyelő módra.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s elutasította a csevegéskérést.';
    $Self->{Translation}->{'Need'} = 'Szükséges';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'Minden értesítés';
    $Self->{Translation}->{'Seen Notifications'} = 'Olvasott értesítések';
    $Self->{Translation}->{'Unseen Notifications'} = 'Olvasatlan értesítések';
    $Self->{Translation}->{'Notification Web View'} = 'Értesítési webnézet';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Ez a név már használatban van, válasszon egy másik nevet.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Egy érvényes cron bejegyzést adjon meg.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = 'Ön nem résztvevő ebben a csevegésben!';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Nem érhető el a külső csevegésekhez. Szeretne elérhető lenni?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Nincs egyetlen hozzárendelt külső csevegőcsatornája sem.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Kijelölt eltüntetése';
    $Self->{Translation}->{'Object Type'} = 'Objektumtípus';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        'Nincs hozzáférése egyetlen csevegőcsatornához sem a rendszeren. Vegye fel a kapcsolatot a rendszergazdával.';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Nyitott csevegéskérések';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s jelentés';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Hiba: ezt a grafikont nem sikerült előállítani: %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Tartalomjegyzék';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'Alapértelmezett csevegőcsatorna';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Aktiválja a csevegés támogatást.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'Ügyintézői előtétprogram-modul regisztráció (csevegéshivatkozás letiltása, ha csevegés szolgáltatás nincs bekapcsolva, vagy az ügyintéző nincs a csevegéscsoportban).';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Ügyintézői csoport, amely csevegéskéréseket és csevegést fogadhat el.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Ügyintézői csoport, amely csevegéskéréseket hozhat létre.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = 'Ügyintézői csoport, amely használhatja a videohívás funkciót a csevegésekben.';
    $Self->{Translation}->{'Agent interface availability.'} = 'Ügyintézői felület elérhetősége.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Ügyintézői felület értesítési modul a nyitott csevegéskérések ellenőrzéséhez.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Annak lehetővé tétele az ügyfeleknek, hogy csak olyan csatornákat válasszanak, amelyek rendelkeznek elérhető ügyintézőkkel.';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Annak lehetővé tétele a nyilvános felhasználóknak, hogy csak olyan csatornákat válasszanak, amelyek rendelkeznek elérhető ügyintézőkkel.';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Lehetővé teszi egy kis formátumú értesítési webnézet meglétét.';
    $Self->{Translation}->{'Chat Channel'} = 'Csevegőcsatorna';
    $Self->{Translation}->{'Chat Channel:'} = 'Csevegőcsatorna:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'Csevegőcsatorna, amely az ebben a várólistában lévő jegyekkel kapcsolatos kommunikációhoz lesz használva.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Csevegőcsatorna a várólista leképezéséhez.';
    $Self->{Translation}->{'Chat overview'} = 'Csevegés áttekintő';
    $Self->{Translation}->{'Chats'} = 'Csevegések';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Törli a régi csevegési naplókat.';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'Oszlop értesítési webnézet szűrők a „Kis” típusú értesítési webnézethez.';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Az ügyintézői felület értesítési webnézetében szűrhető oszlopok. Lehetséges beállítások: 0 = letiltva, 1 = elérhető, 2 = alapértelmezetten engedélyezett.';
    $Self->{Translation}->{'Contact with data'} = 'Adatokkal rendelkező partner';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Csevegőcsatornák létrehozása és kezelése.';
    $Self->{Translation}->{'Create new chat'} = 'Új csevegés létrehozása';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'Ügyfél előtétprogram-modul regisztráció (csevegéshivatkozás letiltása, ha a csevegés szolgáltatás nincs bekapcsolva, vagy nincs elérhető ügyintéző a csevegéshez).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Alapértelmezett ügyintézőnév az ügyfél- és a nyilvános felülethez. Ha engedélyezve van, akkor az ügyintéző valódi neve nem lesz látható az ügyfeleknek vagy a nyilvános felhasználóknak a csevegés használata közben.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Alapértelmezett szöveg az ügyfélfelülethez.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Alapértelmezett szöveg a nyilvános felülethez.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Meghatározza azon ügyintézői beállítások csoportkulcsainak listáját, amelyek láthatóak lesznek az ügyfélfelületen (csak akkor működik, ha a DefaultAgentName le van tiltva). Példa: ha meg szeretné jeleníteni a PreferencesGroups###Language értékét, akkor adja hozzá a Language kulcsot.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Meghatároz egy szöveget az ügyintézői beállításokhoz az ügyfélfelületen (csak akkor működik, ha a DefaultAgentName le van tiltva).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Meghatározza, hogy az ügyfél-felhasználók képesek-e csevegőcsatornákat kiválasztani. Ha nem, akkor a csevegés az alapértelmezett csevegőcsatornában lesz létrehozva.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Meghatározza, hogy egy jegy zárolása szükséges-e egy ügyféllel történő csevegés indításához a jegynagyítás nézetből.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Meghatározza, hogy kell-e számokat hozzáfűzni az alapértelmezett ügyintézőnévhez. Ha engedélyezve van, akkor a DefaultAgentName értékével együtt számok lesznek (például 1, 2, 3, …).';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Meghatározza, hogy a nyilvános felhasználók képesek-e csevegőcsatornákat kiválasztani. Ha nem, akkor a csevegés az alapértelmezett csevegőcsatornában lesz létrehozva.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Meghatározza azt a modult, amely egy értesítést jelenít meg az ügyintézői felületen, ha az ügyintéző elérhető a külső csevegésekhez, de elfelejtette beállítani az előnyben részesített csatornákat.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Meghatározza azt a modult, amely egy értesítést jelenít meg az ügyintézői felületen, ha az ügyintéző nem érhető el az ügyfelekkel való csevegéshez (csak ha a Ticket::Agent::AvailableForChatsAfterLogin „Nem” értékre van állítva).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Azon napok számát határozza meg, amíg egy értesítésnek láthatónak kell lennie az értesítési webnézet képernyőn (a „0” érték azt jeleni, hogy mindig látható).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Meghatározza a csevegésablakok sorrendjét.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Meghatározza a PhantomJS bináris útvonalát. Használhat egy statikus összeállítást a http://phantomjs.org/download.html oldalról a könnyű telepítési folyamathoz.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Meghatározza azt az időtartamot (percben), mielőtt „Nincs válasz” üzenet jelenik meg az ügyfélnek.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        'Meghatározza azt az időtartamot (percben), mielőtt az ügyintéző „távol” lesz inaktivitás miatt.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        'Meghatározza azt az időtartamot (percben), mielőtt az ügyfél „távol” lesz inaktivitás miatt.';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = 'Meghatározza a beállításokat az értekezlet értesítéshez.';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = 'Meghatározza a beállításokat a naptár értesítéshez.';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Meghatározza a beállításokat a jegyértesítéshez.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Meghatározza a forrás dinamikus mezőt a történeti adatok tárolásához.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Meghatározza a cél dinamikus mezőket a történeti adatok tárolásához.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'Dinamikus mezők partner adatai háttérprogram grafikus felület';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'Dinamikus mezők adatbázis háttérprogram grafikus felület';
    $Self->{Translation}->{'Edit contacts with data'} = 'Adatokkal rendelkező partnerek szerkesztése';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Engedélyezi az értesítési webnézet tömeges művelet szolgáltatást az ügyintézői előtétprogramnál, hogy egyszerre több értesítésen tudjon dolgozni.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Csak a felsorolt csoportoknak engedélyezi az értesítési webnézet tömeges művelet szolgáltatást.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Engedélyezi az idővonal nézetet az AgentTicketZoom képernyőn.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'Eseménymodul regisztráció (történeti adatok tárolása dinamikus mezőkben).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = 'Előtétprogram-modul regisztráció az ügyfélfelülethez.';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Előtétprogram-modul regisztráció a nyilvános felülethez.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'HTML tartalomhorgok előállítása a megadott blokkoknál azért, hogy a szűrők használhassák azokat.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Ha engedélyezve van, akkor ellenőrizni fogja az ügyintézők elérhetőségét a bejelentkezéskor. Ha a felhasználó elérhető a külső csevegésekhez, akkor csökkenteni fogja az elérhetőséget kizárólag a belső csevegésekre.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor egy értesítés fog megjelenni minden egyes oldalon, ha a jelenlegi ügyintéző nem érhető el csevegéshez.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor az ügyintézők jegy nélkül is indíthatnak csevegést az ügyféllel.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor az ügyfelek jegy nélkül is indíthatnak csevegést egy ügyintézővel.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor csak a jegy ügyfele indíthat csevegést egy jegynagyítás nézetből.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor az ügyintézői jegynagyítás nézetből indított csevegés csak akkor lesz lehetséges, ha a jegy ügyfele éppen elérhető.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'Ha ez a jelző „Igen” értékre van állítva, akkor az ügyfél jegynagyítás nézetből indított csevegés csak akkor lesz lehetséges, ha vannak elérhető ügyintézők a hozzákapcsolt csevegőcsatornán.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Lehetővé teszi egy ügyféllel történő csevegés indítását az ügyintézői felületről.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Lehetővé teszi egy ügyintézővel történő csevegés indítását az ügyintézői felületről.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Lehetővé teszi egy ügyintézővel történő csevegés indítását az ügyfélfelületről.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Lehetővé teszi egy ügyintézővel történő csevegés indítását a nyilvános felületről.';
    $Self->{Translation}->{'Manage team agents.'} = 'Csapatügyintézők kezelése.';
    $Self->{Translation}->{'My chats'} = 'Saját csevegések';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Az alapértelmezett csevegőcsatorna neve. Ha ez a csatorna nem létezik, akkor automatikusan létre lesz hozva. Ne hozzon létre ugyanolyan nevű csevegőcsatornát, mint az alapértelmezett csevegőcsatorna. Az alapértelmezett csatorna nem lesz megjelenítve, ha a csevegőcsatornák engedélyezve vannak az ügyfélfelületen és a nyilvános felületen. Az összes ügyintéző-ügyintéző csevegés az alapértelmezett csatornában lesz.';
    $Self->{Translation}->{'No agents available message.'} = 'Nincsenek elérhető ügyintézők üzenet.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'Oldalankénti értesítéskorlát a „Kis” értesítési webnézetnél';
    $Self->{Translation}->{'Notification web view'} = 'Értesítési webnézet';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = '„Kis” értesítési webnézet korlát';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Olvasatlan értesítések:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'A napok száma, miután a csevegés törlésre kerül.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Az órák száma, miután a bezárt csevegés törlésre kerül.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Kimenetszűrő a szabványos tt fájlokhoz.';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        'Kimenetszűrő a szükséges dinamikus mező nevek beágyazásához a rejtett beviteli mezőbe.';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Kimenetszűrő a szükséges JavaScript beágyazásához a nézetekbe.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = 'Paraméterek az értesítési webnézet szűrőkhöz.';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'A ChatChannel objektum paraméterei az ügyintézői felület beállítás nézetében.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Paraméterek a kis értesítési nézet oldalaihoz (amelyekben az értesítések megjelennek).';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'Jogosultsági szint egy ügyféllel történő csevegés indításához az ügyintéző jegynagyítás nézetéből.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Kérjük legyen elnéző velünk, amíg az ügyintézőink egyike kezelni tudja a csevegéskérését. Köszönjük a türelmét.';
    $Self->{Translation}->{'Prepend'} = 'Eléfűzés';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Bezárt csevegések eltávolítása, amelyek régebbiek mint a ChatEngine::ChatTTL.';
    $Self->{Translation}->{'Remove old chats.'} = 'Régi csevegések eltávolítása.';
    $Self->{Translation}->{'Resource overview page.'} = 'Erőforrás áttekintő oldal.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Erőforrás áttekintő képernyő.';
    $Self->{Translation}->{'Resources list.'} = 'Erőforrások listája.';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'A meglévő adatokkal rendelkező partnerek kezdeti helyettesítő karakter keresését futtatja az AdminContactWithData modulhoz való hozzáféréskor.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Beállítja, hogy egy csevegéskérés kiküldhető-e az ügyintéző jegynagyítás nézetéből.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Beállítja, hogy egy csevegéskérés kiküldhető-e az ügyfél jegynagyítás nézetéből.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Az összes jegymelléklet megjelenítése';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Megjeleníti a jegyben elérhető összes mellékletet.';
    $Self->{Translation}->{'Start new chat'} = 'Új csevegés indítása';
    $Self->{Translation}->{'Team agents management screen.'} = 'Csapatügyintézők kezelése képernyő.';
    $Self->{Translation}->{'Team list'} = 'Csapatlista';
    $Self->{Translation}->{'Team management screen.'} = 'Csapatkezelés képernyő.';
    $Self->{Translation}->{'Team management.'} = 'Csapatkezelés.';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Az a szöveg, amely ezen SLA kijelölésén jelenik meg a CustomerTicketMessage képernyőn.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Az ügyintézői felület fejlécében megjelenített logó a „business” felszínnél. További leírásért nézze meg az „AgentLogo” bejegyzést.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'Jelenleg nincsenek elérhető csevegés ügyintézők. Próbálja meg később.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'Jelenleg nincsenek elérhető csevegés ügyintézők. A meglévő jegyhez való bejegyzés hozzáadásához kattintson ide:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'Jelenleg nincsenek elérhető csevegés ügyintézők. Egy új jegy létrehozásához kattintson ide:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'Ez a csevegés véget ért. Hagyja el azt, vagy automatikusan le lesz zárva.';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'Ez a csevegés véget ért. Hagyja el azt, vagy automatikusan le lesz zárva. Letöltheti ezt a csevegést.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'Ez a csevegés befejeződött. Most már bezárhatja a csevegésablakot.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'Ez a csevegés befejeződött. Az oldal tetején lévő gomb használatával indíthat egy új csevegést.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Eszköztárelem egy értesítési webnézethez.';
    $Self->{Translation}->{'Video and audio call screen.'} = 'Video- és hanghívás képernyő.';
    $Self->{Translation}->{'View notifications'} = 'Értesítések megtekintése';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        'Az előnyben részesített külső csevegőcsatornák kiválasztása. Értesítést fog kapni az ezekben a csevegőcsatornákban létrejött külső csevegéskérésekről.';

}

1;
