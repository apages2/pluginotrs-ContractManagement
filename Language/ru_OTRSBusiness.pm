# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::ru_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Управление каналами чатов';
    $Self->{Translation}->{'Add Chat Channel'} = 'Добавить канал чата';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Редактировать канал чата';
    $Self->{Translation}->{'Name invalid'} = 'Некорректное имя';
    $Self->{Translation}->{'Need Group'} = 'Требуется группа';
    $Self->{Translation}->{'Need Valid'} = 'Требуется Действительность';
    $Self->{Translation}->{'Comment invalid'} = 'Комментарий некорректен';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Статус облачного сервиса';
    $Self->{Translation}->{'Cloud service availability'} = 'Доступность облачного сервиса';
    $Self->{Translation}->{'Remaining SMS units'} = 'Остаток СМС';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        '';
    $Self->{Translation}->{'Phone field for agent'} = 'Поле "Телефон" для агента';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        '';
    $Self->{Translation}->{'Phone field for customer'} = 'Поле "Телефон" для клиента';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        '';
    $Self->{Translation}->{'Sender string'} = 'Строка отправки';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        '';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Данное поле обязательно и не должно быть длиннее 11 символов';
    $Self->{Translation}->{'Allowed role members'} = 'Разрешенные роли участников';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        '';
    $Self->{Translation}->{'Save configuration'} = 'Сохранить конфигурацию';
    $Self->{Translation}->{'Data Protection Information'} = '';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = '';
    $Self->{Translation}->{'Add contact with data'} = '';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = '';
    $Self->{Translation}->{'Edit contact with data'} = '';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = '';
    $Self->{Translation}->{'Mandatory fields'} = 'Обязательные поля';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Разделенный запятыми список обязательных ключей (необязательно). Ключи  \'Name/Имя\' и \'ValidID\' всегда обязательны и не должны включаться в этот список.';
    $Self->{Translation}->{'Sorted fields'} = 'Отсортированные поля';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Список, разделенных запятыми, ключей в порядке сортировки (по желанию). Ключи, перечисленные здесь идут на первом месте, все остальные поля следуют после них и в алфавитном порядке.';
    $Self->{Translation}->{'Searchable fields'} = 'Поисковые поля';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Список поисковых ключей, разделенных запятыми (по желанию). Ключ \'Name/Имя\' всегда поисковое и его не надо включать в список.';
    $Self->{Translation}->{'Add/Edit'} = 'Добавить/Редактировать';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Тип данных';
    $Self->{Translation}->{'Searchfield'} = 'Поле поиска';
    $Self->{Translation}->{'Listfield'} = '';
    $Self->{Translation}->{'Driver'} = 'Драйвер';
    $Self->{Translation}->{'Server'} = 'Сервер';
    $Self->{Translation}->{'Table / View'} = 'Таблица / Обзор/View';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = '';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Префикс поля поиска';
    $Self->{Translation}->{'Searchsuffix'} = 'Суффикс поля поиска';
    $Self->{Translation}->{'Result Limit'} = '';
    $Self->{Translation}->{'Case Sensitive'} = 'Чувствительно к регистру';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = '';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Обзор ресурсов';
    $Self->{Translation}->{'Manage Calendars'} = 'Управлять календарями';
    $Self->{Translation}->{'Manage Teams'} = '';
    $Self->{Translation}->{'Manage Team Agents'} = '';
    $Self->{Translation}->{'Add new Appointment'} = 'Добавить новое мероприятие';
    $Self->{Translation}->{'Add Appointment'} = 'Добавить мероприятие';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'Filter for calendars'} = 'Фильтр для Календарей';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Копировать публичный URL календаря';
    $Self->{Translation}->{'This is a resource overview page.'} = '';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Не назначен календарь. Добавьте календарь используя экран управления календарями.';
    $Self->{Translation}->{'No teams found.'} = '';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = '';
    $Self->{Translation}->{'Team'} = 'Команда';
    $Self->{Translation}->{'No team agents found.'} = '';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        '';
    $Self->{Translation}->{'Too many active calendars'} = 'Слишком много активных календарей';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Пожалуйста или отключите некоторые или увеличьте предельное количество в настройках.';
    $Self->{Translation}->{'Restore default settings'} = '';
    $Self->{Translation}->{'Week'} = 'Неделя';
    $Self->{Translation}->{'Timeline Month'} = 'Месячный график';
    $Self->{Translation}->{'Timeline Week'} = 'Недельный график';
    $Self->{Translation}->{'Timeline Day'} = 'График дня';
    $Self->{Translation}->{'Jump'} = 'Перейти';
    $Self->{Translation}->{'Appointment'} = 'Мероприятие';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Это повторяющееся мероприятие';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Вы желаете редактировать только текущее мероприятие или все его повторения';
    $Self->{Translation}->{'All occurrences'} = 'Все вхождения/копии';
    $Self->{Translation}->{'Just this occurrence'} = 'Только эту копию';
    $Self->{Translation}->{'Dismiss'} = 'Отклонить';
    $Self->{Translation}->{'Resources'} = '';
    $Self->{Translation}->{'Shown resources'} = '';
    $Self->{Translation}->{'Available Resources'} = '';
    $Self->{Translation}->{'Filter available resources'} = '';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = '';
    $Self->{Translation}->{'Basic information'} = 'Основные данные';
    $Self->{Translation}->{'Resource'} = 'Ресурсы';
    $Self->{Translation}->{'Date/Time'} = 'Дата/Время';
    $Self->{Translation}->{'End date'} = 'Дата окончания';
    $Self->{Translation}->{'Repeat'} = 'Повторение';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = '';
    $Self->{Translation}->{'Team Import'} = '';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        '';
    $Self->{Translation}->{'Upload team configuration'} = '';
    $Self->{Translation}->{'Import team'} = '';
    $Self->{Translation}->{'Filter for teams'} = '';
    $Self->{Translation}->{'Export team'} = '';
    $Self->{Translation}->{'Edit Team'} = '';
    $Self->{Translation}->{'Team with same name already exists.'} = '';
    $Self->{Translation}->{'Permission group'} = 'Групповые права';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = '';
    $Self->{Translation}->{'Teams'} = '';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = '';
    $Self->{Translation}->{'Change Agent Relations for Team'} = '';
    $Self->{Translation}->{'Change Team Relations for Agent'} = '';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'Управление чатами';
    $Self->{Translation}->{'Hints'} = 'Советы';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        '';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Запросы от клиентов в Общем чате';
    $Self->{Translation}->{'My Chat Channels'} = 'Мои каналы чатов';
    $Self->{Translation}->{'All Chat Channels'} = 'Все каналы чатов';
    $Self->{Translation}->{'Channel'} = 'Канал';
    $Self->{Translation}->{'Requester'} = 'Запрашивающая сторона';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Чат - запросы загружаются, пожалуйста, подождите...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Запросы общего чата от неавторизованных пользователей';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Запросы чата персонально для вас';
    $Self->{Translation}->{'My Active Chats'} = 'Мои активные чаты';
    $Self->{Translation}->{'Open ticket'} = 'Открыть заявку';
    $Self->{Translation}->{'Open company'} = '';
    $Self->{Translation}->{'Discard & close this chat'} = 'Отказаться и закрыть этот чат';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Наблюдать за всей активностью в этом чате';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Наблюдать за активностью клиента в этом чате';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Не наблюдать за этим чатом';
    $Self->{Translation}->{'Audio Call'} = '';
    $Self->{Translation}->{'Video Call'} = '';
    $Self->{Translation}->{'Toggle settings'} = '';
    $Self->{Translation}->{'Leave chat'} = 'Покинуть чат';
    $Self->{Translation}->{'Leave'} = 'Покинуть';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Создать новую телефонную заявку из этого чата и закрыть его после этого';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Добавить содержание этого чата к существующей заявке и закрыть его после этого';
    $Self->{Translation}->{'Append'} = '';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Пригласить агента в этот чат';
    $Self->{Translation}->{'Invite'} = 'Пригласить';
    $Self->{Translation}->{'Change chat channel'} = 'Сменить канал чата';
    $Self->{Translation}->{'Channel change'} = 'Канал изменен';
    $Self->{Translation}->{'Switch to participant'} = '';
    $Self->{Translation}->{'Participant'} = '';
    $Self->{Translation}->{'Switch to an observer'} = '';
    $Self->{Translation}->{'Observer'} = '';
    $Self->{Translation}->{'Download this Chat'} = 'Сохранить чат';
    $Self->{Translation}->{'Join invited chat as an observer'} = '';
    $Self->{Translation}->{'Join invited chat as a participant'} = '';
    $Self->{Translation}->{'Open chat in a Popup'} = '';
    $Self->{Translation}->{'New window'} = 'Новое окно';
    $Self->{Translation}->{'New Message'} = 'Новое сообщение';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter для новой строки)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s покинул это обсуждение.';
    $Self->{Translation}->{'Online agents'} = 'Агенты онлайн';
    $Self->{Translation}->{'Reload online agents'} = 'Обновить агентов онлайн';
    $Self->{Translation}->{'Destination channel'} = 'Канал назначения';
    $Self->{Translation}->{'Open chat'} = '';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = '';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        '';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'В настоящий момент нет запросов из чата.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Это окончательно удалит содержимое чата. Хотите продолжить?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Этот запрос чата уже принят другим участником.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = '';
    $Self->{Translation}->{'Please select a user.'} = 'Пожалуйста, выберите пользователя';
    $Self->{Translation}->{'Please select a permission level.'} = 'Пожалуйста, выберите уровень доступа';
    $Self->{Translation}->{'Invite Agent.'} = 'Пригласить агента';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Пожалуйста, выберите целевой канал чата';
    $Self->{Translation}->{'Please select a channel.'} = 'Пожалуйста, выберите канал';
    $Self->{Translation}->{'Chat preview'} = 'Предпросмотр чата';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Пожалуйста, выберите доступный канал';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Чат от агента к клиенту';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Чат от клиента к агенту';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Чат между агентами';
    $Self->{Translation}->{'Public to agent chat.'} = 'Публичный чат с агентом';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Вы не можете оставить клиента в этом чате одного';
    $Self->{Translation}->{'You'} = '';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Ваш чат не может быть запущен из-за внутренней ошибки.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Ваш запрос в чате создан.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'В настоящий момент имеется %s открытых запросов чата.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Пользователь уже приглашен в ваш чат';
    $Self->{Translation}->{'Insufficient permissions.'} = '';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = '';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Добавить обсуждение/Chat к заявке';
    $Self->{Translation}->{'Append to'} = 'Добавить к';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'Содержимое чата будет добавлено в качестве новой заметки к выбранной заявке.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Чат с';
    $Self->{Translation}->{'Leave Chat'} = 'Покинуть чат';
    $Self->{Translation}->{'User is currently in the chat.'} = '';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Текущий канал чата';
    $Self->{Translation}->{'Available channels'} = 'Доступные каналы';
    $Self->{Translation}->{'Reload'} = 'Перезагрузить';
    $Self->{Translation}->{'Update Channel'} = 'Обновить канал';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Детализированный поиск';
    $Self->{Translation}->{'Add an additional attribute'} = 'Добавить дополнительный атрибут';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Подробный обзор';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Уведомлений на страницу';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = '';
    $Self->{Translation}->{'Related To'} = '';
    $Self->{Translation}->{'Select this notification'} = '';
    $Self->{Translation}->{'Zoom into'} = '';
    $Self->{Translation}->{'Dismiss this notification'} = '';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = '';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = '';
    $Self->{Translation}->{'OTRS Notification'} = '';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = '';
    $Self->{Translation}->{'Add New Statistics Report'} = '';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = '';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        '';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        '';
    $Self->{Translation}->{'Configure PhantomJS'} = '';
    $Self->{Translation}->{'General settings'} = '';
    $Self->{Translation}->{'Automatic generation settings'} = '';
    $Self->{Translation}->{'Automatic generation times (cron)'} = '';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        '';
    $Self->{Translation}->{'Last automatic generation time'} = '';
    $Self->{Translation}->{'Next planned automatic generation time'} = '';
    $Self->{Translation}->{'Automatic generation language'} = '';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        '';
    $Self->{Translation}->{'Email subject'} = '';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = '';
    $Self->{Translation}->{'Email body'} = '';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = '';
    $Self->{Translation}->{'Email recipients'} = '';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = '';
    $Self->{Translation}->{'Output settings'} = '';
    $Self->{Translation}->{'Headline'} = '';
    $Self->{Translation}->{'Caption for preamble'} = '';
    $Self->{Translation}->{'Preamble'} = '';
    $Self->{Translation}->{'Caption for epilogue'} = '';
    $Self->{Translation}->{'Epilogue'} = '';
    $Self->{Translation}->{'Add statistic to report'} = '';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = '';
    $Self->{Translation}->{'Statistics Reports'} = '';
    $Self->{Translation}->{'Edit statistics report "%s".'} = '';
    $Self->{Translation}->{'Delete statistics report "%s"'} = '';
    $Self->{Translation}->{'Do you really want to delete this report?'} = '';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = '';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        '';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Вложения из';
    $Self->{Translation}->{'Attachment Overview'} = 'Обзор вложений';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Эта заявка не имеет вложений.';
    $Self->{Translation}->{'Hide inline attachments'} = '';
    $Self->{Translation}->{'Filter Attachments'} = 'Фильтровать вложения';
    $Self->{Translation}->{'Select All'} = 'Выбрать все';
    $Self->{Translation}->{'Click to download this file'} = 'Нажмите для загрузки этого файла';
    $Self->{Translation}->{'Open article in main window'} = 'Открыть сообщение/заметку в главном окне';
    $Self->{Translation}->{'Download selected files as archive'} = 'Загрузить выбранные файлы как архив';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = '';
    $Self->{Translation}->{'Close video call'} = '';
    $Self->{Translation}->{'Toggle audio'} = '';
    $Self->{Translation}->{'Toggle video'} = '';
    $Self->{Translation}->{'User has declined your invitation.'} = '';
    $Self->{Translation}->{'User has left the call.'} = '';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = '';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = '';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = '';
    $Self->{Translation}->{'Requesting media stream...'} = '';
    $Self->{Translation}->{'Waiting for other party to respond...'} = '';
    $Self->{Translation}->{'Accepting the invitation...'} = '';
    $Self->{Translation}->{'Initializing...'} = '';
    $Self->{Translation}->{'Connecting, please wait...'} = '';
    $Self->{Translation}->{'Connection established!'} = '';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s включился в это обсуждение.';
    $Self->{Translation}->{'Incoming chat requests'} = '';
    $Self->{Translation}->{'Outgoing chat requests'} = '';
    $Self->{Translation}->{'Active chats'} = '';
    $Self->{Translation}->{'Closed chats'} = '';
    $Self->{Translation}->{'Chat request description'} = '';
    $Self->{Translation}->{'Create new ticket'} = '';
    $Self->{Translation}->{'Add an article'} = '';
    $Self->{Translation}->{'Start a new chat'} = 'Начать новое обсуждение/chat';
    $Self->{Translation}->{'Select channel'} = '';
    $Self->{Translation}->{'Add to an existing ticket'} = '';
    $Self->{Translation}->{'Active Chat'} = 'Активный чат';
    $Self->{Translation}->{'Download Chat'} = '';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Чат загружается...';
    $Self->{Translation}->{'Chat completed'} = '';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = '';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = '';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Ваше имя';
    $Self->{Translation}->{'Start a new Chat'} = 'Начать новое обсуждение/chat';
    $Self->{Translation}->{'Chat complete'} = 'Чат завершен';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = '';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        '';
    $Self->{Translation}->{'Preface'} = 'Предисловие';
    $Self->{Translation}->{'Postface'} = '';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = '';
    $Self->{Translation}->{'Chat channel %s edited'} = '';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = '';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        '';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = '';
    $Self->{Translation}->{'Invalid GroupID!'} = '';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = '';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        '';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        '';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = '';
    $Self->{Translation}->{'New request for joining a chat'} = '';
    $Self->{Translation}->{'Agent invited %s.'} = '';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '';
    $Self->{Translation}->{'Need'} = '';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = '';
    $Self->{Translation}->{'Seen Notifications'} = '';
    $Self->{Translation}->{'Unseen Notifications'} = '';
    $Self->{Translation}->{'Notification Web View'} = '';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = '';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = '';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = '';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        '';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = '';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = '';
    $Self->{Translation}->{'Object Type'} = '';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        '';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = '';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = '';
    $Self->{Translation}->{'Table of Contents'} = '';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = '';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Включить поддержку обсуждений/chat.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        '';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Группа агентов, которые могут принимать запросы на обсуждение и участвовать в них.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Группы агентов, которые могут создавать запросы на обсуждение.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = '';
    $Self->{Translation}->{'Agent interface availability.'} = '';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Модуль интерфейса агента, проверяющий наличие открытых запросов на обсуждение/chat.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        '';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        '';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = '';
    $Self->{Translation}->{'Chat Channel'} = '';
    $Self->{Translation}->{'Chat Channel:'} = '';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        '';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = '';
    $Self->{Translation}->{'Chat overview'} = 'Обзор обсуждений/Chat overview';
    $Self->{Translation}->{'Chats'} = 'Обсуждения/Chats';
    $Self->{Translation}->{'Cleans up old chat logs.'} = '';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        '';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        '';
    $Self->{Translation}->{'Contact with data'} = '';
    $Self->{Translation}->{'Create and manage chat channels.'} = '';
    $Self->{Translation}->{'Create new chat'} = 'Создать новое обсуждение/chat';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        '';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Имя агента по умолчанию для клиентского и общедоступного интерфейсов. Если параметр включен, реальное имя агента не будет отображаться клиентам или анонимным пользователям при обсуждении.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Текст по умолчанию для интерфейса клиента.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Текст по умолчанию для публичного/общедоступного интерфейса.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        '';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        '';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        '';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        '';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        '';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        '';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        '';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        '';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        '';
    $Self->{Translation}->{'Defines the order of chat windows.'} = '';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = '';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = '';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = '';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Задает исходное динамическое поле для хранения исторических данных.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Задает динамическое поле назначения для хранения исторических данных.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = '';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = '';
    $Self->{Translation}->{'Edit contacts with data'} = '';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        '';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        '';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Включает Хронологический вид в AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        '';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = '';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Frontend module registration для public/публичного/общедоступного интерфейса.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        '';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        '';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        '';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Дает возможность начать обсуждение с клиентом из интерфейса агента.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Дает возможность начать обсуждение с агентом из интерфейса агента.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Дает возможность начать обсуждение с агентом из интерфейса клиента.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Дает возможность начать обсуждение с агентом из общедоступного интерфейса.';
    $Self->{Translation}->{'Manage team agents.'} = '';
    $Self->{Translation}->{'My chats'} = 'Мои обсуждения/chats';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        '';
    $Self->{Translation}->{'No agents available message.'} = '';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        '';
    $Self->{Translation}->{'Notification web view'} = '';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = '';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Непросмотренных уведомлений:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = '';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = '';
    $Self->{Translation}->{'Output filter for standard tt files.'} = '';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        '';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        '';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = '';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        '';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        '';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        '';
    $Self->{Translation}->{'Prepend'} = '';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = '';
    $Self->{Translation}->{'Remove old chats.'} = 'Удалить старые чаты';
    $Self->{Translation}->{'Resource overview page.'} = '';
    $Self->{Translation}->{'Resource overview screen.'} = '';
    $Self->{Translation}->{'Resources list.'} = '';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Выполняет начальный поиск по символу подстановки в списке контактов при доступе к модулю AdminContactWithData.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        '';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        '';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Показать все вложения заявок';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Показать все вложения доступные в заявке.';
    $Self->{Translation}->{'Start new chat'} = 'Начать новое обсуждение/chat';
    $Self->{Translation}->{'Team agents management screen.'} = '';
    $Self->{Translation}->{'Team list'} = '';
    $Self->{Translation}->{'Team management screen.'} = '';
    $Self->{Translation}->{'Team management.'} = '';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Текст, который будет отображаться при выборе этого SLA в CustomerTicketMessage/при создании заявки клиентом.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Логотип, отображаемый в заголовке экрана в интерфейсе агента для окраса "business". Смотрите описание "AgentLogo" для дальнейших пояснений.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        '';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        '';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        '';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        '';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        '';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = '';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        '';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = '';
    $Self->{Translation}->{'Video and audio call screen.'} = '';
    $Self->{Translation}->{'View notifications'} = 'Просмотр уведомлений';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        '';

}

1;
