# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::StatsReport;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
    'Kernel::System::Valid',
    'Kernel::System::YAML',
);

=head1 NAME

Kernel::System::StatsReport

=head1 SYNOPSIS

Backend for statistics reports.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $StatsReportObject = $Kernel::OM->Get('Kernel::System::StatsReport');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item StatsReportAdd()

add new StatsReport.

returns id of new StatsReport if successful or undef otherwise

    my $ID = $StatsReportObject->StatsReportAdd(
        Name    => 'some name',
        Config  => $ConfigHashRef,
        ValidID => 1,
        UserID  => 123,
    );

=cut

sub StatsReportAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Key (qw(Name Config ValidID UserID)) {
        if ( !$Param{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Key!",
            );
            return;
        }
    }

    # check config
    if ( !IsHashRefWithData( $Param{Config} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "StatsReport Config should be a non empty hash reference!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check if stats report with this name already exists
    return if !$DBObject->Prepare(
        SQL => "
            SELECT id
            FROM stats_report
            WHERE name = ?",
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $StatsReportExists;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $StatsReportExists = 1;
    }

    if ($StatsReportExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The Name:$Param{Name} already exists for a stats report!",
        );
        return;
    }

    # dump config as string
    my $Config = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => $Param{Config} );

    # md5 of content
    my $MD5 = $Kernel::OM->Get('Kernel::System::Main')->MD5sum(
        String => $Kernel::OM->Get('Kernel::System::Time')->SystemTime() . int( rand(1000000) ),
    );

    # sql
    return if !$DBObject->Do(
        SQL =>
            'INSERT INTO stats_report (name, config, config_md5, valid_id, '
            . ' create_time, create_by, change_time, change_by)'
            . ' VALUES (?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Name}, \$Config, \$MD5, \$Param{ValidID},
            \$Param{UserID}, \$Param{UserID},
        ],
    );

    return if !$DBObject->Prepare(
        SQL  => 'SELECT id FROM stats_report WHERE config_md5 = ?',
        Bind => [ \$MD5 ],
    );

    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'StatsReport',
    );

    return $ID;
}

=item StatsReportGet()

get StatsReports attributes

    my $StatsReport = $StatsReportObject->StatsReportGet(
        ID   => 123,            # ID or Name must be provided
        Name => 'MyStatsReport',
    );

Returns:

    $StatsReport = {
        ID         => 123,
        Name       => 'some name',
        Config     => $ConfigHashRef,
        ValidID    => 123,
        CreateTime => '2011-02-08 15:08:00',
        ChangeTime => '2011-02-08 15:08:00',
    };

=cut

sub StatsReportGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} && !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID or Name!'
        );
        return;
    }

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $CacheKey;
    if ( $Param{ID} ) {
        $CacheKey = 'StatsReportGet::ID::' . $Param{ID};
    }
    else {
        $CacheKey = 'StatsReportGet::Name::' . $Param{Name};

    }
    my $Cache = $CacheObject->Get(
        Type => 'StatsReport',
        Key  => $CacheKey,
    );
    return $Cache if $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # sql
    if ( $Param{ID} ) {
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, config, valid_id, create_time, change_time '
                . 'FROM stats_report WHERE id = ?',
            Bind  => [ \$Param{ID} ],
            Limit => 1,
        );
    }
    else {
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, config, valid_id, create_time, change_time '
                . 'FROM stats_report WHERE name = ?',
            Bind  => [ \$Param{Name} ],
            Limit => 1,
        );
    }

    # get yaml object
    my $YAMLObject = $Kernel::OM->Get('Kernel::System::YAML');

    my %Data;
    while ( my @Data = $DBObject->FetchrowArray() ) {

        my $Config = $YAMLObject->Load( Data => $Data[2] );

        %Data = (
            ID         => $Data[0],
            Name       => $Data[1],
            Config     => $Config,
            ValidID    => $Data[3],
            CreateTime => $Data[4],
            ChangeTime => $Data[5],
        );
    }

    # get the cache TTL (in seconds)
    my $CacheTTL = int(
        $Kernel::OM->Get('Kernel::Config')->Get('StatsReportConfig::CacheTTL')
            || 3600
    );

    # set cache
    $CacheObject->Set(
        Type  => 'StatsReport',
        Key   => $CacheKey,
        Value => \%Data,
        TTL   => $CacheTTL,
    );

    return \%Data;
}

=item StatsReportUpdate()

update StatsReport attributes

returns 1 if successful or undef otherwise

    my $Success = $StatsReportObject->StatsReportUpdate(
        ID      => 123,
        Name    => 'some name',
        Config  => $ConfigHashRef,
        ValidID => 1,
        UserID  => 123,
    );

=cut

sub StatsReportUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Key (qw(ID Name Config ValidID UserID)) {
        if ( !$Param{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Key!",
            );
            return;
        }
    }

    # check config
    if ( !IsHashRefWithData( $Param{Config} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "StatsReport Config should be a non empty hash reference!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check if stats report with this name already exists
    return if !$DBObject->Prepare(
        SQL => "
            SELECT id
            FROM stats_report
            WHERE name = ?
            AND id != ?",
        Bind  => [ \$Param{Name}, \$Param{ID} ],
        Limit => 1,
    );

    my $StatsReportExists;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $StatsReportExists = 1;
    }

    if ($StatsReportExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The Name:$Param{Name} already exists for a stats report!",
        );
        return;
    }

    # dump config as string
    my $Config = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => $Param{Config} );

    # md5 of content
    my $MD5 = $Kernel::OM->Get('Kernel::System::Main')->MD5sum(
        String => $Kernel::OM->Get('Kernel::System::Time')->SystemTime() . int( rand(1000000) ),
    );

    # check if config and valid_id is the same
    return if !$DBObject->Prepare(
        SQL   => 'SELECT config, valid_id, name FROM stats_report WHERE id = ?',
        Bind  => [ \$Param{ID} ],
        Limit => 1,
    );

    my $ConfigCurrent;
    my $ValidIDCurrent;
    my $NameCurrent;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $ConfigCurrent  = $Data[0];
        $ValidIDCurrent = $Data[1];
        $NameCurrent    = $Data[2];
    }

    return 1 if $ValidIDCurrent eq $Param{ValidID}
        && $Config eq $ConfigCurrent
        && $NameCurrent eq $Param{Name};

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE stats_report SET name = ?, config = ?, '
            . ' config_md5 = ?, valid_id = ?, change_time = current_timestamp, '
            . ' change_by = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Config, \$MD5, \$Param{ValidID}, \$Param{UserID},
            \$Param{ID},
        ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'StatsReport',
    );

    return 1;
}

=item StatsReportDelete()

delete a StatsReport

returns 1 if successful or undef otherwise

    my $Success = $StatsReportObject->StatsReportDelete(
        ID      => 123,
        UserID  => 123,
    );

=cut

sub StatsReportDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Key (qw(ID UserID)) {
        if ( !$Param{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Key!",
            );
            return;
        }
    }

    # check if exists
    my $StatsReport = $Self->StatsReportGet(
        ID => $Param{ID},
    );
    return if !IsHashRefWithData($StatsReport);

    # delete web service
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => 'DELETE FROM stats_report WHERE id = ?',
        Bind => [ \$Param{ID} ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'StatsReport',
    );

    return 1;
}

=item StatsReportList()

get StatsReport list

    my $List = $StatsReportObject->StatsReportList();

    or

    my $List = $StatsReportObject->StatsReportList(
        Valid => 0, # optional, defaults to 1
    );

=cut

sub StatsReportList {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $Valid = 1;
    if ( !$Param{Valid} ) {
        $Valid = '0';
    }
    my $CacheKey = 'StatsReportList::Valid::' . $Valid;
    my $Cache    = $CacheObject->Get(
        Type => 'StatsReport',
        Key  => $CacheKey,
    );
    return $Cache if ref $Cache;

    my $SQL = 'SELECT id, name FROM stats_report';

    if ( !defined $Param{Valid} || $Param{Valid} eq 1 ) {

        # get valid object
        my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

        $SQL .= ' WHERE valid_id IN (' . join ', ', $ValidObject->ValidIDsGet() . ')';
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare( SQL => $SQL );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[1];
    }

    # get the cache TTL (in seconds)
    my $CacheTTL = int(
        $Kernel::OM->Get('Kernel::Config')->Get('StatsReportConfig::CacheTTL')
            || 3600
    );

    # set cache
    $CacheObject->Set(
        Type  => 'StatsReport',
        Key   => $CacheKey,
        Value => \%Data,
        TTL   => $CacheTTL,
    );

    return \%Data;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
