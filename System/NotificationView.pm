# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::NotificationView;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Cache',
    'Kernel::System::Log',
    'Kernel::System::Time',
);

=head1 NAME

Kernel::System::NotificationView - to manage the notification view entries

=head1 SYNOPSIS

All functions to manage the notification event list entries.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item NotificationAdd()

adds a new notification to the database

    my $NotificationID = $NotificationViewObject->NotificationAdd(
        Name            => 'some notification name',
        Comment         => 'some notification comments',    # optional
        Subject         => 'some subject',
        Body            => 'some body',
        ObjectType      => 'some object type',              # e.g. Ticket
        ObjectID        => 123,
        ObjectReference => '54321',                            # optional, but very useful (like the TicketNumber)
        UserID          => 123,
    );

returns:

    $NotificationID = 123        # or false in case of a failure

=cut

sub NotificationAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Name Subject Body ObjectType ObjectID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{ObjectReference} //= "$Param{ObjectType}-$Param{ObjectID}";

    # calculate a task entity
    my $NotificationEntitiy = $Kernel::OM->Get('Kernel::System::Time')->SystemTime() . int rand 1000000;

    my $Age  = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();
    my $Seen = 0;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # insert data into db
    return if !$DBObject->Do(
        SQL => '
            INSERT INTO notification_view
                (notification_entity, name, comments, subject, body, object_type, object_id,
                object_reference, seen, create_time, create_time_unix, user_id)
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?, ?)',
        Bind => [
            \$NotificationEntitiy, \$Param{Name}, \$Param{Comment}, \$Param{Subject}, \$Param{Body},
            \$Param{ObjectType}, \$Param{ObjectID}, \$Param{ObjectReference}, \$Seen, \$Age, \$Param{UserID},
        ],
    );

    # get id
    $DBObject->Prepare(
        SQL => '
            SELECT id
            FROM notification_view
            WHERE notification_entity = ?',
        Bind => [ \$NotificationEntitiy ],
    );

    my $NotificationID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $NotificationID = $Row[0];
    }

    return if !$NotificationID;

    # delete cache
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    for my $CacheKey (
        'NotificationList',
        "NotificationList::UserID::$Param{UserID}::ObjectType::$Param{ObjectType}",
        "NotificationList::UserID::$Param{UserID}::ObjectType::all",
        "NotificationList::UserID::all::ObjectType::$Param{ObjectType}",
        )
    {
        $CacheObject->Delete(
            Type => 'NotificationViewList',
            Key  => $CacheKey,
        );
    }

    for my $CacheKey (
        'NotificationListGet',
        "NotificationListGet::UserID::$Param{UserID}::ObjectType::$Param{ObjectType}",
        "NotificationListGet::UserID::$Param{UserID}::ObjectType::all",
        "NotificationListGet::UserID::all::ObjectType::$Param{ObjectType}",
        )
    {
        $CacheObject->Delete(
            Type => 'NotificationViewListGet',
            Key  => $CacheKey,
        );
    }
    return $NotificationID;
}

=item NotificationGet()

returns the notification data

    my %Notification = $NotificationViewObject->NotificationGet(
        NotificationID => 123,
    );

returns:

    %Notification = (
        NotificationID => 123,
        Name            => 'some notification name',
        Comment         => 'some notification comments',
        Subject         => 'some notification subject',
        Body            => 'some notification body',
        ObjectType      => 'some object type',
        ObjectID        => 123,
        ObjectReference => '54321',
        Seen            => 1,                           # 1 or 0
        CreateTime      => '2015-05-07 12:27:00',
        CreateTimeUnix  => 123456,
        UserID          => 123,
    )

=cut

sub NotificationGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{NotificationID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need NotificationID!',
        );
        return;
    }

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # create cache key
    my $CacheKey = 'NotificationGet::NotificationID::' . $Param{NotificationID};

    # read cache
    my $Cache = $CacheObject->Get(
        Type           => 'NotificationView',
        Key            => $CacheKey,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );
    return %{$Cache} if $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $DBObject->Prepare(
        SQL => '
            SELECT id, name, comments, subject, body, object_type, object_id, object_reference, seen, create_time, create_time_unix, user_id
            FROM notification_view
            WHERE id = ?',
        Bind => [ \$Param{NotificationID} ],
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{NotificationID}  = $Row[0];
        $Data{Name}            = $Row[1];
        $Data{Comment}         = $Row[2];
        $Data{Subject}         = $Row[3];
        $Data{Body}            = $Row[4];
        $Data{ObjectType}      = $Row[5];
        $Data{ObjectID}        = $Row[6];
        $Data{ObjectReference} = $Row[7];
        $Data{Seen}            = $Row[8] // 0;
        $Data{CreateTime}      = $Row[9];
        $Data{CreateTimeUnix}  = $Row[10];
        $Data{UserID}          = $Row[11];
    }

    return if !%Data;

    # set cache
    $CacheObject->Set(
        Type           => 'NotificationView',
        Key            => $CacheKey,
        TTL            => 60 * 30,
        Value          => \%Data,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );

    return %Data;
}

=item NotificationDelete()

deletes notifications from the database

    my $Success = $NotificationViewObject->NotificationDelete(
        NotificationID => 123,
        UserID         => 123,
    );

or

    my $Success = $NotificationViewObject->NotificationDelete(
        ObjectType => 'Ticket',
        ObjectID   => 123,
        UserID     => 123,
    );

or

    my $Success = $NotificationViewObject->NotificationDelete(
        UserID   => 123,
    );

returns

    $Success = 1;       # or false in case of a failure

=cut

sub NotificationDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if (
        ( $Param{ObjectType} && !$Param{ObjectID} )
        || ( !$Param{ObjectType} && $Param{ObjectID} )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ObjectID and ObjectType",
        );
        return;
    }

    my %Notification;
    if ( $Param{NotificationID} ) {
        %Notification = $Self->NotificationGet(
            NotificationID => $Param{NotificationID},
        );
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my @Bind;

    my $SQL = '
        DELETE FROM notification_view';

    if ( $Param{NotificationID} ) {
        $SQL .= '
            WHERE id = ?';
        push @Bind, \$Param{NotificationID};
    }
    elsif ( $Param{ObjectID} ) {
        $SQL .= '
            WHERE object_type = ?
                AND object_id = ?';
        push @Bind, \$Param{ObjectType};
        push @Bind, \$Param{ObjectID};
    }
    else {
        $SQL .= '
            WHERE user_id = ?';
        push @Bind, \$Param{UserID};
    }

    # delete notifications
    $DBObject->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # delete cache
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    if ( $Param{NotificationID} ) {
        $CacheObject->Delete(
            Type => 'NotificationView',
            Key  => 'NotificationGet::NotificationID::' . $Param{NotificationID},
        );

        # if notification could be get delete specific cache, otherwise do nothing
        #     (notification should be already deleted)
        if (%Notification) {
            for my $CacheKey (
                'NotificationList',
                "NotificationList::UserID::$Notification{UserID}::ObjectType::$Notification{ObjectType}",
                "NotificationList::UserID::$Notification{UserID}::ObjectType::all",
                "NotificationList::UserID::all::ObjectType::$Notification{ObjectType}",
                )
            {
                $CacheObject->Delete(
                    Type => 'NotificationViewList',
                    Key  => $CacheKey,
                );
            }

            for my $CacheKey (
                'NotificationListGet',
                "NotificationListGet::UserID::$Notification{UserID}::ObjectType::$Notification{ObjectType}",
                "NotificationListGet::UserID::$Notification{UserID}::ObjectType::all",
                "NotificationListGet::UserID::all::ObjectType::$Notification{ObjectType}",
                )
            {
                $CacheObject->Delete(
                    Type => 'NotificationViewListGet',
                    Key  => $CacheKey,
                );
            }
        }
    }
    else {
        $CacheObject->CleanUp(
            Type => 'Notification',
        );

        $CacheObject->CleanUp(
            Type => 'NotificationViewList',
        );

        $CacheObject->CleanUp(
            Type => 'NotificationViewListGet',
        );
    }

    return 1;
}

=item NotificationList()

returns a list of notifications (filtered by a user id if given)

    my %NotificationList = $NotificationViewObject->NotificationList(
        UserID     => 123,      # optional
        ObjectType => 'Ticket'  # optional
    );

returns

    %NotificationList = (
        123 => 'Notification 1',
        456 => 'Notification 2'.
    );

=cut

sub NotificationList {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # create cache key
    my $CacheKey = 'NotificationList';
    if ( $Param{UserID} || $Param{ObjectType} ) {
        $CacheKey .= '::UserID::' . ( $Param{UserID} || 'all' ) . '::ObjectType::' . ( $Param{ObjectType} || 'all' );
    }

    # read cache
    my $Cache = $CacheObject->Get(
        Type           => 'NotificationViewList',
        Key            => $CacheKey,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );
    return %{$Cache} if $Cache;

    my $SQL = '
            SELECT id, name
            FROM notification_view';

    my @Bind;

    if ( $Param{UserID} ) {
        $SQL .= '
            WHERE user_id = ?';
        push @Bind, \$Param{UserID},
    }

    if ( $Param{ObjectType} && $Param{UserID} ) {
        $SQL .= '
            AND object_type = ?';
        push @Bind, \$Param{ObjectType},
    }
    elsif ( $Param{ObjectType} ) {
        $SQL .= '
            WHERE object_type = ?';
        push @Bind, \$Param{ObjectType},
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[1];
    }

    # set cache
    $CacheObject->Set(
        Type           => 'NotificationViewList',
        Key            => $CacheKey,
        TTL            => 60 * 30,
        Value          => \%Data,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );

    return %Data;
}

=item NotificationListGet()

returns a list of notifications and its details (filtered by a user id if given)

    my %NotificationList = $NotificationViewObject->NotificationListGet(
        UserID     => 123,      # optional
        ObjectType => 'Ticket', # optional
    );

returns

    %NotificationList = (
        123 => {
            NotificationID => 123,
            Name           => 'Notification 1,
            Comment        => 'some notification comment'
            # ...
        }
        456 => {
            NotificationID => 456,
            Name           => 'Notification 2,
            Comment        => 'some notification comment'
            # ...
        }
    );

=cut

sub NotificationListGet {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # create cache key
    my $CacheKey = 'NotificationListGet';
    if ( $Param{UserID} || $Param{ObjectType} ) {
        $CacheKey .= '::UserID::' . ( $Param{UserID} || 'all' ) . '::ObjectType::' . ( $Param{ObjectType} || 'all' );
    }

    # read cache
    my $Cache = $CacheObject->Get(
        Type           => 'NotificationViewListGet',
        Key            => $CacheKey,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );
    return %{$Cache} if $Cache;

    my $SQL = '
            SELECT id
            FROM notification_view';

    my @Bind;

    if ( $Param{UserID} ) {
        $SQL .= '
            WHERE user_id = ?';
        push @Bind, \$Param{UserID},
    }

    if ( $Param{ObjectType} && $Param{UserID} ) {
        $SQL .= '
            AND object_type = ?';
        push @Bind, \$Param{ObjectType},
    }
    elsif ( $Param{ObjectType} ) {
        $SQL .= '
            WHERE object_type = ?';
        push @Bind, \$Param{ObjectType},
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @NotificationIDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @NotificationIDs, $Row[0];
    }

    my %Data;

    for my $NotificationID (@NotificationIDs) {
        my %NotificationData = $Self->NotificationGet(
            NotificationID => $NotificationID,
        );

        if (%NotificationData) {
            $Data{$NotificationID} = \%NotificationData;
        }
    }

    # set cache
    $CacheObject->Set(
        Type           => 'NotificationViewListGet',
        Key            => $CacheKey,
        TTL            => 60 * 30,
        Value          => \%Data,
        CacheInMemory  => 0,
        CacheInBackend => 1,
    );

    return %Data;
}

=item NotificationSeenSet()

mark a notification as seen or unseen

    my $Success = $NotificationViewObject->NotificationSeenSet(
        NotificationID => 123,
        Seen           => 1,    # optional 1 or 0
        UserID         => 123,
    );

returns

    Success = 1;        # or false in case of an error

=cut

sub NotificationSeenSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(NotificationID UserID)) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get current notification
    my %Notification = $Self->NotificationGet(
        %Param,
    );

    if ( !%Notification ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Notification $Param{NotificationID} is invalid",
        );

        return;
    }

    $Param{Seen} //= 1;

    if ( $Param{Seen} != 0 && $Param{Seen} != 1 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Seen value is invalid",
        );

        return;
    }

    # update needed?
    return 1 if $Param{Seen} eq $Notification{Seen};

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            UPDATE notification_view
            SET seen = ?
            WHERE id = ?',
        Bind => [ \$Param{Seen}, \$Param{NotificationID} ],
    );

    # delete cache
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    $CacheObject->Delete(
        Type => 'NotificationView',
        Key  => 'NotificationGet::NotificationID::' . $Param{NotificationID},
    );

    for my $CacheKey (
        'NotificationListGet',
        "NotificationListGet::UserID::$Param{UserID}::ObjectType::$Notification{ObjectType}",
        "NotificationListGet::UserID::$Param{UserID}::ObjectType::all",
        "NotificationListGet::UserID::all::ObjectType::$Notification{ObjectType}",
        )
    {
        $CacheObject->Delete(
            Type => 'NotificationViewListGet',
            Key  => $CacheKey,
        );
    }

    return 1;
}

=item NotificationSearch()

To find sent event based notifications in your system.

    my @NotificationIDs = $NotificationViewObject->NotificationSearch(
        # result (required)
        Result => 'ARRAY' || 'HASH' || 'COUNT',

        # result limit
        Limit => 100,

        # notification name (optional) as STRING or as ARRAYREF
        Name => '%SomeName%',
        Name => ['%SomeName%', '%SomeOther%'],

        # notification subject (optional) as STRING or as ARRAYREF
        Subject => '%SomeText%',
        Subject => ['%SomeTest1%', '%SomeTest2%'],

        ObjectTypes       => ['Ticket', 'Other'],

        ObjectReferences  => ['123', '456'],

        ObjectIDs         => [1, 42, 512],

        UserIDs           => [1, 12, 455, 32]

        Seen              => [1, 0],

        # OrderBy and SortBy (optional)
        OrderBy => 'Down',  # Down|Up
        SortBy  => 'Age',   # Name|Age|Subject|ObjectType|ObjectID

        # OrderBy and SortBy as ARRAY for sub sorting (optional)
        OrderBy => ['Down', 'Up'],
        SortBy  => ['Priority', 'Age'],


        # CacheTTL, cache search result in seconds (optional)
        CacheTTL => 60 * 15,
    );

Returns:

Result: 'ARRAY'

    @NotificationIDs = ( 1, 2, 3 );

Result: 'HASH'

    %NotificationIDs = (
        1 => 'SomeName',
        2 => 'SomeOther',
        3 => 'SomeOther2',
    );

Result: 'COUNT'

    $Count = 123;

=cut

sub NotificationSearch {
    my ( $Self, %Param ) = @_;

    my $Result  = $Param{Result}  || 'HASH';
    my $OrderBy = $Param{OrderBy} || 'Down';
    my $SortBy  = $Param{SortBy}  || 'Age';
    my $Limit   = $Param{Limit}   || 10000;

    if ( !$Param{ContentSearch} ) {
        $Param{ContentSearch} = 'AND';
    }

    my %SortOptions = (
        Name            => 'nev.name',
        Age             => 'nev.create_time_unix',
        Subject         => 'nev.subject',
        ObjectType      => 'nev.object_type',
        ObjectID        => 'nev.object_id',
        ObjectReference => 'nev.object_reference',
        Seen            => 'nev.seen',
        UserID          => 'nev.user_id',
    );

    # check types of given arguments
    ARGUMENT:
    for my $Key (qw( ObjectTypes ObjectIDs ObjectReferences UserIDs )) {
        next ARGUMENT if !$Param{$Key};
        next ARGUMENT if ref $Param{$Key} eq 'ARRAY' && @{ $Param{$Key} };

        # log error
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The given param '$Key' is invalid or an empty array reference!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # quote id array elements
    ARGUMENT:
    for my $Key (qw( ObjectIDs UserIDs )) {
        next ARGUMENT if !$Param{$Key};

        # quote elements
        for my $Element ( @{ $Param{$Key} } ) {
            if ( !defined $DBObject->Quote( $Element, 'Integer' ) ) {

                # log error
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "The given param '$Element' in '$Key' is invalid!",
                );
                return;
            }
        }
    }

    my $ParamCheckString = ( join '', keys %Param ) || '';

    if ( ref $Param{SortBy} eq 'ARRAY' ) {
        $ParamCheckString .= ( join '', @{ $Param{SortBy} } );
    }
    elsif ( ref $Param{SortBy} ne 'HASH' ) {
        $ParamCheckString .= $Param{SortBy} || '';
    }

    # check sort/order by options
    my @SortByArray;
    my @OrderByArray;
    if ( ref $SortBy eq 'ARRAY' ) {
        @SortByArray  = @{$SortBy};
        @OrderByArray = @{$OrderBy};
    }
    else {
        @SortByArray  = ($SortBy);
        @OrderByArray = ($OrderBy);
    }
    for my $Count ( 0 .. $#SortByArray ) {
        if ( !$SortOptions{ $SortByArray[$Count] } ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need valid SortBy (' . $SortByArray[$Count] . ')!',
            );
            return;
        }
        if ( $OrderByArray[$Count] ne 'Down' && $OrderByArray[$Count] ne 'Up' ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need valid OrderBy (' . $OrderByArray[$Count] . ')!',
            );
            return;
        }
    }

    # create sql
    my $SQLSelect;
    if ( $Result eq 'COUNT' ) {
        $SQLSelect = 'SELECT COUNT(DISTINCT(nev.id))';
    }
    else {
        $SQLSelect = 'SELECT DISTINCT nev.id, nev.name';
    }

    my $SQLFrom = ' FROM notification_view nev ';

    my $SQLExt = ' WHERE 1=1';

    if ( $Param{ObjectTypes} ) {
        my @QuotedObjectTypes = map { "'" . $DBObject->Quote($_) . "'" } @{ $Param{ObjectTypes} };
        $SQLExt .= " AND nev.object_type IN ( ${\(join ', ', sort @QuotedObjectTypes)} ) ";
    }

    if ( $Param{ObjectReferences} ) {
        my @QuotedObjectReferences = map { "'" . $DBObject->Quote($_) . "'" } @{ $Param{ObjectReferences} };
        $SQLExt .= " AND nev.object_reference IN ( ${\(join ', ', sort @QuotedObjectReferences)} ) ";
    }

    if ( $Param{ObjectIDs} ) {
        $SQLExt .= $Self->_InConditionGet(
            TableColumn => 'nev.object_id',
            IDRef       => $Param{ObjectIDs},
        );
    }

    if ( $Param{UserIDs} ) {
        $SQLExt .= $Self->_InConditionGet(
            TableColumn => 'nev.user_id',
            IDRef       => $Param{UserIDs},
        );
    }

    if ( $Param{Seen} ) {
        $SQLExt .= $Self->_InConditionGet(
            TableColumn => 'nev.seen',
            IDRef       => $Param{Seen},
        );
    }

    # other notification stuff
    my %FieldSQLMap = (
        Name    => 'nev.name',
        Subject => 'nev.subject',
    );

    ATTRIBUTE:
    for my $Key ( sort keys %FieldSQLMap ) {

        next ATTRIBUTE if !defined $Param{$Key};

        # if it's no ref, put it to array ref
        if ( ref $Param{$Key} eq '' ) {
            $Param{$Key} = [ $Param{$Key} ];
        }

        # process array ref
        my $Used = 0;

        VALUE:
        for my $Value ( @{ $Param{$Key} } ) {

            next VALUE if !$Value;

            # replace wild card search
            $Value =~ s/\*/%/gi;

            # check search attribute, we do not need to search for *
            next VALUE if $Value =~ /^\%{1,3}$/;

            if ( !$Used ) {
                $SQLExt .= ' AND (';
                $Used = 1;
            }
            else {
                $SQLExt .= ' OR ';
            }

            # add * to prefix/suffix on title search
            my %ConditionFocus;
            if ( $Param{ConditionInline} && ( $Key eq 'Name' || $Key eq 'Subject' ) ) {
                $ConditionFocus{Extended} = 1;
                if ( $Param{ContentSearchPrefix} ) {
                    $ConditionFocus{SearchPrefix} = $Param{ContentSearchPrefix};
                }
                if ( $Param{ContentSearchSuffix} ) {
                    $ConditionFocus{SearchSuffix} = $Param{ContentSearchSuffix};
                }
            }

            # scape (brakes) and other characters like & and -
            $Value = $DBObject->QueryStringEscape(
                QueryString => $Value,
            );

            # use search condition extension
            $SQLExt .= $DBObject->QueryCondition(
                Key   => $FieldSQLMap{$Key},
                Value => $Value,
                %ConditionFocus,
            );
        }
        if ($Used) {
            $SQLExt .= ')';
        }
    }

    # database query for sort/order by option
    if ( $Result ne 'COUNT' ) {
        $SQLExt .= ' ORDER BY';
        for my $Count ( 0 .. $#SortByArray ) {
            if ( $Count > 0 ) {
                $SQLExt .= ',';
            }

            $SQLSelect .= ', ' . $SortOptions{ $SortByArray[$Count] };
            $SQLExt    .= ' ' . $SortOptions{ $SortByArray[$Count] };

            if ( $OrderByArray[$Count] eq 'Up' ) {
                $SQLExt .= ' ASC';
            }
            else {
                $SQLExt .= ' DESC';
            }
        }
    }

    # check cache
    my $CacheObject;
    if ( $Param{CacheTTL} ) {
        $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
        my $CacheData = $CacheObject->Get(
            Type => 'NotificationViewSearch',
            Key  => $SQLSelect . $SQLFrom . $SQLExt . $Result . $Limit,
        );

        if ( defined $CacheData ) {
            if ( ref $CacheData eq 'HASH' ) {
                return %{$CacheData};
            }
            elsif ( ref $CacheData eq 'ARRAY' ) {
                return @{$CacheData};
            }
            elsif ( ref $CacheData eq '' ) {
                return $CacheData;
            }
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Invalid ref ' . ref($CacheData) . '!'
            );
            return;
        }
    }

    # database query
    my %Notifications;
    my @NotificationIDs;
    my $Count;
    return
        if !$DBObject->Prepare(
        SQL   => $SQLSelect . $SQLFrom . $SQLExt,
        Limit => $Limit,
        );
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Count = $Row[0];
        $Notifications{ $Row[0] } = $Row[1];
        push @NotificationIDs, $Row[0];
    }

    # return COUNT
    if ( $Result eq 'COUNT' ) {
        if ($CacheObject) {
            $CacheObject->Set(
                Type  => 'NotificationViewSearch',
                Key   => $SQLSelect . $SQLFrom . $SQLExt . $Result . $Limit,
                Value => $Count,
                TTL   => $Param{CacheTTL} || 60 * 4,
            );
        }
        return $Count;
    }

    # return HASH
    elsif ( $Result eq 'HASH' ) {
        if ($CacheObject) {
            $CacheObject->Set(
                Type  => 'NotificationViewSearch',
                Key   => $SQLSelect . $SQLFrom . $SQLExt . $Result . $Limit,
                Value => \%Notifications,
                TTL   => $Param{CacheTTL} || 60 * 4,
            );
        }
        return %Notifications;
    }

    # return ARRAY
    else {
        if ($CacheObject) {
            $CacheObject->Set(
                Type  => 'NotificationViewSearch',
                Key   => $SQLSelect . $SQLFrom . $SQLExt . $Result . $Limit,
                Value => \@NotificationIDs,
                TTL   => $Param{CacheTTL} || 60 * 4,
            );
        }
        return @NotificationIDs;
    }
}

=item NameFilterValuesGet()

get a list of notification event names within the given notification event list

    my $Values = $NotificationViewObject->NameFilterValuesGet(
        NotificationIDs => [23, 1, 56, 74],                    # array ref list of notification event IDs
    );

    returns

    $Values = {
        'Notification1' => 'Notification1',
        'Notification2' => 'Notification2',
    };

=cut

sub NameFilterValuesGet {
    my ( $Self, %Param ) = @_;

    if ( !IsArrayRefWithData( $Param{NotificationIDs} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'NotificationIDs must be an array ref!',
        );
        return;
    }

    my $NotificationIDString = $Self->_InConditionGet(
        TableColumn => 'nev.id',
        IDRef       => $Param{NotificationIDs},
        ,
    );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT DISTINCT(nev.name)
            FROM notification_view nev
            WHERE 1=1'
            . $NotificationIDString
            . ' ORDER BY nev.name DESC',
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( $Row[0] ) {
            $Data{ $Row[0] } = $Row[0];
        }
    }

    return \%Data;
}

=item ObjectTypeFilterValuesGet()

get a list of notification event object types within the given notification event list

    my $Values = $NotificationViewObject->ObjectTypeFilterValuesGet(
        NotificationIDs => [23, 1, 56, 74],                    # array ref list of notification event IDs
    );

    returns

    $Values = {
        'Ticket'=> 'Ticket',
        'Other' => 'Other',
    };

=cut

sub ObjectTypeFilterValuesGet {
    my ( $Self, %Param ) = @_;

    if ( !IsArrayRefWithData( $Param{NotificationIDs} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'NotificationIDs must be an array ref!',
        );
        return;
    }

    my $NotificationIDString = $Self->_InConditionGet(
        TableColumn => 'nev.id',
        IDRef       => $Param{NotificationIDs},
        ,
    );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT DISTINCT(nev.object_type)
            FROM notification_view nev
            WHERE 1=1'
            . $NotificationIDString
            . ' ORDER BY nev.object_type DESC',
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( $Row[0] ) {
            $Data{ $Row[0] } = $Row[0];
        }
    }

    return \%Data;
}

=item ObjectReferenceFilterValuesGet()

get a list of notification event object references within the given notification event list

    my $Values = $NotificationViewObject->ObjectReferenceFilterValuesGet(
        NotificationIDs => [23, 1, 56, 74],                    # array ref list of notification event IDs
    );

    returns

    $Values = {
        123 => '1978348789',
        456 => '8788987223',
    };

=cut

sub ObjectReferenceFilterValuesGet {
    my ( $Self, %Param ) = @_;

    if ( !IsArrayRefWithData( $Param{NotificationIDs} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'NotificationIDs must be an array ref!',
        );
        return;
    }

    my $NotificationIDString = $Self->_InConditionGet(
        TableColumn => 'nev.id',
        IDRef       => $Param{NotificationIDs},
        ,
    );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT DISTINCT(nev.object_reference)
            FROM notification_view nev
            WHERE 1=1'
            . $NotificationIDString
            . ' ORDER BY nev.object_reference DESC',
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( $Row[0] ) {
            $Data{ $Row[0] } = $Row[0];
        }
    }

    return \%Data;
}

=begin Internal:

=cut

=item _InConditionGet()

internal function to create an

    AND table.column IN (values)

condition string from an array.

    my $SQLPart = $NotificationViewObject->_InConditionGet(
        TableColumn => 'table.column',
        IDRef       => $ArrayRef,
    );

=cut

sub _InConditionGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Key (qw(TableColumn IDRef)) {
        if ( !$Param{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Key!",
            );
            return;
        }
    }

    # sort ids to cache the SQL query
    my @SortedIDs = sort { $a <=> $b } @{ $Param{IDRef} };

    # quote values
    SORTEDID:
    for my $Value (@SortedIDs) {
        next SORTEDID if !defined $Kernel::OM->Get('Kernel::System::DB')->Quote( $Value, 'Integer' );
    }

    # split IN statement with more than 900 elements in more statements combined with OR
    # because Oracle doesn't support more than 1000 elements for one IN statement.
    my @SQLStrings;
    while ( scalar @SortedIDs ) {

        # remove section in the array
        my @SortedIDsPart = splice @SortedIDs, 0, 900;

        # link together IDs
        my $IDString = join ', ', @SortedIDsPart;

        # add new statement
        push @SQLStrings, " $Param{TableColumn} IN ($IDString) ";
    }

    my $SQL = '';
    if (@SQLStrings) {

        # combine statements
        $SQL = join ' OR ', @SQLStrings;

        # encapsulate conditions
        $SQL = ' AND ( ' . $SQL . ' ) ';
    }
    return $SQL;
}

1;

=end Internal:

=cut

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
