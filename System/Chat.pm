# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Chat;

use strict;
use warnings;

use Kernel::System::Time;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::AuthSession',
    'Kernel::System::ChatChannel',
    'Kernel::System::CustomerUser',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
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
    my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item ChatAdd()

add a new chat (request).

    my $ChatID = $ChatObject->ChatAdd(
        Status        => 'request',  # request or active
        RequesterName => 'Some Name',
        RequesterType => 'User',     # 'User', 'Customer' or 'Public'
        TargetType    => 'Customer', # 'User' or 'Customer'
        RequesterID   => 3,
        ChannelID     => 3 ,         # not required
        TicketID      => 3,          # not required, related TicketID
    );

returns
    my $ChatID = 1;

=cut

sub ChatAdd {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Status RequesterID RequesterName RequesterType TargetType ChannelID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( length $Param{RequesterID} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "RequesterName cannot be longer than 255 characters (is: $Param{RequesterName})!"
        );
        return;
    }

    if ( length $Param{RequesterName} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "RequesterName cannot be longer than 255 characters (is: $Param{RequesterName})!"
        );
        return;
    }

    if ( length $Param{RequesterType} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "RequesterType cannot be longer than 255 characters (is: $Param{RequesterType})!"
        );
        return;
    }

    if ( length $Param{TargetType} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "TargetType cannot be longer than 255 characters (is: $Param{TargetType})!",
        );
        return;
    }

    if ( $Param{Status} ne 'request' && $Param{Status} ne 'active' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Invalid chat status $Param{Status}!",
        );
        return;
    }

    # set TicketID to 0 if it's not provided
    if ( !$Param{TicketID} ) {
        $Param{TicketID} = 0;
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO chat
                (status, requester_id, requester_name, requester_type, target_type, create_time, change_time, chat_channel_id, ticket_id)
                VALUES (?, ?, ?, ?, ?, current_timestamp, current_timestamp, ?, ?)',
        Bind => [
            \$Param{Status},        \$Param{RequesterID}, \$Param{RequesterName},
            \$Param{RequesterType}, \$Param{TargetType},  \$Param{ChannelID},
            \$Param{TicketID},
        ],
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => '
            SELECT id
                FROM chat
                WHERE status = ?
                    AND requester_name = ?
                    AND requester_type = ?
                    AND target_type = ?
                ORDER BY id DESC',
        Bind => [
            \$Param{Status}, \$Param{RequesterName}, \$Param{RequesterType}, \$Param{TargetType},
        ],
        Limit => 1,
    );

    # fetch the result
    my $ChatID;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $ChatID = $Row[0];
    }

    return $ChatID;
}

=item ChatUpdate()

update a chat.

    my $Success = $ChatObject->ChatUpdate(
        ChatID  => $ChatID,
        Status  => 'request', # request, active or closed
                              # status closed is used for deprecated chats
                              # chats with status closed will be removed from database by OTRS Daemon
    );
returns
    my $Success = 1;

=cut

sub ChatUpdate {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Status ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if (
        $Param{Status} ne 'request'
        && $Param{Status} ne 'active'
        && $Param{Status} ne 'closed'
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Invalid chat status $Param{Status}!",
        );
        return;
    }

    my $SQL = '
            UPDATE chat
                SET status = ?, change_time = current_timestamp
                WHERE id = ? ';

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{Status}, \$Param{ChatID},
        ],
    );

    return 1;
}

=item ChatGet()

get a chat's data.

    my %Chat = $ChatObject->ChatGet(
        ChatID => $ID,
    );

result:
    %Chat = (
        ChatID          => '1',
        Status          => 'Active',
        RequesterID     => 'jdoe',
        RequesterName   => 'John Doe,
        RequesterType   => 'Customer',
        TargetType      => 'Agent',
        CreateTime      => '2015-07-03 13:25:41',
        ChatChannelID   => 1,
        TicketID        => 0,
    );

=cut

sub ChatGet {
    my ( $Self, %Param ) = @_;

    my $SQL = '
            SELECT id, status, requester_id, requester_name, requester_type, target_type, create_time, chat_channel_id, ticket_id
                FROM chat
                WHERE id = ?';

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Param{ChatID} ],
        Limit => 1,
    );

    my %Result;

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        %Result = (
            ChatID        => $Row[0],
            Status        => $Row[1],
            RequesterID   => $Row[2],
            RequesterName => $Row[3],
            RequesterType => $Row[4],
            TargetType    => $Row[5],
            CreateTime    => $Row[6],
            ChatChannelID => $Row[7],
            TicketID      => $Row[8],
        );
    }

    return %Result;
}

=item ChatList()

list all or specific chats.
    my @AllChats = $ChatObject->ChatList();
    my @Chats = $ChatObject->ChatList(
        Status        => 'request',     # optional, request or active
        RequesterType => 'Customer',    # optional
        TargetType    => 'User',        # optional
        ChannelIDs    => [3,5,7],       # optional
        Outdated      => 1,             # optional, list chats that passed the decay time
        # Filter chats based on chat_participants (needs at least ChatterID and ChatterType)
        ChatterID     => $ChatterID,    # Optional, typically this would be a UserID
        ChatterType   => $ChatterType,  # Optional, typically this would be 'User', 'Customer' or 'Public'
        ChatterActive => 0 or 1,        # Optional, if specified looks for confirmed or unconfirmed chat participants
        MaskAgentName => 1,             # optional, will use the appropriate config setting to display a generic agent name instead of the real one
    );

returns:
    @Chats = [
        {
            'ChatID' => '168',
            'CreateTime' => '2015-07-06 06:49:47',
            'Status' => 'active',
            'Channel' => 'Channel 1',
            'RequesterType' => 'Customer',
            'Order' => 0,
            'RequesterID' => 'jdoe',
            'RequesterName' => 'John Doe',
            'TargetType' => 'User',
            'Invitation' => '0',
            'ChannelID' => '72',
            'TicketID' => '0',
        },
        {
            'ChatID' => '171',
            'CreateTime' => '2015-07-07 13:40:52',
            'Status' => 'active',
            'Channel' => 'Channel 2',
            'RequesterType' => 'Customer',
            'Order' => 0,
            'RequesterID' => 'jdoe',
            'RequesterName' => 'John Doe',
            'TargetType' => 'User',
            'Invitation' => '0',
            'ChannelID' => '72',
            'TicketID' => '0'
        }
    ];

=cut

sub ChatList {
    my ( $Self, %Param ) = @_;

    # Check if chats should be appended or prepended
    my $ChatAppend = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatOrder') || '';

    # Get Chat order from user preference
    my %Preferences;
    my @Order;

    if ( defined $Param{ChatterType} && $Param{ChatterType} eq 'User' ) {
        %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
            UserID => $Param{ChatterID},
        );

        if ( defined $Preferences{ChatOrder} ) {
            @Order = split( ',', $Preferences{ChatOrder} );
        }
    }

    my $SQLSelect = '
        SELECT DISTINCT chat.id, chat.status, chat.requester_id, chat.requester_name,
            chat.requester_type, chat.target_type, chat.create_time, chat.chat_channel_id, chat.ticket_id';
    my $SQLFrom = 'FROM chat';
    my @SQLWhereItems;
    my @Bind;

    if ( $Param{Status} ) {
        push @SQLWhereItems, 'chat.status = ?';
        push @Bind,          \$Param{Status};
    }
    if ( $Param{RequesterType} ) {
        push @SQLWhereItems, 'chat.requester_type = ?';
        push @Bind,          \$Param{RequesterType};
    }
    if ( $Param{TargetType} ) {
        push @SQLWhereItems, 'chat.target_type = ?';
        push @Bind,          \$Param{TargetType};
    }

    if ( $Param{ChannelIDs} && @{ $Param{ChannelIDs} } > 0 ) {

        # Set value to something like ?,?,?,?,
        my $INItems = '?,' x scalar @{ $Param{ChannelIDs} };

        # Remove last ,
        chop $INItems;

        push @SQLWhereItems, 'chat.chat_channel_id IN (' . $INItems . ')';

        for my $ChannelID ( @{ $Param{ChannelIDs} } ) {
            push @Bind, \$ChannelID;
        }
    }
    elsif ( $Param{ChannelIDs} && @{ $Param{ChannelIDs} } == 0 ) {

        # User has no selected channels, return nothing
        push @SQLWhereItems, '1=0';
    }

    if ( $Param{ChatterID} && $Param{ChatterType} ) {
        $SQLSelect .= " , chat_participant.invitation";
        $SQLFrom   .= ', chat_participant';
        push @SQLWhereItems, 'chat.id = chat_participant.chat_id';
        push @SQLWhereItems, 'chat_participant.chatter_id = ?';
        push @Bind,          \$Param{ChatterID};
        push @SQLWhereItems, 'chat_participant.chatter_type = ?';
        push @Bind,          \$Param{ChatterType};

        if ( defined $Param{ChatterActive} ) {
            push @SQLWhereItems, 'chat_participant.chatter_active = ?';
            push @Bind,          \$Param{ChatterActive};
        }
    }

    if ( $Param{Outdated} && !$Param{Status} ) {
        my $ChatRemoveTime = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDecayTime');

        # only if this SysConfig is enabled
        if ($ChatRemoveTime) {

            # transfer to seconds
            $ChatRemoveTime = $ChatRemoveTime * 24 * 60 * 60;
            my $ChatDecayTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime() - $ChatRemoveTime;
            $ChatDecayTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime2TimeStamp(
                SystemTime => $ChatDecayTime
            );
            push @SQLWhereItems, 'chat.change_time <= ?';
            push @Bind,          \$ChatDecayTime;
        }
    }
    elsif ( defined $Param{Status} && $Param{Status} eq 'closed' && $Param{Outdated} ) {
        my $ChatTTL = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatTTL');

        # only if this SysConfig is enabled
        if ($ChatTTL) {
            my $TimeToStore   = 60 * 60 * $ChatTTL;
            my $ChatDecayTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime() - $TimeToStore;

            $ChatDecayTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime2TimeStamp(
                SystemTime => $ChatDecayTime
            );

            push @SQLWhereItems, 'chat.change_time <= ?';
            push @Bind,          \$ChatDecayTime;

        }
    }

    my $SQLWhere = '';
    if (@SQLWhereItems) {
        $SQLWhere = "WHERE " . join( ' AND ', @SQLWhereItems );
    }
    my $SQLOrder = 'ORDER BY id ASC ';

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => join( ' ', $SQLSelect, $SQLFrom, $SQLWhere, $SQLOrder ),
        Bind => \@Bind,
    );

    my @Result;
    my $DefaultAgentName = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::DefaultAgentName') || '';

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        my $RequesterName = $Row[3];
        my $RequesterType = $Row[4];
        my $TargetType    = $Row[5];

        # don't display the real agent name (if wanted)
        if ( $Param{MaskAgentName} && $DefaultAgentName ) {

            # replace the agent name in system generated messages
            if ( $RequesterType eq 'User' && $TargetType eq 'Customer' ) {
                $RequesterName = $DefaultAgentName;
            }
        }

        push @Result, {
            ChatID        => $Row[0],
            Status        => $Row[1],
            RequesterID   => $Row[2],
            RequesterName => $RequesterName,
            RequesterType => $RequesterType,
            TargetType    => $TargetType,
            CreateTime    => $Row[6],
            ChannelID     => $Row[7],
            TicketID      => $Row[8],
            Invitation    => $Row[9],
        };
    }

    # Result contains channel id, so we need to get Channel name (can't do it in loop, because DBObject is singletone)
    for my $Item (@Result) {

        # if chat is started from channel
        if ( $Item->{ChannelID} ) {
            my $Channel = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChannelLookup(
                ChannelID => $Item->{ChannelID},
            );
            $Item->{Channel} = $Channel;
        }

        my $Index = 0;
        ++$Index until $Index > $#Order || $Order[$Index] eq $Item->{ChatID};
        if ( $Index == @Order ) {
            $Item->{Order} = 0;
        }
        else {
            $Item->{Order} = $Index;
        }
    }

    # Sort
    if ($ChatAppend) {
        @Result = sort { $a->{Order} cmp $b->{Order} } @Result;
    }
    else {
        @Result = sort { $b->{Order} cmp $a->{Order} } @Result;
    }

    return @Result;
}

=item CustomerIDGet()
Get CustomerID for given Chat.
    my $CustomerUserID = $ChatObject->CustomerIDGet(
        Chat => \%Chat,
    );
Result:
    $CustomerUserID = "jdoe";

=cut

sub CustomerIDGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Chat)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $CustomerUserID;

    # Get Chat details
    my %Chat = %{ $Param{Chat} };

    # Check if chat contains customer
    if ( $Chat{RequesterType} && $Chat{RequesterType} eq 'Customer' ) {
        $CustomerUserID = $Chat{RequesterID};
    }
    elsif ( $Chat{TargetType} && $Chat{TargetType} eq 'Customer' ) {

        # We must search for customer in participant table
        my @Participants = $Self->ChatParticipantList(
            ChatID => $Chat{ChatID},
        );

        PARTICIPANT:
        for my $Participant (@Participants) {

            # Skip if not customer
            next PARTICIPANT if $Participant->{ChatterType} ne 'Customer';

            $CustomerUserID = $Participant->{ChatterID};
            last PARTICIPANT;
        }
    }

    return $CustomerUserID;
}

=item ChatPermissionLevelGet()

Get user's permission level for particular chat.
    my $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
        ChatID => 2,
        UserID => 1,
    );
    $PermissionLevel = "Participant";

=cut

sub ChatPermissionLevelGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => '
            SELECT permission_level
                FROM chat_participant
                WHERE
                    chat_id = ?
                    AND chatter_id = ?
                    AND chatter_type = ?',
        Bind => [
            \$Param{ChatID}, \$Param{UserID}, \'User',
        ],
    );

    my $Result;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Result = $Row[0];
    }

    return $Result;
}

=item ChatDelete()

delete chat.
    my $Success = $ChatObject->ChatDelete(
        ChatID => $ID,
    );
returns
    $Success = 1;

=cut

sub ChatDelete {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM chat_message
                WHERE chat_id = ?',
        Bind => [
            \$Param{ChatID},
        ],
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM chat_participant
                WHERE chat_id = ?',
        Bind => [
            \$Param{ChatID},
        ],
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM chat_invite
                WHERE chat_id = ?',
        Bind => [
            \$Param{ChatID},
        ],
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM chat_flag
                WHERE chat_id = ?',
        Bind => [
            \$Param{ChatID},
        ],
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM chat
                WHERE id = ?',
        Bind => [
            \$Param{ChatID},
        ],
    );

    return if !$Self->ChatFlagDelete(
        ChatID   => $Param{ChatID},
        AllUsers => 1,
    );

    return 1;
}

=item ChatCleanup()

removes chats

    my $Success = $ChatObject->ChatCleanup(
        Cleanup => 'Old' # if Cleanup is old, old chats will be removed
                         # else closed chats will be removed
    );

=cut

sub ChatCleanup {
    my ( $Self, %Param ) = @_;

    my $Success = 1;

    if ( $Param{Cleanup} && $Param{Cleanup} eq 'Old' ) {
        for my $Chat ( $Self->ChatList( Outdated => 1 ) ) {
            if ( !$Self->ChatDelete( ChatID => $Chat->{ChatID} ) ) {
                $Success = 0;
            }
        }
    }
    else {
        for my $Chat (
            $Self->ChatList(
                Status   => 'closed',
                Outdated => 1,
            )
            )
        {
            if ( !$Self->ChatDelete( ChatID => $Chat->{ChatID} ) ) {
                $Success = 0;
            }
        }
    }

    return $Success;
}

=item ChatParticipantAdd()

grants a chatter access to a chat.

    my $Success = $ChatObject->ChatParticipantAdd(
        ChatID          => $ChatID,
        ChatterID       => $ChatterID,    # Typically this would be a UserID
        ChatterName     => 'John Doe',    # Visible name to display in chats
        ChatterType     => $ChatterType,  # Typically this would be 'User' or 'Customer'
        ChatterActive   => 1,             # 0 or 1, indicates if chat request was accepted
        PermissionLevel => 'Owner',       # (required for agents) Permissions in selected chat - 'Owner', 'Observer', 'Participant'
        Invitation      => 1,             # user is invited to chat
        Monitoring      => 2              # 0,1 or 2. 0 - do  not monitor this chat
                                                      1 - monitor Customer activity in the chat
                                                      2 - monitor all activity in the chat
    );

=cut

sub ChatParticipantAdd {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterID ChatterName ChatterType)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( $Param{ChatterType} eq 'User' && !defined $Param{PermissionLevel} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need PermissionLevel!",
        );
        return;
    }
    if ( !defined $Param{ChatterActive} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ChatterActive!",
        );
        return;
    }
    if ( length $Param{ChatterName} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "ChatterName cannot be longer than 255 characters (is: $Param{ChatterName})!",
        );
        return;
    }

    if ( length $Param{ChatterType} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "ChatterType cannot be longer than 255 characters (is: $Param{ChatterType})!",
        );
        return;
    }

    # if there is no Param{Invitation} set it to 0
    $Param{Invitation} = $Param{Invitation} // 0;

    # if there is no Param{Monitoring} set it to 0
    $Param{Monitoring} = $Param{Monitoring} // 0;

    # check is this user already in this chat ( as inactive or left for example )
    my %ChatParticipant = $Self->ChatParticipantCheck(
        ChatID      => $Param{ChatID},
        ChatterType => $Param{ChatterType},
        ChatterID   => $Param{ChatterID},
        NoActive    => 1,
    );

    # if user is already in this chat, just update him
    if (%ChatParticipant) {
        return $Self->ChatParticipantUpdate(
            %Param,
        );
    }

    my $SQL = '
        INSERT INTO chat_participant
            (chat_id, chatter_id, chatter_name, chatter_type, chatter_active, create_time, invitation, monitoring_chat';
    if ( $Param{PermissionLevel} ) {
        $SQL .= ', permission_level';
    }
    $SQL .= ') VALUES (?, ?, ?, ?, ?, current_timestamp, ?, ?';
    if ( $Param{PermissionLevel} ) {
        $SQL .= ', ?';
    }

    $SQL .= ')';

    my @Bind = (
        \$Param{ChatID}, \$Param{ChatterID}, \$Param{ChatterName}, \$Param{ChatterType},
        \$Param{ChatterActive}, \$Param{Invitation}, \$Param{Monitoring}
    );
    if ( $Param{PermissionLevel} ) {
        push @Bind, \$Param{PermissionLevel};
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    return 1;
}

=item ChatParticipantUpdate()

confirms a chat participant.

    my $Success = $ChatObject->ChatParticipantUpdate(
        ChatID          => $ChatID,
        ChatterID       => $ChatterID,    # Typically this would be a UserID
        ChatterType     => $ChatterType,  # Typically this would be 'User' or 'Customer'
        ChatterActive   => $ChatterActive # -1, 0 or 1 (left/declined / inactive / active)
        Monitoring      => 1              #  0 , 1  or 2 , not required
        PermissionLevel => 'Participant'
    );

=cut

sub ChatParticipantUpdate {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterID ChatterType)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( length $Param{ChatterType} > 255 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "ChatterType cannot be longer than 255 characters (is: $Param{ChatterType})!",
        );
        return;
    }

    $Param{ChatterActive} = $Param{ChatterActive} // 0;

    my $SQL = "
            UPDATE chat_participant
                SET chatter_active = ?";

    my @Bind = ( \$Param{ChatterActive} );

    # change Monitoring if needed
    if ( defined $Param{Monitoring} ) {
        $SQL .= ', monitoring_chat = ?';
        push @Bind, \$Param{Monitoring};
    }

    # if Permission Level needs to be changed
    if ( $Param{PermissionLevel} ) {
        $SQL .= ", permission_level = ?";
        push @Bind, \$Param{PermissionLevel};
    }

    $SQL .= ' WHERE
                chat_id = ?
                AND chatter_id = ?
                AND chatter_type = ?';

    push @Bind, \$Param{ChatID}, \$Param{ChatterID}, \$Param{ChatterType};

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # if participant is user
    if ( $Param{ChatterType} eq 'User' ) {

        # set flag seen for this chat
        # it will prevent showing notifications for this chat again
        my $Success = $Self->ChatFlagSet(
            ChatID => $Param{ChatID},
            Key    => 'NotificationNewChatSeen',
            Value  => 1,
            UserID => $Param{ChatterID},
        );
    }

    return 1;
}

=item AgentPermissionsUpdate()

changes agent permissions to ( Participant / Observer )

    my $Success = $ChatObject->AgentPermissionsUpdate(
        ChatID          => $ChatID,
        ChatterID       => $ChatterID,          # Typically this would be a UserID
        PermissionLevel => $PermissionLevel,    # Participant or Observer
        ChatterActive   => $ChatterActive,      # 0 or 1
    );

=cut

sub AgentPermissionsUpdate {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterID PermissionLevel ChatterActive)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # user can only switch to Observer or Participant
    # permissions are checked before
    if ( $Param{PermissionLevel} ne 'Participant' && $Param{PermissionLevel} ne 'Observer' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "PermissionLevel must be Observer or Participant (is: $Param{PermissionLevel})!",
        );
        return;
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            UPDATE chat_participant
                SET chatter_active = ?,
                permission_level = ?
                WHERE
                    chat_id = ?
                    AND chatter_id = ?
                    AND chatter_type = ?',
        Bind => [
            \$Param{ChatterActive}, \$Param{PermissionLevel}, \$Param{ChatID}, \$Param{ChatterID}, \'User',
        ],
    );

    return 1;
}

=item ContributorsCount()

Return number of currently involved contributing agents.
    my $Count = $ChatObject->ContributorsCount(
        ChatID        => $ChatID,
    );
Result:
   $Count = 4;

=cut

sub ContributorsCount {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = "
        SELECT COUNT(*)
            FROM chat_participant
            WHERE
                chat_id = ?
                AND chatter_type = 'User'
                AND permission_level != 'Observer'
                AND chatter_active > 0 ";

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatID},
        ],
    );

    my $Result;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Result = $Row[0];
    }

    return $Result;
}

=item CustomerPresent()

Returns 1 if there is active Customer in the chat
Works the same for the public users
    my $CustomerPresent = $ChatObject->CustomerPresent(
        ChatID        => $ChatID,
        Active        => 1, # optional, include only active customers
    );
Result:
   $CustomerPresent = 1;

=cut

sub CustomerPresent {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = "
        SELECT COUNT(*)
            FROM chat_participant
            WHERE
                chat_id = ? AND
                    ( chatter_type = 'Customer' OR
                      chatter_type = 'Public'
                    ) ";

    if ( $Param{Active} ) {
        $SQL .= " AND chatter_active > 0 ";
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatID},
        ],
    );

    my $Result;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Result = $Row[0];
    }

    return $Result;
}

=item ChatParticipantList()

Lists all participants of a chat

    my @Participants = $ChatObject->ChatParticipantList(
        ChatID => $ChatID,
    );

returns
    [
        (
            ChatterName     => 'Firstname Lastname',
            ChatterID       => 123,
            ChatterType     => 'User',
            ChatterActive   => 1,
            PermissionLevel => 'Owner',
            Status          => 1,               # Might not be included
            Monitoring      => 2,
        ),
        (
            ChatterName     => 'Firstname Lastname',
            ChatterID       => 123,
            ChatterType     => 'User',
            ChatterActive   => 1,
            PermissionLevel => 'Participant',
            Status          => 1,               # Might not be included
            Monitoring      => 0,
        )
    ]

=cut

sub ChatParticipantList {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => '
            SELECT chatter_name, chatter_id, chatter_type, chatter_active, permission_level, monitoring_chat
                FROM chat_participant
                WHERE chat_id = ?
                ORDER BY chatter_active DESC, chatter_type ASC',
        Bind => [
            \$Param{ChatID},
        ],
    );

    my @Result;

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {

        push @Result, {
            ChatterName     => $Row[0],
            ChatterID       => $Row[1],
            ChatterType     => $Row[2],
            ChatterActive   => $Row[3],
            PermissionLevel => $Row[4],
            Monitoring      => $Row[5],
            }
    }

    # Check if this is Agent to Agent
    my $A2A = $Self->IsChatAgentToAgent(
        ChatID => $Param{ChatID},
    );

    # Check each user availability
    CHATTER:
    for my $Chatter (@Result) {
        if ( $Chatter->{ChatterType} eq 'User' ) {
            $Chatter->{Status} = $Self->AgentAvailabilityGet(
                UserID   => $Chatter->{ChatterID},
                External => $A2A ? 0 : 1,
            );
        }
        else {
            $Chatter->{Status} = $Self->CustomerAvailabilityGet(
                UserID => $Chatter->{ChatterID},
            );
        }
    }

    return @Result;
}

=item ChatParticipantNumberGet()

get number of chat participants ( 1, 2, 3) - used with default agent name
example: if DefaultAgentName is on and DefaultAgentNumbers is on result will be:
SupportAgent1, SupportAgent2 ,...

    my $ChatParticipantNumber = $ChatObject->ChatParticipantNumberGet(
        ChatID      => $ChatID,
        ChatterName => $ChatterName,
    );

returns
    $ChatParticipantNumber = 1;

=cut

sub ChatParticipantNumberGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterName)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $ChatParticipantNumber = 0;

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => '
            SELECT chatter_name,id
                FROM chat_participant
                WHERE chat_id = ? AND chatter_type = "User"
                ORDER BY id ASC',
        Bind => [
            \$Param{ChatID},
        ],
    );

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {

        # increase ChatParticipantNumber
        $ChatParticipantNumber++;

        if ( $Row[0] eq $Param{ChatterName} ) {
            return $ChatParticipantNumber;
        }
    }

    # if not found return empty
    return "";
}

=item AgentAvailabilityGet()

Get agents availability
    my $AgentAvailability = $ChatObject->AgentAvailabilityGet(
        UserID      => 2,   # UserID
        External    => 1,   # optional (default 1) Get external availability
    );

returns
    $AgentAvailability = 1; # 0 - off-line, 1 - unavailable, 2 - away, 3 - on-line

=cut

sub AgentAvailabilityGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{External} = 1 if !defined $Param{External};

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    # By default user is off-line
    my $Result = 0;

    # Check if user is logged in
    my %Online = $Self->OnlineUserList(
        UserType      => 'User',
        Group         => $ChatReceivingAgentsGroup,
        UserID        => $Param{UserID},
        External      => 0,
        IgnoreSuspend => 1,
    );

    SESSION:
    for my $Session ( sort keys %Online ) {
        if ( $Param{External} ) {

            # Chat with customer
            if ( $Online{$Session}->{ChatAvailability} < 2 ) {

                # User is logged in but not available for external chat
                # Set to 1 if not higher
                if ( $Result < 1 ) {
                    $Result = 1;
                }
            }
            elsif ( $Online{$Session}->{Suspend} ) {

                # User is logged in, available for external chat but not active for some time
                # Set to 2 if not higher
                if ( $Result < 2 ) {
                    $Result = 2;
                }
            }
            else {

                # User is on-line
                # Set to 3
                $Result = 3;

                # Don't check any more, user has max availability
                last SESSION;
            }
        }
        else {

            # Chat with agent
            if ( $Online{$Session}->{ChatAvailability} < 1 ) {

                # User is logged in but not available for internal chat
                # Set to 1 if not higher
                if ( $Result < 1 ) {
                    $Result = 1;
                }
            }
            elsif ( $Online{$Session}->{Suspend} ) {

                # User is logged in, available for internal chat but not active for some time
                # Set to 2 if not higher
                if ( $Result < 2 ) {
                    $Result = 2;
                }
            }
            else {

                # User is on-line
                # Set to 3
                $Result = 3;

                # Don't check any more, user has max availability
                last SESSION;
            }
        }
    }

    return $Result;
}

=item CustomerAvailabilityGet()

Get chat availability of customer user.
    my $CustomerAvailability = $ChatObject->CustomerAvailabilityGet(
        UserID => 'customer-1',   # CustomerUserID
    );

Returns:
    $CustomerAvailability = 3; # 0 - off-line, 2 - away, 3 - on-line

=cut

sub CustomerAvailabilityGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $Available = 0;

    my %Customer = $Self->OnlineUserList(
        UserType      => 'Customer',
        UserID        => $Param{UserID},
        IgnoreSuspend => 1,
    );

    if (%Customer) {
        SESSION:
        for my $Session ( sort keys %Customer ) {
            if ( $Customer{$Session}{Suspend} ) {
                $Available = 2 if $Available < 2;
            }
            else {
                $Available = 3;
                last SESSION;
            }
        }
    }

    return $Available;
}

=item ChatParticipantCheck()

checks if a chatter has access to a chat
    my %Access = $ChatObject->ChatParticipantCheck(
        ChatID        => $ChatID,
        ChatterID     => $ChatterID,    # Typically this would be a UserID
        ChatterType   => $ChatterType,  # Typically this would be 'User' or 'Customer'
        NoActive      => 1,             # do not force to show only active chatters
    );
Returns
    my %Access = {
        ChatParticipantID => 123,
        ChatterActive     => 0,
        PermissionLevel   => 'Owner',
        Invitation        => 1,
    };

=cut

sub ChatParticipantCheck {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterID ChatterType)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = '
            SELECT id, chatter_active, permission_level, invitation
                FROM chat_participant
                WHERE
                    chat_id = ?
                    AND chatter_id = ?
                    AND chatter_type = ?';

    if ( !$Param{NoActive} ) {
        $SQL .= ' AND chatter_active != -1 '
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatID}, \$Param{ChatterID}, \$Param{ChatterType},
        ],
        Limit => 1,
    );

    my %Result;

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Result{ChatParticipantID} = $Row[0];
        $Result{ChatterActive}     = $Row[1];
        $Result{PermissionLevel}   = $Row[2];
        $Result{Invitation}        = $Row[3];
    }

    return %Result;
}

=item ChatParticipantRemove()

revokes chatter access.

    my $Success = $ChatObject->ChatParticipantRemove(
        ChatID        => $ChatID,
        ChatterID     => $ChatterID,    # Typically this would be a UserID
                                        # or
        ChatterType   => $ChatterType   # Typically this would be 'User' or 'Customer'
    );

or

    my $Success = $ChatObject->ChatParticipantRemove(
        ChatID        => $ChatID,
        All           => 1,
    );

=cut

sub ChatParticipantRemove {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( !$Param{All} && ( !$Param{ChatterID} || !$Param{ChatterType} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need All or ChatterID and ChatterType!",
        );
        return;
    }

    if ( $Param{All} ) {
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => '
                DELETE FROM chat_participant
                    WHERE chat_id = ?',
            Bind => [
                \$Param{ChatID},
            ],
        );
    }
    else {
        # set chatter_active to -1 => user left the chat
        # this is necessary because if we delete user from chat_participant
        # all user's messages will become unavailable
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => '
                UPDATE chat_participant
                    SET chatter_active = -1
                    WHERE chat_id = ?
                        AND chatter_id = ?
                        AND chatter_type = ?',
            Bind => [
                \$Param{ChatID}, \$Param{ChatterID}, \$Param{ChatterType},
            ],
        );

        # if participant is user
        if ( $Param{ChatterType} eq 'User' ) {

            # set flag seen for this chat
            # it will prevent showing notifications for this chat again
            my $Success = $Self->ChatFlagSet(
                ChatID => $Param{ChatID},
                Key    => 'NotificationNewChatSeen',
                Value  => 1,
                UserID => $Param{ChatterID},
            );
        }
    }

    return 1;
}

=item ChatMessageAdd()

adds a message to a chat.

    my $Success = $ChatObject->ChatMessageAdd(
        ChatID          => $ChatID,
        ChatterID       => 'Heinz Hinz',
        ChatterType     => 'User',
        MessageText     => 'My message',        # plain text, max. 3800 characters
        SystemGenerated => 1,                   # optional, 0 or 1 (for internal messages like XY has left the chat)
        Internal        => 0,                   # optional (default 0) - If 1, this message will not be presented to the customer
        Customer        => 1,                   # optional (default 0) - If 1, this meesage will not be presented to the agent
    );

=cut

sub ChatMessageAdd {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID ChatterID ChatterType MessageText)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get participants of the chat
    my @Participants = $Self->ChatParticipantList(
        ChatID => $Param{ChatID},
    );

    # check who should be notified regarding this message
    PARTICIPANT:
    for my $Participant (@Participants) {

        # skip Customers and public users
        next PARTICIPANT if $Participant->{ChatterType} ne 'User';

        # skip Observers
        next PARTICIPANT if $Participant->{PermissionLevel} eq 'Observer';

        # skip Participants who don't want to be disturbed for this chat
        next PARTICIPANT if defined $Participant->{Monitoring} && $Participant->{Monitoring} == 0;

        # do not notify user for his own activity
        next PARTICIPANT if $Participant->{ChatterID} eq $Param{ChatterID};

        # notify only active participants
        next PARTICIPANT if $Participant->{ChatterActive} != 1;

        # if message is from User ( System )
        # and user is not monitoring all messages
        if ( $Param{ChatterType} ne 'Customer' && $Participant->{Monitoring} < 2 ) {
            next PARTICIPANT;
        }

        # set flag seen for this chat
        my $Success = $Self->ChatFlagSet(
            ChatID => $Param{ChatID},
            Key    => 'NotificationChatUpdateSeen',
            Value  => 0,
            UserID => $Participant->{ChatterID},
        );
    }

    # Set 0 if not defined
    $Param{Internal} = $Param{Internal} || 0;

    # Set Internal to Customer value if Internal if not defined
    # and Customer value is defined
    if ( !$Param{Internal} && $Param{Customer} ) {

        # number 2 is to limit view only for the Customer
        $Param{Internal} = 2;
    }

    if ( length $Param{MessageText} > 3800 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "MessageText cannot be longer than 3800 characters (is: $Param{MessageText})!"
        );
        return;
    }

    my %ChatParticipant = $Self->ChatParticipantCheck(%Param);
    if ( !%ChatParticipant ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not find ChatParticipant.",
        );
        return;
    }

    my $SystemGenerated = $Param{SystemGenerated} // 0;

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO chat_message
                (chat_id, chat_participant_id, message_text, system_generated, create_time, internal)
                VALUES (?, ?, ?, ?, current_timestamp,?)',
        Bind => [
            \$Param{ChatID}, \$ChatParticipant{ChatParticipantID}, \$Param{MessageText},
            \$SystemGenerated, \$Param{Internal}
        ],
    );

    return 1;
}

=item ChatMessageList()

lists chat messages of a chat.

To get all chat messages:

    my @ChatMessages = $ChatObject->ChatMessageList(
        ChatID          => $ChatID,         # get all messages
        MaskAgentName   => 1,               # optional, will use the appropriate config setting to display a generic agent name instead of the real one
        ExcludeInternal => 1,               # optional (default 0) - if set, system will return only external messages
        ExcludeCustomer => 0,               # optional (default 0) - if set, will return only messages agent can see
    );

If you already have a part of the chat, you can ask for new entries:

    my @ChatMessages = $ChatObject->ChatMessageList(
        ChatID                  => $ChatID,
        LastKnownChatMessageID  => $ChatMessageID,  # optional
        FirstMessage            => 1,               # optional, get the first text message
    );

returns

    (
        {
            ID          => 123,
            MessageText => 'My chat message',
            CreateTime  => '2014-04-04 10:10:10',
            SystemGenerated => 0,
            ChatterID   => '123',
            ChatterType => 'User',
            ChatterName => 'John Doe',
        },
        ...
    )

=cut

sub ChatMessageList {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{ExcludeInternal} = $Param{ExcludeInternal} || 0;

    my $Limit;

    my $SQL = '
        SELECT chat_message.id, chat_message.message_text, chat_message.create_time, chat_message.system_generated,
            chat_participant.chatter_id, chat_participant.chatter_type, chat_participant.chatter_name

            FROM chat_message, chat_participant
            WHERE
                chat_message.chat_id = ?
                AND chat_message.chat_participant_id = chat_participant.id ';

    if ( $Param{ExcludeInternal} ) {
        $SQL .= 'AND internal != 1 ';
    }
    elsif ( $Param{ExcludeCustomer} ) {
        $SQL .= 'AND internal != 2 ';
    }

    my @Bind = ( \$Param{ChatID} );

    if ( $Param{LastKnownChatMessageID} ) {
        $SQL .= 'AND chat_message.id > ? ';
        push @Bind, \$Param{LastKnownChatMessageID};
    }

    if ( $Param{FirstMessage} ) {
        $SQL .= 'AND chat_message.system_generated = 0 ';
        $Limit = 1;
    }

    $SQL .= 'ORDER BY chat_message.id ASC ';

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => $Limit,
    );

    my @Result;
    my $DefaultAgentName = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::DefaultAgentName') || '';

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {

        my $MessageText     = $Row[1];
        my $SystemGenerated = $Row[3];
        my $ChatterType     = $Row[5];
        my $ChatterName     = $Row[6];

        push @Result, {
            ID              => $Row[0],
            MessageText     => $MessageText,
            CreateTime      => $Row[2],
            SystemGenerated => $SystemGenerated,
            ChatterID       => $Row[4],
            ChatterType     => $ChatterType,
            ChatterName     => $ChatterName,
        };
    }

    # add numbers to DefaultAgentNames if needed
    # only do this if DefaultAgentName is available
    # otherwise we're using real agent names
    if (
        $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::DefaultAgentNameNumbers')
        && $DefaultAgentName
        && $Param{MaskAgentName}
        )
    {
        MESSAGE:
        for my $Message (@Result) {
            next MESSAGE if $Message->{ChatterType} eq 'Customer';

            my $ChatterName = $Message->{ChatterName};

            # get ChatterNumber
            my $ChatterNumber = $Self->ChatParticipantNumberGet(
                ChatID      => $Param{ChatID},
                ChatterName => $Message->{ChatterName},
            );

            # replace the agent name in system generated messages
            if ( $Message->{SystemGenerated} && $Message->{ChatterType} eq 'User' ) {
                $Message->{MessageText} =~ s{$ChatterName}{$DefaultAgentName$ChatterNumber}msg;
            }
            else {
                $Message->{ChatterName} = $DefaultAgentName . $ChatterNumber;
            }

        }
    }

    return @Result;
}

=item ChatInvite()

Invite agent to chat.
    my %InviteResult = $ChatObject->ChatInvite(
        ChatID           => 5,           # Chat ID
        InviteUserID     => 3,           # User ID of target agent
        UserID           => 2,           # User ID of the agent who is inviting
        InvitationChatID => 1,           # id of a chat through which communication will go
    );

=cut

sub ChatInvite {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID UserID InviteUserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return (
                'MissingParameter' => $Param{$Needed},
            );
        }
    }
    if ( !$Param{PermissionLevel} ) {
        $Param{PermissionLevel} = '0';
    }

    # Needed objects
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my $DBObject          = $Kernel::OM->Get('Kernel::System::DB');

    my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $Param{InviteUserID},
    );

    return if !%User;

    # Check if user was already invited
    my $SQLCheck = '
        SELECT COUNT(*)
            FROM chat_invite
            WHERE
                chat_id = ?
                AND chatter_id = ?';
    if (
        !$DBObject->Prepare(
            SQL  => $SQLCheck,
            Bind => [
                \$Param{ChatID}, \$Param{InviteUserID}
            ],
        )
        )
    {
        return;
    }

    my $AlreadyInvited = 0;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $AlreadyInvited = $Row[0];
    }

    return if $AlreadyInvited;

    # Get Chat details
    my %Chat = $Self->ChatGet(
        ChatID => $Param{ChatID},
    );

    # set InvitationChatID to 0 if it's not defined
    if ( !$Param{InvitationChatID} ) {
        $Param{InvitationChatID} = 0;
    }

    my $SQL = "
            INSERT INTO chat_invite
                (chat_id, chatter_id, create_time,invitation_chat_id)
                VALUES (?, ?, current_timestamp, ?)";

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatID}, \$Param{InviteUserID}, \$Param{InvitationChatID},
        ],
    );

    return 1;
}

=item ChatInvitesGet()

Check if there is chat invite for given user.

    my $ChatID = $ChatObject->ChatInvitesGet(
        UserID              => 123,
        InvitationChatID    => 3,   # id of the chat in which user is invited to participate another
        ChatID              => 3,   # DO NOT USE BOTH ChatID and InvitationChatID
    );

Result:
    $ChatID = 2;

=cut

sub ChatInvitesGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = "
            SELECT chat_id FROM chat_invite
                WHERE chatter_id = ?";

    my $ID;

    if ( $Param{InvitationChatID} ) {
        $SQL .= " AND invitation_chat_id = ?";
        $ID = $Param{InvitationChatID};
    }
    elsif ( $Param{ChatID} ) {
        $SQL .= " AND chat_id = ?";
        $ID = $Param{ChatID};
    }
    else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need InvitationChatID or ChatID!",
        );
        return;
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{UserID},
            \$ID,
        ],
    );

    my $Result;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Result = $Row[0];
    }

    return $Result;
}

=item ChatDecline()

Decline chat invitation (only possible for agent to agent chats).

    my $Success = $ChatObject->ChatDecline(
        UserID        => 123,
        ChatID        => 4,
        Message       => "User xy has declined the chat request.",
    );

=cut

sub ChatDecline {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID ChatID Message)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my %Access = $Self->ChatParticipantCheck(
        ChatID      => $Param{ChatID},
        ChatterID   => $Param{UserID},
        ChatterType => 'User',
    );

    # Check if Chatter active is 0 (not yet accepted)
    if ( defined $Access{ChatterActive} && $Access{ChatterActive} != 0 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "$Param{UserID} does not have permissions to decline ChatID $Param{ChatID}!",
        );
        return;
    }

    # Write message
    my $MessageSuccess = $Self->ChatMessageAdd(
        ChatID          => $Param{ChatID},
        ChatterID       => $Param{UserID},
        ChatterType     => 'User',
        MessageText     => $Param{Message},
        SystemGenerated => 1,
        Internal        => 1,
    );

    if ($MessageSuccess) {
        my $Success = $Self->ChatParticipantUpdate(
            ChatID        => $Param{ChatID},
            ChatterID     => $Param{UserID},
            ChatterType   => 'User',
            ChatterActive => -1,               # Decline
        );

        if ($Success) {

            my $SuccessRemove = $Self->ChatInviteRemove(
                UserID => $Param{UserID},
                ChatID => $Param{ChatID},
            );
            return $SuccessRemove;
        }
    }
    return 0;
}

=item ChatChannelUpdate()

Move the chat to another channel.

    my $Success = $ChatObject->ChatChannelUpdate(
        UserID        => 123,
        ChatID        => 4,
        ChatChannelID => 5,
    );

returns
    $Success = 1;

=cut

sub ChatChannelUpdate {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID ChatID ChatChannelID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = "
            UPDATE chat
                SET chat_channel_id = ?
                WHERE id = ?";

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatChannelID}, \$Param{ChatID},
        ],
    );

    return 1;
}

=item ChatInviteRemove()

Delete invate for particular user and chat

    my $Success = $ChatObject->ChatInviteRemove(
        UserID             => 123,
        ChatID             => 4,
        InvitationChatID   => 3, # don't use ChatID and InvitationChatID, send only one
    );

return
    $Success = 1;

=cut

sub ChatInviteRemove {
    my ( $Self, %Param ) = @_;

    my $SQL = "
        DELETE FROM chat_invite
            WHERE ";

    my @Bind;

    if ( $Param{ChatID} ) {
        $SQL .= ' chatter_id = ? AND chat_id = ? ';
        push @Bind, \$Param{UserID};
        push @Bind, \$Param{ChatID};
    }
    elsif ( $Param{InvitationChatID} ) {
        $SQL .= ' invitation_chat_id = ? ';
        push @Bind, \$Param{InvitationChatID};
    }
    else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need ChatID with UserID or InvitationChatID",
        );
        return;
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    return 1;

}

=item OnlineUserList()

fetches a list of online users.

    my %OnlineUsers = $ChatObject->OnlineUserList(
        UserType      => 'User',         # optional, Get only users of particular type ('User' or 'Customer')

        Group         => 'chat',         # Group that user must belong to
        UserID        => 5,              # optional, check if a specific user is online
        External      => 1,              # optional (default 1) - return only users available for external chat requests
        IgnoreSuspend => 0,              # optional (default 0) If 1, system will skip the check if agent is not active, but will return suspend status instead.
    );

returns a hash of sessions

    {
        '13QA68d8D7IACAKzxSUKne3uVWpjZdoY5m' => {
          'UserSessionStart' => 1402047758,
          'UserLastRequest' => 1402047758,
          'UserEmail' => 'root@example.com',
          'UserIsGroup[chat]' => 'Yes',
          'UserRemoteUserAgent' => 'none',
          'UserID' => 'ut-onlineuserlist-ChatCustomer-test843809',
          'UserRemoteAddr' => 'none',
          'UserLogin' => 'ut-onlineuserlist-ChatCustomer-test843809',
          'UserType' => 'Customer',
          'UserChallengeToken' => 'rBNoBkumaygHucwpqE9fY1HBxmqq8cvW',
          'ChatAvailability' => 0,                      # 0,1,2
          ...
        },
        ...
    }

=cut

sub OnlineUserList {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Group} && !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Group or UserID!",
        );
        return;
    }

    if ( !defined $Param{External} ) {
        $Param{External} = 1;
    }

    if ( !defined $Param{IgnoreSuspend} ) {
        $Param{IgnoreSuspend} = 0;
    }

    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');
    my $UserObject    = $Kernel::OM->Get('Kernel::System::User');

    # Online thresholds for agents and customers (default 5 min).
    my $AgentOnlineThreshold    = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::AgentOnlineThreshold')    || 5;
    my $CustomerOnlineThreshold = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::CustomerOnlineThreshold') || 5;

    my @Sessions = $SessionObject->GetAllSessionIDs();

    my $Time = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();
    my %Result;

    SESSIONID:
    for my $SessionID (@Sessions) {
        next SESSIONID if !$SessionID;

        # get session data
        my %Data = $SessionObject->GetSessionIDData( SessionID => $SessionID );

        next SESSIONID if !%Data;
        next SESSIONID if !$Data{UserID};

        if ( defined $Param{UserType} ) {
            next SESSIONID if $Data{UserType} ne $Param{UserType};
        }

        if ( defined $Param{UserID} ) {
            next SESSIONID if $Data{UserID} ne $Param{UserID};
        }

        # check last request time / idle time out
        next SESSIONID if !$Data{UserLastRequest};

        if ( !$Param{IgnoreSuspend} ) {

            # check if user is inactive for x minutes (defined in SysConfig)
            next SESSIONID if $Data{UserLastRequest} + ( 60 * $AgentOnlineThreshold ) < $Time;
        }

        # Group might not be defined
        if ( defined $Param{Group} ) {
            next SESSIONID if !$Data{"UserIsGroup[$Param{Group}]"};
        }

        if ( $Param{UserType} && $Param{UserType} eq 'User' ) {

            # check if the user is not available
            my %Preferences = $UserObject->GetPreferences(
                UserID => $Data{UserID},
            );

            if ( !$Param{IgnoreSuspend} ) {
                if ( defined $Preferences{ChatAvailability} ) {
                    if ( $Param{External} ) {

                        # External availability
                        next SESSIONID if $Preferences{ChatAvailability} < 2;
                    }
                    else {
                        # Internal availability
                        next SESSIONID if $Preferences{ChatAvailability} < 1;
                    }
                }
                else {

                    # User never used chat availability yet
                    next SESSIONID;
                }
            }
            $Data{ChatAvailability} = $Preferences{ChatAvailability} // 0;

            if ( $Param{IgnoreSuspend} ) {
                my $TargetTime = $Data{UserLastRequest} + ( 60 * $AgentOnlineThreshold );
                $Data{Suspend} = $TargetTime < $Time ? 1 : 0;
            }
        }
        elsif ( $Param{UserType} && $Param{UserType} eq 'Customer' ) {
            if ( $Param{IgnoreSuspend} ) {
                my $TargetTime = $Data{UserLastRequest} + ( 60 * $CustomerOnlineThreshold );
                $Data{Suspend} = $TargetTime < $Time ? 1 : 0;
            }
        }

        $Result{$SessionID} = \%Data;
    }

    return %Result;
}

=item AvailableUsersGet()

Returns a list of currently online users and their selected channels.
    my %Available = $ChatObject->AvailableUsersGet(
        Key => 'ExternalChannels'       # (Required)
    );

Returns:
    %Available = {
        '123'   =>                  # UserID
                    [ 1, 3, 5 ],    # Chat Channel IDs
        ...
    };

=cut

sub AvailableUsersGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Key)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # Needed objects
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    # Ok, now check if there are actually chat agents online.
    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    # Get currently online users
    my %OnlineUsers = $Self->OnlineUserList(
        UserType => 'User',                       # 'User' or 'Customer'
        Group    => $ChatReceivingAgentsGroup,    # Group that user must belong to
    );

    my %Result;
    USER:
    for my $Session ( sort keys %OnlineUsers ) {
        my $UserID = $OnlineUsers{$Session}->{UserID};

        # Get custom selected chat channels for user
        my @ChatChannels = $ChatChannelObject->CustomChatChannelsGet(
            Key    => $Param{Key},
            UserID => $UserID,
        );

        $Result{$UserID} = \@ChatChannels;
    }

    return %Result;

}

=item IsChatAgentToAgent()

Checks is this A2A chat.
    my $A2AChat = $ChatObject->IsChatAgentToAgent(
        ChatID => 1,
    );

Returns:
    $A2AChat = 1;       # 0 if it's not

=cut

sub IsChatAgentToAgent {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $SQL = "
        SELECT COUNT(*)
            FROM chat
            WHERE
                id = ?
                AND requester_type = 'User'
                AND target_type = 'User'
        ";

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{ChatID},
        ],
    );

    my $Count;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $Count = $Row[0];
    }

    # If count is 0, it's A2C, otherwise it's A2A
    return $Count;
}

=item ChatFlagSet()

set Chat flags

    my $Success = $ChatObject->ChatFlagSet(
        ChatID => 123,
        Key      => 'Seen',
        Value    => 1,
        UserID   => 123, # apply to this user
    );

returns
    $Success = 1;

=cut

sub ChatFlagSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ChatID Key Value UserID)) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my @Flags = $Self->ChatFlagGet(%Param);

    if (@Flags) {

        if ( $Flags[0] ) {

            # get flag, it's single result only
            my %Flag = %{ $Flags[0] };

            # check if set is needed
            return 1 if defined $Flag{ $Param{Key} } && $Flag{ $Param{Key} } eq $Param{Value};
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # set flag
    return if !$DBObject->Do(
        SQL => '
            DELETE FROM chat_flag
                WHERE chat_id = ?
                    AND chat_key = ?
                    AND create_by = ?',
        Bind => [ \$Param{ChatID}, \$Param{Key}, \$Param{UserID} ],
    );
    return if !$DBObject->Do(
        SQL => '
            INSERT INTO chat_flag
                (chat_id, chat_key, chat_value, create_time, create_by)
                VALUES (?, ?, ?, current_timestamp, ?)',
        Bind => [ \$Param{ChatID}, \$Param{Key}, \$Param{Value}, \$Param{UserID} ],
    );

    return 1;
}

=item ChatFlagDelete()

delete Chat flag

    my $Success = $ChatObject->ChatFlagDelete(
        ChatID   => 123,
        Key      => 'Seen',
        UserID   => 123,
    );

    my $Success = $ChatObject->ChatFlagDelete(
        ChatID   => 123,
        AllUsers => 1,
    );

returns:
    $Success = 1;

=cut

sub ChatFlagDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ChatID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # only one of these parameters is needed
    if ( !$Param{UserID} && !$Param{AllUsers} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID or AllUsers param!",
        );
        return;
    }

    # if all users parameter was given
    if ( $Param{AllUsers} ) {

        # do db insert
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => '
                DELETE FROM chat_flag
                    WHERE chat_id = ?',
            Bind => [ \$Param{ChatID} ],
        );
    }
    else {

        # do db insert
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => '
                DELETE FROM chat_flag
                    WHERE chat_id = ?
                        AND create_by = ?
                        AND Chat_key = ?',
            Bind => [ \$Param{ChatID}, \$Param{UserID}, \$Param{Key} ],
        );
    }

    return 1;
}

=item ChatFlagGet()

get chat flags.
One of the following parameters is mandatory:
ChatID
Key
KeyNot
UserID
ValueID
ValueNot

examples:

    # get all chat flags for one user and one chat
    my @Flags = $ChatObject->ChatFlagGet(
        ChatID => 123,
        UserID => 123, # to get flags one user
    );

    # get all chat update flags for one chat and for all users
    # which are unseen (Value is not 1)
    my @Flags = $ChatObject->ChatFlagGet(
        ChatID   => 123,
        ValueNot => 1,
        Key      => "NotificationChatUpdateSeen",
    );

    # get all new chat flags which are already seen
    # for one chat and for all users
    my @Flags = $ChatObject->ChatFlagGet(
        ChatID   => 123,
        Value    => 1,
        Key      => "NotificationNewChatSeen"
    );

    # get all unseen update flags for one user and for all chats
    my @Flags = $ChatObject->ChatFlagGet(
        UserID   => 123,
        Key      => "NotificationChatUpdateSeen",
        ValueNot => 1, # to get all unseen flags for the user
    );

    # get all flags for one chat
    my @Flags = $ChatObject->ChatFlagGet(
        ChatID   => 123,
    );

    # get all flags for one chat where key is not "NotificationNewChatSeen"
    my @Flags = $ChatObject->ChatFlagGet(
        ChatID   => 123,
        KeyNot   => 'NotificationNewChatSeen',
    );

returns:
    @Flags  = [
        {
            Key    => 'Seen',
            Value  => 1,
            ChatID => 123,
            UserID => 1,
        },
        ...
    ];

=cut

sub ChatFlagGet {
    my ( $Self, %Param ) = @_;

    if (
        !$Param{Value}
        && !$Param{ValueNot}
        && !$Param{ChatID}
        && !$Param{UserID}
        && !$Param{Key}
        && !$Param{KeyNot}
        )
    {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need at least one param of: ChatID, Key, KeyNot, UserID, Value, ValueNot!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = 'SELECT chat_key, chat_value , chat_id, create_by
               FROM chat_flag
               WHERE 1=1';

    my @Bind;

    my @Flags;

    # get all flags for this user
    if ( $Param{ValueNot} ) {
        $SQL .= ' AND chat_value != ?';
        push @Bind, \$Param{ValueNot};
    }
    elsif ( $Param{Value} ) {
        $SQL .= ' AND chat_value = ?';
        push @Bind, \$Param{ValueNot};
    }

    if ( $Param{UserID} ) {
        $SQL .= ' AND create_by = ?';
        push @Bind, \$Param{UserID};
    }

    if ( $Param{ChatID} ) {
        $SQL .= ' AND chat_id = ?';
        push @Bind, \$Param{ChatID};
    }

    if ( $Param{Key} ) {
        $SQL .= ' AND chat_key = ?';
        push @Bind, \$Param{Key};
    }
    elsif ( $Param{KeyNot} ) {
        $SQL .= ' AND chat_key != ?';
        push @Bind, \$Param{KeyNot};
    }

    # sql query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1500,
    );

    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Flags, {
            Key    => $Row[0],
            Value  => $Row[1],
            ChatID => $Row[2],
            UserID => $Row[3],
        };
    }

    return @Flags;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
