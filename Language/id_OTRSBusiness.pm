# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::id_OTRSBusiness;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminChatChannel
    $Self->{Translation}->{'Manage Chat Channels'} = 'Mengatur obrolan';
    $Self->{Translation}->{'Add Chat Channel'} = 'Tambah obrolan';
    $Self->{Translation}->{'Edit Chat Channel'} = 'Mengatur obrolan';
    $Self->{Translation}->{'Name invalid'} = 'Nama tidak sah';
    $Self->{Translation}->{'Need Group'} = 'butuh Grup';
    $Self->{Translation}->{'Need Valid'} = 'Perlu sah';
    $Self->{Translation}->{'Comment invalid'} = 'Komentar tidak sah';

    # Template: AdminCloudServiceSMS
    $Self->{Translation}->{'Cloud service status'} = 'status layanan cloud';
    $Self->{Translation}->{'Cloud service availability'} = 'ketersediaan layanan cloud';
    $Self->{Translation}->{'Remaining SMS units'} = 'Sisa unit SMS';
    $Self->{Translation}->{'Is currently not possible to check the state for this cloud service.'} =
        'Saat ini tidak memungkinkan untuk memeriksa state untuk layanan cloud ini.';
    $Self->{Translation}->{'Phone field for agent'} = 'bidang telepon untuk agen';
    $Self->{Translation}->{'Agent data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'field data agen dari mana nomor ponsel untuk mengirim pesan melalui SMS harus diambil.';
    $Self->{Translation}->{'Phone field for customer'} = 'bidang telepon untuk pelanggan';
    $Self->{Translation}->{'Customer data field from which the mobile phone number for sending messages via SMS should be taken.'} =
        'data pelanggan lapangan dari mana nomor ponsel untuk mengirim pesan melalui SMS harus diambil.';
    $Self->{Translation}->{'Sender string'} = 'Pengirim';
    $Self->{Translation}->{'Will be shown as sender name of the SMS (Not longer than 11 characters).'} =
        'Akan ditampilkan sebagai nama pengirim SMS (Tidak lebih dari 11 karakter).';
    $Self->{Translation}->{'This field is required and must be not longer than 11 characters.'} =
        'Bidang ini diperlukan dan tidak lebih dari 11 karakter.';
    $Self->{Translation}->{'Allowed role members'} = 'Memberikan ijin untuk role member';
    $Self->{Translation}->{'If selected, only users assigned to these roles will be able to receive messages via SMS (optional).'} =
        'Jika terpilih, hanya pengguna yang ditugaskan untuk peran ini akan dapat menerima pesan melalui SMS (opsional).';
    $Self->{Translation}->{'Save configuration'} = 'Simpan konfigurasi';
    $Self->{Translation}->{'Data Protection Information'} = 'Informasi Perlindungan Data';

    # Template: AdminContactWithData
    $Self->{Translation}->{'Contact with data management'} = 'Kontak dengan manajemen data';
    $Self->{Translation}->{'Add contact with data'} = 'Tambah kontak dengan data';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Masukkan istilah pencarian untuk mencari kontak dengan data.';
    $Self->{Translation}->{'Edit contact with data'} = 'Edit kontak dengan data';

    # Template: AdminDynamicFieldContactWithData
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Ini adalah atribut data yang mungkin untuk kontak.';
    $Self->{Translation}->{'Mandatory fields'} = 'Bidang wajib';
    $Self->{Translation}->{'Comma separated list of mandatory keys (optional). Keys \'Name\' and \'ValidID\' are always mandatory and doesn\'t have to be listed here.'} =
        'Daftar dipisahkan koma kunci wajib (opsional). Keys \'Nama\' dan \'ValidID\' selalu wajib dan tidak harus tercantum di sini.';
    $Self->{Translation}->{'Sorted fields'} = 'Susunan bidang';
    $Self->{Translation}->{'Comma separated list of keys in sort order (optional). Keys listed here come first, all remaining fields afterwards and sorted alphabetically.'} =
        'Daftar dipisahkan koma kunci dalam urutan (opsional). Kunci tercantum di sini datang pertama, semua bidang yang tersisa setelah itu dan diurutkan berdasarkan abjad.';
    $Self->{Translation}->{'Searchable fields'} = 'Pencarian bidang';
    $Self->{Translation}->{'Comma separated list of searchable keys (optional). Key \'Name\' is always searchable and doesn\'t have to be listed here.'} =
        'Daftar dipisahkan oleh koma, kunci dicari (opsional). Key \'Nama\' selalu dicari dan tidak harus tercantum di sini.';
    $Self->{Translation}->{'Add/Edit'} = 'Tambah/Aturan';

    # Template: AdminDynamicFieldDatabase
    $Self->{Translation}->{'Datatype'} = 'Jenis data';
    $Self->{Translation}->{'Searchfield'} = 'Bidang pencarian';
    $Self->{Translation}->{'Listfield'} = 'Susunan bidang';
    $Self->{Translation}->{'Driver'} = 'Pengemudi';
    $Self->{Translation}->{'Server'} = 'Server';
    $Self->{Translation}->{'Table / View'} = 'Tabel / View';
    $Self->{Translation}->{'Must be unique column from the table entered in Table/View.'} = '';
    $Self->{Translation}->{'CacheTTL'} = 'CacheTTL';
    $Self->{Translation}->{'Searchprefix'} = 'Pencarian prefix';
    $Self->{Translation}->{'Searchsuffix'} = 'Pencarian Suffix';
    $Self->{Translation}->{'Result Limit'} = 'Batas hasil';
    $Self->{Translation}->{'Case Sensitive'} = 'Case sensitif';

    # Template: AdminNotificationEventTransportSMSSettings
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Penerima nomor SMS';

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
    $Self->{Translation}->{'Dismiss'} = 'Memberhentikan';
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
    $Self->{Translation}->{'Manage Chats'} = 'Mengatur obrolan';
    $Self->{Translation}->{'Hints'} = 'Hints';
    $Self->{Translation}->{'Please note: This tab will be used by any request which is related to chats. If you leave the chat manager (e.g. by using the navigation bar on top of the page), starting a new chat or other chat-related actions will possibly reload this tab any time. This means that it is recommended to leave the chat manager opened in this particular tab.'} =
        'Harap dicatat: Tab ini akan digunakan oleh setiap permintaan yang berkaitan dengan obrolan. Jika Anda meninggalkan manajer chatting/obrolan (misalnya dengan menggunakan bar navigasi di atas halaman), memulai obrolan baru atau tindakan yang berhubungan dengan chat lainnya mungkin akan reload tab ini setiap saat. Ini berarti bahwa itu dianjurkan untuk meninggalkan manajer obrolan dibuka di tab tertentu.';
    $Self->{Translation}->{'General Chat Requests From Customers'} = 'Obrolan Permintaan Umum Dari Pelanggan';
    $Self->{Translation}->{'My Chat Channels'} = 'Channel obrolan saya';
    $Self->{Translation}->{'All Chat Channels'} = 'Semua channel dari obrolan';
    $Self->{Translation}->{'Channel'} = 'Channel';
    $Self->{Translation}->{'Requester'} = 'Pemohon';
    $Self->{Translation}->{'Chat requests are being loaded, please stand by...'} = 'Permintaan obrolan sedang dimuat, silakan bersedia ...';
    $Self->{Translation}->{'General Chat Requests From Public Users'} = 'Obrolan Permintaan Umum Dari Pengguna Umum';
    $Self->{Translation}->{'Personal Chat Requests For You'} = 'Obrolan Permintaan Pribadi Untuk Anda';
    $Self->{Translation}->{'My Active Chats'} = 'Obrolan aktif saya';
    $Self->{Translation}->{'Open ticket'} = 'Tiket terbuka';
    $Self->{Translation}->{'Open company'} = 'Perusahaan terbuka';
    $Self->{Translation}->{'Discard & close this chat'} = 'Buang & menutup obrolan ini';
    $Self->{Translation}->{'Monitoring all activity in this chat'} = 'Memonitor semua aktivitas di chat ini';
    $Self->{Translation}->{'Monitoring customer activity in this chat'} = 'Pemantauan aktivitas pelanggan dalam obrolan ini';
    $Self->{Translation}->{'Not monitoring this chat'} = 'Dilarang memantau obrolan ini';
    $Self->{Translation}->{'Audio Call'} = '';
    $Self->{Translation}->{'Video Call'} = '';
    $Self->{Translation}->{'Toggle settings'} = 'pengaturan beralih';
    $Self->{Translation}->{'Leave chat'} = 'Tinggalkan obrolan';
    $Self->{Translation}->{'Leave'} = 'Tinggalkan';
    $Self->{Translation}->{'Create a new phone ticket from this chat and close it afterwards'} =
        'Buat tiket ponsel baru dari obrolan ini dan menutupnya setelah itu';
    $Self->{Translation}->{'Append this chat to an existing ticket and close it afterwards'} =
        'Menambahkan obrolan ini ke tiket yang ada dan menutupnya setelah itu';
    $Self->{Translation}->{'Append'} = 'Menambahkan';
    $Self->{Translation}->{'Invite additional agent to join the chat'} = 'Mengundang agen tambahan untuk bergabung dalam obrolan';
    $Self->{Translation}->{'Invite'} = 'Mengundang';
    $Self->{Translation}->{'Change chat channel'} = 'Ubah obrolan channel';
    $Self->{Translation}->{'Channel change'} = 'Ubah channel';
    $Self->{Translation}->{'Switch to participant'} = 'Tukar ke partisipan';
    $Self->{Translation}->{'Participant'} = 'Partisipan';
    $Self->{Translation}->{'Switch to an observer'} = 'Beralih ke pengamat';
    $Self->{Translation}->{'Observer'} = 'Pengamat';
    $Self->{Translation}->{'Download this Chat'} = 'Muat turun obrolan ini';
    $Self->{Translation}->{'Join invited chat as an observer'} = 'Bergabung obrolan sebagai pengamat';
    $Self->{Translation}->{'Join invited chat as a participant'} = 'Bergabung obrolan sebagai peserta';
    $Self->{Translation}->{'Open chat in a Popup'} = 'Obrolan terbuka disebuah Popup';
    $Self->{Translation}->{'New window'} = 'Window baru';
    $Self->{Translation}->{'New Message'} = 'Pesan baru';
    $Self->{Translation}->{'(Shift + Enter for new line)'} = '(Shift + Enter untuk baris baru)';
    $Self->{Translation}->{'%s has left this chat.'} = '%s meninggalkan obrolan';
    $Self->{Translation}->{'Online agents'} = 'agen secara online';
    $Self->{Translation}->{'Reload online agents'} = 'Reload agen secara online';
    $Self->{Translation}->{'Destination channel'} = 'Tujuan channel';
    $Self->{Translation}->{'Open chat'} = 'Buka obrolan';
    $Self->{Translation}->{'User has already left the chat or has not yet joined it.'} = '';
    $Self->{Translation}->{'You are no longer in this chat. Click this message to remove the chat box.'} =
        'Anda tidak lagi dalam obrolan ini. Klik pesan ini untuk menghapus kotak obrolan';
    $Self->{Translation}->{'There are currently no chat requests.'} = 'Saat ini tidak ada permintaan obrolan';
    $Self->{Translation}->{'This will permanently delete the chat contents. Do you want to continue?'} =
        'Ini akan menghapus isi obrolan secara permanen. Apakah Anda ingin melanjutkan?';
    $Self->{Translation}->{'This chat request was already accepted by another person.'} = 'Permintaan obrolan ini sudah diterima oleh orang lain.';
    $Self->{Translation}->{'You have no permission to accept this chat request.'} = 'Anda tidak memiliki izin untuk menerima permintaan obrolan ini.';
    $Self->{Translation}->{'Please select a user.'} = 'Silakan pilih pengguna.';
    $Self->{Translation}->{'Please select a permission level.'} = 'Silakan pilih tingkat izin.';
    $Self->{Translation}->{'Invite Agent.'} = 'Undang Agen.';
    $Self->{Translation}->{'Please, select destination chat channel.'} = 'Silakan, pilih tujuan saluran obrolan';
    $Self->{Translation}->{'Please select a channel.'} = 'Pilih saluran obrolan';
    $Self->{Translation}->{'Chat preview'} = 'Pratinjau obrolan';
    $Self->{Translation}->{'Please select a valid channel.'} = 'Silakan pilih saluran sah';
    $Self->{Translation}->{'Agent to customer chat.'} = 'Agen untuk pelanggan chat.';
    $Self->{Translation}->{'Customer to agent chat.'} = 'Pelanggan untuk agen chat.';
    $Self->{Translation}->{'Agent to agent chat.'} = 'Obrolan agen ke agen';
    $Self->{Translation}->{'Public to agent chat.'} = 'Publik untuk obrolan agen';
    $Self->{Translation}->{'You can\'t leave Customer alone in the chat.'} = 'Anda tidak bisa meninggalkan Pelanggan sendiri dalam obrolan.';
    $Self->{Translation}->{'You'} = 'Anda';
    $Self->{Translation}->{'Your chat could not be started because of an internal error.'} =
        'Obrolan anda tidak dapat dimulai karena kesalahan internal.';
    $Self->{Translation}->{'Your chat request was created.'} = 'Permintaan obrolan anda telah dibuat.';
    $Self->{Translation}->{'There are currently %s open chat requests.'} = 'Terdapat %s sedang terbuka permintaan chat.';
    $Self->{Translation}->{'User was already invited to your chat!'} = 'Pengguna sudah diundang untuk obrolan Anda!';
    $Self->{Translation}->{'Insufficient permissions.'} = 'izin tidak memadai.';
    $Self->{Translation}->{'System was unable to save your sequence of chats.'} = 'Sistem tidak dapat menyimpan urutan obrolan anda';

    # Template: AgentChatAppend
    $Self->{Translation}->{'Append Chat to Ticket'} = 'Menambahkan obrolan untuk Tiket';
    $Self->{Translation}->{'Append to'} = 'menambahkan ke';
    $Self->{Translation}->{'The chat will be appended as a new article to the chosen ticket.'} =
        'obrolan akan ditambahkan sebagai artikel baru untuk tiket yang dipilih.';

    # Template: AgentChatPopup
    $Self->{Translation}->{'Chat with'} = 'Obrolan dengan';
    $Self->{Translation}->{'Leave Chat'} = 'Tinggalkan obrolan';
    $Self->{Translation}->{'User is currently in the chat.'} = '';

    # Template: AgentChatPreview
    $Self->{Translation}->{'Current chat channel'} = 'Saluran atur obrolan';
    $Self->{Translation}->{'Available channels'} = 'saluran yang tersedia';
    $Self->{Translation}->{'Reload'} = 'Isi ulang';
    $Self->{Translation}->{'Update Channel'} = 'Memperbarui saluran';

    # Template: AgentDynamicFieldDatabaseDetailedSearch
    $Self->{Translation}->{'Detailed search'} = 'Pencarian secara rinci';
    $Self->{Translation}->{'Add an additional attribute'} = 'Menambahkan atribut tambahan';

    # Template: AgentDynamicFieldDatabaseDetails
    $Self->{Translation}->{'Details view'} = 'melihat rincian';

    # Template: AgentNotificationViewNavBar
    $Self->{Translation}->{'Notifications per page'} = 'Pemberitahuan per halaman';

    # Template: AgentNotificationViewSmall
    $Self->{Translation}->{'No notification data found.'} = 'Tidak ada data pemberitahuan ditemukan.';
    $Self->{Translation}->{'Related To'} = 'Berhubungan dengan';
    $Self->{Translation}->{'Select this notification'} = 'Pilih pemberitahuan ini';
    $Self->{Translation}->{'Zoom into'} = 'memperbesar';
    $Self->{Translation}->{'Dismiss this notification'} = 'Mengabaikan pemberitahuan ini';
    $Self->{Translation}->{'Dismiss Selected Notifications'} = 'Singkirkan Pemberitahuan Terpilih';
    $Self->{Translation}->{'Do you really want to dismiss the selected notifications?'} = 'Apakah Anda benar-benar ingin memberhentikan pemberitahuan yang dipilih?';
    $Self->{Translation}->{'OTRS Notification'} = 'Pemberitahuan OTRS';

    # Template: AgentStatisticsReportsAdd
    $Self->{Translation}->{'Reports » Add'} = 'Laporan > Tambah';
    $Self->{Translation}->{'Add New Statistics Report'} = 'Tambahkan Statistik Laporan Baru';

    # Template: AgentStatisticsReportsEdit
    $Self->{Translation}->{'Reports » Edit — %s'} = 'Laporan » Ubah -%s';
    $Self->{Translation}->{'Here you can combine several statistics to a report which you can generate as a PDF manually or automatically at configured times.'} =
        'Di sini Anda dapat menggabungkan beberapa statistik laporan yang dapat Anda menghasilkan sebagai PDF secara manual atau secara otomatis pada waktu dikonfigurasi.';
    $Self->{Translation}->{'Please note that you can only select charts as statistics output format if you configured PhantomJS on your system.'} =
        'Harap dicatat bahwa Anda hanya dapat memilih grafik sebagai format statistik output jika Anda dikonfigurasi PhantomJS pada sistem Anda.';
    $Self->{Translation}->{'Configure PhantomJS'} = 'Konfigurasi PhantomJS';
    $Self->{Translation}->{'General settings'} = 'Pengaturan Umum';
    $Self->{Translation}->{'Automatic generation settings'} = 'Pengaturan generasi otomatis';
    $Self->{Translation}->{'Automatic generation times (cron)'} = 'Generasi otomatis (cron)';
    $Self->{Translation}->{'Specify when the report should be automatically generated in cron format, e. g. "10 1 * * *" for every day at 1:10 am.'} =
        'Menentukan kapan laporan harus dihasilkan secara otomatis dalam format cron, e. g. "10 1 * * *" untuk setiap hari di 1:10 am.';
    $Self->{Translation}->{'Last automatic generation time'} = 'Generasi terakhir otomatis';
    $Self->{Translation}->{'Next planned automatic generation time'} = 'Berikutnya direncanakan waktu generasi otomatis';
    $Self->{Translation}->{'Automatic generation language'} = 'Bahasa generasi otomatis';
    $Self->{Translation}->{'The language to be used when the report is automatically generated.'} =
        'bahasa yang akan digunakan ketika laporan secara otomatis dihasilkan.';
    $Self->{Translation}->{'Email subject'} = 'subjek email';
    $Self->{Translation}->{'Specify the subject for the automatically generated email.'} = '';
    $Self->{Translation}->{'Email body'} = 'badan email';
    $Self->{Translation}->{'Specify the text for the automatically generated email.'} = 'Tentukan teks untuk email secara otomatis.';
    $Self->{Translation}->{'Email recipients'} = 'penerima email';
    $Self->{Translation}->{'Specify recipient email addresses (comma separated).'} = 'Tentukan alamat email penerima (dipisahkan koma).';
    $Self->{Translation}->{'Output settings'} = 'pengaturan output';
    $Self->{Translation}->{'Headline'} = 'Headline';
    $Self->{Translation}->{'Caption for preamble'} = 'Caption untuk basa-basi';
    $Self->{Translation}->{'Preamble'} = 'Pembukaan';
    $Self->{Translation}->{'Caption for epilogue'} = 'Caption untuk epilog';
    $Self->{Translation}->{'Epilogue'} = 'epilog';
    $Self->{Translation}->{'Add statistic to report'} = 'Tambahkan statistik melaporkan';

    # Template: AgentStatisticsReportsOverview
    $Self->{Translation}->{'Reports » Overview'} = 'Laporan » Ikhtisar';
    $Self->{Translation}->{'Statistics Reports'} = 'statistik Laporan';
    $Self->{Translation}->{'Edit statistics report "%s".'} = 'Mengedit laporan statistik "%s".';
    $Self->{Translation}->{'Delete statistics report "%s"'} = 'Menghapus laporan statistik "%s"';
    $Self->{Translation}->{'Do you really want to delete this report?'} = 'Apakah Anda benar-benar ingin menghapus laporan ini?';

    # Template: AgentStatisticsReportsView
    $Self->{Translation}->{'Reports » View — %s'} = 'Laporan » Lihat - %s';
    $Self->{Translation}->{'This statistics report contains configuration errors and can currently not be used.'} =
        'Laporan statistik ini mengandung kesalahan konfigurasi dan dapat saat ini tidak digunakan.';

    # Template: AgentTicketAttachmentView
    $Self->{Translation}->{'Attachments of'} = 'lampiran';
    $Self->{Translation}->{'Attachment Overview'} = 'Ikhtisar lampiran';
    $Self->{Translation}->{'This ticket does not have any attachments.'} = 'Tiket ini tidak memiliki lampiran.';
    $Self->{Translation}->{'Hide inline attachments'} = '';
    $Self->{Translation}->{'Filter Attachments'} = 'Filter Lampiran';
    $Self->{Translation}->{'Select All'} = 'Pilih Semua';
    $Self->{Translation}->{'Click to download this file'} = 'Klik untuk men-download file ini';
    $Self->{Translation}->{'Open article in main window'} = 'Terbuka artikel di jendela utama';
    $Self->{Translation}->{'Download selected files as archive'} = 'Download file terpilih sebagai arsip';

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
    $Self->{Translation}->{'%s has joined this chat.'} = '%s Telah bergabung obrolan ini';
    $Self->{Translation}->{'Incoming chat requests'} = 'permintaan obrolan masuk';
    $Self->{Translation}->{'Outgoing chat requests'} = 'permintaan chatting keluar';
    $Self->{Translation}->{'Active chats'} = 'obrolan aktif';
    $Self->{Translation}->{'Closed chats'} = 'obrolan tertutup';
    $Self->{Translation}->{'Chat request description'} = 'Deskripsi obrolan permintaan';
    $Self->{Translation}->{'Create new ticket'} = 'Buat tiket baru';
    $Self->{Translation}->{'Add an article'} = 'Menambahkan sebuah artikel';
    $Self->{Translation}->{'Start a new chat'} = 'Membuat obrolan baru';
    $Self->{Translation}->{'Select channel'} = 'Pilih saluran';
    $Self->{Translation}->{'Add to an existing ticket'} = 'Tambahkan ke tiket yang ada';
    $Self->{Translation}->{'Active Chat'} = 'Aktifkan obrolan';
    $Self->{Translation}->{'Download Chat'} = 'Memuat turun obrolan';
    $Self->{Translation}->{'Chat is being loaded...'} = 'Obrolan sedang dimuat';
    $Self->{Translation}->{'Chat completed'} = 'Obrolan selesai';

    # Template: CustomerVideoChat
    $Self->{Translation}->{'Fullscreen'} = '';

    # Template: OutputFilterPostSLASelectionDialog
    $Self->{Translation}->{'Please confirm your selection'} = 'Silahkan konfirmasi pilihan anda';

    # Template: PublicChat
    $Self->{Translation}->{'Your name'} = 'Nama anda';
    $Self->{Translation}->{'Start a new Chat'} = 'Memulai obrolan baru';
    $Self->{Translation}->{'Chat complete'} = 'Obrolan selesai';

    # Template: StatsWidget
    $Self->{Translation}->{'Remove statistic'} = 'Menghilangkan statistic';
    $Self->{Translation}->{'If you don\'t specify a title here, the title of the statistic will be used.'} =
        'Jika anda tidak menentukan judul di sini, judul statistik akan digunakan.';
    $Self->{Translation}->{'Preface'} = 'Kata pengantar';
    $Self->{Translation}->{'Postface'} = 'Postface';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Saluran obrolan %s ditambahkan';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Saluran obrolan %s diubah';

    # Perl Module: Kernel/Modules/AdminCloudServiceSMS.pm
    $Self->{Translation}->{'Cloud service "%s" updated!'} = 'Layanan cloud "%s" diperbarukan!';
    $Self->{Translation}->{'Cloud Service config "%s" saved!'} = 'Layanan konfigurasi cloud "%s" disimpan!';

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
        'Obrolan %s telah ditutup dan berhasil ditambahkan ke Tiket  %s';
    $Self->{Translation}->{'Video call feature has been disabled! Please check if %s is available for the current system.'} =
        '';
    $Self->{Translation}->{'%s has joined this chat as an observer.'} = '%s telah bergabung obrolan ini sebagai pengamat.';
    $Self->{Translation}->{'If you accept, any active call you may have will be closed.'} = '';
    $Self->{Translation}->{'New request for joining a chat'} = 'permintaan baru untuk bergabung chatting';
    $Self->{Translation}->{'Agent invited %s.'} = 'Agen diundang %s.';
    $Self->{Translation}->{'%s changed chat channel to %s.'} = '%s mengganti saluran obrolan menjadi %s.';
    $Self->{Translation}->{'%s has switched to participant mode.'} = '%s telah beralih ke modus peserta.';
    $Self->{Translation}->{'%s has switched to observer mode.'} = '%s telah beralih ke modus pengamat.';
    $Self->{Translation}->{'%s has rejected the chat request.'} = '%s telah menolak permintaan obrolan.';
    $Self->{Translation}->{'Need'} = '';

    # Perl Module: Kernel/Modules/AgentNotificationView.pm
    $Self->{Translation}->{'All Notifications'} = 'semua Pemberitahuan';
    $Self->{Translation}->{'Seen Notifications'} = 'Pemberitahuan dilihat';
    $Self->{Translation}->{'Unseen Notifications'} = 'Pemberitahuan gaib/tidak terlihat';
    $Self->{Translation}->{'Notification Web View'} = 'Pemberitahuan Webview';

    # Perl Module: Kernel/Modules/AgentStatisticsReports.pm
    $Self->{Translation}->{'This name is already in use, please choose a different one.'} = 'Nama ini sudah digunakan, silahkan pilih satu yang berbeda.';
    $Self->{Translation}->{'Please provide a valid cron entry.'} = 'Harap memberikan entri cron valid.';

    # Perl Module: Kernel/Modules/AgentVideoChat.pm
    $Self->{Translation}->{'You are not participant in this chat!'} = '';

    # Perl Module: Kernel/Output/HTML/Notification/ChatAvailabilityCheck.pm
    $Self->{Translation}->{'You are unavailable for external chats. Would you like to go online?'} =
        'Anda tidak tersedia untuk obrolan eksternal. Apakah Anda ingin online?';

    # Perl Module: Kernel/Output/HTML/Notification/ChatPreferredChannelsCheck.pm
    $Self->{Translation}->{'You don\'t have any external chat channel assigned.'} = 'Anda tidak memiliki saluran chatting eksternal ditugaskan.';

    # Perl Module: Kernel/Output/HTML/NotificationView/Small.pm
    $Self->{Translation}->{'Dismiss Selected'} = 'Pilihan ditutup';
    $Self->{Translation}->{'Object Type'} = 'Jenis obyek';

    # Perl Module: Kernel/Output/HTML/Preferences/CustomChatChannel.pm
    $Self->{Translation}->{'You do not have access to any chat channels in the system. Please contact the administrator.'} =
        '';

    # Perl Module: Kernel/Output/HTML/ToolBar/ChatRequests.pm
    $Self->{Translation}->{'Open Chat Requests'} = 'Terbuka Permintaan obrolan';

    # Perl Module: Kernel/Output/PDF/StatisticsReports.pm
    $Self->{Translation}->{'%s Report'} = '%s Laporan';
    $Self->{Translation}->{'Error: this graph could not be generated: %s.'} = 'Kesalahan: grafik ini tidak dapat dihasilkan: %s.';
    $Self->{Translation}->{'Table of Contents'} = 'Daftar Isi';

    # Perl Module: Kernel/System/ChatChannel.pm
    $Self->{Translation}->{'Default chat channel'} = 'saluran default obrolan';

    # SysConfig
    $Self->{Translation}->{'Activates chat support.'} = 'Mengaktifkan dukungan obrolan';
    $Self->{Translation}->{'Agent frontend module registration (disable chat link if chat feature is inactive or agent is not in chat group).'} =
        'pendaftaran agen frontend modul (disable obrolan Link jika fitur chat tidak aktif atau agen tidak dalam grup chat).';
    $Self->{Translation}->{'Agent group that can accept chat requests and chat.'} = 'kelompok agen yang dapat menerima permintaan obrolan dan obrolan';
    $Self->{Translation}->{'Agent group that can create chat requests.'} = 'kelompok agen yang dapat membuat permintaan obrolan';
    $Self->{Translation}->{'Agent group that can use video calling feature in chats.'} = '';
    $Self->{Translation}->{'Agent interface availability.'} = 'ketersediaan antarmuka agen.';
    $Self->{Translation}->{'Agent interface notification module to check for open chat requests.'} =
        'Agen modul pemberitahuan untuk memeriksa permintaan obrolan';
    $Self->{Translation}->{'Allow customer to select only channels that have available agent(s).'} =
        'Memungkinkan pelanggan untuk memilih saluran yang memiliki agen yang tersedia (s).';
    $Self->{Translation}->{'Allow public users to select only channels that have available agent(s).'} =
        'Memungkinkan pengguna umum untuk memilih saluran yang memiliki agen yang tersedia (s).';
    $Self->{Translation}->{'Allows having a small format notification web view.'} = 'Memungkinkan memiliki tampilan pemberitahuan web Format kecil.';
    $Self->{Translation}->{'Chat Channel'} = 'Saluran obrolan';
    $Self->{Translation}->{'Chat Channel:'} = 'Saluran obrolan:';
    $Self->{Translation}->{'Chat channel that will be used for communication related to the tickets in this queue.'} =
        'channel chat yang akan digunakan untuk komunikasi yang berkaitan dengan tiket di antrian ini.';
    $Self->{Translation}->{'Chat channel to queue mapping.'} = 'Obrolan saluran untuk antrian pemetaan.';
    $Self->{Translation}->{'Chat overview'} = 'Obrolan secara keseluruhan';
    $Self->{Translation}->{'Chats'} = 'Obrolan';
    $Self->{Translation}->{'Cleans up old chat logs.'} = 'Membersihkan obrolan lama';
    $Self->{Translation}->{'Column notification web view filters for Notification web view type "Small".'} =
        'pemberitahuan kolom tampilan web filter untuk Pemberitahuan Jenis tampilan web "kecil"';
    $Self->{Translation}->{'Columns that can be filtered in the notification web view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Kolom yang dapat disaring dalam pemberitahuan tampilan web dari antarmuka agen. pengaturan mungkin: 0 = Tidak tersedia, 1 = Tersedia, 2 = Diaktifkan secara default.';
    $Self->{Translation}->{'Contact with data'} = 'Kontak dengan data';
    $Self->{Translation}->{'Create and manage chat channels.'} = 'Membuat dan mengelola saluran obrolan';
    $Self->{Translation}->{'Create new chat'} = 'Buat obrolan baru';
    $Self->{Translation}->{'Customer frontend module registration (disable chat link if chat feature is inactive or no agents are available for chat).'} =
        'pendaftaran modul frontend kustom (mematikan obrolan Link jika fitur chat tidak aktif atau tidak ada agen yang tersedia untuk chatting).';
    $Self->{Translation}->{'Default agent name for customer and public interface. If enabled, the real name of the agent will not be visible to customers/public users while using the chat.'} =
        'Nama agen default untuk pelanggan dan antarmuka publik. Jika diaktifkan, nama asli dari agen tidak akan terlihat oleh pelanggan / pengguna umum saat menggunakan chat.';
    $Self->{Translation}->{'Default text for the customer interface.'} = 'Teks default untuk antarmuka pelanggan.';
    $Self->{Translation}->{'Default text for the public interface.'} = 'Teks default untuk antarmuka publik.';
    $Self->{Translation}->{'Defines a list of agent preferences group keys that will be visible in Customer interface (works only if DefaultAgentName is disabled). Example: If you want to display PreferencesGroups###Language, add Language.'} =
        'Mendefinisikan daftar agen kunci kelompok preferensi yang akan terlihat dalam antarmuka Pelanggan (hanya bekerja jika DefaultAgentName dinonaktifkan). Contoh: Jika Anda ingin menampilkan PreferencesGroups###Language, tambah bahasa.';
    $Self->{Translation}->{'Defines a text for Agent Preferences in the Customer interface (works only if DefaultAgentName is disabled).'} =
        'Mendefinisikan teks untuk Preferences Agen di antarmuka Pelanggan (hanya bekerja jika DefaultAgentName dinonaktifkan).';
    $Self->{Translation}->{'Defines if customer users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Mendefinisikan jika pengguna pelanggan dapat memilih saluran obrolan. Jika tidak, chatting akan dibuat default obrolan Channel.';
    $Self->{Translation}->{'Defines if locking a ticket is required to start a chat with the customer from the ticket zoom view.'} =
        'Mendefinisikan penguncian tiket diperlukan untuk memulai obrolan dengan pelanggan dari tampilan zoom tiket.';
    $Self->{Translation}->{'Defines if numbers should be appended to DefaultAgentName. If enabled, together with DefaultAgentName will be numbers (e.g. 1,2,3,...).'} =
        'Mendefinisikan jika nomor harus ditambahkan ke DefaultAgentName. Jika diaktifkan, bersama-sama dengan DefaultAgentName akan menjadi angka (misalnya 1,2,3, ...).';
    $Self->{Translation}->{'Defines if public users are able to select Chat Channel. If not, chat will be created in default Chat Channel.'} =
        'Mendefinisikan pengguna publik dapat memilih saluran obrolan. Jika tidak, chatting akan dibuat default obrolan Channel.';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is available for external chats, but forgot to set preferred channel(s).'} =
        'Mendefinisikan modul untuk menampilkan pemberitahuan di antarmuka agen, jika agen yang tersedia untuk chatting eksternal, tapi lupa untuk mengatur saluran yang disukai (s).';
    $Self->{Translation}->{'Defines the module to display a notification in the agent interface, if the agent is not available for chat with customers (only if Ticket::Agent::AvailableForChatsAfterLogin is set to No).'} =
        'Mendefinisikan modul untuk menampilkan pemberitahuan di antarmuka agen, jika agen tidak tersedia untuk ngobrol dengan pelanggan (hanya jika Ticket::Agent::AvailableForChatsAfterLogin diatur menjadi Tidak).';
    $Self->{Translation}->{'Defines the number of days a notification should be still shown in the notification web view screen (value of \'0\' means always show).'} =
        'Mendefinisikan jumlah hari pemberitahuan harus tetap ditampilkan dalam tampilan layar web pemberitahuan (nilai \'0\' berarti selalu menunjukkan).';
    $Self->{Translation}->{'Defines the order of chat windows.'} = 'Mendefinisikan urutan jendela obrolan.';
    $Self->{Translation}->{'Defines the path to the PhantomJS binary. You can use a static build from http://phantomjs.org/download.html for an easy installation process.'} =
        'Mendefinisikan path ke biner PhantomJS. Anda dapat menggunakan membangun statis dari http://phantomjs.org/download.html untuk proses instalasi yang mudah.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before No Answer message is displayed to the customer.'} =
        'Mendefinisikan periode waktu (dalam menit) sebelum ada Jawaban pesan ditampilkan kepada pelanggan.';
    $Self->{Translation}->{'Defines the period of time (in minutes) before agent is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the period of time (in minutes) before customer is marked as "away" due to inactivity.'} =
        '';
    $Self->{Translation}->{'Defines the settings for appointment notification.'} = '';
    $Self->{Translation}->{'Defines the settings for calendar notification.'} = '';
    $Self->{Translation}->{'Defines the settings for ticket notification.'} = 'Menentukan pengaturan untuk pemberitahuan tiket.';
    $Self->{Translation}->{'Defines the source dynamic field for storing historical data.'} =
        'Mendefinisikan bidang yang dinamis sumber untuk menyimpan data historis.';
    $Self->{Translation}->{'Defines the target dynamic fields for storing historical data.'} =
        'Mendefinisikan target bidang dinamis untuk menyimpan data historis.';
    $Self->{Translation}->{'Dynamic Fields Contact Data Backend GUI'} = 'GUI dinamis Fields Hubungi data Backend';
    $Self->{Translation}->{'Dynamic Fields Database Backend GUI'} = 'Dinamis Fields database Backend GUI';
    $Self->{Translation}->{'Edit contacts with data'} = 'Mengedit kontak dengan data';
    $Self->{Translation}->{'Enables notification web view bulk action feature for the agent frontend to work on more than one notification at a time.'} =
        'Mengaktifkan fitur notifikasi tampilan web tindakan massal untuk frontend agen untuk bekerja pada lebih dari satu notifikasi pada satu waktu.';
    $Self->{Translation}->{'Enables notification web view bulk action feature only for the listed groups.'} =
        'Aktifkan fitur tindakan massal pemberitahuan tampilan web hanya untuk kelompok terdaftar.';
    $Self->{Translation}->{'Enables the timeline view in AgentTicketZoom.'} = 'Memungkinkan tampilan timeline di Agen Tiket Zoom.';
    $Self->{Translation}->{'Event module registration (store historical data in dynamic fields).'} =
        'pendaftaran modul acara (menyimpan data historis dalam bidang yang dinamis).';
    $Self->{Translation}->{'Frontend module registration for the cusotmer interface.'} = '';
    $Self->{Translation}->{'Frontend module registration for the public interface.'} = 'Pendaftaran modul Halamandepan untuk antarmuka umum.';
    $Self->{Translation}->{'Generate HTML comment hooks for the specified blocks so that filters can use them.'} =
        'Hasilkan HTML komentar kait untuk blok tertentu sehingga filter dapat menggunakannya.';
    $Self->{Translation}->{'If enabled it will check agents availability on login. If user is available for external chats, it will reduce availability to internal chats only.'} =
        'Jika diaktifkan itu akan memeriksa ketersediaan agen pada login. Jika pengguna yang tersedia untuk chatting eksternal, itu akan mengurangi ketersediaan untuk chatting internal saja.';
    $Self->{Translation}->{'If this flag is set to Yes, a notification will be displayed on each page if the current agent is not available for chat.'} =
        'Jika bendera ini diatur ke Ya, pemberitahuan akan ditampilkan di setiap halaman jika agen saat ini tidak tersedia untuk chatting.';
    $Self->{Translation}->{'If this flag is set to Yes, agents can start a chat with a customer without a ticket.'} =
        'Jika bendera ini diatur ke Ya, agen dapat memulai obrolan dengan pelanggan tanpa tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, customers can start a chat with an agent without a ticket.'} =
        'Jika bendera ini diatur ke Ya, pelanggan dapat memulai obrolan dengan agen tanpa tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, only the ticket customer can start a chat from a ticket zoom view.'} =
        'Jika bendera ini diatur ke Ya, hanya pelanggan tiket dapat memulai obrolan dari pandangan zoom tiket.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from agent ticket zoom view will only be possible, if the ticket customer is online.'} =
        'Jika bendera ini diatur ke Ya, mulai chatting dari pandangan zoom tiket agen hanya akan mungkin, jika pelanggan tiket online.';
    $Self->{Translation}->{'If this flag is set to Yes, starting a chat from customer ticket zoom view will only be possible, if there are available agents in the linked chat channel.'} =
        'Jika bendera ini diatur ke Ya, mulai chatting dari pandangan zoom tiket pelanggan hanya akan mungkin, jika ada agen yang tersedia di chat saluran terkait.';
    $Self->{Translation}->{'Makes it possible to start a chat with a customer from the agent interface.'} =
        'Memungkinkan untuk memulai obrolan dengan seorang pelanggan dari antarmuka agen.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the agent interface.'} =
        'Memungkinkan untuk memulai obrolan dengan agen dari antarmuka agen.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the customer interface.'} =
        'Memungkinkan untuk memulai obrolan dengan agen dari antarmuka pelanggan.';
    $Self->{Translation}->{'Makes it possible to start a chat with an agent from the public interface.'} =
        'Memungkinkan untuk memulai obrolan dengan agen dari antarmuka publik.';
    $Self->{Translation}->{'Manage team agents.'} = '';
    $Self->{Translation}->{'My chats'} = 'Obrolan saya';
    $Self->{Translation}->{'Name of default chat channel. If this channel does not exist, it will be created automatically. Please do not create a chat channel with the same name as default chat channel. The default channel won\'t be displayed, if chat channels are enabled in Customer interface and Public interface. All agent to agent chats will be in the default channel.'} =
        'Nama saluran default chat. Jika saluran ini tidak ada, maka akan dibuat secara otomatis. Jangan membuat saluran chatting dengan nama yang sama dengan saluran default chat. Saluran default tidak akan ditampilkan, jika saluran chatting diaktifkan di antarmuka pelanggan dan antarmuka Umum. Semua agen untuk chatting agen akan di saluran default.';
    $Self->{Translation}->{'No agents available message.'} = 'Tidak ada agen pesan yang tersedia.';
    $Self->{Translation}->{'Notification limit per page for Notification web view "Small"'} =
        'Batas pemberitahuan per halaman untuk pemberitahuan tampilan web "Kecil"';
    $Self->{Translation}->{'Notification web view'} = 'Pemberitahuan tampilan web';
    $Self->{Translation}->{'Notification web view "Small" Limit'} = 'Bata pemberitahuan tampilan web "Kecil" ';
    $Self->{Translation}->{'Notifications Unseen:'} = 'Pemberitahuan tidak terlihat';
    $Self->{Translation}->{'Number of days after chat will be deleted.'} = 'Jumlah hari setelah obrolan akan dihapus.';
    $Self->{Translation}->{'Number of hours after closed chat will be deleted.'} = 'Jumlah jam setelah chatting tertutup akan dihapus.';
    $Self->{Translation}->{'Output filter for standard tt files.'} = 'Filter output untuk file tt standar.';
    $Self->{Translation}->{'Output filter to inject the necessary Dynamic field names in hidden input.'} =
        '';
    $Self->{Translation}->{'Output filter to inject the necessary JavaScript into the views.'} =
        'Filter output untuk menyuntikkan diperlukan JavaScript ke dalam pandangan.';
    $Self->{Translation}->{'Parameters for notification web view filters.'} = '';
    $Self->{Translation}->{'Parameters for the ChatChannel object in the preference view of the agent interface.'} =
        'Parameter untuk ChatChannel objek dalam tampilan preferensi antarmuka agen.';
    $Self->{Translation}->{'Parameters for the pages (in which the notifications are shown) of the small notifications view.'} =
        'Parameter untuk halaman (di mana pemberitahuan akan ditampilkan) dari pemberitahuan kecil.';
    $Self->{Translation}->{'Permission level to start a chat with customer from agent ticket zoom view.'} =
        'tingkat izin untuk memulai obrolan dengan pelanggan dari pandangan zoom tiket agen.';
    $Self->{Translation}->{'Please bear with us until one of our agents is able to handle your chat request. Thank you for your patience.'} =
        'Tolong beruang dengan kami sampai salah satu agen kami dapat menangani permintaan chat Anda. Terima kasih atas kesabaran Anda.';
    $Self->{Translation}->{'Prepend'} = 'Prepend';
    $Self->{Translation}->{'Remove closed chats older than ChatEngine::ChatTTL.'} = 'Hapus chattingan yang lebih lama dari ChatEngine::ChatTTL.';
    $Self->{Translation}->{'Remove old chats.'} = 'Hapus chattingan lama';
    $Self->{Translation}->{'Resource overview page.'} = '';
    $Self->{Translation}->{'Resource overview screen.'} = '';
    $Self->{Translation}->{'Resources list.'} = '';
    $Self->{Translation}->{'Runs an initial wildcard search of the existing contacts with data when accessing the AdminContactWithData module.'} =
        'Menjalankan pencarian wildcard awal kontak yang ada dengan data saat mengakses AdminContactWithData modul ';
    $Self->{Translation}->{'Sets if a chat request can be sent out from agent ticket zoom view.'} =
        'Menetapkan jika permintaan chatting dapat dikirim keluar dari pandangan zoom tiket agen.';
    $Self->{Translation}->{'Sets if a chat request can be sent out from customer ticket zoom view.'} =
        'Menetapkan jika permintaan chatting dapat dikirim keluar dari pandangan zoom tiket pelanggan.';
    $Self->{Translation}->{'Show all ticket attachments'} = 'Tampilkan semua lampiran tiket';
    $Self->{Translation}->{'Shows all attachments available in the ticket.'} = 'Menunjukkan semua lampiran yang tersedia di tiket.';
    $Self->{Translation}->{'Start new chat'} = 'Mulai obrolan baru';
    $Self->{Translation}->{'Team agents management screen.'} = '';
    $Self->{Translation}->{'Team list'} = '';
    $Self->{Translation}->{'Team management screen.'} = '';
    $Self->{Translation}->{'Team management.'} = '';
    $Self->{Translation}->{'Text which is being displayed on selection of this SLA on CustomerTicketMessage.'} =
        'Teks yang sedang ditampilkan pada pemilihan SLA ini pada CustomerTicketMessage';
    $Self->{Translation}->{'The logo shown in the header of the agent interface for the skin "business". See "AgentLogo" for further description.'} =
        'Logo dalam header dari antarmuka agen untuk "bisnis". Lihat "Agen Logo" untuk deskripsi lebih lanjut.';
    $Self->{Translation}->{'There are no chat agents available at present. Please try again later.'} =
        'Tidak ada obrolan agen yang tersedia saat ini. Silakan coba lagi nanti.';
    $Self->{Translation}->{'There are no chat agents available at present. To add an article to the existing ticket, please click here:'} =
        'Tidak ada obrolan agen yang tersedia saat ini. Untuk menambahkan sebuah artikel ke tiket yang ada, silakan klik di sini:';
    $Self->{Translation}->{'There are no chat agents available at present. To create a new ticket, please click here:'} =
        'Tidak ada obrolan agen yang tersedia saat ini. Untuk membuat tiket baru, silakan klik di sini:';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically.'} =
        'obrolan ini telah berakhir. Silakan tinggalkan atau akan ditutup secara otomatis.';
    $Self->{Translation}->{'This chat has ended. Please leave it or it will be closed automatically. You can download this chat.'} =
        'obrolan ini telah berakhir. Silakan tinggalkan atau akan ditutup secara otomatis. Anda dapat men-download chat ini.';
    $Self->{Translation}->{'This chat is completed. You can now close the chat window.'} = 'obrolan ini selesai. Sekarang Anda dapat menutup jendela chat.';
    $Self->{Translation}->{'This chat is completed. You can start a new chat using the button on top of this page.'} =
        'obrolan ini selesai. Anda dapat memulai obrolan baru menggunakan tombol di atas halaman ini.';
    $Self->{Translation}->{'Tool-bar item for a notification web view.'} = 'Item Toolbar untuk tampilan web pemberitahuan.';
    $Self->{Translation}->{'Video and audio call screen.'} = '';
    $Self->{Translation}->{'View notifications'} = 'Lihat pemberitahuan';
    $Self->{Translation}->{'Your selection of your preferred external chat channels. You will be notified about external chat requests in these chat channels.'} =
        '';

}

1;
