# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::th_TH_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'จัดการช่องทางแชท';
    $Self->{Translation}->{'Add Chat Channel'} = 'เพิ่มช่องทางแชท';
    $Self->{Translation}->{'Edit Chat Channel'} = 'แก้ไขช่องทางแชท';
    $Self->{Translation}->{'Name invalid'} = 'ชื่อไม่ถูกต้อง';
    $Self->{Translation}->{'Need Group'} = 'ต้องการกลุ่ม';
    $Self->{Translation}->{'Need Valid'} = 'ต้องการที่ถูกต้อง';
    $Self->{Translation}->{'Comment invalid'} = 'คอมเมนต์ไม่ถูกต้อง';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'สถานะการบริการระบบคลาวด์';
    $Self->{Translation}->{'Cloud service availability'} = 'การบริการระบบคลาวด์ที่พร้อมใช้งาน';
    $Self->{Translation}->{'Remaining SMS units'} = 'หน่วย SMS ที่ยังเหลืออยู่';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'ยังไม่สามารถตรวจสอบสถานะของการบริการระบบคลาวด์ตอนนี้';
    $Self->{Translation}->{'Phone field for agent'} = 'ช่องข้อมูลโทรศัพท์สำหรับเอเย่นต์';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'ช่องข้อมูลเอเย่นต์ซึ่งมาจากหมายเลขโทรศัพท์มือถือสำหรับการส่งข้อความผ่านทาง SMS จะต้องดำเนินการ';
    $Self->{Translation}->{'Phone field for customer'} = 'ช่องข้อมูลโทรศัพท์สำหรับลูกค้า';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'ช่องข้อมูลลูกค้าซึ่งมาจากหมายเลขโทรศัพท์มือถือสำหรับการส่งข้อความผ่านทาง SMS จะต้องดำเนินการ';
    $Self->{Translation}->{'Sender string'} = 'ผู้ส่งสตริง';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'จะแสดงเป็นชื่อผู้ส่ง SMS (ความยาวไม่เกิน 11 ตัวอักษร)';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'ข้อมูลนี้จำเป็นต้องมีและต้องมีตัวอักษรไม่เกิน 11 ตัวอักษร';
    $Self->{Translation}->{'Allowed role members'} = 'สมาชิกบทบาทที่ได้รับอนุญาต';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'ถ้าเลือกเฉพาะผู้ใช้ที่ได้รับมอบหมายให้บทบาทเหล่านี้จะสามารถได้รับข้อความผ่านทาง SMS (ตัวเลือก)';
    $Self->{Translation}->{'Save configuration'} = 'บันทึกการกำหนดค่า';
    $Self->{Translation}->{'Data Protection Information'} = 'ข้อมูลการป้องกันข้อมูล';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'ติดต่อกับการจัดการข้อมูล';
    $Self->{Translation}->{'Add contact with data'} = 'เพิ่มการติดต่อด้วยข้อมูล';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'กรุณากรอกคำค้นหาที่จะค้นหาเบอร์ติดต่อด้วยข้อมูล';
    $Self->{Translation}->{'Edit contact with data'} = 'แก้ไขการติดต่อด้วยข้อมูล';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'ข้อมูลเหล่านี้เป็นคุณลักษณะของข้อมูลที่เป็นไปได้สำหรับการติดต่อ';
    $Self->{Translation}->{'Mandatory fields'} = 'ข้อมูลที่จำเป็น';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'คั่นรายการคีย์บังคับด้วยเครื่องหมายจุลภาค (ทางเลือก) คีย์ \'Name\' และ \'ValidID\'  มักจะจำเป็นและไม่จำเป็นต้องจัดอยู่ในรายการนี้';
    $Self->{Translation}->{'Sorted fields'} = 'จัดเรียงฟิลด์';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'คั่นรายการคีย์ในลำดับการจัดเรียงด้วยจุลภาค (ทางเลือก) เริ่มด้วยคีย์ที่อยู่ในรายการตามด้วยฟิลด์ที่เหลือทั้งหมดหลังจากนั้นเรียงตามตัวอักษร';
    $Self->{Translation}->{'Searchable fields'} = 'ฟิลด์ที่สามารถค้นหาได้';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'คั่นรายการคีย์ที่สามารถค้นหาได้ด้วยเครื่องหมายจุลภาค (ทางเลือก) คีย์ \'Name\' จะสามารถค้นหาได้ตลอดและไม่จำเป็นต้องจัดอยู่ในรายการนี้';
    $Self->{Translation}->{'Add/Edit'} = 'เพิ่ม/แก้ไข';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Datatype';
    $Self->{Translation}->{'Searchfield'} = 'Searchfield';
    $Self->{Translation}->{'Listfield'} = 'Listfield';
    $Self->{Translation}->{'Driver'} = 'Driver';
    $Self->{Translation}->{'Server'} = 'เซิร์ฟเวอร์';
    $Self->{Translation}->{'Table / View'} = 'ตาราง / มุมมอง';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = '';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Searchprefix';
    $Self->{Translation}->{'Searchsuffix'} = 'Searchsuffix';
    $Self->{Translation}->{'Result Limit'} = 'ขีดจำกัดของผลลัพธ์';
    $Self->{Translation}->{'Case Sensitive'} = 'case สำคัญ';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'หมายเลขผู้รับ SMS';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = '';
    $Self->{Translation}->{'Manage Calendars'} = '';
    $Self->{Translation}->{'Manage Teams'} = '';
    $Self->{Translation}->{'Manage Team Agents'} = '';
    $Self->{Translation}->{'Add new Appointment'} = '';
    $Self->{Translation}->{'Add Appointment'} = '';
    $Self->{Translation}->{'Calendars'} = '';
    $Self->{Translation}->{'Filter for calendars'} = '';
    $Self->{Translation}->{'URL'} = '';
    $Self->{Translation}->{'Copy public calendar URL'} = '';
    $Self->{Translation}->{'This is a resource overview page.'} = '';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        '';
    $Self->{Translation}->{'No teams found.'} = '';
    $Self->{Translation}->{'Please add a team first by using Manage Teams page.'} = '';
    $Self->{Translation}->{'Team'} = '';
    $Self->{Translation}->{'No team agents found.'} = '';
    $Self->{Translation}->{'Please assign agents to a team first by using Manage Team Agents page.'} =
        '';
    $Self->{Translation}->{'Too many active calendars'} = '';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '';
    $Self->{Translation}->{'Restore default settings'} = '';
    $Self->{Translation}->{'Week'} = '';
    $Self->{Translation}->{'Timeline Month'} = '';
    $Self->{Translation}->{'Timeline Week'} = '';
    $Self->{Translation}->{'Timeline Day'} = '';
    $Self->{Translation}->{'Jump'} = '';
    $Self->{Translation}->{'Appointment'} = '';
    $Self->{Translation}->{'This is a repeating appointment'} = '';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        '';
    $Self->{Translation}->{'All occurrences'} = '';
    $Self->{Translation}->{'Just this occurrence'} = '';
    $Self->{Translation}->{'Dismiss'} = 'ยกเลิก';
    $Self->{Translation}->{'Resources'} = '';
    $Self->{Translation}->{'Shown resources'} = '';
    $Self->{Translation}->{'Available Resources'} = '';
    $Self->{Translation}->{'Filter available resources'} = '';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = '';
    $Self->{Translation}->{'Basic information'} = '';
    $Self->{Translation}->{'Resource'} = '';
    $Self->{Translation}->{'Date/Time'} = '';
    $Self->{Translation}->{'End date'} = '';
    $Self->{Translation}->{'Repeat'} = '';

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
    $Self->{Translation}->{'Permission group'} = '';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = '';
    $Self->{Translation}->{'Teams'} = '';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = '';
    $Self->{Translation}->{'Change Agent Relations for Team'} = '';
    $Self->{Translation}->{'Change Team Relations for Agent'} = '';

    # Template: AgentChat
    $Self->{Translation}->{'Manage Chats'} = 'จัดการแชท';
    $Self->{Translation}->{'Hints'} = 'คำแนะนำ';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'โปรดทราบ: แท็บนี้จะถูกใช้โดยการร้องขอใด ๆ ที่เกี่ยวข้องกับการแชท ถ้าคุณปล่อยการจัดการการแชท (เช่นโดยการใช้แถบนำทางที่ด้านบนของหน้า) เริ่มต้นแชทใหม่หรือแชทอื่น ๆ ที่เกี่ยวข้องอาจจะถูกแสดงผลซ้ำในแท็บนี้ตลอดเวลา ซึ่งหมายความว่ามันจะแนะนำให้ออกจากผู้จัดการแชทที่เปิดอยู่ในแท็บนี้โดยเฉพาะอย่างยิ่ง';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'การร้องขอแชททั่วไปจากลูกค้า';
    $Self->{Translation}->{'My Chat Channels'} = 'ช่องทางแชทของฉัน';
    $Self->{Translation}->{'All Chat Channels'} = 'ช่องทางแชททั้งหมด';
    $Self->{Translation}->{'Channel'} = 'ช่องทางแชท';
    $Self->{Translation}->{'Requester'} = 'ผู้ร้องขอ';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'การร้องขอแชทกำลังโหลดโปรดstand by ...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'การร้องขอแชททั่วไปจากผู้ใช้สาธารณะ';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'การร้องขอแชทส่วนบุคคลสำหรับคุณ';
    $Self->{Translation}->{'My Active Chats'} = 'แชทที่ใช้งานของฉัน';
    $Self->{Translation}->{'Open ticket'} = 'เปิดตั๋ว';
    $Self->{Translation}->{'Open company'} = 'เปิดบริษัท';
    $Self->{Translation}->{'Discard & close this chat'} = 'ยกเลิกและปิดแชทนี้';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'ตรวจสอบกิจกรรมทั้งหมดในแชทนี้';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'การตรวจสอบกิจกรรมของลูกค้าในแชทนี้';
    $Self->{Translation}->{'Not monitoring this chat'} = 'ไม่ต้องตรวจสอบแชทนี้';
    $Self->{Translation}->{'Audio Call'} = '';
    $Self->{Translation}->{'Video Call'} = '';
    $Self->{Translation}->{'Toggle settings'} = 'การตั้งค่าเครื่องมือ';
    $Self->{Translation}->{'Leave chat'} = 'ออกจากการแชท';
    $Self->{Translation}->{'Leave'} = 'ออกจาก';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'สร้างตั๋วโทรศัพท์ใหม่จากแชทนี้และปิดมันหลังจากนั้น';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'ผนวกแชทนี้เพื่อตั๋วที่มีอยู่และปิดมันหลังจากนั้น';
    $Self->{Translation}->{'Append'} = 'ผนวก';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'เชิญเอเย่นต์เพิ่มเติมเพื่อเข้าร่วมการสนทนา';
    $Self->{Translation}->{'Invite'} = 'เชิญ';
    $Self->{Translation}->{'Change chat channel'} = 'เปลี่ยนทางแชท';
    $Self->{Translation}->{'Channel change'} = 'เปลี่ยนช่อง';
    $Self->{Translation}->{'Switch to participant'} = 'เปลี่ยนเป็นผู้เข้าร่วม';
    $Self->{Translation}->{'Participant'} = 'ผู้เข้าร่วม';
    $Self->{Translation}->{'Switch to an observer'} = 'เปลี่ยนเป็นผู้สังเกตการณ์';
    $Self->{Translation}->{'Observer'} = 'ผู้สังเกตการณ์';
    $Self->{Translation}->{'Download this Chat'} = 'ดาวน์โหลดแชทนี้';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'เข้าร่วมแชทที่ได้รับเชิญในฐานะผู้สังเกตการณ์';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'เข้าร่วมแชทที่ได้รับเชิญในฐานะผู้เข้าร่วม';
    $Self->{Translation}->{'Open chat in a Popup'} = 'เปิดแชทในป๊อปอัพ';
    $Self->{Translation}->{'New window'} = 'หน้าต่างใหม่';
    $Self->{Translation}->{'New Message'} = 'ข้อความใหม่';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter สำหรับบรรทัดใหม่)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s ได้ออกจากการแชท';
    $Self->{Translation}->{'Online agents'} = 'เอเย่นต์ออนไลน์';
    $Self->{Translation}->{'Reload online agents'} = 'โหลดเอเย่นต์ออนไลน์';
    $Self->{Translation}->{'Destination channel'} = 'ช่องปลายทาง';
    $Self->{Translation}->{'Open chat'} = 'เปิดแชท';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = '';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'คุณไม่ได้อยู่ในการสนทนานี้ คลิกที่ข้อความนี้เพื่อลบกล่องแชท';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'ไม่มีการร้องขอแชทในขณะนี้';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'จะลบเนื้อหาการสนทนานี้อย่างถาวร คุณต้องการที่จะดำเนินการต่อหรือไม่?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'คำขอแชทนี้ได้รับการยอมรับโดยบุคคลอื่นแล้ว';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'คุณไม่มีสิทธิ์ที่จะยอมรับคำขอแชทนี้';
    $Self->{Translation}->{'Please select a user.'} = 'กรุณาเลือกผู้ใช้';
    $Self->{Translation}->{'Please select a permission level.'} = 'กรุณาเลือกระดับการอนุญาต';
    $Self->{Translation}->{'Invite Agent.'} = 'เชิญเอเย่นต์';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'กรุณาเลือกปลายทางช่องแชท';
    $Self->{Translation}->{'Please select a channel.'} = 'กรุณาเลือกช่อง';
    $Self->{Translation}->{'Chat preview'} = 'ตัวอย่างการแชท';
    $Self->{Translation}->{'Please select a valid channel.'} = 'โปรดเลือกช่องทางที่ถูกต้อง';
    $Self->{Translation}->{'Agent to customer chat.'} = 'การสนทนาระหว่างเอเย่นต์กับลูกค้า';
    $Self->{Translation}->{'Customer to agent chat.'} = 'การสนทนาระหว่างลูกค้ากับเอเย่นต์';
    $Self->{Translation}->{'Agent to agent chat.'} = 'การสนทนาระหว่างเอเย่นต์กับเอเย่นต์';
    $Self->{Translation}->{'Public to agent chat.'} = 'การสนทนาระหว่างสาธารณะกับเอเย่นต์';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'คุณไม่สามารถปล่อยให้ลูกค้าอยู่ตามลำพังในการแชท';
    $Self->{Translation}->{'You'} = 'คุณ';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'แชทของคุณไม่สามารถเริ่มต้นเนื่องจากข้อผิดพลาดภายใน';
    $Self->{Translation}->{'Your chat request was created.'} = 'คำขอแชทของคุณถูกสร้างขึ้นแล้ว';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'ขณะนี้มีการเปิด%sการร้องขอการสนทนา';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'ผู้ใช้ถูกเชิญเข้าร่วมการแชทของคุณแล้ว!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'สิทธิ์ไม่เพียงพอ';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'ระบบไม่สามารถที่จะบันทึกลำดับการแชทของคุณ';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'ผนวกแชทไปยังตั๋ว';
    $Self->{Translation}->{'Append to'} = 'ผนวกกับ';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'แชทจะถูกผนวกเป็นบทความใหม่ไปกับตั๋วที่ได้รับเลือก';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'สนทนากับ';
    $Self->{Translation}->{'Leave Chat'} = 'ออกจากการแชท';
    $Self->{Translation}->{'User is currently in the chat.'} = '';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'ช่องทางการสนทนาในปัจจุบัน';
    $Self->{Translation}->{'Available channels'} = 'ช่องทางที่สามารถใช้ได้';
    $Self->{Translation}->{'Reload'} = 'โหลดใหม่';
    $Self->{Translation}->{'Update Channel'} = 'อัปเดตช่องทางแชท';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'ค้นหารายละเอียด';
    $Self->{Translation}->{'Add an additional attribute'} = 'เพิ่มแอตทริบิวต์อื่นๆ';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'ดูรายละเอียด';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'การแจ้งเตือนต่อหนึ่งหน้า';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'ไม่พบข้อมูลการแจ้งเตือน';
    $Self->{Translation}->{'Related To'} = 'เกี่ยวกับ';
    $Self->{Translation}->{'Select this notification'} = 'เลือกการแจ้งเตือนนี้';
    $Self->{Translation}->{'Zoom into'} = 'ซูมเข้า';
    $Self->{Translation}->{'Dismiss this notification'} = 'ปิดการแจ้งเตือนนี้';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'ปิดการแจ้งเตือนที่เลือกไว้';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'คุณต้องการที่จะปิดการแจ้งเตือนที่เลือกนี้หรือไม่?';
    $Self->{Translation}->{'OTRS Notification'} = 'การแจ้งเตือน OTRS';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'รายงาน»เพิ่ม';
    $Self->{Translation}->{'Add New Statistics Report'} = 'เพิ่มรายงานสถิติใหม่';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'รายงาน » แก้ไข  — %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'คุณสามารถรวมสถิติต่างๆไปยังรายงานซึ่งคุณสามารถสร้างเป็น PDF ด้วยตนเองหรือโดยอัตโนมัติในเวลาที่กำหนดที่นี่';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'โปรดทราบว่าคุณสามารถเลือกแผนภูมิเป็นรูปแบบสถิติเท่านั้นถ้าคุณกำหนดค่า PhantomJS ในระบบของคุณ';
    $Self->{Translation}->{'Configure PhantomJS'} = 'กำหนดค่า PhantomJS';
    $Self->{Translation}->{'General settings'} = 'การตั้งค่าทั่วไป';
    $Self->{Translation}->{'Automatic generation settings'} = 'การตั้งค่าการผลิตอัตโนมัติ';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'เวลาการผลิตอัตโนมัติ (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'ระบุเมื่อรายงานควรได้รับการสร้างขึ้นโดยอัตโนมัติในรูปแบบ cron เช่น "10 1 * * *" สำหรับทุกวันณ 01:10';
    $Self->{Translation}->{'Last automatic generation time'} = 'เวลาการผลิตอัตโนมัติล่าสุด';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'การวางแผนเวลาการผลิตอัตโนมัติถัดไป';
    $Self->{Translation}->{'Automatic generation language'} = 'ภาษาการผลิตอัตโนมัติ';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'ภาษาที่จะใช้เมื่อรายงานถูกสร้างขึ้นโดยอัตโนมัติ';
    $Self->{Translation}->{'Email subject'} = 'หัวข้อจดหมาย';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = '';
    $Self->{Translation}->{'Email body'} = 'เนื้อหาอีเมล์';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'ระบุข้อความสำหรับอีเมลที่สร้างขึ้นอัตโนมัติ';
    $Self->{Translation}->{'Email recipients'} = 'ผู้รับอีเมล';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'ระบุที่อยู่อีเมลของผู้รับ (คั่นด้วยเครื่องหมายจุลภาค)';
    $Self->{Translation}->{'Output settings'} = 'การตั้งค่าการส่งออก';
    $Self->{Translation}->{'Headline'} = 'พาดหัว';
    $Self->{Translation}->{'Caption for preamble'} = 'คำบรรยายใต้คำนำ';
    $Self->{Translation}->{'Preamble'} = 'คำนำ';
    $Self->{Translation}->{'Caption for epilogue'} = 'คำบรรยายใต้ภาพสำหรับบทส่งท้าย';
    $Self->{Translation}->{'Epilogue'} = 'บทส่งท้าย';
    $Self->{Translation}->{'Add statistic to report'} = 'เพิ่มสถิติในการรายงาน';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'รายงาน » ภาพรวม';
    $Self->{Translation}->{'Statistics Reports'} = 'รายงานสถิติ';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'แก้ไขรายงานสถิติ "%s".';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'ลบรายงานสถิติ "%s".';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'คุณต้องการที่จะลบรายงานนี้หรือไม่?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'รายงาน»ดู — %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'รายงานสถิตินี้มีข้อผิดพลาดในการตั้งค่าและสามารถยังไม่ได้นำมาใช้ได้';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'สิ่งที่แนบมาของ';
    $Self->{Translation}->{'Attachment Overview'} = 'ข้อมูลทั่วไปของสิ่งที่แนบมา';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'ตั๋วนี้ไม่มีเอกสารแนบมา';
    $Self->{Translation}->{'Hide inline attachments'} = '';
    $Self->{Translation}->{'Filter Attachments'} = 'ตัวกรองสิ่งที่แนบมา';
    $Self->{Translation}->{'Select All'} = 'เลือกทั้งหมด';
    $Self->{Translation}->{'Click to download this file'} = 'คลิกที่นี่เพื่อดาวน์โหลดไฟล์นี้';
    $Self->{Translation}->{'Open article in main window'} = 'เปิดบทความในหน้าต่างหลัก';
    $Self->{Translation}->{'Download selected files as archive'} = 'ดาวน์โหลดไฟล์ที่เลือกเป็นข้อมูลถาวร';

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
    $Self->{Translation}->{'%s has joined this chat.'} = '%s ได้เข้าร่วมแชทนี้';
    $Self->{Translation}->{'Incoming chat requests'} = 'การร้องขอแชทขาเข้า';
    $Self->{Translation}->{'Outgoing chat requests'} = 'การร้องขอแชทขาออก';
    $Self->{Translation}->{'Active chats'} = 'แชทที่ใช้งานอยู่';
    $Self->{Translation}->{'Closed chats'} = 'แชทที่ปิดแล้ว';
    $Self->{Translation}->{'Chat request description'} = 'รายละเอียดการร้องขอการพูดคุย';
    $Self->{Translation}->{'Create new ticket'} = 'สร้างตั๋วใหม่';
    $Self->{Translation}->{'Add an article'} = 'เพิ่มบทความ';
    $Self->{Translation}->{'Start a new chat'} = 'เริ่มการแชทใหม่';
    $Self->{Translation}->{'Select channel'} = 'เลือกช่อง';
    $Self->{Translation}->{'Add to an existing ticket'} = 'เพิ่มในตั๋วที่มีอยู่';
    $Self->{Translation}->{'Active Chat'} = 'แชทที่ใช้งานอยู่';
    $Self->{Translation}->{'Download Chat'} = 'ดาวน์โหลดแชท';
    $Self->{Translation}->{'Chat is being loaded...'} = 'แชทกำลังโหลด';
    $Self->{Translation}->{'Chat completed'} = 'เสร็จสิ้นการแชท';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = '';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'กรุณายืนยันการเลือกของคุณ';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'ชื่อของคุณ';
    $Self->{Translation}->{'Start a new Chat'} = 'เริ่มการแชทใหม่';
    $Self->{Translation}->{'Chat complete'} = 'เสร็จสิ้นการแชท';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'ลบสถิติ';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'ถ้าคุณไม่ระบุชื่อที่นี่ชื่อของสถิติที่จะถูกนำมาใช้';
    $Self->{Translation}->{'Preface'} = 'Preface';
    $Self->{Translation}->{'Postface'} = 'Postface';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'เพิ่ม %s ช่องการแชท';
    $Self->{Translation}->{'Chat channel %s edited'} = 'แก้ไข %s ช่องการแชท';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'อัพเดต "%s" การบริการระบบคลาวด์';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'การกำหนดค่าบริการระบบคลาวด์ "%s"  บันทึกไว้แล้ว!';

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
        'แชท %s ได้ถูกปิดและถูกผนวกลงในตั๋วสำเร็จแล้ว';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        '';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%sเข้าร่วมแชทในฐานะผู้สังเกตการณ์';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = '';
    $Self->{Translation}->{'New request for joining a chat'} = 'คำขอใหม่สำหรับการเข้าร่วมการสนทนา';
    $Self->{Translation}->{'Agent invited %s.'} = 'เอเย่นต์ที่ได้รับเชิญ% s';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s เปลี่ยนทางแชทไปยัง %s';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s ได้เปลี่ยนไปเป็นโหมดผู้เข้าร่วม';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s ได้เปลี่ยนไปเป็นโหมดสังเกตการณ์';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s ได้ปฏิเสธคำขอของการแชท';
    $Self->{Translation}->{'Need'} = '';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'การแจ้งเตือนทั้งหมด';
    $Self->{Translation}->{'Seen Notifications'} = 'การแจ้งเตือนที่เห็นแล้ว';
    $Self->{Translation}->{'Unseen Notifications'} = 'การแจ้งเตือนที่มองไม่เห็น';
    $Self->{Translation}->{'Notification Web View'} = 'Webview การแจ้งเตือน';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'ชื่อนี้ถูกใช้งานแล้ว โปรดเลือกชื่ออื่น';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'โปรดระบุรายการ cron ที่ถูกต้อง';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = '';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'คุณจะไม่สามารถใช้งานการสนทนาภายนอก คุณต้องการที่จะออนไลน์ต่อไปหรือไม่';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'คุณยังไม่มีช่องทางแชทภายนอกที่ได้รับมอบหมาย';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'ยกเลิกที่เลือกไว้';
    $Self->{Translation}->{'Object Type'} = 'ประเภทของออบเจค';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        '';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'เปิดการร้องขอการแชท';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s รายงาน';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'ข้อผิดพลาด: ไม่สามารถสร้างกราฟนี้ได้: %s';
    $Self->{Translation}->{'Table of Contents'} = 'สารบัญ';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'ช่องการแชทเริ่มต้น';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'เปิดใช้งานการสนับสนุนการแชท';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'การลงทะเบียนโมดูล Frontend (ปิดการใช้งานการเชื่อมโยงการสนทนา หากฟีเจอร์การสนทนาถูกปิดใช้งานหรือเอเย่นต์ไม่ได้อยู่ในกลุ่มแชท)';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'กลุ่มเอเย่นต์ที่สามารถยอมรับการร้องขอการแชทและแชท';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'กลุ่มเอเย่นต์ที่สามารถสร้างการร้องขอแชท';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = '';
    $Self->{Translation}->{'Agent interface availability.'} = 'ความพร้อมใช้งานอินเตอร์เฟซตัวแทน';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'โมดูลการแจ้งเตือนของเอเย่นต์อินเตอร์เฟซเพื่อตรวจสอบสำหรับการร้องขอเปิดการแชท';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'อนุญาตให้ลูกค้าเลือกช่องทางแชทที่มีตัวแทนที่มีอยู่เท่านั้น (s)';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'อนุญาตให้ผุ้ใช้สาธารณะเลือกช่องทางแชทที่มีตัวแทนที่มีอยู่เท่านั้น (s)';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'อนุญาตให้มีการแจ้งเตือน WebView ในรูปแบบขนาดเล็ก';
    $Self->{Translation}->{'Chat Channel'} = 'ช่องทางแชท';
    $Self->{Translation}->{'Chat Channel:'} = 'ช่องทางแชท:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'ช่องทางสำหรับการพูดคุยที่จะใช้สำหรับการสื่อสารที่เกี่ยวข้องกับตั๋วในคิวนี้';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'ช่องทางแชทในการทำแผนที่คิว';
    $Self->{Translation}->{'Chat overview'} = 'ภาพรวมของการแชท';
    $Self->{Translation}->{'Chats'} = 'แชท';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'ล้างค่าบันทึกการสนทนาเก่า';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'การแจ้งเตือนคอลัมน์ WebView จะกรองการแจ้งเตือน WebView ขนาด "เล็ก"';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'คอลัมน์ที่สามารถกรองข้อมูลได้ในการแจ้งเตือน WebView การตั้งค่าที่เป็นไปได้: 0 = ปิดใช้งาน 1 = พร้อมใช้ 2 = เปิดใช้งานตามค่าเริ่มต้น ';
    $Self->{Translation}->{'Contact with data'} = 'ติดต่อกับข้อมูล';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'สร้างและจัดการช่องแชท';
    $Self->{Translation}->{'Create new chat'} = 'สร้างแชทใหม่';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'การลงทะเบียนโมดูล Frontend ของลูกค้า (ปิดการใช้งานการเชื่อมโยงการสนทนา หากฟีเจอร์การสนทนาถูกปิดใช้งานหรือเอเย่นต์ไม่ได้อยู่ในกลุ่มแชท)';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'ใช้ชื่อเริ่มต้นของตัวแทนสำหรับลูกค้าและอินเตอร์เฟซสาธารณะ หากเปิดใช้ชื่อจริงของตัวแทนจะไม่ปรากฏขึ้นในให้กับลูกค้า / ผู้ใช้ทั่วไปในขณะที่ใช้การแชท';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'ข้อความเริ่มต้นสำหรับอินเตอร์เฟซของลูกค้า';
    $Self->{Translation}->{'Default text for the public interface.'} = 'ข้อความเริ่มต้นสำหรับอินเตอร์เฟซสาธารณะ';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'กำหนดรายการของปุ่มการตั้งค่ากลุ่มตัวแทนที่จะมองเห็นได้ในอินเตอร์เฟซของลูกค้า (ทำงานเฉพาะในกรณีที่ DefaultAgentName ถูกปิดใช้งาน) ตัวอย่าง: เพิ่มภาษา หากคุณต้องการแสดง PreferencesGroups###Language';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'กำหนดข้อความสำหรับการตั้งค่าเอเย่นต์ในอินเตอร์เฟสของลูกค้า (ทำงานเฉพาะถ้า DefaultAgentName ถูกปิดใช้งาน)';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'กำหนดถ้าผู้ใช้ของลูกค้าสามารถเลือกช่องทางแชท ถ้าไม่แชทจะถูกสร้างขึ้นในช่องทางสำหรับการพูดคุยเริ่มต้น';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'กำหนดหากการล็อคตั๋วจำเป็นต้องมีการเริ่มต้นการสนทนากับลูกค้าจากมุมมองซูมตั๋ว';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'กำหนดถ้าตัวเลขควรจะถูกผนวกเข้ากับDefaultAgentName หากเปิดใช้งานร่วมกับ DefaultAgentName จะมีค่าเป็นตัวเลข (เช่น 1,2,3, ... )';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'กำหนดถ้าผู้ใช้สาธารณะสามารถเลือกช่องทางแชท ถ้าไม่แชทจะถูกสร้างขึ้นในช่องทางสำหรับการพูดคุยเริ่มต้น';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'กำหนดโมดูลเพื่อแสดงการแจ้งเตือนในอินเตอร์เฟซของเอเย่น์ ถ้าเอเย่นต์สามารถใช้งานการสนทนาภายนอก แต่ลืมที่จะกำหนดช่องทางที่ต้องการ (s)';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'กำหนดโมดูลเพื่อแสดงการแจ้งเตือนในอินเตอร์เฟซของเอเย่น์ ถ้าเอเย่นต์ไม่สามารถสนทนากับลูกค้า (เฉพาะในกรณีที่ Ticket::Agent::AvailableForChatsAfterLogin ถูกตั้งค่าเป็น No)';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'กำหนดจำนวนวันที่การแจ้งเตือนควรจะแสดงอยู่ในหน้าจอของมุมมองเว็บแจ้งเตือน (ค่า \'0\' หมายถึงแสดงตลอดเวลา)';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'กำหนดคำสั่งของหน้าต่างแชท';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'กำหนดเส้นทางไปยังไบนารี PhantomJS คุณสามารถใช้การสร้างสถิติจาก http://phantomjs.org/download.html สำหรับขั้นตอนการติดตั้งโดยง่าย';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'กำหนดระยะเวลา (นาที) ก่อนที่จะไม่มีข้อความคำตอบแสดงให้กับลูกค้า';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = '';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = '';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'กำหนดการตั้งค่าสำหรับการแจ้งเตือนตั๋ว';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'กำหนดแหล่งที่มาของข้อมูลแบบไดนามิกสำหรับการจัดเก็บข้อมูลที่ผ่านมา';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'กำหนดฟิลด์เป้าหมายแบบไดนามิกสำหรับการจัดเก็บข้อมูลที่ผ่านมา';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'ฟิลด์ไดนามิก Contact Data Backend GUI';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'ฟิลด์แบบไดนามิก Database Backend GUI';
    $Self->{Translation}->{'Edit contacts with data'} = 'แก้ไขรายชื่อผู้ติดต่อด้วยข้อมูล';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'เปิดใช้งานฟีเจอร์การแจ้งเตือน WebView ที่ทำงานเป็นกลุ่มสำหรับ frontend ของเอเย่นต์ในการทำงานมากกว่าหนึ่งการแจ้งเตือนในเวลาเดียวกัน';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'เปิดใช้งานการแจ้งเตือน WebView คุณลักษณะการทำงานเป็นกลุ่มเฉพาะกลุ่มที่ระบุไว้';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'เปิดใช้งานมุมมองไทม์ไลน์ใน AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'การลงทะเบียนโมดูลอีเว้นท์ (เก็บข้อมูลที่ผ่านมาในฟิลด์แบบไดนามิก)';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = '';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'การลงทะเบียนโมดูล Frontend สำหรับอินเตอร์เฟซสาธารณะ';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'สร้าง HTML สำหรับการแสดงความคิดเห็นสำหรับบล็อกที่ระบุไว้เพื่อให้ฟิลเตอร์สามารถใช้งานได้';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'หากเปิดการใช้งานจะถูกตรวจสอบความพร้อมตัวแทนเมื่อเข้าสู่ระบบ หากผู้ใช้สามารถใช้การสนทนาภายนอกก็จะถูกลดความพร้อมเพื่อการสนทนาภายในเท่านั้น';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'ถ้าตั้งค่าสถานะนี้เปน ใช่ การแจ้งเตือนจะแสดงในแต่ละหน้าถ้าเอเย่นต์ในปัจจุบันไม่สามารถใช้ได้สำหรับการแชท';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'ถ้าตั้งค่าสถานะนี้เป็น ใช่ เอเย่นต์สามารถเริ่มต้นการสนทนากับลูกค้าได้โดยไม่มีตั๋ว';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'ถ้าตั้งค่าสถานะนี้เป็น ใช่ ลูกค้าสามารถเริ่มต้นการสนทนากับเอเย่นต์ได้โดยไม่มีตั๋ว ';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'ถ้าตั้งค่าสถานะนี้เป็น ใช่ ลูกค้าที่มีตั๋วเท่านั้นที่สามารถเริ่มต้นการสนทนาจากมุมมองการซูมตั๋ว';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'ถ้าตั้งค่าสถานะนี้เป็น ใช่ การเริ่มต้นแชทจากมุมมองการซูมตั๋วของเอเย่นต์เท่านั้นที่จะเป็นไปได้ในกรณีที่ลูกค้าที่มีตั๋วกำลังออนไลน์';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'ถ้าตั้งค่าสถานะนี้เป็น ใช่ การเริ่มต้นแชทจากมุมมองการซูมตั๋วของลูกค้าเท่านั้นที่จะเป็นไปได้ในกรณีมีตัวแทนในช่องทางแชทที่ถูกเชื่อมโยง';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'ทำให้มันเป็นไปได้เพื่อที่จะเริ่มต้นการสนทนากับลูกค้าจากอินเตอร์เฟซของเอเย่นต์';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'ทำให้มันเป็นไปได้ที่จะเริ่มต้นการสนทนากับเอเย่นต์จากอินเตอร์เฟซของลูกค้า';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'ทำให้มันเป็นไปได้ที่จะเริ่มต้นการสนทนากับเอเย่นต์จากอินเตอร์เฟซของลูกค้า';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'ทำให้มันเป็นไปได้ที่จะเริ่มต้นการสนทนากับเอเย่นต์จากอินเตอร์เฟซสาธารณะ';
    $Self->{Translation}->{'Manage team agents.'} = '';
    $Self->{Translation}->{'My chats'} = 'แชทของฉัน';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'ชื่อของช่องทางแชทเริ่มต้น หากช่องนี้ไม่มีอยู่ก็จะถูกสร้างขึ้นโดยอัตโนมัติ โปรดอย่าสร้างช่องแชทที่มีชื่อเดียวกับช่องทางแชทเริ่มต้น ช่องทางเริ่มต้นไม่สามารถแสดงได้ถ้าช่องแชทได้รับการเปิดใช้งานในอินเตอร์เฟซของลูกค้าและการอินเตอร์เฟซสาธารณะ แชทเอเย่นต์ถึงเอเย่นต์จะอยู่ในช่องทางเริ่มต้น';
    $Self->{Translation}->{'No agents available message.'} = 'ไม่มีข้อความจากเอเย่นต์ที่มีอยู่';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'จำกัดการแจ้งเตือนในแต่ละหน้าสำหรับการแจ้งเตือน WebView  "เล็ก"';
    $Self->{Translation}->{'Notification web view'} = 'การแจ้งเตือน WebView ';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'จำกัดการแจ้งเตือน WebView "เล็ก"';
    $Self->{Translation}->{'Notifications Unseen:'} = 'การแจ้งเตือน Unseen:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'จำนวนวันหลังจากที่แชทจะถูกลบ';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'จำนวนชั่วโมงหลังจากการแชทแบบปิดจะถูกลบ';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'กรองเอาท์พุทสำหรับไฟล์มาตรฐาน TT ';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        '';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'กรองเอาท์พุทเพื่อฉีด JavaScript ที่จำเป็นเข้าไปในมุมมอง';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = '';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'พารามิเตอร์สำหรับออบเจค ChatChannel ในมุมมองการตั้งค่าของอินเตอร์เฟซเอเย่นต์';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'พารามิเตอร์สำหรับหน้าเว็บ (ซึ่งการแจ้งเตือนจะแสดง) ของมุมมองการแจ้งเตือนขนาดเล็ก';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'ระดับการอนุญาตที่จะเริ่มต้นการสนทนากับลูกค้าจากมุมมองการซูมตั๋วเอเย่นต์';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'โปรดอดทนรอสักครู่จนกระทั่งหนึ่งในเอเย่นต์ของเรสามารถจัดการกับคำขอแชทของคุณ ขอขอบคุณสำหรับความอดทนของคุณ.';
    $Self->{Translation}->{'Prepend'} = 'ย่อหน้า';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'ลบการสนทนาแบบปิดที่เก่ากว่า ChatEngine::ChatTTL ออก';
    $Self->{Translation}->{'Remove old chats.'} = 'ลบการสนทนาเก่า';
    $Self->{Translation}->{'Resource overview page.'} = '';
    $Self->{Translation}->{'Resource overview screen.'} = '';
    $Self->{Translation}->{'Resources list.'} = '';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'เรียกใช้การค้นหาสัญลักษณ์เริ่มต้นของรายชื่อที่มีอยู่กับข้อมูลเมื่อเข้าถึงโมดูล AdminContactWithData';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'ตั้งค่าถ้าการร้องขอการแชทสามารถส่งออกจากมุมมองการซุมตั๋วเอเย่นต์';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'ตั้งค่าถ้าการร้องขอการแชทสามารถส่งออกจากมุมมองการซุมตั๋วลูกค้า';
    $Self->{Translation}->{'Show all ticket attachments'} = 'แสดงตั๋วที่มีสิ่งที่แนบมาทั้งหมด';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'แสดงสิ่งที่แนบมาที่สามารถใช้ได้ทั้งหมด';
    $Self->{Translation}->{'Start new chat'} = 'เริ่มการแชทใหม่';
    $Self->{Translation}->{'Team agents management screen.'} = '';
    $Self->{Translation}->{'Team list'} = '';
    $Self->{Translation}->{'Team management screen.'} = '';
    $Self->{Translation}->{'Team management.'} = '';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'ข้อความที่จะถูกแสดงในการเลือกของ SLA นี้ ใน CustomerTicketMessage.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'โลโก้ที่แสดงในส่วนหัวของอินเตอร์เฟซเอเย่นต์สำหรับสกีน "ธุรกิจ" โปรดดูที่ "ตัวแทนโลโก้" สำหรับรายละเอียดเพิ่มเติม';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'ไม่มีตัวแทนการแชทที่พร้อมใช้งานในปัจจุบัน กรุณาลองใหม่อีกครั้งในภายหลัง.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'ไม่มีตัวแทนการแชทที่พร้อมใช้งานในปัจจุบัน หากต้องการเพิ่มบทความตั๋วที่มีอยู่, กรุณาคลิกที่นี่:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'ไม่มีตัวแทนการแชทที่พร้อมใช้งานในปัจจุบัน หากต้องการสร้างตั๋วใหม่โปรดคลิกที่นี่:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'แชทนี้ได้สิ้นสุดลงแล้ว กรุณาปิดหรือมันจะถูกปิดโดยอัตโนมัติ';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'แชทนี้ได้สิ้นสุดลงแล้ว กรุณาปิดหรือมันจะถูกปิดโดยอัตโนมัติและคุณสามารถดาวน์โหลดแชทนี้';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'แชทนี้เสร็จสมบูรณ์แล้ว ตอนนี้คุณสามารถปิดหน้าต่างแชทนี้ได้';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'แชทนี้เสร็จสมบูรณ์แล้ว คุณสามารถเริ่มการแชทใหม่โดยใช้ปุ่มที่ด้านบนของหน้านี้';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'รายการแถบเครื่องมือสำหรับการแจ้งเตือน WebView';
    $Self->{Translation}->{'Video and audio call screen.'} = '';
    $Self->{Translation}->{'View notifications'} = 'ดูการแจ้งเตือน';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        '';

}

1;
