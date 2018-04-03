# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ChatChannel;

use strict;
use warnings;

use Kernel::System::Time;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::DB',
    'Kernel::System::Group',
    'Kernel::System::JSON',
    'Kernel::System::Log',
    'Kernel::System::Queue',
    'Kernel::System::User',
);

=head1 NAME

Kernel::System::Chat - chat engine backend

=head1 SYNOPSIS

Chat engine backend

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{DBObject} = $Kernel::OM->Get('Kernel::System::DB');

    # set default channel name
    # it will be used in most of methods
    $Self->{DefaultChannelName} = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::DefaultChatChannel");

    $Self->{CacheType} = 'ChatChannel';

    return $Self;
}

=item ChatChannelAdd()

add a new chat channel

    my $ChatChannelID = $ChatChannelObject->ChatChannelAdd(
        Name        => 'request', # request or active
        GroupID     => 12,
        ValidID     => 1,
        UserID      => 1,
        Comment     => "Some comment"
        NoDefaultCheck => 1,  # optional ,do not check is name the same like default channel name
    );

=cut

sub ChatChannelAdd {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Name UserID GroupID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # cleanup channel name
    my $Name = $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
        StringRef => \$Param{Name},
    );
    $Param{Name} = $$Name;

    if (
        ( $Param{Name} eq $Self->{DefaultChannelName} )
        && !$Param{NoDefaultCheck}
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Can't create channel with a same name as default chat channel!"
        );
        return;
    }

    if ( length $Param{Name} > 200 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Name cannot be longer than 200 characters (is: $Param{Name})!",
        );
        return;
    }

    for my $NumericParam (qw(GroupID ValidID UserID)) {
        if ( $Param{$NumericParam} !~ /^\d+?$/ ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "$NumericParam must be a number (is: $Param{$NumericParam})!",
            );
            return;
        }
    }

    return if !$Self->{DBObject}->Do(
        SQL => '
            INSERT INTO chat_channel
               (name, group_id, valid_id, create_time, create_by, change_time, change_by, comments)
               VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{GroupID}, \$Param{ValidID}, \$Param{UserID}, \$Param{UserID},
            \$Param{Comment},
        ],
    );

    return if !$Self->{DBObject}->Prepare(
        SQL => '
            SELECT id
                FROM chat_channel
                WHERE
                    name = ?
                    AND create_by = ?
                ORDER BY id DESC',
        Bind => [
            \$Param{Name}, \$Param{UserID},
        ],
        Limit => 1,
    );

    # fetch the result
    my $ChatChannelID;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $ChatChannelID = $Row[0];
    }

    return $ChatChannelID;
}

=item ChatChannelUpdate()

update a chat channel.

Returns 1 if update is sucessfull.

    my $Status = $ChatChanellObject->ChatChannelUpdate(
        ChatChannelID   => $ChatChannelID,
        Name            => 'New channel',
        GroupID         => 12,
        ValidID         => 1,
        UserID          => 1,
    );

=cut

sub ChatChannelUpdate {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Name GroupID UserID ChatChannelID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # cleanup channel name
    my $Name = $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
        StringRef => \$Param{Name},
    );
    $Param{Name} = $$Name;

    if ( length $Param{Name} > 200 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Name cannot be longer than 200 characters (is: $Param{Name})!",
        );
        return;
    }

    for my $NumericParam (qw(ChatChannelID GroupID ValidID UserID)) {
        if ( $Param{$NumericParam} !~ /^\d+?$/ ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "$NumericParam must be a number (is: $Param{$NumericParam})!",
            );
            return;
        }
    }

    my $DefaultChatChannelID = $Self->DefaultChatChannelGet();

    if ( $Param{ChatChannelID} != $DefaultChatChannelID && $Param{Name} eq $Self->{DefaultChannelName} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Name can't be the same as default channel name!"
        );
        return;
    }

    return if !$Self->{DBObject}->Do(
        SQL => '
            UPDATE chat_channel
                SET
                    name = ?,
                    group_id = ?,
                    valid_id = ?,
                    comments = ?,
                    change_by = ?,
                    change_time = current_timestamp
                WHERE id = ?',
        Bind => [
            \$Param{Name},
            \$Param{GroupID},
            \$Param{ValidID},
            \$Param{Comment},
            \$Param{UserID},
            \$Param{ChatChannelID},
        ],
    );

    return 1;
}

=item ChatChannelGet()

get a chat channel's data.

    my %ChatChannel = $ChatChannelObject->ChatChannelGet(
        ChatChannelID => $ID,
    );

Returns:
    %ChatChannel = {
        ChatChannelID   => 1,
        Name            => 'Channel name',
        GroupID         => 12,
        ValidID         => 1,
        CreateTime      => '2015-01-01 00:00:00',
        CreateBy        => 1,
        ChangeTime      => '2015-01-01 00:00:00',
        ChangeBy        => 1,
        Comment         => 'Channel comment',
    };

=cut

sub ChatChannelGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatChannelID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = '
        SELECT id, name, group_id, valid_id, create_time, create_by, change_time, change_by, comments
            FROM chat_channel
            WHERE id = ?';

    return if !$Self->{DBObject}->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Param{ChatChannelID} ],
        Limit => 1,
    );

    my %ChatChannel;

    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        %ChatChannel = (
            ChatChannelID => $Row[0],
            Name          => $Row[1],
            GroupID       => $Row[2],
            ValidID       => $Row[3],
            CreateTime    => $Row[4],
            CreateBy      => $Row[5],
            ChangeTime    => $Row[6],
            ChangeBy      => $Row[7],
            Comment       => $Row[8],
        );
    }

    return %ChatChannel;
}

=item ChatChannelsGet()

list all chat channels.

    my @AllChatChannels = $ChatChannelObject->ChatChannelsGet(
        Valid          => 1, # optional
        IncludeDefault => 1, # optional
    );

returns:
    @AllChatChannels = [
        {
            ChatChannelID => '1',
            Name          => 'Channel name',
            GroupID       => 12,
            ValidID       => 1,
            CreateTime    => 2015-01-01,
            CreateBy      => 1,
            ChangeTime    => 2015-01-01,
            ChangeBy      => 1,
            Comment       => 'Comment',
        },
        ...
    ];

=cut

sub ChatChannelsGet {
    my ( $Self, %Param ) = @_;

    my $SQLSelect = '
            SELECT id, name, group_id, valid_id, create_time, create_by, change_time, change_by, comments
                FROM chat_channel';

    my $SQLWhere = 'WHERE 1=1';

    if ( defined $Param{Valid} ) {
        $SQLWhere .= ' AND valid_id = 1';
    }

    # skip default channel
    if ( !defined $Param{IncludeDefault} ) {
        $SQLWhere .= " AND name != '" . $Self->{DefaultChannelName} . "'";
    }

    return if !$Self->{DBObject}->Prepare(
        SQL => join( ' ', $SQLSelect, $SQLWhere ),
    );

    my @Result;

    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {

        my %ChatChannel = (
            ChatChannelID => $Row[0],
            Name          => $Row[1],
            GroupID       => $Row[2],
            ValidID       => $Row[3],
            CreateTime    => $Row[4],
            CreateBy      => $Row[5],
            ChangeTime    => $Row[6],
            ChangeBy      => $Row[7],
            Comment       => $Row[8],
        );

        push @Result, \%ChatChannel;
    }

    return @Result;
}

=item ChatChannelPermissionGet()

Return permission for the particular user and channel.
    my $Permission = $ChatChannelObject->ChatChannelPermissionGet(
        UserID        => 123,
        ChatChannelID => 2,
    );
    $Permission = 'Participant';

=cut

sub ChatChannelPermissionGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UserID ChatChannelID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    # mapping internal permission name <=> expected name
    my %Mapping = (
        'chat_owner'       => 'Owner',
        'chat_participant' => 'Participant',
        'chat_observer'    => 'Observer',
    );

    # get group of the current chat channel
    my %ChatChannel = $Self->ChatChannelGet(
        ChatChannelID => $Param{ChatChannelID},
    );

    return if !%ChatChannel;
    return if !$ChatChannel{GroupID};

    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    # check permissions
    for my $Permission (qw(chat_owner chat_participant chat_observer)) {

        # get the chat_participant users permissions for this group
        my %PermissionGroups = $GroupObject->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Permission,
        );

        if ( $PermissionGroups{ $ChatChannel{GroupID} } ) {
            return $Mapping{$Permission};
        }
    }

    return;
}

=item ChatPermissionChannelGet()

Return all channels where the user has one or more certain permissions.

    my %AvailableChannels = $ChatChannelObject->ChatPermissionChannelGet(
        UserID        => 123,
        Permission    => 'chat_participant',
    );

    my %AvailableChannels = $ChatChannelObject->ChatPermissionChannelGet(
        UserID        => 123,
        Permission    => ['chat_observer', 'chat_participant', 'chat_owner'],
    );

    %AvailableChannels = (
        1 => 'first name',
        2 => 'second name',
    )

=cut

sub ChatPermissionChannelGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UserID Permission)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    my @ChatChannels = $Self->ChatChannelsGet(
        Valid => 1,
    );
    my @Permissions = ref $Param{Permission} ? @{ $Param{Permission} } : $Param{Permission};
    my %PermissionChannels;

    for my $Permission (@Permissions) {
        my %PermissionGroups = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Permission,
        );
        for my $ChatChannel (@ChatChannels) {
            if ( $PermissionGroups{ $ChatChannel->{GroupID} } ) {
                $PermissionChannels{ $ChatChannel->{ChatChannelID} } = $ChatChannel->{Name};
            }
        }
    }

    return %PermissionChannels;
}

=item ChatChannelDelete()

dalete a chat channel.

Returns 1 if delete is sucessfull.

    my $Response = $ChatChanellObject->ChatChannelDelete(
        ChatChannelID   => $ChatChannelID,
        UserID          => 1,
    );

=cut

sub ChatChannelDelete {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID ChatChannelID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( $Param{ChatChannelID} !~ /^\d+$/ ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "ChatChannelID in wrong format (is: $Param{ChatChannelID})!"
        );
        return;
    }

    return if !$Self->{DBObject}->Do(
        SQL => '
                DELETE FROM chat_channel
                    WHERE id = ?',
        Bind => [
            \$Param{ChatChannelID},
        ],
    );

    return 1;
}

=item CustomChatChannelsGet()

Get personal chat channels of given UserID.

    my @CustomChatChannels = $ChatChannelObject->CustomChatChannelsGet(
        Key     => 'ExternalChannels',     # user_preferences key ('ExternalChannels' or 'InternalChannels')
        UserID  => 123,
    );

    @CustomChatChannels = [1,3,5];

=cut

sub CustomChatChannelsGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UserID Key)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # Channel ID's
    my @ChatChannelIDs;

    my %Channels = $Kernel::OM->Get('Kernel::System::User')->SearchPreferences(
        Key    => $Param{Key},
        UserID => $Param{UserID},
    );

    if ( exists $Channels{ $Param{UserID} } ) {

        my $ChannelIDsJSON = $Channels{ $Param{UserID} };

        @ChatChannelIDs = @{
            $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                Data => $ChannelIDsJSON,
                )
        };
    }

    return @ChatChannelIDs;
}

=item CustomChatChannelsSet()

Set personal chat channels of given UserID.

    $ChatChannelObject->CustomChatChannelsSet(
        Key             => 'ExternalChannels',     # user_preferences key ('ExternalChannels' or 'InternalChannels')
        UserChannels    => [ 1, 3, 5 ],            # Array of channel ids
        UserID          => 123,
    );

=cut

sub CustomChatChannelsSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UserID Key UserChannels)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my @Channels = @{ $Param{UserChannels} };

    my @AllChatChannels = $Self->ChatChannelsGet(
        Valid => 1,
    );

    my @FilteredChannels;

    # Check if channels are valid
    for my $ChannelID (@Channels) {
        if ( grep { $ChannelID == $_->{ChatChannelID} } @AllChatChannels ) {
            push @FilteredChannels, $ChannelID;
        }
    }

    # Convert to JSON
    my $UserChannelsJSON = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
        Data => \@FilteredChannels,
    );

    # Update user preferences
    $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
        Key    => $Param{Key},
        Value  => $UserChannelsJSON,
        UserID => $Param{UserID},
    );

    return;
}

=item ChannelLookup()

get id or name for channel

    my $Channel = $ChatChannelObject->ChannelLookup( ChannelID => $ChannelID );

    my $ChannelID = $ChatChannelObject->ChannelLookup( Channel => $Channel );

=cut

sub ChannelLookup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Channel} && !$Param{ChannelID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Got no Channel or ChannelID!',
        );
        return;
    }

    my $SQL;

    if ( $Param{ChannelID} ) {
        $SQL = "
            SELECT name
                FROM chat_channel WHERE id=?";
    }
    else {
        $SQL = "
            SELECT id
                FROM chat_channel WHERE name=?";
    }

    $Self->{DBObject}->Prepare(
        SQL  => $SQL,
        Bind => [
            $Param{ChannelID} ? \$Param{ChannelID} : \$Param{Channel},
        ],
    );

    # fetch the result
    my $Result;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Result = $Row[0];
    }

    return $Result;

}

=item ChatChannelQueuesGet()

get all chat channel_queue relations.

    my %Relations = $ChatChannelObject->ChatChannelQueuesGet();

=cut

sub ChatChannelQueuesGet {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    my $CacheKey = 'ChatChannelQueue';

    # read cache
    my $Cache = $CacheObject->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return %{$Cache} if $Cache && ref $Cache eq 'HASH';

    # store all queue to ChatChannel preferences
    my %QueueChatChannelList;

    # create Queue object
    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

    # get all valid queues
    my %Queues = $QueueObject->GetAllQueues();

    for my $QueueID ( sort keys %Queues ) {

        # get Queue preferences
        my %QueuePreferences = $QueueObject->QueuePreferencesGet(
            QueueID => $QueueID,
            UserID  => 1,          # work as System User to get all
        );

        # if there is a ChatChannel set
        if ( $QueuePreferences{ChatChannel} ) {
            $QueueChatChannelList{$QueueID} = $QueuePreferences{ChatChannel};
        }
    }

    # set cache
    $CacheObject->Set(
        Type  => $Self->{CacheType},
        Key   => $CacheKey,
        TTL   => 60 * 60 * 24 * 20,
        Value => \%QueueChatChannelList,
    );

    return %QueueChatChannelList;
}

=item DefaultChatChannelGet()

get id of default chat channel. If chat channel does not exist, it will be created

    my $ChannelID = $ChatChannelObject->DefaultChatChannelGet();

=cut

sub DefaultChatChannelGet {
    my ( $Self, %Param ) = @_;

    # create cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    my $CacheKey = 'DefaultChatChannel';

    # check is default channel id cached already
    # read cache
    my $Cache = $CacheObject->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    return $Cache if $Cache;

    # look for default chat channel
    my $DefaultChannelID = $Self->ChannelLookup(
        Channel => $Self->{DefaultChannelName},
    );

    # if there's no DefaultChannelID, create Default Channel
    if ( !$DefaultChannelID ) {

        # the default assigned group should be the same which is used for
        # the general chat permission
        my $DefaultGroup
            = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::PermissionGroup::ChatReceivingAgents") || 'users';
        my $GroupID = $Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
            Group => $DefaultGroup,
        );

        # if group id can't be determined, default channel can't be created
        if ( !$GroupID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "Group '$DefaultGroup' is set as ChatEngine::PermissionGroup::ChatReceivingAgents, but doesn't exist. Default chat channel can't be created.",
            );
            return;
        }

        $DefaultChannelID = $Self->ChatChannelAdd(
            Name    => $Self->{DefaultChannelName},
            GroupID => $GroupID,
            ValidID => 1,
            UserID  => 1,
            Comment =>
                $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{LanguageObject}->Translate("Default chat channel"),
            NoDefaultCheck => 1,
        );

        # reset cache
        $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
            Type => $Self->{CacheType},
            Key  => $CacheKey,
        );

    }

    # set new cache
    $CacheObject->Set(
        Type  => $Self->{CacheType},
        Key   => $CacheKey,
        TTL   => 60 * 60 * 24 * 20,
        Value => $DefaultChannelID,
    );

    return $DefaultChannelID;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
