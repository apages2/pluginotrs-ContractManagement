# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::zh_CN_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = '管理聊天频道';
    $Self->{Translation}->{'Add Chat Channel'} = '添加聊天频道';
    $Self->{Translation}->{'Edit Chat Channel'} = '编辑聊天频道';
    $Self->{Translation}->{'Name invalid'} = '无效的名字';
    $Self->{Translation}->{'Need Group'} = '需要群组';
    $Self->{Translation}->{'Need Valid'} = '需要有效值';
    $Self->{Translation}->{'Comment invalid'} = '无效的注释';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = '云服务状态';
    $Self->{Translation}->{'Cloud service availability'} = '云服务可用性';
    $Self->{Translation}->{'Remaining SMS units'} = '剩余短信次数';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        '当前伏法检查该云服务器的状态。';
    $Self->{Translation}->{'Phone field for agent'} = '服务人员电话字段';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        '应填写用于通过短信发送消息的手机号码的服务人员数据字段。';
    $Self->{Translation}->{'Phone field for customer'} = '客户电话字段';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        '应填写用于通过短信发送消息的手机号码的客户数据字段。';
    $Self->{Translation}->{'Sender string'} = '发件人字段';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        '显示为短信发件人名称（不超过11个字符）。';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        '这个字段是必须的，并且不能超过11个字符长度。';
    $Self->{Translation}->{'Allowed role members'} = '许可的角色成员';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        '如果选择了本选项，则只有分配给这些角色的用户才能接收到短信消息（可选）。';
    $Self->{Translation}->{'Save configuration'} = '保存配置';
    $Self->{Translation}->{'Data Protection Information'} = '数据保护信息';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = '联系信息管理';
    $Self->{Translation}->{'Add contact with data'} = '添加联系信息';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = '请输入搜索条件以便检索联系信息.';
    $Self->{Translation}->{'Edit contact with data'} = '编辑联系信息';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = '这些是可用于联系的数据属性。';
    $Self->{Translation}->{'Mandatory fields'} = '必须的字段';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        '逗号分隔的必填字段列表（可选）。\'Name\'和\'ValidID\'始终是必填字段，无论在这里有没有。';
    $Self->{Translation}->{'Sorted fields'} = '排序字段';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        '逗号分隔的排序字段列表（可选）。在这里列出的字段会先出现，其它的字段按字母顺序随后。';
    $Self->{Translation}->{'Searchable fields'} = '可搜索的字段';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        '逗号分隔的可搜索字段列表（可选）。\'Name\'始终是可搜索的，无论在这里有没有。';
    $Self->{Translation}->{'Add/Edit'} = '添加/编辑';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = '数据类型';
    $Self->{Translation}->{'Searchfield'} = '搜索字段';
    $Self->{Translation}->{'Listfield'} = '列表区域';
    $Self->{Translation}->{'Driver'} = '驱动程序';
    $Self->{Translation}->{'Server'} = '服务器';
    $Self->{Translation}->{'Table / View'} = '表/视图';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = '';
    $Self->{Translation}->{'CacheTTL'} = '缓存生存时间(CacheTTL)';
    $Self->{Translation}->{'Searchprefix'} = '搜索前缀';
    $Self->{Translation}->{'Searchsuffix'} = '搜索后缀';
    $Self->{Translation}->{'Result Limit'} = '限制返回结果';
    $Self->{Translation}->{'Case Sensitive'} = '区分大小写';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = '收件人短信号码';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = '资源概览';
    $Self->{Translation}->{'Manage Calendars'} = '管理日历';
    $Self->{Translation}->{'Manage Teams'} = '管理团队';
    $Self->{Translation}->{'Manage Team Agents'} = '管理团队服务人员';
    $Self->{Translation}->{'Add new Appointment'} = '添加新的预约';
    $Self->{Translation}->{'Add Appointment'} = '添加预约';
    $Self->{Translation}->{'Calendars'} = '日历';
    $Self->{Translation}->{'Filter for calendars'} = '过滤日历';
    $Self->{Translation}->{'URL'} = '网址';
    $Self->{Translation}->{'Copy public calendar URL'} = '复制公共日历网址';
    $Self->{Translation}->{'This is a resource overview page.'} = '这是资源概览页。';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        '没有找到日历。请先通过管理日历界面添加一个日历。';
    $Self->{Translation}->{'No teams found.'} = '';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = '';
    $Self->{Translation}->{'Team'} = '团队';
    $Self->{Translation}->{'No team agents found.'} = '';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        '';
    $Self->{Translation}->{'Too many active calendars'} = '激活的日历太多';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '请关闭一些日历或者在配置中增加限制数。';
    $Self->{Translation}->{'Restore default settings'} = '恢复默认设置';
    $Self->{Translation}->{'Week'} = '周';
    $Self->{Translation}->{'Timeline Month'} = '月时间表';
    $Self->{Translation}->{'Timeline Week'} = '周时间表';
    $Self->{Translation}->{'Timeline Day'} = '每日时间表';
    $Self->{Translation}->{'Jump'} = '跳转';
    $Self->{Translation}->{'Appointment'} = '预约';
    $Self->{Translation}->{'This is a repeating appointment'} = '这是一个重复的预约';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        '你想仅编辑本次预约的时间还是重复预约所有的时间？';
    $Self->{Translation}->{'All occurrences'} = '所有预约';
    $Self->{Translation}->{'Just this occurrence'} = '仅本次预约';
    $Self->{Translation}->{'Dismiss'} = '取消';
    $Self->{Translation}->{'Resources'} = '资源';
    $Self->{Translation}->{'Shown resources'} = '显示资源';
    $Self->{Translation}->{'Available Resources'} = '可用资源';
    $Self->{Translation}->{'Filter available resources'} = '过滤可用资源';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = '可见资源（可拖放排序）';
    $Self->{Translation}->{'Basic information'} = '基本信息';
    $Self->{Translation}->{'Resource'} = '资源';
    $Self->{Translation}->{'Date/Time'} = '日期 / 时间';
    $Self->{Translation}->{'End date'} = '结束日期';
    $Self->{Translation}->{'Repeat'} = '重复';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = '添加团队';
    $Self->{Translation}->{'Team Import'} = '团队导入';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        '你可以在这里上传一个配置文件来导入一个团队到系统中。这个文件必须是类似团队管理模块导出的.yml格式。';
    $Self->{Translation}->{'Upload team configuration'} = '上传团队配置';
    $Self->{Translation}->{'Import team'} = '导入团队';
    $Self->{Translation}->{'Filter for teams'} = '过滤团队';
    $Self->{Translation}->{'Export team'} = '导出团队';
    $Self->{Translation}->{'Edit Team'} = '编辑团队';
    $Self->{Translation}->{'Team with same name already exists.'} = '已有同名团队。';
    $Self->{Translation}->{'Permission group'} = '权限组';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = '过滤服务人员';
    $Self->{Translation}->{'Teams'} = '团队';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = '管理团队-服务人员关系';
    $Self->{Translation}->{'Change Agent Relations for Team'} = '修改团队的服务人员关系';
    $Self->{Translation}->{'Change Team Relations for Agent'} = '修改服务人员的团队关系';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = '聊天管理';
    $Self->{Translation}->{'Hints'} = '提示';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        '请注意：这个标签可用于与聊天相关的任何请求。如果你离开了聊天管理器（如通过使用了页面顶部的导航栏），开始一个新聊天或其它聊天相关操作可能随时重载这个标签。这意味着建议离开在这个特定标签打开的聊天管理器。';
    $Self->{Translation}->{'General Chat Requests From Customers'} = '由客户发起的一般聊天请求';
    $Self->{Translation}->{'My Chat Channels'} = '我的聊天频道';
    $Self->{Translation}->{'All Chat Channels'} = '所有聊天频道';
    $Self->{Translation}->{'Channel'} = '频道';
    $Self->{Translation}->{'Requester'} = '发起人';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = '聊天请求正在加载, 请稍候...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = '公共用户发起的聊天请求';
    $Self->{Translation}->{'Personal Chat Requests For You'} = '你的私人聊天请求';
    $Self->{Translation}->{'My Active Chats'} = '活跃中的聊天';
    $Self->{Translation}->{'Open ticket'} = '处理工单';
    $Self->{Translation}->{'Open company'} = '打开客户单位';
    $Self->{Translation}->{'Discard & close this chat'} = '放弃并关闭该聊天';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = '在该聊天中监控所有活动';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = '在该聊天中监控用户活动';
    $Self->{Translation}->{'Not monitoring this chat'} = '没有监控该聊天';
    $Self->{Translation}->{'Audio Call'} = '话音通话';
    $Self->{Translation}->{'Video Call'} = '视频通话';
    $Self->{Translation}->{'Toggle settings'} = '切换设置';
    $Self->{Translation}->{'Leave chat'} = '离开聊天';
    $Self->{Translation}->{'Leave'} = '离开';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        '从该聊天创建一个新的电话工单，然后关闭该聊天';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        '将该聊天内容追加到一个现有工单，然后关闭该聊天';
    $Self->{Translation}->{'Append'} = '追加';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = '邀请其它服务人员加入该聊天';
    $Self->{Translation}->{'Invite'} = '邀请';
    $Self->{Translation}->{'Change chat channel'} = '改变聊天频道';
    $Self->{Translation}->{'Channel change'} = '频道更改';
    $Self->{Translation}->{'Switch to participant'} = '切换为参与者';
    $Self->{Translation}->{'Participant'} = '参与者';
    $Self->{Translation}->{'Switch to an observer'} = '切换为观察人员';
    $Self->{Translation}->{'Observer'} = '观察人员';
    $Self->{Translation}->{'Download this Chat'} = '下载该聊天';
    $Self->{Translation}->{'Join invited chat as an observer'} = '作为观察人员加入受邀聊天';
    $Self->{Translation}->{'Join invited chat as a participant'} = '作为参与者加入受邀聊天';
    $Self->{Translation}->{'Open chat in a Popup'} = '在弹出窗口打开聊天';
    $Self->{Translation}->{'New window'} = '新窗口';
    $Self->{Translation}->{'New Message'} = '新的消息';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter 换行)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s 已离开了该聊天。';
    $Self->{Translation}->{'Online agents'} = '在线服务人员';
    $Self->{Translation}->{'Reload online agents'} = '刷新在线服务人员';
    $Self->{Translation}->{'Destination channel'} = '目标频道';
    $Self->{Translation}->{'Open chat'} = '受理聊天';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = '';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        '你不再这个聊天中，点击这个消息以移除聊天窗口。';
    $Self->{Translation}->{'There are currently no chat requests.'} = '当前没有聊天请求。';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        '该聊天内容将彻底删除, 你确认继续吗?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = '该聊天请求已由其他人员响应。';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = '你没有权限接入该聊天请求。';
    $Self->{Translation}->{'Please select a user.'} = '请选择一个用户。';
    $Self->{Translation}->{'Please select a permission level.'} = '请选择一个权限级别。';
    $Self->{Translation}->{'Invite Agent.'} = '邀请服务人员。';
    $Self->{Translation}->{'Please, select destination chat channel.'} = '请选择一个目标聊天频道。';
    $Self->{Translation}->{'Please select a channel.'} = '请选择一个频道。';
    $Self->{Translation}->{'Chat preview'} = '聊天预览';
    $Self->{Translation}->{'Please select a valid channel.'} = '请选择一个有效的频道。';
    $Self->{Translation}->{'Agent to customer chat.'} = '服务人员到客户的聊天。';
    $Self->{Translation}->{'Customer to agent chat.'} = '客户到服务人员的聊天。';
    $Self->{Translation}->{'Agent to agent chat.'} = '服务人员到服务人员的聊天。';
    $Self->{Translation}->{'Public to agent chat.'} = '公共用户到服务人员的聊天。';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = '你不能不管聊天中的客户。';
    $Self->{Translation}->{'You'} = '你';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        '由于内部错误, 你无法开始该聊天。';
    $Self->{Translation}->{'Your chat request was created.'} = '你的聊天请求已经创建。';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = '当前已受理%s聊天请求。';
    $Self->{Translation}->{'User was already invited to your chat!'} = '你的聊天已经邀请了此用户！';
    $Self->{Translation}->{'Insufficient permissions.'} = '权限不足。';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = '系统不能保存你的聊天序列。';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = '追加聊天到工单';
    $Self->{Translation}->{'Append to'} = '追加到';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        '该聊天将作为一个新的信件追加到选择的工单里。';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = '聊天对象：';
    $Self->{Translation}->{'Leave Chat'} = '离开聊天';
    $Self->{Translation}->{'User is currently in the chat.'} = '';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = '当前聊天频道';
    $Self->{Translation}->{'Available channels'} = '可用的频道';
    $Self->{Translation}->{'Reload'} = '刷新';
    $Self->{Translation}->{'Update Channel'} = '更新频道';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = '详情搜索';
    $Self->{Translation}->{'Add an additional attribute'} = '增加另一个搜索条件';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = '详细视图';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = '每页通知数';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = '没有找到通知数据。';
    $Self->{Translation}->{'Related To'} = '相关';
    $Self->{Translation}->{'Select this notification'} = '选择此通知';
    $Self->{Translation}->{'Zoom into'} = '放大';
    $Self->{Translation}->{'Dismiss this notification'} = '取消该通知';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = '取消选择的通知';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = '你真的要取消选择的通知吗？';
    $Self->{Translation}->{'OTRS Notification'} = 'OTRS通知';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = '报告 » 添加';
    $Self->{Translation}->{'Add New Statistics Report'} = '添加新的统计报告';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = '报告 » 编辑 - %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        '这里可以将几个统计组合到一个报告中，在配置的时候手动或自动生成PDF文档。';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        '请注意：如果系统中配置了PhantomJS，你只能选择图表作为统计输出格式。';
    $Self->{Translation}->{'Configure PhantomJS'} = '配置PhantomJS';
    $Self->{Translation}->{'General settings'} = '通用设置';
    $Self->{Translation}->{'Automatic generation settings'} = '自动生成设置';
    $Self->{Translation}->{'Automatic generation times (cron)'} = '自动生成时间（cron）';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        '用CRON格式指定自动生成报告的时间，例如："10 1 * * *"表明在每天凌晨1:10。';
    $Self->{Translation}->{'Last automatic generation time'} = '最近自动生成时间';
    $Self->{Translation}->{'Next planned automatic generation time'} = '下次自动生成时间';
    $Self->{Translation}->{'Automatic generation language'} = '自动生成的语言';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        '自动生成报告时使用的语言。';
    $Self->{Translation}->{'Email subject'} = '电子邮件主题';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = '指定自动生成的电子邮件的主题。';
    $Self->{Translation}->{'Email body'} = '电子邮件正文';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = '指定自动生成的电子邮件的正文内容。';
    $Self->{Translation}->{'Email recipients'} = '电子邮件收件人';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = '指定自动生成的电子邮件的收件人地址（逗号分隔）。';
    $Self->{Translation}->{'Output settings'} = '输出设置';
    $Self->{Translation}->{'Headline'} = '标题';
    $Self->{Translation}->{'Caption for preamble'} = '前言标题';
    $Self->{Translation}->{'Preamble'} = '前言';
    $Self->{Translation}->{'Caption for epilogue'} = '结尾标题';
    $Self->{Translation}->{'Epilogue'} = '结尾';
    $Self->{Translation}->{'Add statistic to report'} = '添加统计到报告';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = '报告 » 概览';
    $Self->{Translation}->{'Statistics Reports'} = '统计报告';
    $Self->{Translation}->{'Edit statistics report "%s".'} = '编辑统计报告“%s”。';
    $Self->{Translation}->{'Delete statistics report "%s"'} = '删除统计报告“%s”';
    $Self->{Translation}->{'Do you really want to delete this report?'} = '你确定要删除这个该报告吗？';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = '报告 » 视图 - %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        '该统计报告有配置错误，当前无法使用。';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = '附件';
    $Self->{Translation}->{'Attachment Overview'} = '附件概况';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = '该工单没有包含附件';
    $Self->{Translation}->{'Hide inline attachments'} = '隐藏内联附件';
    $Self->{Translation}->{'Filter Attachments'} = '过滤附件';
    $Self->{Translation}->{'Select All'} = '选择所有';
    $Self->{Translation}->{'Click to download this file'} = '点击下载该文件';
    $Self->{Translation}->{'Open article in main window'} = '在主窗口打开';
    $Self->{Translation}->{'Download selected files as archive'} = '下载选中的文件以存档';

    # Template: AgentVideoChat
    $Self->{Translation}->{'Your browser does not support HTML5 video.'} = '你的浏览器不支持HTML5视频。';
    $Self->{Translation}->{'Close video call'} = '关闭视频通话';
    $Self->{Translation}->{'Toggle audio'} = '切换语音';
    $Self->{Translation}->{'Toggle video'} = '切换视频';
    $Self->{Translation}->{'User has declined your invitation.'} = '用户拒绝了您的邀请。';
    $Self->{Translation}->{'User has left the call.'} = '用户已经断开了通话。';
    $Self->{Translation}->{'Attempt to connect was unsuccessful. Please try again.'} = '尝试连接未成功，请重试。';
    $Self->{Translation}->{'Permission to media stream has been denied.'} = '媒体流权限已被拒绝。';
    $Self->{Translation}->{'Please allow this page to use your video and audio stream.'} = '要使用视频和音频流，请允许这个页面。';
    $Self->{Translation}->{'Requesting media stream...'} = '请求媒体流...';
    $Self->{Translation}->{'Waiting for other party to respond...'} = '等待对方回应...';
    $Self->{Translation}->{'Accepting the invitation...'} = '接受邀请...';
    $Self->{Translation}->{'Initializing...'} = '初始化...';
    $Self->{Translation}->{'Connecting, please wait...'} = '正在连接，请稍候...';
    $Self->{Translation}->{'Connection established!'} = '已经建立连接！';

    # Template: CustomerChat
    $Self->{Translation}->{'%s has joined this chat.'} = '%s 已加入该聊天中。';
    $Self->{Translation}->{'Incoming chat requests'} = '进入的聊天请求';
    $Self->{Translation}->{'Outgoing chat requests'} = '发出的聊天请求';
    $Self->{Translation}->{'Active chats'} = '活动的聊天';
    $Self->{Translation}->{'Closed chats'} = '已关闭的聊天';
    $Self->{Translation}->{'Chat request description'} = '聊天请求描述';
    $Self->{Translation}->{'Create new ticket'} = '创建新工单';
    $Self->{Translation}->{'Add an article'} = '添加信件';
    $Self->{Translation}->{'Start a new chat'} = '开始新的聊天';
    $Self->{Translation}->{'Select channel'} = '选择频道';
    $Self->{Translation}->{'Add to an existing ticket'} = '添加到现有工单';
    $Self->{Translation}->{'Active Chat'} = '激活聊天';
    $Self->{Translation}->{'Download Chat'} = '下载聊天';
    $Self->{Translation}->{'Chat is being loaded...'} = '聊天已加开始加载...';
    $Self->{Translation}->{'Chat completed'} = '聊天已完成';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = '全屏';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = '请确认你的选择';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = '你的大名';
    $Self->{Translation}->{'Start a new Chat'} = '开始新的聊天';
    $Self->{Translation}->{'Chat complete'} = '聊天完成';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = '移除统计';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        '如果你不在这里指定一个标题，将使用统计的标题。';
    $Self->{Translation}->{'Preface'} = '前言';
    $Self->{Translation}->{'Postface'} = '后记';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = '聊天频道 %s已添加';
    $Self->{Translation}->{'Chat channel %s edited'} = '聊天频道 %s已编辑';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = '云服务“%s”已更新！';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = '云服务配置“%s”已保存！';

    # Perl Module: Kernel/Modules/AgentAppointmentResourceOverview.pm
    $Self->{Translation}->{'This feature is part of the %s package. Please install this free add-on before trying to use it again.'} =
        '这个功能是%s软件包的一部分，请首先免费安装这个附加组件再重试。';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = '需要团队ID！';
    $Self->{Translation}->{'Invalid GroupID!'} = '';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = '无法返回给定团队ID的数据';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = '未分配';

    # Perl Module: Kernel/Modules/AgentChat.pm
    $Self->{Translation}->{'Chat %s has been closed and was successfully appended to Ticket %s.'} =
        '聊天%s已经关闭并成功追加到工单%s。';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        '视频通话功能已被禁用！请检查当前系统%s是否可用。';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s已作为观察者加入该聊天。';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = '';
    $Self->{Translation}->{'New request for joining a chat'} = '加入一个聊天的新请求';
    $Self->{Translation}->{'Agent invited %s.'} = '服务人员已邀请%s。';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s已修改聊天频道为%s。';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s已经切换为参与者。';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s已经切换为观察者。';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s已经拒绝了该聊天请求。';
    $Self->{Translation}->{'Need'} = '需要';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = '所有通知';
    $Self->{Translation}->{'Seen Notifications'} = '已阅通知';
    $Self->{Translation}->{'Unseen Notifications'} = '未读通知';
    $Self->{Translation}->{'Notification Web View'} = '通知网页视图';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = '名称已使用，请选择另外一个。';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = '请提供一条有效的cron条目。';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = '你没有参与这个聊天！';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        '你不可用外部聊天，要上线吗？';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = '你没有分配任何外部聊天。';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = '取消选择';
    $Self->{Translation}->{'Object Type'} = '对象类型';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        '';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = '受理聊天请求';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s报告';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = '错误：该图片无法生成-%s。';
    $Self->{Translation}->{'Table of Contents'} = '目录';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = '默认聊天频道';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = '激活聊天支持';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        '服务人员前端模块注册（如果聊天功能未激活或服务人员不在聊天组中则禁用聊天链接）。';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = '能够接受聊天请求和聊天的服务人员组。';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = '能够创建聊天请求的服务人员组。';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = '在聊天中能够使用视频通话功能的服务人员组。';
    $Self->{Translation}->{'Agent interface availability.'} = '服务人员界面可用性。';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        '服务人员界面检查聊天请求的通知模块。';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        '允许客户只选择有可用服务人员的频道。';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        '允许公共用户只选择有可用服务人员的频道。';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = '允许拥有简洁格式通知的网页视图。';
    $Self->{Translation}->{'Chat Channel'} = '聊天频道';
    $Self->{Translation}->{'Chat Channel:'} = '聊天频道：';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        '聊天频道用于该队列相关工单的沟通。';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = '聊天频道到队列的映射。';
    $Self->{Translation}->{'Chat overview'} = '聊天一览';
    $Self->{Translation}->{'Chats'} = '聊天';
    $Self->{Translation}->{'Cleans up old chat logs.'} = '清除旧的聊天日志。';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        '“简洁”类型通知网页视图的列过滤器。';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        '服务人员界面通知网页视图中用来过滤的列。可能的设置：0 = 禁用，1 = 可用，2 = 默认启用。';
    $Self->{Translation}->{'Contact with data'} = '连接数据';
    $Self->{Translation}->{'Create and manage chat channels.'} = '创建并管理聊天频道。';
    $Self->{Translation}->{'Create new chat'} = '创建新的聊天';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        '客户前端模块注册（如果聊天功能未激活或没有可供聊天的服务人员则禁用聊天链接）。';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        '客户和公共用户界面看到的默认服务人员姓名。如果启用了，聊天时客户/公共用户无法知晓服务人员的真实姓名。';
    $Self->{Translation}->{'Default text for the customer interface.'} = '客户界面的默认文本。';
    $Self->{Translation}->{'Default text for the public interface.'} = '公共用户界面的默认文本。';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        '定义一个客户界面可见的服务人员首选项组键的列表（仅当禁用DefaultAgentName才有效）。例如：你要显示PreferencesGroups###Language，添加语言。';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        '定义客户界面服务人员首选项的一段文本（仅当禁用DefaultAgentName才有效）。';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        '定义客户用户能否选择聊天频道。如果不能，就在默认聊天频道创建聊天。';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        '定义从工单详情视图中开始与客户聊天时是否必须锁定工单。';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        '定义是否在默认服务人员姓名后追加数字，如果启用，将在默认服务人员姓名后加上数字（如1、2、3……）。';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        '定义公共用户能否选择聊天频道。如果不能，就在默认聊天频道创建聊天。';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        '定义在服务人员界面显示一个通知的模块，用于服务人员能够使用外部聊天，但是忘记设置优先频道的时候。';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        '定义在服务人员界面显示一个通知的模块，用于服务人员不能与客户聊天的时候（仅当Ticket::Agent::AvailableForChatsAfterLogin设置为“否”时）。';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        '定义在通知网页视图显示一个通知的天数（设置为0意味着始终显示）。';
    $Self->{Translation}->{'Defines the order of chat windows.'} = '定义聊天窗口的顺序。';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        '定义到PhantomJS程序的路径。可以使用http://phantomjs.org/download.html已编译的文件以简化安装过程。';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        '定义显示“无应答”消息给客户的时间段（分钟）。';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        '定义服务人员因不活动而标记为“离开”的时间段（分钟）。';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        '定义客户因不活动而标记为“离开”的时间段（分钟）。';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = '定义预约通知的设置。';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = '定义日历通知的设置。';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = '定义工单通知的设置。';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        '定义存储历史数据的源动态字段。';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        '定义存储历史数据的目标动态字段。';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = '动态字段联系数据后端GUI';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = '动态字段数据库后端GUI';
    $Self->{Translation}->{'Edit contacts with data'} = '编辑联系信息';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        '启用服务人员界面通知网页视图批量操作功能，以一次性处理多个通知。';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        '仅对列表中的组启用服务人员界面通知网页视图批量操作功能。';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = '在服务人员工单详情窗口启用时间轴视图。';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        '事件模块注册（在动态字段中存储历史数据）。';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = '客户界面的前端模块注册。';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = '公共界面的前端模块注册。';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        '为指定的块生成HTML注释钩子，以供过滤器使用。';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        '如果启用本选项，将在登录时检查服务人员的可用性。如果用户可用外部聊天，就仅减少内部聊天的可用性。';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        '如果本选项设置为“是”，就在每个页面上显示一条当前服务人员无法聊天的通知消息。';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        '如果本选项设置为“是”，服务人员无需工单就能与客户发起聊天。';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        '如果本选项设置为“是”，客户无需工单就能与服务人员发起聊天。';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        '如果本选项设置为“是”，仅工单详情视图中的工单客户可以发起聊天。';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        '如果本选项设置为“是”，在服务人员工单详情视图仅当工单客户在线时才能发起聊天。';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        '如果本选项设置为“是”，在客户工单详情视图仅当可用的服务人员在链接的聊天频道时才能发起聊天。';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        '从服务人员界面可以发起与一个客户的聊天。';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        '从服务人员界面可以发起与一个服务人员的聊天。';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        '从客户界面可以发起与一个服务人员的聊天。';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        '从公共用户界面可以发起与一个服务人员的聊天。';
    $Self->{Translation}->{'Manage team agents.'} = '管理团队的服务人员。';
    $Self->{Translation}->{'My chats'} = '我的聊天';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        '默认的聊天频道名称。如果该频道不存在，将自动创建它。请不要创建一个与默认聊天频道相同名称的聊天频道。如果客户界面和公共用户界面启用了聊天频道，默认频道不会显示出来。所有的服务人员之间的聊天都在默认频道中。';
    $Self->{Translation}->{'No agents available message.'} = '没有服务人员可用的消息。';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        '“简洁”通知网页视图每页的通知限制';
    $Self->{Translation}->{'Notification web view'} = '通知网页视图';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = '“简洁”通知网页视图限制';
    $Self->{Translation}->{'Notifications Unseen:'} = '未读通知：';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = '聊天删除前保留的天数。';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = '已关闭的聊天删除前保留的小时数。';
    $Self->{Translation}->{'Output filter for standard tt files.'} = '标准tt文件的输出过滤器。';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        '在隐藏输入框中注入需要的动态字段名称的输出过滤器。';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        '注入需要的JavaScript到视图中的输出过滤器。';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = '通知网页视图过滤器的参数。';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        '服务人员界面偏好设置视图用于聊天频道对象的参数。';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        '简洁通知视图页面（显示通知的页面）的参数。';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        '从服务人员工单详情视图发起一个与客户的聊天所需的权限级别。';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        '请稍候，我们的服务人员会尽快处理你的聊天请求，感谢您的耐心。';
    $Self->{Translation}->{'Prepend'} = '预先考虑';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = '移除超过ChatEngine::ChatTTL设置的已关闭聊天。';
    $Self->{Translation}->{'Remove old chats.'} = '移除旧的聊天。';
    $Self->{Translation}->{'Resource overview page.'} = '资源概览页面。';
    $Self->{Translation}->{'Resource overview screen.'} = '资源概览窗口。';
    $Self->{Translation}->{'Resources list.'} = '资源列表。';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        '访问AdminContactWithData（管理联系信息）模块时运行一次全部现有联系信息的搜索。';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        '设置服务人员工单详情视图能否发出聊天请求。';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        '设置客户工单详情视图能否发出聊天请求。';
    $Self->{Translation}->{'Show all ticket attachments'} = '显示该工单所有的附件';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = '显示该工单所有可用的附件。';
    $Self->{Translation}->{'Start new chat'} = '开始新的聊天';
    $Self->{Translation}->{'Team agents management screen.'} = '团队服务人员管理窗口。';
    $Self->{Translation}->{'Team list'} = '团队列表';
    $Self->{Translation}->{'Team management screen.'} = '团队管理窗口。';
    $Self->{Translation}->{'Team management.'} = '团队管理。';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        '在该SLA选定的客户工单消息上显示的文本。';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        '服务人员界面皮肤“business（商业版）”中显示在页面顶端的LOGO。查看“AgentLogo”以获得更多描述。';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        '当前没有服务人员可以聊天，请稍后再试。';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        '当前没有服务人员可以聊天，要添加信件到现有工单，请点击这里：';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        '当前没有服务人员可以聊天，要创建一个新工单，请点击这里：';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        '该聊天已经结束，请离开或等它自动关闭。';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        '该聊天已经结束，请离开或等它自动关闭。你可以下载该聊天。';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = '该聊天已经完成，现在可以关闭该聊天窗口。';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        '该聊天已经完成，你可以使用本页面顶部的按钮发起一个新的聊天。';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = '一个通知网页视图的工具栏条目。';
    $Self->{Translation}->{'Video and audio call screen.'} = '视频和音频通话窗口。';
    $Self->{Translation}->{'View notifications'} = '查看通知';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        '你选择的优先外部聊天频道，这些聊天频道有外部聊天请求时你会接到通知。';

}

1;
