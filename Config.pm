# --
# Kernel/Config.pm - Config file for OTRS kernel
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
#  Note:
#
#  -->> Most OTRS configuration should be done via the OTRS web interface
#       and the SysConfig. Only for some configuration, such as database
#       credentials and customer data source changes, you should edit this
#       file. For changes do customer data sources you can copy the definitions
#       from Kernel/Config/Defaults.pm and paste them in this file.
#       Config.pm will not be overwritten when updating OTRS.
# --

package Kernel::Config;

use strict;
use warnings;
use utf8;

sub Load {
    my $Self = shift;
    # ---------------------------------------------------- #
    # database settings                                    #
    # ---------------------------------------------------- #

    # The database host
    $Self->{'DatabaseHost'} = '127.0.0.1';

    # The database name
    $Self->{'Database'} = "otrs";

    # The database user
    $Self->{'DatabaseUser'} = "otrs";

    # The password of database user. You also can use bin/otrs.CryptPassword.pl
    # for crypted passwords
    $Self->{'DatabasePw'} = 'raFzBtF1Qvq1V7VZ';

    # The database DSN for MySQL ==> more: "perldoc DBD::mysql"
    $Self->{'DatabaseDSN'} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost}";

    # The database DSN for PostgreSQL ==> more: "perldoc DBD::Pg"
    # if you want to use a local socket connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};";
    # if you want to use a TCP/IP connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};host=$Self->{DatabaseHost};";
    # if you have PostgresSQL 8.1 or earlier, activate the legacy driver with this line:
#    $Self->{DatabasePostgresqlBefore82} = 1;

    # The database DSN for Microsoft SQL Server - only supported if OTRS is
    # installed on Windows as well
#    $Self->{DatabaseDSN} = "DBI:ODBC:driver={SQL Server};Database=$Self->{Database};Server=$Self->{DatabaseHost},1433";

    # The database DSN for Oracle ==> more: "perldoc DBD::oracle"
#    $ENV{ORACLE_HOME} = '/u01/app/oracle/product/10.2.0/client_1';
#    $ENV{NLS_DATE_FORMAT} = 'YYYY-MM-DD HH24:MI:SS';
#    $ENV{NLS_LANG} = "american_america.utf8";

#    $Self->{DatabaseDSN} = "DBI:Oracle:sid=OTRS;host=$Self->{DatabaseHost};port=1522;";

    # ---------------------------------------------------- #
    # fs root directory
    # ---------------------------------------------------- #
    $Self->{Home} = '/opt/otrs';

    # ---------------------------------------------------- #
    # insert your own config settings "here"               #
    # config settings taken from Kernel/Config/Defaults.pm #
    # ---------------------------------------------------- #
    # $Self->{SessionUseCookie} = 0;
    # $Self->{CheckMXRecord} = 0;
$Self->{'GenericInterface::Operation::Module'}->{'Priority::PriorityGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'Priority',
    'Name' => 'PriorityGet'
};
$Self->{'GenericInterface::Operation::Module'}->{'Queue::QueueGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'Queue',
    'Name' => 'QueueGet'
};
$Self->{'GenericInterface::Operation::Module'}->{'State::StateGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'State',
    'Name' => 'StateGet'
};
$Self->{'GenericInterface::Operation::Module'}->{'Type::TypeGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'Type',
    'Name' => 'TypeGet'
};
$Self->{'GenericInterface::Operation::Module'}->{'CustomerUser::CustomerUserGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'CustomerUser',
    'Name' => 'CustomerUserGet'
};
$Self->{'GenericInterface::Operation::Module'}->{'CustomerCompany::CustomerCompanyGet'} =  {
    'ConfigDialog' => 'AdminGenericInterfaceOperationDefault',
    'Controller' => 'CustomerCompany',
    'Name' => 'CustomerCompanyGet'
};
    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    # data inserted by installer                           #
    # ---------------------------------------------------- #
    # $DIBI$

$Self->{AuthModule1} = 'Kernel::System::Auth::DB';


# $Self->{AuthModule} = 'Kernel::System::Auth::LDAP';
#    $Self->{'AuthModule::LDAP::Host'} = 'srv-radc01.exa.local';
#    $Self->{'AuthModule::LDAP::BaseDN'} = 'dc=EXA,dc=local';
#    $Self->{'AuthModule::LDAP::UID'} = 'sAMAccountName';
#    $Self->{'AuthModule::LDAP::GroupDN'} = 'CN=GG_HELPDESK_ACCESS,OU=SG-GROUP-MSC,OU=SECURITY-GROUP,OU=GROUPES,OU=exaprobe,DC=EXA,DC=local';
#    $Self->{'AuthModule::LDAP::AccessAttr'} = 'member';
# $Self->{'AuthModule::LDAP::UserAttr'} = 'DN';

#    $Self->{'AuthModule::LDAP::SearchUserDN'} = 'adm-ora@exa.local';
#    $Self->{'AuthModule::LDAP::SearchUserPw'} = 'Teioht\'escon';

#    $Self->{'AuthSyncModule'} = 'Kernel::System::Auth::Sync::LDAP';
#    $Self->{'AuthSyncModule::LDAP::Host'} = 'srv-radc01.exa.local';
#    $Self->{'AuthSyncModule::LDAP::BaseDN'} = 'dc=exa,dc=local';
#    $Self->{'AuthSyncModule::LDAP::UID'} = 'sAMAccountName';

#    $Self->{'AuthSyncModule::LDAP::SearchUserDN'} = 'adm-ora@exa.local';
#    $Self->{'AuthSyncModule::LDAP::SearchUserPw'} = 'Teioht\'escon';
#
#  $Self->{'AuthSyncModule::LDAP::UserSyncMap'} = {
#        UserFirstname => 'givenName',
#        UserLastname  => 'sn',
#        UserEmail     => 'mail',
#    };


#    $Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups'} = [
#        'users','faq','admin','stats','faq_admin','faq_approval',
#    ];

$Self->{AuthModule} = 'Kernel::System::Auth::LDAP';
    $Self->{'AuthModule::LDAP::Host'} = 'srv-msc-sodc01.msc.so';
    $Self->{'AuthModule::LDAP::BaseDN'} = 'dc=msc,dc=so';
    $Self->{'AuthModule::LDAP::UID'} = 'sAMAccountName';
    $Self->{'AuthModule::LDAP::GroupDN'} = 'CN=SG_ACCES_OTRS_PREPROD,OU=SG,OU=Exaprobe,DC=msc,DC=so';
    $Self->{'AuthModule::LDAP::AccessAttr'} = 'member:1.2.840.113556.1.4.1941:';
 $Self->{'AuthModule::LDAP::UserAttr'} = 'DN';

    $Self->{'AuthModule::LDAP::SearchUserDN'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
    $Self->{'AuthModule::LDAP::SearchUserPw'} = '7154#99f9db';

    $Self->{'AuthSyncModule'} = 'Kernel::System::Auth::Sync::LDAP';
    $Self->{'AuthSyncModule::LDAP::Host'} = 'srv-msc-sodc01.msc.so';
    $Self->{'AuthSyncModule::LDAP::BaseDN'} = 'dc=msc,dc=so';
    $Self->{'AuthSyncModule::LDAP::UID'} = 'sAMAccountName';
    $Self->{'AuthSyncModule::LDAP::AccessAttr'} = 'member:1.2.840.113556.1.4.1941:';

    $Self->{'AuthSyncModule::LDAP::SearchUserDN'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
    $Self->{'AuthSyncModule::LDAP::SearchUserPw'} = '7154#99f9db';

  $Self->{'AuthSyncModule::LDAP::UserSyncMap'} = {
        UserFirstname => 'givenName',
        UserLastname  => 'sn',
        UserEmail     => 'mail',
    };


    #$Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups'} = [
    #    'users','faq','stats','faq_admin','faq_approval','itsm-configitem',
    #];
    $Self->{'AuthSyncModule::LDAP::UserSyncRolesDefinition'} = {

       'CN=SG_ACCES_OTRS_PREPROD_ADMIN,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
	    'ADMIN-OTRS' => 1 },
       'CN=SG_ACCES_OTRS_PREPROD_SO,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
            'MSC' => 1 },
       'CN=SG_ACCES_OTRS_RESTREINT,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
            'INTEGRATION' => 1 },
       'CN=SG_ACCES_BANQUESMSC,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
            'COMMERCE' => 1 },
       'CN=SG_ACCES_OTRS_CONTRACTMANAGER,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
            'CONTRACT_MANAGER' => 1 },
       'CN=SG_ACCES_OTRS_POOLMANAGER,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
            'POOL_MANAGER' => 1 }
    };


#    $Self->{AuthModule2} = 'Kernel::System::Auth::LDAP';
#    $Self->{'AuthModule::LDAP::Host2'} = 'srv-radc01.exa.local';
#    $Self->{'AuthModule::LDAP::BaseDN2'} = 'dc=EXA,dc=local';
#    $Self->{'AuthModule::LDAP::UID2'} = 'sAMAccountName';
#    $Self->{'AuthModule::LDAP::GroupDN2'} = 'CN=GG_MSCSSL_Profil_Consultants,OU=SG-GROUP-MSC,OU=SECURITY-GROUP,OU=GROUPES,OU=exaprobe,DC=EXA,DC=local';
#    $Self->{'AuthModule::LDAP::AccessAttr2'} = 'member';
# $Self->{'AuthModule::LDAP::UserAttr2'} = 'DN';

#    $Self->{'AuthModule::LDAP::SearchUserDN2'} = 'adm-ora@exa.local';
#    $Self->{'AuthModule::LDAP::SearchUserPw2'} = 'Teioht\'escon';
#
#    $Self->{'AuthSyncModule2'} = 'Kernel::System::Auth::Sync::LDAP';
#    $Self->{'AuthSyncModule::LDAP::Host2'} = 'srv-radc01.exa.local';
#    $Self->{'AuthSyncModule::LDAP::BaseDN2'} = 'dc=exa,dc=local';
#    $Self->{'AuthSyncModule::LDAP::UID2'} = 'sAMAccountName';

#    $Self->{'AuthSyncModule::LDAP::SearchUserDN2'} = 'adm-ora@exa.local';
#    $Self->{'AuthSyncModule::LDAP::SearchUserPw2'} = 'Teioht\'escon';

#  $Self->{'AuthSyncModule::LDAP::UserSyncMap2'} = {
#        UserFirstname => 'givenName',
#        UserLastname  => 'sn',
#        UserEmail     => 'mail',
#    };

#    $Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups2'} = [
#       'users','faq','stats','faq_approval',
#    ];

#   $Self->{AuthModule2} = 'Kernel::System::Auth::LDAP';
#  $Self->{'AuthModule::LDAP::Host2'} = 'srv-msc-sodc01.msc.so';
#    $Self->{'AuthModule::LDAP::BaseDN2'} = 'dc=msc,dc=so';
#    $Self->{'AuthModule::LDAP::UID2'} = 'sAMAccountName';
#    $Self->{'AuthModule::LDAP::GroupDN2'} = 'CN=SG_ACCES_OTRS_RESTREINT,OU=SG,OU=Exaprobe,DC=msc,DC=so';
#    $Self->{'AuthModule::LDAP::AccessAttr2'} = 'member:1.2.840.113556.1.4.1941:';
# $Self->{'AuthModule::LDAP::UserAttr2'} = 'DN';

#    $Self->{'AuthModule::LDAP::SearchUserDN2'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
#    $Self->{'AuthModule::LDAP::SearchUserPw2'} = '7154#99f9db';
#
#    $Self->{'AuthSyncModule2'} = 'Kernel::System::Auth::Sync::LDAP';
#    $Self->{'AuthSyncModule::LDAP::Host2'} = 'srv-msc-sodc01.msc.so';
#    $Self->{'AuthSyncModule::LDAP::BaseDN2'} = 'dc=msc,dc=so';
#    $Self->{'AuthSyncModule::LDAP::UID2'} = 'sAMAccountName';
#    $Self->{'AuthSyncModule::LDAP::AccessAttr2'} = 'member:1.2.840.113556.1.4.1941:';
#
#    $Self->{'AuthSyncModule::LDAP::SearchUserDN2'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
#    $Self->{'AuthSyncModule::LDAP::SearchUserPw2'} = '7154#99f9db';
#
#  $Self->{'AuthSyncModule::LDAP::UserSyncMap2'} = {
#        UserFirstname => 'givenName',
#        UserLastname  => 'sn',
#        UserEmail     => 'mail',
#    };
#
#
    #$Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups2'} = [
    #    'users','faq','stats','faq_approval','itsm-configitem',
    #];
#    $Self->{'AuthSyncModule::LDAP::UserSyncRolesDefinition2'} = {
#       'CN=SG_ACCES_OTRS_ADMIN,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
#	    'ADMIN-OTRS' => 1 },
#       'CN=SG_ACCES_OTRS_SO,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
#            'MSC' => 1 },
#       'CN=SG_ACCES_OTRS_RESTREINT,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
#            'INTEGRATION' => 1 }
#    };

#    $Self->{AuthModule3} = 'Kernel::System::Auth::LDAP';
#    $Self->{'AuthModule::LDAP::Host3'} = 'srv-msc-sodc01.msc.so';
#    $Self->{'AuthModule::LDAP::BaseDN3'} = 'dc=msc,dc=so';
#    $Self->{'AuthModule::LDAP::UID3'} = 'sAMAccountName';
#    $Self->{'AuthModule::LDAP::GroupDN3'} = 'CN=SG_ACCES_BANQUESMSC,OU=SG,OU=Exaprobe,DC=msc,DC=so';
#    $Self->{'AuthModule::LDAP::AccessAttr3'} = 'member:1.2.840.113556.1.4.1941:';
# $Self->{'AuthModule::LDAP::UserAttr3'} = 'DN';

#    $Self->{'AuthModule::LDAP::SearchUserDN3'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
#    $Self->{'AuthModule::LDAP::SearchUserPw3'} = '7154#99f9db';
#
#    $Self->{'AuthSyncModule3'} = 'Kernel::System::Auth::Sync::LDAP';
#    $Self->{'AuthSyncModule::LDAP::Host3'} = 'srv-msc-sodc01.msc.so';
#    $Self->{'AuthSyncModule::LDAP::BaseDN3'} = 'dc=msc,dc=so';
#    $Self->{'AuthSyncModule::LDAP::UID3'} = 'sAMAccountName';
#    $Self->{'AuthSyncModule::LDAP::AccessAttr3'} = 'member:1.2.840.113556.1.4.1941:';

#    $Self->{'AuthSyncModule::LDAP::SearchUserDN3'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
#    $Self->{'AuthSyncModule::LDAP::SearchUserPw3'} = '7154#99f9db';
#
#  $Self->{'AuthSyncModule::LDAP::UserSyncMap3'} = {
#        UserFirstname => 'givenName',
#        UserLastname  => 'sn',
#        UserEmail     => 'mail',
#    };


    #$Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups3'} = {
    #    'stats' => {
#		ro => 1,
#		rw => 0,
#	}
#    };


   # AuthSyncModule::LDAP::UserSyncRolesDefinition
    # (If "LDAP" was selected for AuthModule and you want to sync LDAP
    # groups to otrs roles, define the following.)
#    $Self->{'AuthSyncModule::LDAP::UserSyncRolesDefinition3'} = {
#       'CN=SG_ACCES_BANQUESMSC,OU=SG,OU=Exaprobe,DC=msc,DC=so' => {
#            'COMMERCE' => 1 }
#    };
#
#$Self->{'AuthSyncModule::LDAP::UserSyncGroupsDefinition'} = {
#        # ldap group
#        'CN=GG_HELPDESK_ACCESS,OU=SG-GROUP-MSC' => {
#            # otrs group
#            'admin' => {
#                # permission
 #               rw => 1,
##                ro => 1,
  #          },
 #           'faq' => {
  #              rw => 1,
   #             ro => 1,
    #        },
     #   },
#        'cn=agent2,o=otrs' => {
#            'users' => {
#                rw => 1,
#                ro => 1,
#            },
#        }
#    };
#

# (customer ldap backend and settings)
$Self->{CustomerUser} = {
    Name => 'LDAP Datasource',
    Module => 'Kernel::System::CustomerUser::LDAP',
    Params => {
        # ldap host
        Host => 'srv-msc-sodc01.msc.so',
        # ldap base dn
        BaseDN => 'OU=ENTREPRISES,OU=Clients,DC=msc,DC=so',
        # search scope (one|sub)
        SSCOPE => 'sub',
        # The following is valid but would only be necessary if the
        # anonymous user does NOT have permission to read from the LDAP tree
        UserDN => 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so',
        UserPw => '7154#99f9db',
        # in case you want to add always one filter to each ldap query, use
        # this option. e. g. AlwaysFilter => '(mail=*)' or AlwaysFilter => '(objectclass=user)'
        AlwaysFilter => '(objectclass=user)',
        # if the charset of your ldap server is iso-8859-1, use this:
#        SourceCharset => 'iso-8859-1',

        # Net::LDAP new params (if needed - for more info see perldoc Net::LDAP)
        Params => {
            port => 389,
            timeout => 120,
            async => 0,
            version => 3,
        },
    },
    # customer unique id
    CustomerKey => 'sAMAccountName',
    # customer #
    CustomerID => 'physicalDeliveryOfficeName',
    CustomerUserListFields => ['cn', 'mail'],
    CustomerUserSearchFields => ['sAMAccountName', 'cn', 'mail'],
    CustomerUserSearchPrefix => '',
    CustomerUserSearchSuffix => '*',
    CustomerUserSearchListLimit => 1000,
    CustomerUserPostMasterSearchFields => ['mail'],
    CustomerUserNameFields => ['givenName', 'sn'],
    # show not own tickets in customer panel, CompanyTickets
    CustomerUserExcludePrimaryCustomerID => 0,
    # add a ldap filter for valid users (expert setting)
#    CustomerUserValidFilter => '(!(description=locked))',
    # admin can't change customer preferences
    AdminSetPreferences => 0,
    Map => [
        # note: Login, Email and CustomerID needed!
        # var, frontend, storage, shown (1=always,2=lite), required, storage-type, http-link, readonly
        [ 'UserTitle',      'Title',      'title',           1, 0, 'var', '', 0 ],
        [ 'UserFirstname',  'Firstname',  'givenName',       1, 1, 'var', '', 0 ],
        [ 'UserLastname',   'Lastname',   'sn',              1, 1, 'var', '', 0 ],
        [ 'UserLogin',      'Username',   'sAMAccountName',             1, 1, 'var', '', 0 ],
        [ 'UserEmail',      'Email',      'mail',            1, 1, 'var', '', 0 ],
        [ 'UserCustomerID', 'CustomerID', 'physicalDeliveryOfficeName',            0, 1, 'var', '', 0 ],
        [ 'UserCustomerIDs', 'CustomerIDs', 'company', 1, 0, 'var', '', 0 ],
        [ 'UserPhone',      'Phone',      'telephoneNumber', 1, 0, 'var', '', 0 ],
        [ 'UserAddress',    'Address',    'postaladdress',   1, 0, 'var', '', 0 ],
        [ 'UserComment',    'Comment',    'description',     1, 0, 'var', '', 0 ],
    ],
};

$Self->{CustomerCompany} = {
        Name   => 'Database Backend',
        Module => 'Kernel::System::CustomerCompany::DB',
        Params => {
            # if you want to use an external database, add the
            # required settings
           # DSN  => 'DBI:odbc:yourdsn',
           # Type => 'mssql', # only for ODBC connections
           # DSN => 'DBI:mysql:database=customerdb;host=customerdbhost',
           # User => '',
           # Password => '',
            Table => 'customer_company',
           # ForeignDB => 0,    # set this to 1 if your table does not have create_time, create_by, change_time and change_by fields

            # CaseSensitive defines if the data storage of your DBMS is case sensitive and will be
            # preconfigured within the database driver by default.
            # If the collation of your data storage differs from the default settings,
            # you can set the current behavior ( either 1 = CaseSensitive or 0 = CaseINSensitive )
            # to fit your environment.
            
           # CaseSensitive => 0,

            # SearchCaseSensitive will control if the searches within the data storage are performed
            # case sensitively (if possible) or not. Change this option to 1, if you want to search case sensitive.
            # This can improve the performance dramatically on large databases.
            SearchCaseSensitive => 0,
        },

        # company unique id
        CustomerCompanyKey             => 'customer_id',
        CustomerCompanyValid           => 'valid_id',
        CustomerCompanyListFields      => [ 'customer_id', 'name' ],
        CustomerCompanySearchFields    => ['customer_id', 'name'],
        CustomerCompanySearchPrefix    => '*',
        CustomerCompanySearchSuffix    => '*',
        CustomerCompanySearchListLimit => 250,
        CacheTTL                       => 60 * 60 * 24, # use 0 to turn off cache

        Map => [
            # var, frontend, storage, shown (1=always,2=lite), required, storage-type, http-link, readonly
            [ 'CustomerID',             'CustomerID', 'customer_id', 0, 1, 'var', '', 0 ],
            [ 'CustomerCompanyName',    'Customer',   'name',        1, 1, 'var', '', 0 ],
            [ 'CustomerCompanyStreet',  'Street',     'street',      1, 0, 'var', '', 0 ],
            [ 'CustomerCompanyZIP',     'Zip',        'zip',         1, 0, 'var', '', 0 ],
            [ 'CustomerCompanyCity',    'City',       'city',        1, 0, 'var', '', 0 ],
            [ 'CustomerCompanyCountry', 'Country',    'country',     1, 0, 'var', '', 0 ],
			[ 'CustomerCompanyPremium', 'Premium',    'premium',     1, 0, 'int', '', 0 ],
            [ 'CustomerCompanyURL',     'URL',        'url',         1, 0, 'var', '[% Data.CustomerCompanyURL | html %]', 0 ],
            [ 'CustomerCompanyComment', 'Comment',    'comments',    1, 0, 'var', '', 0 ],
            [ 'ValidID',                'Valid',      'valid_id',    0, 1, 'int', '', 0 ],
        ],
    };

# This is an example configuration for an LDAP auth. backend.
# (make sure Net::LDAP is installed!)
$Self->{'Customer::AuthModule'} = 'Kernel::System::CustomerAuth::LDAP';
$Self->{'Customer::AuthModule::LDAP::Host'} = 'srv-msc-sodc01.msc.so';
$Self->{'Customer::AuthModule::LDAP::BaseDN'} = 'OU=Clients,DC=msc,DC=so';
$Self->{'Customer::AuthModule::LDAP::UID'} = 'sAMAccountName';

# Check if the user is allowed to auth in a posixGroup
# (e. g. user needs to be in a group xyz to use otrs)
$Self->{'Customer::AuthModule::LDAP::GroupDN'} = 'CN=SG_ACCES_OTRS_CLIENTS,OU=SG,OU=Clients,DC=msc,DC=so';
#$Self->{'Customer::AuthModule::LDAP::AccessAttr'} = '';
# for ldap posixGroups objectclass (just uid)
#$Self->{'Customer::AuthModule::LDAP::UserAttr'} = 'UID';
# for non ldap posixGroups objectclass (full user dn)
#$Self->{'Customer::AuthModule::LDAP::UserAttr'} = 'DN';

# The following is valid but would only be necessary if the
# anonymous user does NOT have permission to read from the LDAP tree
$Self->{'Customer::AuthModule::LDAP::SearchUserDN'} = 'CN=ADM OTRS,OU=AdminAccount,DC=msc,DC=so';
$Self->{'Customer::AuthModule::LDAP::SearchUserPw'} = '7154#99f9db';

# in case you want to add always one filter to each ldap query, use
# this option. e. g. AlwaysFilter => '(mail=*)' or AlwaysFilter => '(objectclass=user)'
$Self->{'Customer::AuthModule::LDAP::AlwaysFilter'} = '';

# in case you want to add a suffix to each customer login name, then
# you can use this option. e. g. user just want to use user but
# in your ldap directory exists user@domain.com
#$Self->{'Customer::AuthModule::LDAP::UserSuffix'} = '@domain.com';

# Net::LDAP new params (if needed - for more info see perldoc Net::LDAP)
$Self->{'Customer::AuthModule::LDAP::Params'} = {
    port => 389,
    timeout => 120,
    async => 0,
    version => 3,
};

#Modification pour voir tous les CustomerID
$Self->{CustomerCompany}->{CustomerCompanySearchListLimit} = 1000;

    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
    #                                                      #
    # end of your own config options!!!                    #
    #                                                      #
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
}

# ---------------------------------------------------- #
# needed system stuff (don't edit this)                #
# ---------------------------------------------------- #

use base qw(Kernel::Config::Defaults);

# -----------------------------------------------------#

1;
