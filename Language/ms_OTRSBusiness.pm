# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::ms_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Urus Saluran Chat';
    $Self->{Translation}->{'Add Chat Channel'} = 'Tambah Saluran Chat';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Edit Saluran Chat';
    $Self->{Translation}->{'Name invalid'} = 'Nama tidak sah';
    $Self->{Translation}->{'Need Group'} = 'Perlu Kumpulan';
    $Self->{Translation}->{'Need Valid'} = 'Perlu Sah';
    $Self->{Translation}->{'Comment invalid'} = 'Komen tidak sah';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'Status servis Cloud';
    $Self->{Translation}->{'Cloud service availability'} = 'Kebolehdapatan servis Cloud';
    $Self->{Translation}->{'Remaining SMS units'} = 'Baki unit SMS';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Adalah mustahil pada masa ini untuk memeriksa keadaan servis Cloud.';
    $Self->{Translation}->{'Phone field for agent'} = 'Medan telefon untuk agen';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Medan data agen di mana daripada nombor telefon untuk menghantar pesanan melalui SMS perlu diambil.';
    $Self->{Translation}->{'Phone field for customer'} = 'Medan telefon untuk pelanggan';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'Bidang data pelanggan yang nombor telefon bimbit untuk menghantar mesej melalui SMS perlu diambil.';
    $Self->{Translation}->{'Sender string'} = 'String penghantar';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Akan ditunjukkan sebagai nama penghantar SMS (Tidak lebih daripada 11 aksara).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Bidang ini diperlukan dan mestilah tidak melebihi 11 aksara.';
    $Self->{Translation}->{'Allowed role members'} = 'Membenarkan peranan ahli';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Jika dipilih, hanya pengguna yang diberikan peranan ini akan dapat menerima mesej melalui SMS (pilihan).';
    $Self->{Translation}->{'Save configuration'} = 'Simpan konfigurasi';
    $Self->{Translation}->{'Data Protection Information'} = 'Maklumat Perlindungan Data';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Kenalan dengan pengurusan data';
    $Self->{Translation}->{'Add contact with data'} = 'Tambah kenalan dengan data';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Sila masukkan istilah carian untuk mencari kenalan dengan data.';
    $Self->{Translation}->{'Edit contact with data'} = 'Edit kenalan dengan data';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Ini adalah kemungkinan sifat-sifat data bagi kenalan.';
    $Self->{Translation}->{'Mandatory fields'} = 'Medan wajib';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Dipisahkan oleh koma senarai kekunci mandatori (pilihan). Kekunci \'Nama\'  dan \'ValidID\' sentiasa wajib dan tidak perlu disenaraikan di sini.';
    $Self->{Translation}->{'Sorted fields'} = 'Medan dikelaskan';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Dipisahkan oleh koma senarai kekunci untuk jenis (pilihan). Kunci disenaraikan di sini datang terdahulu, semua medan yang tinggal selepas itu dan disusun mengikut abjad.';
    $Self->{Translation}->{'Searchable fields'} = 'Medan boleh dicari';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Dipisahkan oleh koma senarai kekunci dicari (pilihan). Kunci \'Nama\' sentiasa boleh dicari dan tidak perlu disenaraikan di sini.';
    $Self->{Translation}->{'Add/Edit'} = 'Tambah/Edit';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'JenisData';
    $Self->{Translation}->{'Searchfield'} = 'MedanCarian';
    $Self->{Translation}->{'Listfield'} = 'Medansenarai';
    $Self->{Translation}->{'Driver'} = 'Pemacu';
    $Self->{Translation}->{'Server'} = 'Pelayan';
    $Self->{Translation}->{'Table / View'} = 'Jadual / Paparan';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = '';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Cariprefix';
    $Self->{Translation}->{'Searchsuffix'} = 'Carisuffix';
    $Self->{Translation}->{'Result Limit'} = 'Had Keputusan';
    $Self->{Translation}->{'Case Sensitive'} = 'Huruf Sensitif';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Nombor SMS Penerima';

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
    $Self->{Translation}->{'Dismiss'} = 'Abaikan';
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
    $Self->{Translation}->{'Manage Chats'} = 'Urus Chat';
    $Self->{Translation}->{'Hints'} = 'Petunjuk';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Sila ambil perhatian: Tab ini akan digunakan oleh mana-mana permintaan yang berkaitan dengan chat. Jika anda meninggalkan pengurus chat (contohnya dengan menggunakan bar navigasi di bahagian atas halaman), memulakan chat baru atau tindakan chat lain yang berkaitan mungkin akan menambah nilai tab ini bila-bila masa. Ini bermakna adalah disyorkan untuk meninggalkan pengurus chat terbuka pada tab tertentu.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Permohonan Chat Umum Daripada Pelanggan';
    $Self->{Translation}->{'My Chat Channels'} = 'Saluran Chat Saya';
    $Self->{Translation}->{'All Chat Channels'} = 'Semua Saluran Chat';
    $Self->{Translation}->{'Channel'} = 'Saluran';
    $Self->{Translation}->{'Requester'} = 'Pemohon';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Permohonan chat sedang dimuatnaik, sila bersedia...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Permohonan Chat Umum Daripada Pengguna Awam';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Permohonan Chat Peribadi Untuk Anda';
    $Self->{Translation}->{'My Active Chats'} = 'Chat Aktif Saya';
    $Self->{Translation}->{'Open ticket'} = 'Buka tiket';
    $Self->{Translation}->{'Open company'} = 'Buka syarikat';
    $Self->{Translation}->{'Discard & close this chat'} = 'Buang & tutup chat ini';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Memantau kesemua aktiviti dalam chat ini';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Memantau aktiviti pelanggan dalam chat ini';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Tidak memantau chat ini';
    $Self->{Translation}->{'Audio Call'} = '';
    $Self->{Translation}->{'Video Call'} = '';
    $Self->{Translation}->{'Toggle settings'} = 'Tetapan toggle';
    $Self->{Translation}->{'Leave chat'} = 'Tinggalkan chat';
    $Self->{Translation}->{'Leave'} = 'Tinggalkan';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Cipta tiket telefon baharu daripada chat ini dan tutup selepasnya';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Lampirkan chat ini ke tiket sedia ada dan tutup selepasnya';
    $Self->{Translation}->{'Append'} = 'Lampirkan';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Jemput agen tambahan untuk menyertai chat ini';
    $Self->{Translation}->{'Invite'} = 'Jemput';
    $Self->{Translation}->{'Change chat channel'} = 'Tukar saluran chat';
    $Self->{Translation}->{'Channel change'} = 'Tukar saluran';
    $Self->{Translation}->{'Switch to participant'} = 'Beralih kepada peserta';
    $Self->{Translation}->{'Participant'} = 'Peserta';
    $Self->{Translation}->{'Switch to an observer'} = 'Beralih kepada pemerhati';
    $Self->{Translation}->{'Observer'} = 'Pemerhati';
    $Self->{Translation}->{'Download this Chat'} = 'Muat turun Chat ini';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Sertai chat jemputan sebagai pemerhati';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Sertai chat jemputan sebagai peserta';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Buka chat dalam Popup';
    $Self->{Translation}->{'New window'} = 'Tetingkap baru';
    $Self->{Translation}->{'New Message'} = 'Mesej baharu';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter untuk baris baru)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s telah meninggalkan ruangan sembang ini.';
    $Self->{Translation}->{'Online agents'} = 'Agen dalam talian';
    $Self->{Translation}->{'Reload online agents'} = 'Muat semula agen dalam talian';
    $Self->{Translation}->{'Destination channel'} = 'Saluran destinasi';
    $Self->{Translation}->{'Open chat'} = 'Buka chat';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = '';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Anda sudah tidak lagi di dalam chat ini. Klik mesej ini untuk memadam kotak chat.';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Tiada permohonan chat terkini.';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Ini akan memadam sepenuhnya kandungan chat. Adakah anda ingin meneruskan?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Permohonan chat ini sudah diterima oleh orang lain.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Anda tidak memiliki kebenaran untuk menerima permohonan chat ini.';
    $Self->{Translation}->{'Please select a user.'} = 'Sila pilih pengguna.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Sila pilih peringkat keizinan.';
    $Self->{Translation}->{'Invite Agent.'} = 'Jemput Agen';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Sila pilih destinasi saluran chat.';
    $Self->{Translation}->{'Please select a channel.'} = 'Sila pilih saluran.';
    $Self->{Translation}->{'Chat preview'} = 'Perlihat chat';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Sila pilih saluran yang sah.';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Agen untuk chat pelanggan.';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Pelanggan untuk chat agen.';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Agen untuk chat agen.';
    $Self->{Translation}->{'Public to agent chat.'} = 'Orang awam untuk chat agen.';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Anda tidak boleh meninggalkan Pelanggan berseorangan di dalam chat.';
    $Self->{Translation}->{'You'} = 'Anda';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Chat anda tidak dapat dimulakan kerana kesilapan dalaman.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Permohonan chat anda sudah dicipta.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Pada masa ini terdapat permintaan chat terbuka %s.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Pengguna sudah dijemput untuk chat anda!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'Kebenaran tidak mencukupi.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'Sistem tidak dapat menyimpan turutan chat anda.';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Lampirkan Chat untuk Tiket';
    $Self->{Translation}->{'Append to'} = 'Lampirkan ke';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'Chat ini akan dilampirkan sebagai artikel baru untuk tiket yang dipilih.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Chat dengan';
    $Self->{Translation}->{'Leave Chat'} = 'Tinggalkan Chat';
    $Self->{Translation}->{'User is currently in the chat.'} = '';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Saluran chat terkini';
    $Self->{Translation}->{'Available channels'} = 'Saluran tersedia';
    $Self->{Translation}->{'Reload'} = 'Muat semula';
    $Self->{Translation}->{'Update Channel'} = 'Kemaskini saluran';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Butiran carian';
    $Self->{Translation}->{'Add an additional attribute'} = 'Tambah sifat atribut tambahan';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'Lihat butiran';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Pemberitahuan setiap muka surat';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Tiada data pemberitahuan dijumpai.';
    $Self->{Translation}->{'Related To'} = 'Berkaitan dengan';
    $Self->{Translation}->{'Select this notification'} = 'Pilih pemberitahuan ini';
    $Self->{Translation}->{'Zoom into'} = 'Zum ke';
    $Self->{Translation}->{'Dismiss this notification'} = 'Abaikan pemberitahuan ini';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Abaikan Pemberitahuan Dipilih';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Adakah anda benar-benar mahu untuk menyingkirkan pemberitahuan dipilih?';
    $Self->{Translation}->{'OTRS Notification'} = 'Pemberitahuan OTRS';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Laporan » Tambah';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Tambah Laporan Statistik Baru';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Laporan » Edit — %s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Di sini anda boleh menggabungkan beberapa statistik ke laporan yang anda boleh janakan sebagai PDF secara manual atau secara automatik pada masa-masa dikonfigurasikan.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Sila ambil perhatian bahawa anda hanya boleh memilih carta sebagai format output statistik jika anda konfigurasikan PhantomJS pada sistem anda.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'Mengkonfigurasi PhantomJS';
    $Self->{Translation}->{'General settings'} = 'Tetapan umum';
    $Self->{Translation}->{'Automatic generation settings'} = 'Tetapan penjanaan automatik';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Tetapan penjanaan masa (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Nyatakan apabila laporan itu perlu secara automatik dijana dalam format cron , contoh: "10 1 * * *" untuk setiap hari pada 01:10 am. ';
    $Self->{Translation}->{'Last automatic generation time'} = 'Tetapan penjanaan masa akhir ';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Masa penjanaan automatik yang dirancang seterusnya';
    $Self->{Translation}->{'Automatic generation language'} = 'Bahasa penjanaan automatik';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'Bahasa yang akan digunakan apabila laporan dijana secara automatik.';
    $Self->{Translation}->{'Email subject'} = 'Subjek emel';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = '';
    $Self->{Translation}->{'Email body'} = 'Badan emel';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'Tentukan teks untuk emel yang dijana secara automatik.';
    $Self->{Translation}->{'Email recipients'} = 'Penerima emel';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'Nyatakan alamat emel penerima (dipisahkan oleh koma).';
    $Self->{Translation}->{'Output settings'} = 'Tetapan output';
    $Self->{Translation}->{'Headline'} = 'Tajuk utama';
    $Self->{Translation}->{'Caption for preamble'} = 'Keterangan untuk mukadimah';
    $Self->{Translation}->{'Preamble'} = 'Mukadimah';
    $Self->{Translation}->{'Caption for epilogue'} = 'Keterangan untuk penutup';
    $Self->{Translation}->{'Epilogue'} = 'Penutup';
    $Self->{Translation}->{'Add statistic to report'} = 'Tambah statistik ke laporan';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Laporan » Gambaran keseluruhan';
    $Self->{Translation}->{'Statistics Reports'} = 'Laporan Statistik ';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Edit laporan statistik "%s".';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Padam laporan statistik "%s".';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Adakah anda pasti untuk memadam laporan ini?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Laporan » Lihat - % s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Laporan statistik ini mengandungi ralat konfigurasi dan pada masa ini tidak boleh digunakan.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'Lampiran';
    $Self->{Translation}->{'Attachment Overview'} = 'Gambaran Keseluruhan Lampiran';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Tiket ini tidak mempunyai lampiran.';
    $Self->{Translation}->{'Hide inline attachments'} = '';
    $Self->{Translation}->{'Filter Attachments'} = 'Tapis Lampiran';
    $Self->{Translation}->{'Select All'} = 'Pilih Semua';
    $Self->{Translation}->{'Click to download this file'} = 'Klik untuk muat turun fail ini';
    $Self->{Translation}->{'Open article in main window'} = 'Buka artikel dalam tetingkap utama';
    $Self->{Translation}->{'Download selected files as archive'} = 'Muat turun fail dipilih sebagai arkib';

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
    $Self->{Translation}->{'%s has joined this chat.'} = '%s telah menyertai chat ini.';
    $Self->{Translation}->{'Incoming chat requests'} = 'Permintaan chat masuk';
    $Self->{Translation}->{'Outgoing chat requests'} = 'Permintaan chat keluar';
    $Self->{Translation}->{'Active chats'} = 'Chat aktif';
    $Self->{Translation}->{'Closed chats'} = 'Chat ditutup';
    $Self->{Translation}->{'Chat request description'} = 'Penerangan permohonan chat';
    $Self->{Translation}->{'Create new ticket'} = 'Cipta tiket baru';
    $Self->{Translation}->{'Add an article'} = 'Tambah artikel';
    $Self->{Translation}->{'Start a new chat'} = 'Mulakan chat baru';
    $Self->{Translation}->{'Select channel'} = 'Pilih saluran';
    $Self->{Translation}->{'Add to an existing ticket'} = 'Tambah ke tiket sedia ada';
    $Self->{Translation}->{'Active Chat'} = 'Chat Aktif';
    $Self->{Translation}->{'Download Chat'} = 'Muat turun chat';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Chat sedang dimuatkan...';
    $Self->{Translation}->{'Chat completed'} = 'Chat lengkap';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = '';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Sila sahkan pilihan anda';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Nama anda';
    $Self->{Translation}->{'Start a new Chat'} = 'Mulakan Chat baru';
    $Self->{Translation}->{'Chat complete'} = 'Chat lengkap';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Keluarkan statistik';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Jika anda tidak menentukan tajuk di sini, tajuk statistik akan digunakan.';
    $Self->{Translation}->{'Preface'} = 'Prakata';
    $Self->{Translation}->{'Postface'} = 'Postface';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Saluran Chat %s ditambah';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Saluran chat %s diedit';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Servis cloud "%s" dikemaskini!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Konfigurasi Servis Cloud "%s" disimpan!';

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
        'Chat %s telah ditutup dan telah berjaya dilampirkan pada tiket %s.';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        '';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s telah menyertai chat ini sebagai pemerhati.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = '';
    $Self->{Translation}->{'New request for joining a chat'} = 'Permintaan baru untuk menyertai chat';
    $Self->{Translation}->{'Agent invited %s.'} = 'Agen menjemput %s.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s menukar saluran chat kepada %s.';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s telah menukar ke mod peserta.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s telah menukar ke mod pemerhati.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s telah menolak permohonan chat.';
    $Self->{Translation}->{'Need'} = '';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'Semua pemberitahuan';
    $Self->{Translation}->{'Seen Notifications'} = 'Pemberitahuan dilihat';
    $Self->{Translation}->{'Unseen Notifications'} = 'Pemberitahuan tidak dilihat';
    $Self->{Translation}->{'Notification Web View'} = 'Pemberitahuan Paparan Web';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Nama ini telah digunakan, sila pilih yang lain.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Sila berikan kemasukan cron yang sah.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = '';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Anda tidak tersedia untuk chat luar. Adakah anda ingin pergi ke dalam talian?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Anda tidak mempunyai mana-mana saluran chat luaran yang diberikan.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Abaikan Yang Dipilih';
    $Self->{Translation}->{'Object Type'} = 'Jenis Objek';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        '';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Permohonan Chat Terbuka';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = 'Laporan %s ';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Ralat: graf ini tidak dapat dijana : %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Isi kandungan';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'Saluran chat default';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Mengaktifkan sokongan chat.';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'Pendaftaran modul agen bahagian hadapan (melumpuhkan pautan chat jika ciri chat tidak aktif atau agen tiada di dalam kumpulan chat).';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'Kumpulan agen yang boleh menerima permintaan chat dan berbual.';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'Kumpulan ejen yang boleh membuat permintaan chat.';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = '';
    $Self->{Translation}->{'Agent interface availability.'} = 'Ketersediaan antara muka ejen.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Modul pemberitahuan antara muka agen untuk memeriksa permintaan sembang terbuka.';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Membenarkan pelanggan untuk memilih saluran yang mempunyai ejen(ejen-ejen) tersedia sahaja.';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Membenarkan pengguna awam untuk memilih saluran yang mempunyai ejen(ejen-ejen) tersedia sahaja.';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Membenarkan mempunyai pandangan web pemberitahuan berformat kecil.';
    $Self->{Translation}->{'Chat Channel'} = 'Saluran Chat';
    $Self->{Translation}->{'Chat Channel:'} = 'Saluran Chat:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'Saluran chat yang akan digunakan untuk komunikasi yang berkaitan dengan tiket dalam barisan ini.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Saluran chat ke pemetaan barisan.';
    $Self->{Translation}->{'Chat overview'} = 'Tinjauan chat';
    $Self->{Translation}->{'Chats'} = 'Chat';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Membersihkan log chat lama.';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'Penapis paparan web ruangan pemberitahuan untuk Paparan web Pemberitahuan jenis "Kecil".';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Kolum yang boleh ditapis dalam paparan web pemberitahuan bagi antara muka ejen. Tetapan yang mungkin: 0 = Dilumpuhkan, 1 = Tersedia, 2 = Diaktifkan secara default.';
    $Self->{Translation}->{'Contact with data'} = 'Kenalan dengan data';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Cipta dan uruskan saluran chat.';
    $Self->{Translation}->{'Create new chat'} = 'Cipta chat baru';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'Pendaftaran modul pelanggan bahagian hadapan (melumpuhkan pautan chat jika ciri chat tidak aktif atau tiada ejen tersedia untuk chat).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Nama ejen default untuk pelanggan dan antara muka awam. Jika didayakan, nama sebenar ejen itu tidak akan dapat dilihat oleh pelanggan/pengguna awam semasa menggunakan chat.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Teks default untuk antara muka pelanggan.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Teks default untuk antara muka awam.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Tentukan senarai kekunci kumpulan keutamaan agen yang akan dapat dilihat dalam antara muka Pelanggan (hanya berfungsi jika DefaultAgentName dilumpuhkan).
Contoh: Jika anda ingin paparkan PreferencesGroups###Language, tambah Bahasa.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Tentukan teks untuk Keutamaan Agen di antara muka Pelanggan (hanya berfungsi jika DefaultAgentName dilumpuhkan).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Menentukan jika pengguna pelanggan boleh memilih Saluran Chat. Jika tidak, chat akan dicipta dalam Saluran Chat default.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Menentukan sekiranya tiket diperlukan untuk memulakan chat dengan pelanggan daripada pandangan zum tiket.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Tentukan jika nombor perlu dilampirkan pada DefaultAgentName. Jika didayakan, bersama-sama dengan DefaultAgentName akan menjadi nombor (contohnya 1,2,3 ,...).';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Menentukan jika pengguna awam boleh memilih Saluran Chat. Jika tidak, chat akan dicipta dalam Saluran Chat default.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Mentakrifkan modul untuk memaparkan pemberitahuan dalam antara muka ejen, jika ejen itu tersedia untuk chat luar, tetapi terlupa untuk menetapkan saluran(saluran-saluran) pilihan.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Mentakrifkan modul untuk memaparkan pemberitahuan dalam antara muka ejen, jika ejen itu tidak tersedia untuk berbual dengan pelanggan (hanya jikaTicket::Agent::AvailableForChatsAfterLogin ditetapkan ke Tidak).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Mentakrifkan bilangan hari pemberitahuan harus masih ditunjukkan dalam skrin paparan pemberitahuan web (nilai \'0\' bermaksud sentiasa menunjukkan).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Menentukan susunan tetingkap chat.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Mentakrifkan jalan untuk binari PhantomJS. Anda boleh menggunakan binaan statik dari http://phantomjs.org/download.html untuk proses pemasangan yang mudah.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Menentukan tempoh masa (dalam minit) sebelum mesej Tiada Jawapan dipaparkan pada pelanggan.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = '';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = '';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Mentakrifkan tetapan untuk pemberitahuan tiket.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Mentakrifkan sumber medan dinamik untuk menyimpan data bersejarah.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Mentakrifkan sasaran medan dinamik untuk menyimpan data bersejarah.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'GUI Backend Kenalan Data Medan Dinamik';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'GUI Backend Pangkalan Data Medan Dinamik';
    $Self->{Translation}->{'Edit contacts with data'} = 'Edit kenalan dengan data';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Membolehkan ciri pemberitahuan web paparan  tindakan pukal untuk bahagian hadapan ejen untuk bekerja pada lebih daripada satu pemberitahuan pada satu masa.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Membolehkan ciri pemberitahuan web paparan  tindakan pukal hanya pada kumpulan yang disenaraikan.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Membolehkan pandangan garis masa dalam AgentTicketZoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'Pendaftaran modul acara (simpan data bersejarah dalam medan dinamik).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = '';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Frontend pendaftaran modul untuk antara muka awam.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'Menjana cangkuk komen HTML untuk blok tertentu supaya penapis boleh menggunakannya.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Jika diaktifkan ia akan memeriksa ketersediaan ejen pada log masuk. Jika pengguna tersedia untuk chat luar, ia akan mengurangkan ketersediaan kepada perbualan dalaman sahaja.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Jika flag ini diset ke Ya, pemberitahuan akan dipaparkan dalam setiap halaman jika agen semasa tidak tersedia untuk chat.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Jika flag ini disetkan kepada Ya, ejen boleh memulakan chat dengan pelanggan tanpa tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Jika flag ini disetkan kepada Ya, pelanggan boleh memulakan chat dengan ejen tanpa tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Jika flag ini disetkan kepada Ya, hanya pelanggan tiket boleh memulakan sembang dari pandangan zum tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Jika flag ini disetkan kepada ya, memulakan chat daripada pandangan zum tiket ejen akan hanya dibolehkan, sekiranya pelanggan tiket berada di atas talian.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'JIka flag ini disetkan ke Ya, memulakan chat daripada pandangan zum tiket akan hanya dibolehkan, sekiranya terdapat agen tersedia dalam saluran chat berkaitan.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Membolehkan untuk meulakan chat dengan pelanggan dari antara muka ejen.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Membolehkan untuk memulakan chat dengan agen dari antara muka ejen.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Membolehkan untuk meulakan chat dengan agen dari antara muka pelanggan.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Membolehkan untuk memulakan chat dengan agen dari antara muka awam.';
    $Self->{Translation}->{'Manage team agents.'} = '';
    $Self->{Translation}->{'My chats'} = 'Chat saya';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Nama saluran chat default. Jika saluran ini tidak wujud, ia akan dibuat secara automatik. Sila jangan wujudkan saluran chat dengan nama yang sama sebagai saluran sembang default. Saluran default tidak akan dipaparkan, jika saluran chat didayakan dalam antara muka Pelanggan dan antara muka Awam. Semua Ejen kepada chat ejen akan berada di dalam saluran default.';
    $Self->{Translation}->{'No agents available message.'} = 'Tiada mesej tersedia ejen.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'Had pemberitahuan setiap halaman untuk paparan "Kecil" pemberitahuan web ';
    $Self->{Translation}->{'Notification web view'} = 'Paparan pemberitahuan web';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'Had pemberitahuan web paparan "Kecil"';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Pemberitahuan Tidak Dilihat:';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'Beberapa hari selepas chat akan dipadamkan.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Beberapa jam selepas chat ditutup akan dipadamkan.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Penapis output untuk fail tt piawai.';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        '';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Penapis Output untuk menyuntik JavaScript diperlukan ke dalam pemandangan.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = '';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'Parameter untuk objek SaluranChat dalam paparan pilihan bagi antara muka ejen.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Parameter untuk halaman (di mana pemberitahuan ditunjukkan) pandangan pemberitahuan kecil.';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'Tahap kebenaran untuk memulakan chat dengan pelanggan dari pandangan zum tiket ejen.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Sila bersama dengan kami sehingga salah seorang daripada ejen-ejen kami mampu untuk mengendalikan permintaan chat anda. Terima kasih atas kesabaran anda.';
    $Self->{Translation}->{'Prepend'} = 'Bahagian awal';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Buang chat yang ditutup lama daripada ChatEngine::ChatTTL.';
    $Self->{Translation}->{'Remove old chats.'} = 'Buang chat lama.';
    $Self->{Translation}->{'Resource overview page.'} = '';
    $Self->{Translation}->{'Resource overview screen.'} = '';
    $Self->{Translation}->{'Resources list.'} = '';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Jalankan carian wildcard awal kenalan sedia ada dengan data semasa mengakses modul AdminContactWithData.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Set jika permintaan chat boleh dihantar dari pandangan zum tiket ejen.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Set jika permintaan chat boleh dihantar dari pandangan zum tiket pelanggan.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Tunjuk semua lampiran tiket';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Menunjukkan semua lampiran yang terdapat dalam tiket.';
    $Self->{Translation}->{'Start new chat'} = 'Mulakan chat baru';
    $Self->{Translation}->{'Team agents management screen.'} = '';
    $Self->{Translation}->{'Team list'} = '';
    $Self->{Translation}->{'Team management screen.'} = '';
    $Self->{Translation}->{'Team management.'} = '';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Teks yang sedang dipaparkan pada pemilihan SLA ini di CustomerTicketMessage.';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Logo ditunjukkan di header antara muka ejen bagi kulit "perniagaan". Lihat "AgentLogo" untuk keterangan lanjut.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'Tiada ejen chat tersedia pada masa ini. Sila cuba sebentar lagi.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'Tiada ejen chat tersedia pada masa ini. Untuk menambah artikel untuk tiket yang sedia ada, sila klik di sini:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'Tiada ejen chat tersedia pada masa ini. Untuk membuat tiket baru, sila klik di sini:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'Chat ini sudah berakhir. Sila tinggalkan atau ia akan ditutup secara automatik.';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'Chat ini sudah berakhir. Sila tinggalkan atau ia akan ditutup secara automatik. Anda boleh memuat turun sembang ini.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'Chat ini sudah selesai. Anda kini boleh menutup tetingkap chat.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'Chat ini sudah selesai. Anda boleh memulakan chat baru menggunakan butang di bahagian atas halaman ini.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Alat-bar item  untuk paparan pemberitahuan web.';
    $Self->{Translation}->{'Video and audio call screen.'} = '';
    $Self->{Translation}->{'View notifications'} = 'Lihat pemberitahuan';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        '';

}

1;
