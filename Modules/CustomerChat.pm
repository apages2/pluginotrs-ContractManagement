# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerChat;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->{ChatID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ChatID' );

    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
        return $Self->ErrorResponse(
            Message => "Chat is not active.",
        );
    }

    if ( $Self->{Subaction} eq 'CreateChatRequest' ) {
        if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::CustomerToAgent') ) {
            return $Self->ErrorResponse(
                Message => "Chat is not active.",
            );
        }
        return $Self->CreateChatRequest();
    }

    if ( $Self->{Subaction} eq 'ChatCompleted' ) {
        return $Self->ChatCompleted();
    }
    elsif ( $Self->{Subaction} eq 'ChatOverview' ) {
        if (
            !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::CustomerToAgent')
            && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToCustomer')
            )
        {
            return $Self->ErrorResponse(
                Message => "Chat is not active.",
            );
        }
        return $Self->ChatOverview();
    }
    elsif ( $Self->{Subaction} eq 'ChatGetOpenRequests' ) {
        return $Self->ChatGetOpenRequests();
    }

    # All following subactions require chat access.
    if ( !$Self->{ChatID} ) {
        return $Self->ErrorResponse(
            Message => "Need ChatID.",
        );
    }

    my %ChatParticipant = $Kernel::OM->Get('Kernel::System::Chat')->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'Customer',
    );

    if ( !%ChatParticipant ) {
        return $Self->ErrorResponse(
            Message => "No permission.",
        );
    }

    if ( $Self->{Subaction} eq 'ChatLeave' ) {
        return $Self->ChatLeave();
    }
    elsif ( $Self->{Subaction} eq 'ChatScreen' ) {
        return $Self->ChatScreen();
    }
    elsif ( $Self->{Subaction} eq 'ChatMessageAdd' ) {
        return $Self->ChatMessageAdd();
    }
    elsif ( $Self->{Subaction} eq 'ChatUpdate' ) {
        return $Self->ChatUpdate();
    }
    elsif ( $Self->{Subaction} eq 'AgentPreferences' ) {
        return $Self->AgentPreferences();
    }
    elsif ( $Self->{Subaction} eq 'ChatClose' ) {
        return $Self->ChatClose();
    }

    return $Self->ErrorResponse(
        Message => "Unkown Subaction.",
    );
}

sub ChatOverview {
    my ( $Self, %Param ) = @_;

    my $ActiveFilter = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Filter' )
        || 'IncomingChatRequests';

    my @Filters = (
        {
            ID     => 'IncomingChatRequests',
            Search => {
                Status        => 'request',
                TargetType    => 'Customer',
                ChatterID     => $Self->{UserID},
                ChatterType   => 'Customer',
                ChatterActive => 0,
            },
        },
        {
            ID     => 'OutgoingChatRequests',
            Search => {
                Status        => 'request',
                RequesterType => 'Customer',
                ChatterID     => $Self->{UserID},
                ChatterType   => 'Customer',
                ChatterActive => 1,
            },
        },
        {
            ID     => 'ActiveChats',
            Search => {
                Status        => 'active',
                ChatterID     => $Self->{UserID},
                ChatterType   => 'Customer',
                ChatterActive => 1,
            },
        },
        {
            ID     => 'ClosedChats',
            Search => {
                Status        => 'closed',
                ChatterID     => $Self->{UserID},
                ChatterType   => 'Customer',
                ChatterActive => 1,
            },
        },
    );

    my %Chats;

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    for my $Filter (@Filters) {
        $Chats{ $Filter->{ID} } = [
            $ChatObject->ChatList(
                %{ $Filter->{Search} },
                MaskAgentName => 1,
                )
        ];

        # Get first text message of active chats
        if ( $Filter->{ID} eq $ActiveFilter ) {
            for my $Chat ( @{ $Chats{ $Filter->{ID} } } ) {
                my ($FirstMessage) = $ChatObject->ChatMessageList(
                    ChatID          => $Chat->{ChatID},
                    FirstMessage    => 1,
                    MaskAgentName   => 1,
                    ExcludeInternal => 1,
                );

                if ($FirstMessage) {
                    $Chat->{FirstMessage} = $LayoutObject->Ascii2Html(
                        Text        => $FirstMessage->{MessageText},
                        LinkFeature => 1,
                    );
                }
            }
        }
    }

    my $Output = $LayoutObject->CustomerHeader(
        Refresh => 1 * 60,
    );
    $Output .= $LayoutObject->CustomerNavigationBar();

    $LayoutObject->Block(
        Name => 'ChatOverview',
        Data => {
            Filters      => \@Filters,
            ActiveFilter => $ActiveFilter,
            Chats        => \%Chats,
        },
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => "CustomerChat",
    );
    $Output .= $LayoutObject->CustomerFooter();

    return $Output;

}

sub CreateChatRequest {
    my ( $Self, %Param ) = @_;

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check is TicketID sent
    my $TicketID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'TicketID' );

    # check are Chat Channels enabled on Customer interface
    my $ChatChannelsEnabled
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::CustomerInterface::AllowChatChannels');

    # check SysConfig for allowing to start a chat with an agent without a ticket
    if (
        !$Kernel::OM->Get('Kernel::Config')->Get('Ticket::Customer::StartChatWOTicket')
        && !$TicketID
        )
    {
        return $Self->ErrorResponse(
            Message => "You can not start a chat out of the ticket.",
        );
    }

    my %Errors;

    if ( $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'CreateAction' ) ) {

        my $Message = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Message' );

        if ( !$Message ) {
            $Errors{MessageError} = 'ServerError';
        }
        elsif ( length $Message > 3800 ) {
            $Errors{MessageError} = 'ServerError';
        }

        my $RequesterName = $Self->_SenderName();

        # Set chat channel
        my $ChannelID;

        # Get selected channel id
        $ChannelID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ChannelID' );

        # if there's no ChannelID look at the PreselectedChannelID
        if ( !$ChannelID ) {
            $ChannelID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'PreselectedChannelID' );
        }

        # if still there is no chat channel, use default chat channel
        # for this chat channels must not be enabled
        if ( !$ChannelID && !$ChatChannelsEnabled ) {
            $ChannelID = $ChatChannelObject->DefaultChatChannelGet();
        }

        if ( !%Errors ) {

            $Self->{ChatID} = $ChatObject->ChatAdd(
                Status        => 'request',
                RequesterID   => $Self->{UserID},
                RequesterName => $RequesterName,
                RequesterType => 'Customer',
                TargetType    => 'User',
                ChannelID     => $ChannelID,
                TicketID      => $TicketID,
            );

            my $GrantSuccess = $ChatObject->ChatParticipantAdd(
                ChatID        => $Self->{ChatID},
                ChatterID     => $Self->{UserID},
                ChatterType   => 'Customer',
                ChatterName   => $RequesterName,
                ChatterActive => 1,
            );

            my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                "%s has joined this chat.",
                $Self->_SenderName(),
            );

            $ChatObject->ChatMessageAdd(
                ChatID          => $Self->{ChatID},
                ChatterID       => $Self->{UserID},
                ChatterType     => 'Customer',
                SystemGenerated => 1,
                MessageText     => $JoinMessage,
            );

            $ChatObject->ChatMessageAdd(
                ChatID      => $Self->{ChatID},
                ChatterID   => $Self->{UserID},
                ChatterType => 'Customer',
                MessageText => $Message,
            );

            return $LayoutObject->Redirect(
                OP => "Action=$Self->{Action};Subaction=ChatScreen;ChatID=$Self->{ChatID};TicketID=$TicketID",
            );
        }
    }

    # Get channels data
    my @ChatChannelsData;

    if ($ChatChannelsEnabled) {
        @ChatChannelsData = $ChatChannelObject->ChatChannelsGet(
            Valid => 1,
        );
    }

    my $SelectedChannelID;

    if ($TicketID) {

        # chat request is sent from ticket
        # create related ticket
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID => $TicketID,
        );

        # if such ticket is not defined
        if ( !%Ticket ) {
            return $LayoutObject->CustomerFatalError(
                Message => "Wrong Ticket provided",
            );
        }

        # set TicketID into param
        $Param{TicketID} = $TicketID;

        # get all queues to tickets relations
        my %QueueChatChannelRelations = $ChatChannelObject->ChatChannelQueuesGet();

        # if a support chat channel is set for this queue
        if ( !$QueueChatChannelRelations{ $Ticket{QueueID} } ) {
            return $LayoutObject->CustomerFatalError(
                Message => "Wrong Ticket provided",
            );
        }
        $SelectedChannelID = $QueueChatChannelRelations{ $Ticket{QueueID} };
        $Param{PreselectedChannelID} = $SelectedChannelID;
    }

    # Get all online users
    my @OnlineUsers = $ChatObject->OnlineUserList(
        UserType => 'User',                      # 'User' or 'Customer'
        Group    => $ChatReceivingAgentsGroup,
    );

    my $AvailabilityCheck = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::CustomerFrontend::AvailabilityCheck")
        || 0;
    my %AvailableUsers;
    if ($AvailabilityCheck) {
        %AvailableUsers = $ChatObject->AvailableUsersGet(
            Key => 'ExternalChannels',
        );
    }

    my $NumberOfDisabledChannels = 0;

    # check for availlable chat channels if Chat channels are enabled
    if ($ChatChannelsEnabled) {

        # Rename hash keys: Name => Value, ChatChannelID => Key
        for my $ChatChannelData (@ChatChannelsData) {
            $ChatChannelData->{Value} = delete $ChatChannelData->{Name};
            $ChatChannelData->{Key}   = delete $ChatChannelData->{ChatChannelID};

            if ($AvailabilityCheck) {
                my $UserAvailable = 0;

                CHAT_CHANNEL:

                # iterate available users
                for my $UserID ( sort keys %AvailableUsers ) {

                    if ( grep( /^$ChatChannelData->{Key}$/, @{ $AvailableUsers{$UserID} } ) ) {

                        # get user's permission level
                        my $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                            UserID        => $UserID,
                            ChatChannelID => $ChatChannelData->{Key},
                        );

                        # if user can be owner in this channel, channel is available
                        if ( $PermissionLevel && $PermissionLevel eq 'Owner' ) {
                            $UserAvailable = 1;
                            last CHAT_CHANNEL;
                        }
                    }
                }

                if ( !$UserAvailable ) {
                    $ChatChannelData->{Disabled} = 1;
                    $NumberOfDisabledChannels++;
                }
            }
        }
    }

    my $Output = $LayoutObject->CustomerHeader();

    my $Channel;

    # show channels block only if chat channels are enabled
    if ($ChatChannelsEnabled) {
        $Channel = $LayoutObject->BuildSelection(
            Data         => \@ChatChannelsData,
            Name         => 'ChannelID',
            PossibleNone => 1,
            Class        => 'Validate_Required',
            SelectedID   => $SelectedChannelID,
            Disabled     => $SelectedChannelID ? 1 : 0,    # disable this if channel id is selected
        );
    }

    $LayoutObject->Block(
        Name => 'CreateChatRequest',
        Data => {
            %Errors,
            %Param,
            Channel => $Channel,
        },
    );

    my $AllowChat = 1;

    # check should chat be enabled
    if ($ChatChannelsEnabled) {
        if ( scalar @ChatChannelsData == $NumberOfDisabledChannels ) {

            # revoke allow chat
            $AllowChat = 0;
        }
    }
    else {

        # get number of available user for chat
        my @AvailableUserIDs = keys %AvailableUsers;
        if ( scalar @AvailableUserIDs == 0 && $AvailabilityCheck ) {
            $AllowChat = 0;
        }
    }

    # Display chat unavailable notification if needed
    if ( !$AllowChat ) {
        if ( $Param{TicketID} ) {
            $LayoutObject->Block(
                Name => 'ChatNotAvailableTicket',
                Data => {
                    TicketID => $Param{TicketID},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'ChatNotAvailable',
                Data => {
                },
            );
        }
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => "CustomerChat",
    );
    $Output .= $LayoutObject->CustomerFooter();

    return $Output;
}

sub ChatScreen {
    my ( $Self, %Param ) = @_;

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    # check is TicketID sent
    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

    # General access was checked before, now we want to know if we re-enter the chat.
    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'Customer',
    );

    if ( !$ChatParticipant{ChatterActive} ) {

        # update chat status
        $ChatObject->ChatUpdate(
            ChatID => $Self->{ChatID},
            Status => 'active',
        );

        my $Message = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has joined this chat.",
            $Self->_SenderName(),
        );

        $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'Customer',
            SystemGenerated => 1,
            MessageText     => $Message,
        );

        $ChatObject->ChatParticipantUpdate(
            ChatID        => $Self->{ChatID},
            ChatterID     => $Self->{UserID},
            ChatterType   => 'Customer',
            ChatterActive => 1,
        );
    }

    # Get threshold from sysconfig
    my $Threshold = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::NoAnswerTreshhold") || 1;

    my $Output = $LayoutObject->CustomerHeader();

    # Check if system should display Customer Information
    my $DefaultAgentName = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::DefaultAgentName") || 0;

    $LayoutObject->Block(
        Name => 'ChatScreen',
        Data => {
            ChatID     => $Self->{ChatID},
            SenderName => $Self->_SenderName(),
            Threshold  => $Threshold,
            TicketID   => $TicketID,
            Shrink     => $DefaultAgentName ? '' : 'Shrinked',
        },
    );

    if ( !$DefaultAgentName ) {
        $LayoutObject->Block(
            Name => 'Agent',
            Data => {

            },
        );
    }

    # Check if video chat should be started.
    my $VideoChatStart = $ParamObject->GetParam( Param => 'VideoChatStart' ) || 0;
    if ($VideoChatStart) {
        $LayoutObject->Block(
            Name => 'VideoChatStart',
            Data => {
                NoVideo => $ParamObject->GetParam( Param => 'NoVideo' ) || '',
            },
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'CustomerChat',
    );
    $Output .= $LayoutObject->CustomerFooter();

    return $Output;
}

sub ChatMessageAdd {
    my ( $Self, %Param ) = @_;

    my $Message = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Message' );

    my %ChatData = $Kernel::OM->Get('Kernel::System::Chat')->ChatGet(
        ChatID => $Self->{ChatID},
    );

    # do not allow writing if chat is closed
    if (
        $ChatData{Status} ne 'closed'
        && $Message
        && length $Message <= 3800
        )
    {
        $Kernel::OM->Get('Kernel::System::Chat')->ChatMessageAdd(
            ChatID      => $Self->{ChatID},
            ChatterID   => $Self->{UserID},
            ChatterType => 'Customer',
            MessageText => $Message,
        );
    }

    return $Self->ChatUpdate();
}

sub ChatGetOpenRequests {
    my ( $Self, %Param ) = @_;

    my $Chats = $Kernel::OM->Get('Kernel::System::Chat')->ChatList(
        Status        => 'request',
        TargetType    => 'Customer',
        ChatterID     => $Self->{UserID},
        ChatterType   => 'Customer',
        ChatterActive => 0,
    );

    # Save WebRTC capabilities of user's web browser.
    $Kernel::OM->Get('Kernel::System::CustomerUser')->SetPreferences(
        Key    => 'VideoChatHasWebRTC',
        Value  => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'HasWebRTC' ) // '0',
        UserID => $Self->{UserID},
    );

    # Get video chat invites.
    my $VideoChatInvite;
    my $Invites = $Kernel::OM->Get('Kernel::System::VideoChat')->ReceiveSignals(
        TargetID   => $Self->{UserID},
        TargetType => 'Customer',
        SignalKey  => 'VideoChatInvite',
    );

    if ( scalar @{ $Invites // [] } > 0 ) {

        INVITE:
        for my $Invite ( @{$Invites} ) {

            # Compose dialog text.
            my $DialogText = $Kernel::OM->Get('Kernel::Language')->Translate(
                $Invite->{SignalValue} eq '4'
                ? 'You have been invited to an audio call.'
                : 'You have been invited to a video call.',
            );

            if (
                $Invite->{RequesterType} eq 'User'
                && !$Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::DefaultAgentName")
                )
            {
                my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                    UserID => $Invite->{RequesterID},
                );
                $DialogText = $Kernel::OM->Get('Kernel::Language')->Translate(
                    $Invite->{SignalValue} eq '4'
                    ? "<b>%s</b> invited you to an audio call."
                    : "<b>%s</b> invited you to a video call.",
                    $User{UserFullname},
                );
            }

            $VideoChatInvite = {
                %{$Invite},
                DialogText => $DialogText,
            };

            # Process only first invite.
            last INVITE;
        }
    }

    my $Return = {
        Count           => scalar $Chats,
        VideoChatInvite => $VideoChatInvite,
    };

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Return ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatLeave {
    my ( $Self, %Param ) = @_;

    my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');

    my %Chat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    my $SenderName = $Self->_SenderName();

    # In case that the chat was not answered yet by an agent, or still empty, delete it.
    if ( $Chat{Status} eq 'request' ) {
        $ChatObject->ChatDelete(
            ChatID => $Self->{ChatID},
        );
    }

    # Otherwise add the leave message.
    else {
        my $Message = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has left this chat.",
            $Self->_SenderName(),
        );

        $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'Customer',
            SystemGenerated => 1,
            MessageText     => $Message,
        );

        $ChatObject->ChatParticipantUpdate(
            ChatID        => $Self->{ChatID},
            ChatterID     => $Self->{UserID},
            ChatterType   => 'Customer',
            ChatterActive => 0,
        );
    }

    # check number of active users
    my $ContributorCount = $ChatObject->ContributorsCount(
        ChatID => $Self->{ChatID},
    );

    # if there are no users active anymore, delete this chat
    if ( $ContributorCount == 0 ) {
        $ChatObject->ChatDelete(
            ChatID => $Self->{ChatID},
        );
    }

    return $Self->ChatCompleted();
}

sub ChatCompleted {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = $LayoutObject->CustomerHeader();

    $LayoutObject->Block(
        Name => 'ChatCompleted',
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => "CustomerChat",
    );
    $Output .= $LayoutObject->CustomerFooter();

    return $Output;
}

sub ChatUpdate {
    my ( $Self, %Param ) = @_;

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %ChatData = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    @{ $ChatData{ChatMessages} } = $ChatObject->ChatMessageList(
        ChatID        => $Self->{ChatID},
        MaskAgentName => 1,
        LastKnownChatMessageID =>
            $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'LastKnownChatMessageID' ),
        ExcludeInternal => 1,
    );

    for my $Message ( @{ $ChatData{ChatMessages} } ) {

        # Localize time and apply time zone, if needed.
        $Message->{CreateTime}
            = $LayoutObject->{LanguageObject}->FormatTimeString( $Message->{CreateTime}, 'DateFormat' );

        # Convert the message text to HTML with link quoting option. Treat original message
        #   as plain text, in order to avoid possible code injection. See bug#12481 for more
        #   information.
        $Message->{MessageText} = $LayoutObject->Ascii2Html(
            Text        => $Message->{MessageText},
            LinkFeature => 1,
        );
    }

    # get chat participants
    my @Participants = $ChatObject->ChatParticipantList(
        ChatID => $Self->{ChatID},
    );

    my $TargetUser;

    PARTICIPANT:
    for my $Participant (@Participants) {

        # skip non-agents, inactive participants and observers
        next PARTICIPANT if $Participant->{ChatterType} ne 'User';
        next PARTICIPANT if $Participant->{ChatterActive} != 1;
        next PARTICIPANT if $Participant->{PermissionLevel} eq 'Observer';

        $TargetUser = $Participant;

        last PARTICIPANT;
    }

    if ($TargetUser) {
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $TargetUser->{ChatterID},
        );
        $ChatData{HasWebRTC} = $User{VideoChatHasWebRTC} // '0';
    }
    else {
        $ChatData{HasWebRTC} = '0';
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%ChatData ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub AgentPreferences {
    my ( $Self, %Param ) = @_;

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @Result;

    # Get chat participants
    my @Participants = $ChatObject->ChatParticipantList(
        ChatID => $Self->{ChatID},
    );

    # Check which preferences should be returned (SysConfig)
    my @PreferenceList = @{ $ConfigObject->Get('ChatEngine::CustomerFrontend::AgentPreferences') };

    PARTICIPANT:
    for my $Participant (@Participants) {

        # skip users, inactive participants and observers
        next PARTICIPANT if $Participant->{ChatterType} ne 'User';
        next PARTICIPANT if $Participant->{ChatterActive} != 1;
        next PARTICIPANT if $Participant->{PermissionLevel} eq 'Observer';

        # Get current agent preferences
        my %Preferences = $UserObject->GetPreferences(
            UserID => $Participant->{ChatterID},
        );

        PREFERENCE:
        for my $Preference (@PreferenceList) {

            # Get preference registration
            my $PreferenceRegistration = $ConfigObject->Get('PreferencesGroups')->{$Preference};

            # Check if active
            next PREFERENCE if !$PreferenceRegistration->{'Active'};

            $Kernel::OM->ObjectParamAdd(
                $PreferenceRegistration->{'Module'} => {
                    UserID     => 1,
                    UserObject => $Kernel::OM->Get('Kernel::System::User'),
                    ConfigItem => $PreferenceRegistration,
                },
            );

            # Get module for this preference
            my $Module = $Kernel::OM->Get( $PreferenceRegistration->{'Module'} );

            # Skip if this module is not registered
            next PREFERENCE if !$Module;

            my @Parameters = $Module->Param(
                UserData => {
                    UserID => $Participant->{ChatterID},
                    }
            );

            next PREFERENCE if !@Parameters;

            PARAMETER:
            for my $CurrentParameter (@Parameters) {
                if ( !defined $CurrentParameter->{Block} ) {

                    # Check for block in module registration
                    if ( defined $PreferenceRegistration->{'Block'} ) {
                        $CurrentParameter->{Block} = $PreferenceRegistration->{'Block'};
                    }
                }

                my %Information = (
                    Label => $CurrentParameter->{Key} || $PreferenceRegistration->{Label},
                );

                # Default handler
                if ( !defined $CurrentParameter->{Block} ) {

                    # Default is option
                    if ( defined $PreferenceRegistration->{Data} ) {

                        # It contains data
                        my $SelectedValue = $PreferenceRegistration->{DataSelected};
                        $Information{Value} = $Preferences{ $PreferenceRegistration->{PrefKey} };
                    }
                    else {

                        # It contains no Data, but it contains output html (stored in Option)

                        # Loop through all options
                        my @Options;
                        while ( $CurrentParameter->{'Option'} =~ /(<option.*?<\/option>)/g ) {
                            my $Option = $1;

                            if ( $Option =~ /\"selected\"/g ) {

                                # Extract name
                                $Option =~ />(.*?)<\/option>/g;

                                # Add name
                                push @Options, $1;
                            }
                        }
                        $Information{Value} = join( ', ', @Options );
                    }

                    next PARAMETER if !$Information{Value};
                }

                # Upload
                elsif ( $CurrentParameter->{Block} eq 'Upload' ) {

                    if ( $PreferenceRegistration->{PrefKey} ) {
                        if (
                            $Preferences{ $PreferenceRegistration->{PrefKey} }
                            && $CurrentParameter->{Type} eq 'ImagePreferences'
                            )
                        {
                            $Information{Value} = $Kernel::OM->Get('Kernel::System::Image')->ImageGet(
                                Key      => 'ImagePreferences',
                                ID       => $CurrentParameter->{UserData}->{UserID},
                                Filename => $Preferences{ $PreferenceRegistration->{PrefKey} },
                                Inline   => 1,
                            );
                        }
                    }

                    next PARAMETER if !$Information{Value};
                }

                # Option
                elsif ( $CurrentParameter->{Block} eq 'Option' ) {
                    if ( defined $PreferenceRegistration->{PrefKey} ) {
                        if ( defined $Preferences{ $PreferenceRegistration->{PrefKey} } ) {
                            $Information{Value}
                                = $CurrentParameter->{Data}->{ $Preferences{ $PreferenceRegistration->{PrefKey} } };
                        }
                    }
                    elsif ( defined $CurrentParameter->{Name} ) {
                        $Information{Value} = $Preferences{ $CurrentParameter->{Name} };
                    }
                    next PARAMETER if !$Information{Value};
                }

                # Input
                elsif ( $CurrentParameter->{Block} eq 'Input' ) {

                    # Set value from user preferences
                    $Information{Value} = $Preferences{ $CurrentParameter->{Name} };

                    next PARAMETER if !$Information{Value};
                }

                # OutOfOffice
                elsif ( $CurrentParameter->{Block} eq 'OutOfOffice' ) {
                    next PREFERENCE if !$Preferences{'OutOfOffice'};

                    $Information{Value} =
                        $Preferences{OutOfOfficeStartMonth} . '/'
                        . $Preferences{OutOfOfficeStartDay} . '/'
                        . $Preferences{OutOfOfficeStartYear} . ' - '
                        .
                        $Preferences{OutOfOfficeEndMonth} . '/'
                        . $Preferences{OutOfOfficeEndDay} . '/'
                        . $Preferences{OutOfOfficeEndYear};
                }

                # Everything else
                else {
                    next PARAMETER if !$Information{Value};
                }

                # Check if result already contains this participant
                my @Item = grep { $_->{Participant} eq $Participant->{ChatterName} } @Result;
                if (@Item) {
                    push @{ $Item[0]->{Information} }, \%Information;
                }
                else {
                    push @Result, {
                        Participant => $Participant->{ChatterName},
                        Information => [ \%Information ],
                    };
                }
            }
        }
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \@Result ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatClose {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'Close called',
        Message  => "Hello!",
    );

    # Threshold was reached, close the chat
    my $Success = $ChatObject->ChatUpdate(
        ChatID => $Self->{ChatID},
        Status => 'closed',
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Success ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ErrorResponse {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # In case of an AJAX request we don't want an error HTML page.
    #   We'll just redirect to the chat completed page
    if ( $Kernel::OM->Get('Kernel::System::Web::Request')->IsAJAXRequest() ) {
        my %Response = (
            Redirect => '?Action=CustomerChat;Subaction=ChatCompleted',
        );
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \%Response ),
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    return $LayoutObject->CustomerFatalError(
        Message => $Param{Message},
    );
}

sub _SenderName {
    my ( $Self, %Param ) = @_;

    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my %UserData           = $CustomerUserObject->CustomerUserDataGet(
        User => $Self->{UserID},
    );

    my $RequesterName = $UserData{UserFirstname} // '';
    if ( $UserData{UserLastname} ) {
        $RequesterName .= ' ' . $UserData{UserLastname};
    }
    $RequesterName ||= $Self->{UserID};

    return $RequesterName;
}

1;
