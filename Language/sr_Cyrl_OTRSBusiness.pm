# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::sr_Cyrl_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Управљање каналима за ћаскања';
    $Self->{Translation}->{'Add Chat Channel'} = 'Додај канал за ћаскања';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Уреди канал за ћаскања';
    $Self->{Translation}->{'Name invalid'} = 'Неисправан назив';
    $Self->{Translation}->{'Need Group'} = 'Обавезна група';
    $Self->{Translation}->{'Need Valid'} = 'Обавезна важност';
    $Self->{Translation}->{'Comment invalid'} = 'Неисправан коментар';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Статус сервиса у облаку';
    $Self->{Translation}->{'Cloud service availability'} = 'Доступност сервиса у облаку';
    $Self->{Translation}->{'Remaining SMS units'} = 'Преостали број СМС';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Провера статуса овог сервиса у облаку тренутно није могућа.';
    $Self->{Translation}->{'Phone field for agent'} = 'Број телефона оператера';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Поље оператера са мобилним телефонским бројем за слање СМС порука. ';
    $Self->{Translation}->{'Phone field for customer'} = 'Број телефона клијента';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Поље клијента са мобилним телефонским бројем за слање СМС порука.';
    $Self->{Translation}->{'Sender string'} = 'Пошиљаоц';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Биће приказано као назив пошиљаоца СМС поруке (не дуже од 11 карактера).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Ово боље је обавезно и не сме бити дуже од 11 карактера.';
    $Self->{Translation}->{'Allowed role members'} = 'Припадници улоге';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Уколико је омогућено, само припадници ових улога ће примити СМС поруке (опционо).';
    $Self->{Translation}->{'Save configuration'} = 'Сачувај конфигурацију';
    $Self->{Translation}->{'Data Protection Information'} = 'Информације о заштити података';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Управљање контакта са подацима';
    $Self->{Translation}->{'Add contact with data'} = 'Додај контакт са подацима';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Молимо унесите појам претраге ѕа контакт са подацима.';
    $Self->{Translation}->{'Edit contact with data'} = 'Уреди контакт са подацима';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Ово су могући атрибути за контакте.';
    $Self->{Translation}->{'Mandatory fields'} = 'Обавезна поља';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Листа обавезних кључева одвојених запетом (опционо). Кључеви \'Name\' и \'ValidID\' су увек обавезни и не морају бити излистани овде.';
    $Self->{Translation}->{'Sorted fields'} = 'Сортирана поља';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Листа кључева за сортирање одвојених запетом (опционо). Кључеви излистани овде увек долазе на првом месту, сва остала поља су сортирана по абецедном редоследу.';
    $Self->{Translation}->{'Searchable fields'} = 'Поља за претрагу';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Листа кључева за претрагу одвојених запетом (опционо). Кључ \'Name\' је увек могуће претражити и не мора бити излистан овде.';
    $Self->{Translation}->{'Add/Edit'} = 'Додај/Уреди';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Тип података';
    $Self->{Translation}->{'Searchfield'} = 'Поље за претрагу';
    $Self->{Translation}->{'Listfield'} = 'Поље за приказ';
    $Self->{Translation}->{'Driver'} = 'Драјвер';
    $Self->{Translation}->{'Server'} = 'Сервер';
    $Self->{Translation}->{'Table / View'} = 'Табела / Преглед';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = 'Мора да буде јединствена колона у табели унета на прегледу табела.';
    $Self->{Translation}->{'CacheTTL'} = 'Истек периода кеша';
    $Self->{Translation}->{'Searchprefix'} = 'Префикс претраге';
    $Self->{Translation}->{'Searchsuffix'} = 'Суфикс претраге';
    $Self->{Translation}->{'Result Limit'} = 'Лимит резултата';
    $Self->{Translation}->{'Case Sensitive'} = 'Зависи од великих и малих слова';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Бројеви СМС примаоца';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Преглед ресурса';
    $Self->{Translation}->{'Manage Calendars'} = 'Управљање календарима';
    $Self->{Translation}->{'Manage Teams'} = 'Управљање тимовима';
    $Self->{Translation}->{'Manage Team Agents'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'Add new Appointment'} = 'Додај нови термин';
    $Self->{Translation}->{'Add Appointment'} = 'Додај термин';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'Filter for calendars'} = 'Филтер за календаре';
    $Self->{Translation}->{'URL'} = 'Адреса';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Ископирај јавну адресу календара (URL)';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ова страница служи за преглед ресурса.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Није пронађен ниједан календар. Молимо прво додајте календар коришћењем екрана Управљање календарима.';
    $Self->{Translation}->{'No teams found.'} = 'Ниједан тим није пронађен.';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = 'Молимо прво додајте тим коришћењем екрана Управљање тимовима.';
    $Self->{Translation}->{'Team'} = 'Тим';
    $Self->{Translation}->{'No team agents found.'} = 'Ниједан оператер није пронађен у тиму.';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        'Молимо прво додајте оператера у тим коришћењем екрана Управљање оператерима у тимовима.';
    $Self->{Translation}->{'Too many active calendars'} = 'Превише активних календара';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Или прво искључите приказ неког календара или повећајте лимит у конфигурацији.';
    $Self->{Translation}->{'Restore default settings'} = 'Вратите подразумевана подешавања';
    $Self->{Translation}->{'Week'} = 'Седмица';
    $Self->{Translation}->{'Timeline Month'} = 'Месечна оса';
    $Self->{Translation}->{'Timeline Week'} = 'Седмична оса';
    $Self->{Translation}->{'Timeline Day'} = 'Дневна оса';
    $Self->{Translation}->{'Jump'} = 'Скочи';
    $Self->{Translation}->{'Appointment'} = 'Термин';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Овај термин се понавља';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Да ли желите да измени само ово или сва понављања?';
    $Self->{Translation}->{'All occurrences'} = 'Сва понављања';
    $Self->{Translation}->{'Just this occurrence'} = 'Само ово понављање';
    $Self->{Translation}->{'Dismiss'} = 'Одбаци';
    $Self->{Translation}->{'Resources'} = 'Ресурси';
    $Self->{Translation}->{'Shown resources'} = 'Приказани ресурси';
    $Self->{Translation}->{'Available Resources'} = 'Доступни ресурси';
    $Self->{Translation}->{'Filter available resources'} = 'Филтер за доступне ресурсе';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Видљиви ресурси (редослед према превуци и пусти)';
    $Self->{Translation}->{'Basic information'} = 'Основне информације';
    $Self->{Translation}->{'Resource'} = 'Ресурс';
    $Self->{Translation}->{'Date/Time'} = 'Датум/време';
    $Self->{Translation}->{'End date'} = 'Датум краја';
    $Self->{Translation}->{'Repeat'} = 'Понављање';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Додај тим';
    $Self->{Translation}->{'Team Import'} = 'Увоз тима';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Овде можете учитати конфигурациону датотеку за увоз тима у ваш систем. Фајл мора бити у истом .yml формату који је могуће добити извозом у екрану управљања тимовима.';
    $Self->{Translation}->{'Upload team configuration'} = 'Учитај конфигурацију тима';
    $Self->{Translation}->{'Import team'} = 'Увези тим';
    $Self->{Translation}->{'Filter for teams'} = 'Филтер за тимове';
    $Self->{Translation}->{'Export team'} = 'Извези тим';
    $Self->{Translation}->{'Edit Team'} = 'Измени тим';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Тим са истим називом већ постоји.';
    $Self->{Translation}->{'Permission group'} = 'Група приступа';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Филтер за оператере';
    $Self->{Translation}->{'Teams'} = 'Тимови';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Измени припадност оператера тиму';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Измени припадност тиму оператерима';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'Управљање ћаскањима';
    $Self->{Translation}->{'Hints'} = 'Савети';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Напомињемо: овај прозор ће се користити за било који захтев у вези ћаскања. Уколико напуштате менаџер ћаскања (нпр. коришћењем навигације при врху стране), покретање новог ћаскања или било које друге функције у вези истог може довести до освежавања овог прозора. Препоручљиво је да држите менаџер ћаскања отворен у овом конкретном прозору.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Општи захтеви за ћаскања од клијената';
    $Self->{Translation}->{'My Chat Channels'} = 'Моји канали за ћаскања';
    $Self->{Translation}->{'All Chat Channels'} = 'Сви канали за ћаскања';
    $Self->{Translation}->{'Channel'} = 'Канал';
    $Self->{Translation}->{'Requester'} = 'Наручилац';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Захтеви за ћаскање се учитавају, молимо сачекајте...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Општи захтеви за ћаскања од јавних корисника';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Лични захтеви за ћаскања за вас';
    $Self->{Translation}->{'My Active Chats'} = 'Моја активна ћаскања';
    $Self->{Translation}->{'Open ticket'} = 'Отвори тикет';
    $Self->{Translation}->{'Open company'} = 'Отвори фирму';
    $Self->{Translation}->{'Discard & close this chat'} = 'Затвори и обриши ово ћаскање';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Надгледање свих активности у овом ћаскању';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Надгледање клијентских активности у овом ћаскању';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Без надгледања активности у овом ћаскању';
    $Self->{Translation}->{'Audio Call'} = 'Аудио позив';
    $Self->{Translation}->{'Video Call'} = 'Видео позив';
    $Self->{Translation}->{'Toggle settings'} = 'Преклопи подешавања';
    $Self->{Translation}->{'Leave chat'} = 'Напусти ћаскање';
    $Self->{Translation}->{'Leave'} = 'Напусти';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Креирај нови телефонски тикет од овог ћаскања и затвори га';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Додај ово ћаскање постојећем тикету и затвори га';
    $Self->{Translation}->{'Append'} = 'Додај';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Позовите додатног оператера да се придужи ћаскању';
    $Self->{Translation}->{'Invite'} = 'Позив';
    $Self->{Translation}->{'Change chat channel'} = 'Промени канал за ћаскања';
    $Self->{Translation}->{'Channel change'} = 'Промена канала';
    $Self->{Translation}->{'Switch to participant'} = 'Пређи на учесника';
    $Self->{Translation}->{'Participant'} = 'Учесник';
    $Self->{Translation}->{'Switch to an observer'} = 'Пређи на посматрача';
    $Self->{Translation}->{'Observer'} = 'Посматрач';
    $Self->{Translation}->{'Download this Chat'} = 'Преузми ово ћаскање';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Придружи се ћаскању као посматрач';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Придружи се ћаскању као учесник';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Отвори ћаскање у прозору';
    $Self->{Translation}->{'New window'} = 'Нови прозор';
    $Self->{Translation}->{'New Message'} = 'Нова порука';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter за проред)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s је напустио ово ћаскање.';
    $Self->{Translation}->{'Online agents'} = 'Оператери на вези';
    $Self->{Translation}->{'Reload online agents'} = 'Освежи оператере на вези';
    $Self->{Translation}->{'Destination channel'} = 'Канал одредишта';
    $Self->{Translation}->{'Open chat'} = 'Отвори ћаскање';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = 'Корисник је већ напустио ћаскање или се још није придружио.';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Више нисте део овог ћаскања. Кликните на ову поруку за уклањање прозора.';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Тренутно нема захтева за ћаскање.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Ово ће трајно уклонити садржај ћаскања. Да ли желите да наставите?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Овај захтев за ћаскање је већ прихваћен од стране другог корисника.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Немате дозволу да прихватите овај захтев за ћаскање.';
    $Self->{Translation}->{'Please select a user.'} = 'Молимо да одаберете корисника.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Молимо да одаберете ниво приступа.';
    $Self->{Translation}->{'Invite Agent.'} = 'Позови оператера.';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Молимо да одаберете канал одредишта.';
    $Self->{Translation}->{'Please select a channel.'} = 'Молимо да одаберете канал.';
    $Self->{Translation}->{'Chat preview'} = 'Приказ ћаскања';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Молимо да одаберете важећи канал.';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Ћаскање измећу оператера и клијента.';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Ћаскање између клијента и оператера.';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Ћаскање између оператера.';
    $Self->{Translation}->{'Public to agent chat.'} = 'Ћаскање између јавних корисника и оператера.';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Не можете оставити клијента самог у ћаскању.';
    $Self->{Translation}->{'You'} = 'Ви';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Ваше ћаскање није могло бити покренуто због интерне грешке.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Ваш захтев за ћаскање је креиран.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Тренутно има %s отворених захтева за ћаскање.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Корисник је већ позван у ваше ћаскање!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'Недовољне дозволе.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'Систем није успео да сними ваш редослед ћаскања.';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Додајте ћаскање у тикет';
    $Self->{Translation}->{'Append to'} = 'Додајте у';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'Ћаскање ће бити додато као нови чланак у изабраном тикету.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Ћаскање са';
    $Self->{Translation}->{'Leave Chat'} = 'Напусти ћаскање';
    $Self->{Translation}->{'User is currently in the chat.'} = 'Корисник је тренутно у ћаскању.';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Тренутни канал за ћаскања';
    $Self->{Translation}->{'Available channels'} = 'Расположиви канали';
    $Self->{Translation}->{'Reload'} = 'Освежи';
    $Self->{Translation}->{'Update Channel'} = 'Промени канал';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Детаљна претрага';
    $Self->{Translation}->{'Add an additional attribute'} = 'Додај још један атрибут';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Детаљни приказ';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Обавештења по страни';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Нису пронађена обавештења.';
    $Self->{Translation}->{'Related To'} = 'Повезано са';
    $Self->{Translation}->{'Select this notification'} = 'Изабери ово обавештење';
    $Self->{Translation}->{'Zoom into'} = 'Увећај';
    $Self->{Translation}->{'Dismiss this notification'} = 'Oдбаци ово обавештење';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Одбаци изабрана обавештења';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Да ли заиста желите да одбаците изабрана обавештења?';
    $Self->{Translation}->{'OTRS Notification'} = 'OTRS обавештење';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Извештаји » Додај';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Додај нови статистички извештај';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Извештаји » Измени — %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Овде можете искомбиновати више статистика у извештај који можете генерисати као PDF ручно или аутоматски у одређено време.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Напомињемо да можете изабрати графиконе као излазни формат статистике уколико сте подесили PhantomJS на вашем систему.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'Подеси PhantomJS';
    $Self->{Translation}->{'General settings'} = 'Општа подешавања';
    $Self->{Translation}->{'Automatic generation settings'} = 'Подешавање аутоматског генерисања';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Време аутоматског генерисања (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Дефинишите када ће извештај бити аутоматски генерисан у cron формату, нпр. "10 1 * * *" за сваки дан у 01:10 ујутру.';
    $Self->{Translation}->{'Last automatic generation time'} = 'Време последњег аутоматског генерисања';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Време следећег планираног аутоматског генерисања';
    $Self->{Translation}->{'Automatic generation language'} = 'Језик аутоматског генерисања';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'Језик који ће бити коришћен приликом аутоматског генерисања извештаја.';
    $Self->{Translation}->{'Email subject'} = 'Предмет имејла';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = 'Дефинише предмет за аутоматско генерисан имејл.';
    $Self->{Translation}->{'Email body'} = 'Имејл порука';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'Дефинише текст аутоматско генерисаног имејла.';
    $Self->{Translation}->{'Email recipients'} = 'Примаоци имејла';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'Дефинише адресе примаца (одвојене запетом).';
    $Self->{Translation}->{'Output settings'} = 'Подешавања излаза';
    $Self->{Translation}->{'Headline'} = 'Наслов';
    $Self->{Translation}->{'Caption for preamble'} = 'Поднаслов увода';
    $Self->{Translation}->{'Preamble'} = 'Увод';
    $Self->{Translation}->{'Caption for epilogue'} = 'Поднаслов закључка';
    $Self->{Translation}->{'Epilogue'} = 'Закључак';
    $Self->{Translation}->{'Add statistic to report'} = 'Додај статистику у извештај';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Извештаји » Преглед';
    $Self->{Translation}->{'Statistics Reports'} = 'Статистички извештаји';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Уреди статистички извештај "%s".';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Обриши статистички извештај "%s"';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Да ли заиста желите да обришете овај извештај?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Извештаји » Погледај — %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Овај статистички извештај садржи конфигурационе грешке и сад се не може користити.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Прилози уз';
    $Self->{Translation}->{'Attachment Overview'} = 'Преглед прилога';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Овај тикет нема прилоге.';
    $Self->{Translation}->{'Hide inline attachments'} = 'Сакри непосредне прилоге';
    $Self->{Translation}->{'Filter Attachments'} = 'Филтрирај прилоге';
    $Self->{Translation}->{'Select All'} = 'Изабери све';
    $Self->{Translation}->{'Click to download this file'} = 'Кликните за преузимање датотеке';
    $Self->{Translation}->{'Open article in main window'} = 'Отвори чланак у главном прозору';
    $Self->{Translation}->{'Download selected files as archive'} = 'Преузимање изабраних датотека као архив';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = 'Ваш прегледач не подржава HTML5 видео.';
    $Self->{Translation}->{'Close video call'} = 'Прекини видео позив';
    $Self->{Translation}->{'Toggle audio'} = 'Искључи/укључи звук';
    $Self->{Translation}->{'Toggle video'} = 'Искључи/укључи видео';
    $Self->{Translation}->{'User has declined your invitation.'} = 'Корисник је одбио ваш позив.';
    $Self->{Translation}->{'User has left the call.'} = 'Корисник је напустио позив.';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = 'Покушај успостављања везе није успео. Молимо покушајте поново.';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = 'Приступ медија стриму је одбијен.';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = 'Молимо омогућите овој страници приступ вашем видео и аудио стриму.';
    $Self->{Translation}->{'Requesting media stream...'} = 'Захтев за медија стрим...';
    $Self->{Translation}->{'Waiting for other party to respond...'} = 'Чекање на одговор друге стране...';
    $Self->{Translation}->{'Accepting the invitation...'} = 'Прихварање позивнице...';
    $Self->{Translation}->{'Initializing...'} = 'Иницијализација...';
    $Self->{Translation}->{'Connecting, please wait...'} = 'Повезивање, молимо сачекајте...';
    $Self->{Translation}->{'Connection established!'} = 'Веза успостављена!';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s се придружио овом ћаскању.';
    $Self->{Translation}->{'Incoming chat requests'} = 'Долазни захтеви за ћаскање';
    $Self->{Translation}->{'Outgoing chat requests'} = 'Одлазни захтеви за ћаскање';
    $Self->{Translation}->{'Active chats'} = 'Активна ћаскања';
    $Self->{Translation}->{'Closed chats'} = 'Затворена ћаскања';
    $Self->{Translation}->{'Chat request description'} = 'Опис захтева за ћаскање';
    $Self->{Translation}->{'Create new ticket'} = 'Креирај нови тикет';
    $Self->{Translation}->{'Add an article'} = 'Додај чланак';
    $Self->{Translation}->{'Start a new chat'} = 'Почни ново ћаскање';
    $Self->{Translation}->{'Select channel'} = 'Изабери канал';
    $Self->{Translation}->{'Add to an existing ticket'} = 'Додај постојећем тикету';
    $Self->{Translation}->{'Active Chat'} = 'Активно ћаскање';
    $Self->{Translation}->{'Download Chat'} = 'Преузми ћаскање';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Ћаскање се учитава...';
    $Self->{Translation}->{'Chat completed'} = 'Ћаскање завршено';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = 'Цео екран';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Молимо потврди ваш избор';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Ваше име';
    $Self->{Translation}->{'Start a new Chat'} = 'Почни ново ћаскање';
    $Self->{Translation}->{'Chat complete'} = 'Ћаскање завршено';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Уклони статистику';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Уколико не дефинишете наслов овде, биће искоришћен назив статистике.';
    $Self->{Translation}->{'Preface'} = 'Предговор';
    $Self->{Translation}->{'Postface'} = 'Закључак';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Додат канал за ћаскање %s';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Измењен канал за ћаскање';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Освежен сервис у облаку "%s"!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Сачувана конфигурација сервиса у облаку "%s"!';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        'Ова функција је део пакета %s. Молимо инсталирајте овај бесплатан додатни модул пре поновног коришћења.';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Потребан ИД тима!';
    $Self->{Translation}->{'Invalid GroupID!'} = 'Неисправан GroupID!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'Не могу прибавити податке за дати TeamID';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Недодељено';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        'Ћаскање %s је затворено и успешно је додато у тикет %s.';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        'Функција видео позива је искључена! Молимо проверите да ли је %s доступан за ваш систем.';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s се придружио овом ћаскању као посматрач.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = 'Уколико прихватите, сви активни позиви ће бити прекинути.';
    $Self->{Translation}->{'New request for joining a chat'} = 'Нов захтев за придруживање ћаскању';
    $Self->{Translation}->{'Agent invited %s.'} = 'Оператер је позвао %s.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s је променио канал за ћаскање на %s';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s је прешао на мод учесника.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s је прешао на мод посматрача.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s је одбио захтев за ћаскање.';
    $Self->{Translation}->{'Need'} = 'Потребан';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'Сва обавештења';
    $Self->{Translation}->{'Seen Notifications'} = 'Виђена обавештења';
    $Self->{Translation}->{'Unseen Notifications'} = 'Невиђена обавештења';
    $Self->{Translation}->{'Notification Web View'} = 'Веб приказ обавештења';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Ово име је већ употребљено, молимо изаберите неко друго.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Молимо да унесете исправно cron правило.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = 'Ви нисте учесник у овом ћаскању!';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Нисте доступни за ћаскања са клијентима. Да ли желите да будете доступни?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Немате подешених екстерних канала за ћаскања.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Одбаци изабрано';
    $Self->{Translation}->{'Object Type'} = 'Тип објекта';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        'Немате приступ каналима за ћаскање у систему. Молимо контактирајте администратора.';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Отворени захтеви за ћаскања';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s извештај';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Грешка приликом генерисања овог графикона: %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Садржај';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'Подразумевани канал за ћаскања';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Активира ћаскање.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'Регистрација модула приступа у интерфејсу оператера (онемогућава везу за ћаскања уколико се не користи или оператер не припада одговарајућој групи).';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Групе оператера које могу прихватити захтеве за ћаскање.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Групе оператера које могу креирати захтеве за ћаскање.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = 'Група оператера која може да користи функцију видео позива.';
    $Self->{Translation}->{'Agent interface availability.'} = 'Доступност у интерфејсу оператера.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Модул интерфејса оператера за проверу отворених захтева за ћаскање.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Дозволи клијенту да изабере само канале који имау доступне оператере.';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Дозволи јавном кориснику да изабере само канале који имају доступне оператере.';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Дозвољава приступ умањеном формату веб приказа обавештења.';
    $Self->{Translation}->{'Chat Channel'} = 'Канал за ћаскања';
    $Self->{Translation}->{'Chat Channel:'} = 'Канал за ћаскања:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'Канал за ћаскања који ће бити коришћен за комуникацију у вези тикета у овом реду.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Мапа канала за ћаскања и редова.';
    $Self->{Translation}->{'Chat overview'} = 'Преглед ћаскања';
    $Self->{Translation}->{'Chats'} = 'Ћаскања';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Чишћење застарелих ћаскања.';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'Филтери колона за умањени веб приказ обавештења.';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Колоне које могу бити филтриране у веб приказу обавештења. Могућа подешавања: 0 = Онемогучено, 1 = Достпуно, 2 = Подразумевано омогућено.';
    $Self->{Translation}->{'Contact with data'} = 'Контакт са подацима';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Креирање и управљање каналима за ћаскања.';
    $Self->{Translation}->{'Create new chat'} = 'Направи ново ћаскање';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'Регистрација модула приступа у интерфејсу клијента (онемогућава везу за ћаскања уколико се не користи или нема доступних оператера).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Подразумевано име оператера у интерфејсу клијента и јавном интерфејсу. Уколико је омогућено, право име оператера неће бити видљиво за клијенте/јавне кориснике за време ћаскања.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Подразумевани текст за интерфејс клијента.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Подразумевани текст за јавни кориснички интерфејс.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Дефинише листу кључева подешавања оператера која ће бити видљива у интерфејсу клијента (функционише само уколико је DefaultAgentName онемогућено). Пример: уколико желите да прикажете PreferencesGroups###Language, додајте Language.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Дефинише текст за подешавања оператера у интерфејсу клијента (функционише само уколико је DefaultAgentName онемогућено).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Дефинише да ли клијенти могу да изаберу канал ћаскања. Уколико не могу, ћаскања ће бити креирана у подразумеваном каналу.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Дефинише да ли је закључавање тикета обавезно пре него што је могуће покренути ћаскање са клијентом из детаљног прегледа тикета.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Дефинише да ли ће бројеви бити придодати DefaultAgentName. Уколико је омогућено, DefaultAgentName ће бити приказано са бројевима (нпр. 1, 2, 3, ...).';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Дефинише да ли јавни корисници могу да изаберу канал ћаскања. Уколико не могу, ћаскања ће бити креирана у подразумеваном каналу.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Дефинише модул за приказ упозорења у интерфејсу оператера, уколико је оператер доступан за ћаскања са клијентима, али нема подешених канала.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Дефинише модул за приказ обавештења у интерфејсу оепратера, уколико оепратер није доступан за ћаскања са клијентима (само ако је Ticket::Agent::AvailableForChatsAfterLogin подешено на Не).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Дефинише број дана колико дуго ће обавештење бити приказано у веб прегледу (вредност \'0\' значи да ће увек бити приказано).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Дефинише редослед прозора за ћаскање.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Дефинише путању до PhantomJS програма. Можете користити статичку верзију програма са http://phantomjs.org/download.html за једноставну инсталацију.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Дефинише период времена (у минутима) после ког ће порука да нема одговора бити приказана клијенту.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        'Дефинише период времена (у минутима) после ког ће оператер бити означен као "одсутан".';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        'Дефинише период времена (у минутима) после ког ће корисник бити означен као "одсутан".';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = 'Дефинише подешавања за обавештења о терминима.';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = 'Дефинише подешавања за обавештења о календарима.';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Дефинише подешавања за обавештења о тикетима.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Дефинише изворно динамичко поље за чување информација.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Дефинише циљно динамичко поље за чување информација.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'Позадински приказ динамичког поља са контактом';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'Позадински приказ динамичког поља базе података';
    $Self->{Translation}->{'Edit contacts with data'} = 'Уређивање контаката са подацима';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Омогућава масовну акцију у веб приказу обавештења у интерфејсу оператера на више од једне ставке истовремено.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Омогућава својство масовне акције у веб приказу обавештења само за излистане групе.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Омогућава хронолошки приказ у AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'Регистрација модула догађаја (чување информација у динамичким пољима).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = 'Регистрација модула за интерфејс клијента.';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Регистрација приступног модула за јавни интерфејс.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'Генерише HTML коментаре за одговарајуће блокове да би филтери могли да их користе.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Уколико је омогућено, проверава доступност оператера по логовању. Уколико је оператер доступан за ћаскања са клијентима, ограничиће доступност само на ћаскања са оператерима.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Уколико је ово подешено на Да и оператер није доступан за ћаскања, биће приказано обавештење на свакој страни.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Уколико је ово подешено на Да, оператери могу да покрену ћаскање са клијентом без тикета.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Уколико је ово подешено на Да, клијенти могу да покрену ћаскање са оператером без тикета.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Уколико је ово подешено на Да, само клијент тикета може покренути ћаскање из детаљног приказа.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Уколико је ово подешено на Да, покретање ћаскања из детаљног приказа тикета ће бити могуће само уколико је клијент на вези.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'Уколико је ово подешено на Да, покретање ћаскања из детаљног приказа тикета ће бити могуће само уколико има доступних оператера у одговарајућем каналу.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Омогућава покретање ћаскања са клијентом из интерфејса оператера.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Омогућава покретање ћаскања са оператером из оператерског интерфејса.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Омогућава покретање ћаскања са оператером из интерфејса клијента.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Омогућава покретање ћаскања са оператером из јавног интерфејса.';
    $Self->{Translation}->{'Manage team agents.'} = 'Управљање оператерима у тимовима.';
    $Self->{Translation}->{'My chats'} = 'Моја ћаскања';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Назив подразумеваног канала за ћаскања. Уколико овај канал не постоји, биће креиран аутоматски. Молимо вас да не креирате канал са истим називом као подразумевани. Подразумевани канал неће бити приказан уколико су канали омогућени у интерфејсу клијента. Сва ћаскања измећу оператера ће бити у подразумеваном каналу.';
    $Self->{Translation}->{'No agents available message.'} = 'Порука о недоступности оператера.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'Ограничење обавештења по страни за умањени веб приказ.';
    $Self->{Translation}->{'Notification web view'} = 'Веб приказ обавештења';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'Ограничење умањеног веб приказа обавештења';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Невиђена обавештења:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'Број дана после кога ће ћаскање бити обрисано.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Број сати после ког ће затворена ћаскања бити обрисана.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Излазни филтер за стандарне TT датотеке.';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        'Излазни филтер за убацивање неопходних скривених динамичких поља.';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Излазни филтер за убацивање неопходног JavaScript у прегледе.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = 'Параметри за филтере у веб прикази обавештења.';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'Параметри за подешавање канала за ћаскање у интерфејсу оператера.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Параметри страница (на којима су обавештења приказана) у умањеном веб приказу обавештења.';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'Ниво приступа неопходан за покретање ћаскања са клијентом из детаљног приказа тикета у интерфејсу оператера.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Молимо сачекајте док неко од наших оператера не буде у могућности да обради ваш захтев. Хвала на стрпљењу.';
    $Self->{Translation}->{'Prepend'} = 'Додај';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Уклања затворена ћаскања старија од ChatEngine::ChatTTL.';
    $Self->{Translation}->{'Remove old chats.'} = 'Уклања стара ћаскања.';
    $Self->{Translation}->{'Resource overview page.'} = 'Страница прегледа ресурса.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Екран прегледа ресурса.';
    $Self->{Translation}->{'Resources list.'} = 'Листа ресурса.';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Покреће иницијалну претрагу за постојећим контактима са подацима приликом приступа модулу AdminContactWithData.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Дефинише да ли захтев за ћаскање може бити послат из детаљног прегледа тикета у интерфејсу оператера.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Дефинише да ли захтев за ћаскање може бити послат из детаљног прегледа тикета у интерфејсу клијента.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Прикажи све прилоге тикета';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Приказује све расположиве прилоге за тикет.';
    $Self->{Translation}->{'Start new chat'} = 'Почни ново ћаскање';
    $Self->{Translation}->{'Team agents management screen.'} = 'Екран управљања оператерима у тимовима.';
    $Self->{Translation}->{'Team list'} = 'Листа тимова';
    $Self->{Translation}->{'Team management screen.'} = 'Екран управљања тимовима.';
    $Self->{Translation}->{'Team management.'} = 'Управљање тимом.';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Текст који ће бити приказан приликом селекције SLA у CustomerTicketMessage.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Лого приказан у заглављу интерфејса оператера за изглед "business". Погледајте "AgentLogo" за детаљнији опис.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'У овом тренутку нема слободних оператера. Молимо покушајте касније.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'У овом тренутку нема доступних оператера. За додавање чланка постојећем тикету, молимо кликните овде:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'У овом тренутку нема доступних оператера. За креирање новог тикета, молимо кликните овде:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'Ово ћаскање је завршено. Можете га напустити или ће бити затворено аутоматски.';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'Ово ћаскање је завршено. Можете га напустити или ће бити затворено аутоматски. Можете преузети ово ћаскање.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'Ово ћаскање је завршено. Можете затворити овај прозор.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'Ово ћаскање је завршено. Можете покренути ново коришћењем везе при врху ове стране.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Ставка алатне линије за веб приказ обавештења.';
    $Self->{Translation}->{'Video and audio call screen.'} = 'Екран видео и аудио позива.';
    $Self->{Translation}->{'View notifications'} = 'Преглед обавештења';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        'Ваш избор канала за ћаскање са клијентима. Бићете обавештени о захтевима за ћаскања у овим каналима.';

}

1;
