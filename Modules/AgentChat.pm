# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentChat;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $Self->{ChatID}           = $ParamObject->GetParam( Param => 'ChatID' );
    $Self->{ShowOpenRequests} = $ParamObject->GetParam( Param => 'ShowOpenRequests' ) || 0;
    $Self->{AvailableForChat} = $ParamObject->GetParam( Param => 'AvailableForChat' ) || 0;
    $Self->{Msg}              = $ParamObject->GetParam( Param => 'Msg' ) || 0;

    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
        return $LayoutObject->FatalError(
            Message => "Chat is not active.",
        );
    }

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    my $ChatStartingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatStartingAgents');

    if (
        $Self->{UserID} != 1
        && (
            !$ChatReceivingAgentsGroup
            || !$ChatStartingAgentsGroup
            || (
                !$LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
                && !$LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
            )
        )
        )
    {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    if ( $Self->{Subaction} eq 'ChatRequestAccept' ) {
        if (
            $Self->{UserID} != 1
            && !$LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
            )
        {
            return $LayoutObject->FatalError(
                Message => "No permission.",
            );
        }
        return $Self->ChatRequestAccept();
    }
    elsif ( $Self->{Subaction} eq 'ChatStart' ) {
        if (
            $Self->{UserID} != 1
            && !$LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
            )
        {
            return $LayoutObject->FatalError(
                Message => "No permission.",
            );
        }
        return $Self->ChatStart();
    }
    elsif ( $Self->{Subaction} eq 'ChatListUpdate' ) {
        return $Self->ChatListUpdate();
    }
    elsif ( $Self->{Subaction} eq 'ChatMessageAdd' ) {
        return $Self->ChatMessageAdd();
    }
    elsif ( $Self->{Subaction} eq 'ChatDiscard' ) {
        return $Self->ChatDiscard();
    }
    elsif ( $Self->{Subaction} eq 'ChatGetOpenRequests' ) {
        return $Self->ChatGetOpenRequests();
    }
    elsif ( $Self->{Subaction} eq 'GetInviteAgentList' ) {
        return $Self->GetInviteAgentList();
    }
    elsif ( $Self->{Subaction} eq 'InviteAgent' ) {
        return $Self->InviteAgent();
    }
    elsif ( $Self->{Subaction} eq 'PermissionLevel' ) {
        return $Self->PermissionLevel();
    }
    elsif ( $Self->{Subaction} eq 'Channels' ) {
        return $Self->Channels();
    }
    elsif ( $Self->{Subaction} eq 'ChangeChannel' ) {
        return $Self->ChangeChannel();
    }
    elsif ( $Self->{Subaction} eq 'LeaveChat' ) {
        return $Self->LeaveChat();
    }
    elsif ( $Self->{Subaction} eq 'ChatRoleSwitch' ) {
        return $Self->ChatRoleSwitch();
    }
    elsif ( $Self->{Subaction} eq 'UpdateChatOrder' ) {
        return $Self->UpdateChatOrder();
    }
    elsif ( $Self->{Subaction} eq 'DeclineRequest' ) {
        return $Self->DeclineRequest();
    }
    elsif ( $Self->{Subaction} eq 'SetAvailability' ) {
        return $Self->SetAvailability();
    }
    elsif ( $Self->{Subaction} eq 'GetAvailability' ) {
        return $Self->GetAvailability();
    }
    elsif ( $Self->{Subaction} eq 'UpdateOnlineUsers' ) {
        return $Self->UpdateOnlineUsers();
    }
    elsif ( $Self->{Subaction} eq 'ChatMonitorSwitch' ) {
        return $Self->ChatMonitorSwitch();
    }
    elsif ( $Self->{Subaction} eq 'VideoChatRequest' ) {
        return $Self->VideoChatRequest();
    }

    return $Self->ChatScreen();
}

sub ChatScreen {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $Output       = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    my $SenderName = $Self->_SenderName();

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    $Self->{ChatAppended}    = $ParamObject->GetParam( Param => 'ChatAppended' )    || 0;
    $Self->{AppendChatID}    = $ParamObject->GetParam( Param => 'AppendChatID' )    || 0;
    $Self->{AppendTicketID}  = $ParamObject->GetParam( Param => 'AppendTicketID' )  || 0;
    $Self->{AppendArticleID} = $ParamObject->GetParam( Param => 'AppendArticleID' ) || 0;

    # notify info
    if ( $Self->{ChatAppended} && $Self->{AppendChatID} && $Self->{AppendTicketID} && $Self->{AppendArticleID} ) {
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet( TicketID => $Self->{AppendTicketID} );
        $Output .= $LayoutObject->Notify(
            Info => $LayoutObject->{LanguageObject}->Translate(
                'Chat %s has been closed and was successfully appended to Ticket %s.',
                $Self->{AppendChatID},
                $Ticket{TicketNumber},
            ),
            Link => $LayoutObject->{Baselink}
                . 'Action=AgentTicketZoom;TicketID='
                . $Ticket{TicketID}
                . ';ArticleID='
                . $Self->{AppendArticleID},
        );
    }

    my $VideoChatAgentsGroup = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::VideoChatAgents');

    if ( $LayoutObject->{"UserIsGroup[$VideoChatAgentsGroup]"} ) {

        # Enable the video chat feature if system is entitled or we are in unit test mode (no TURN
        #   servers required for successful connection).
        my $VideoChatEnabled = $Kernel::OM->Get('Kernel::System::VideoChat')->IsEnabled()
            || $ParamObject->GetParam( Param => 'UnitTestMode' ) // 0;

        if ( !$VideoChatEnabled ) {
            $Output .= $LayoutObject->Notify(
                Priority => 'Warning',
                Info     => $LayoutObject->{LanguageObject}->Translate(
                    'Video call feature has been disabled! Please check if %s is available for the current system.',
                    "OTRS Business Solution\x{2122}",
                ),
                Link => $LayoutObject->{Baselink} . 'Action=AdminRegistration;',
            );
        }
    }

    $LayoutObject->Block(
        Name => 'ChatScreen',
        Data => {
            SenderName => $SenderName,
        },
    );

    if ( $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToAgent') ) {
        $LayoutObject->Block(
            Name => 'RequestsToCurrentAgent',
            Data => {
                SenderName => $SenderName,
            },
        );
    }

    my $ChatStarted = $ParamObject->GetParam( Param => 'ChatStarted' );

    if ($ChatStarted) {
        if ( $ChatStarted eq 'Error' ) {
            $LayoutObject->Block(
                Name => 'ChatStartedError',
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'ChatStartedSuccess',
                Data => {
                    ChatID => $ChatStarted,
                },
            );
        }
    }

    if ( $Self->{ShowOpenRequests} ) {
        $LayoutObject->Block(
            Name => 'ShowOpenRequests',
            Data => {
                Count => $Self->{ShowOpenRequests},
            },
        );
    }

    # check if the user is available
    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    my $FilterExternalChatChannels = $ParamObject->GetParam(
        Param => 'FilterExternalChatChannels',
    ) || 'My';

    my $FilterInternalChatChannels = $ParamObject->GetParam(
        Param => 'FilterInternalChatChannels',
    ) || 'My';

    #PublicRequests
    if ( $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::PublicToAgent') ) {
        $LayoutObject->Block(
            Name => 'PublicRequests',
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentChat',
        Data         => {
            FilterExternalChatChannels => $FilterExternalChatChannels,
            FilterInternalChatChannels => $FilterInternalChatChannels,
            Msg                        => $Self->{Msg},
        },
    );
    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub ChatStart {
    my ( $Self, %Param ) = @_;

    my $Error;

    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    my %GetParam;
    for my $Field (
        qw(ChatStartUserID ChatStartUserType ChatStartUserFullname ChatStartFirstMessage)
        )
    {
        $GetParam{$Field} = $ParamObject->GetParam( Param => $Field );
        if ( !$GetParam{$Field} ) {
            $Error = 1;
        }
    }

    # get chat channel
    $GetParam{ChannelID} = $ParamObject->GetParam( Param => "ChannelID" );

    # if chat channel is not defined, use default chat channel
    if ( !$GetParam{ChannelID} ) {
        $GetParam{ChannelID} = $ChatChannelObject->DefaultChatChannelGet();
    }

    # get TicketID
    $GetParam{TicketID} = $ParamObject->GetParam( Param => "TicketID" );

    my $TargetType = 'User';
    if ( $GetParam{ChatStartUserType} eq 'Customer' ) {
        $TargetType = 'Customer';
    }

    # check is agent-to-agent chat enabled
    if (
        $TargetType eq 'User'
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToAgent')
        )
    {
        $Error = 1;
    }

    # check is agent-to-customer chat enabled
    if (
        $TargetType eq 'Customer'
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToCustomer')
        )
    {
        $Error = 1;
    }

    my $ChatID;

    if ( !$Error ) {
        my $SenderName = $Self->_SenderName();

        $ChatID = $ChatObject->ChatAdd(
            Status        => 'request',
            RequesterID   => $Self->{UserID},
            RequesterName => $SenderName,
            RequesterType => 'User',
            TargetType    => $TargetType,
            ChannelID     => $GetParam{ChannelID},
            TicketID      => $GetParam{TicketID},
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $ChatID,
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            ChatterName     => $SenderName,
            ChatterActive   => 1,
            PermissionLevel => 'Owner',
            Monitoring      => 0,                 # do not monitor activity in the chat by default
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $ChatID,
            ChatterID       => $GetParam{ChatStartUserID},
            ChatterType     => $TargetType,
            ChatterName     => $GetParam{ChatStartUserFullname},
            ChatterActive   => 0,
            PermissionLevel => 'Owner',
            Monitoring      => 0,                                  # do not monitor activity in the chat by default
        );

        my $Success = $ChatObject->ChatMessageAdd(
            ChatID      => $ChatID,
            ChatterID   => $Self->{UserID},
            ChatterType => 'User',
            MessageText => $GetParam{ChatStartFirstMessage},
        );

        # Update chat order
        $Self->_ChatOrderUpdate(
            ChatID => $ChatID,
        );

        return $LayoutObject->Redirect(
            OP => "Action=AgentChat;ChatStarted=$ChatID",
        );
    }

    # show error message
    return $LayoutObject->FatalError(
        Message => "Error creating a chat.",
    );
}

sub ChatListUpdate {
    my ( $Self, %Param ) = @_;

    my %Chats;

    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    my %LastKnownChatMessageIDs = %{
        $Kernel::OM->Get('Kernel::System::JSON')->Decode(
            Data => $ParamObject->GetParam( Param => 'LastKnownChatMessageIDs' ) || '{}',
            ) // {}
    };

    my @ExternalChannels;

    # flag showing are chat channels enabled on Customer interface
    my $CustomerChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get(
        'ChatEngine::CustomerInterface::AllowChatChannels'
    );

    # check are public chat channels enabled
    # if they are, pass ExternalChatChannels for ChannellIDs when searching for public requests
    # otherwise all channels will be monitored
    my $PublicChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get(
        'ChatEngine::PublicInterface::AllowChatChannels'
    );

    # if chat channels are enabled on public or customer interface
    # get user's chat channels
    # otherwise just work with the default chat channel
    if ( $CustomerChannelsEnabled || $PublicChannelsEnabled ) {

        # this will filter external chat channels
        # depending on this setting, user will see public and customer chat request only in channels he's monitoring
        if ( $ParamObject->GetParam( Param => 'FilterExternalChatChannels' ) eq 'My' ) {

            # Show only channels defined in agent preferences
            @ExternalChannels = $ChatChannelObject->CustomChatChannelsGet(
                Key    => 'ExternalChannels',
                UserID => $Self->{UserID},
            );
        }

        elsif ( $ParamObject->GetParam( Param => 'FilterExternalChatChannels' ) eq 'All' ) {

            # Show all channels
            my @AllChannels = $ChatChannelObject->ChatChannelsGet(
                Valid => 1,
            );

            for my $Channel (@AllChannels) {
                push @ExternalChannels, $Channel->{ChatChannelID};
            }
        }
        else {
            return $LayoutObject->FatalError(
                Message => "Error. Please contact your admin team",
            );
        }

        # check for the each channel does user has Owner permissions
        # if not, remove them
        # don't show channels in which user can't accept a chat
        for ( my $i = 0; $i < scalar @ExternalChannels; $i++ ) {
            my $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                UserID        => $Self->{UserID},
                ChatChannelID => $ExternalChannels[$i],
            );

            if ( !$PermissionLevel || $PermissionLevel ne 'Owner' ) {
                delete $ExternalChannels[$i];
            }
        }
    }

    # get default chat channel and put it in array
    # if chat channels are disabled on Customer or Agent interface => all agents are monitoring default chat channel
    my $DefaultChannelID = $ChatChannelObject->DefaultChatChannelGet();

    # put default channel in array
    # it can be passed to method calls instead of External channels array
    my @DefaultChannelArray = ($DefaultChannelID);

    # Get customer requests
    $Chats{RequestsToAllAgents} = [
        $ChatObject->ChatList(
            Status        => "request",
            RequesterType => 'Customer',
            TargetType    => 'User',
            ChannelIDs    => $CustomerChannelsEnabled ? \@ExternalChannels : \@DefaultChannelArray,
            )
    ];

    # if public channels are enabled
    # otherwise public block won't be displayed
    if ( $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::PublicToAgent') ) {

        # Get public requests to all agents
        $Chats{PublicRequestsToAllAgents} = [
            $ChatObject->ChatList(
                Status        => "request",
                RequesterType => 'Public',
                TargetType    => 'User',
                ChannelIDs    => $PublicChannelsEnabled ? \@ExternalChannels : \@DefaultChannelArray,
                )
        ];
    }

    if ( $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToAgent') ) {

        # A2A chat requests
        $Chats{RequestsToCurrentAgent} = [

            # all personal chat requests
            $ChatObject->ChatList(
                Status        => "request",
                RequesterType => 'User',
                TargetType    => 'User',
                ChatterType   => 'User',
                ChatterID     => $Self->{UserID},
                ChatterActive => 0,
            ),

            # get invitations for agent to agent chat
            $ChatObject->ChatList(
                Status        => "active",
                RequesterType => 'User',
                TargetType    => 'User',
                ChatterType   => 'User',
                ChatterID     => $Self->{UserID},
                ChatterActive => 0,
            ),
        ];

        # Sort
        my @RequestsToCurrentAgent = sort { $a->{CreateTime} cmp $b->{CreateTime} }
            @{ $Chats{RequestsToCurrentAgent} };
        $Chats{RequestsToCurrentAgent} = \@RequestsToCurrentAgent;
    }

    # Now get all active chats of the current user
    $Chats{ActiveChats} = [
        $ChatObject->ChatList(
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 1,
        ),
    ];

    # Get participants and first message for every chat and perform cleanups
    for my $Type ( sort keys %Chats ) {
        for my $Chat ( @{ $Chats{$Type} || [] } ) {

            # Localize time and apply time zone, if needed.
            $Chat->{CreateTime}
                = $LayoutObject->{LanguageObject}->FormatTimeString( $Chat->{CreateTime}, 'DateFormat' );

            # get chat participants to display on top of each box
            my @ParticipantList = $ChatObject->ChatParticipantList(
                ChatID => $Chat->{ChatID},
            );

            if (@ParticipantList) {
                $Chat->{Participants} = \@ParticipantList;
            }

            # count number of agents in chat
            # we're not using API because we're anyway iterating list of participants
            # we're doing it because of Monitoring state
            # and to find company of the Customer
            my $ContributorsCount = 0;

            # check user monitoring status
            # also check is customer present in the chat
            CHATPARTICIPANT:
            for my $ChatParticipant (@ParticipantList) {
                if ( $ChatParticipant->{ChatterID} eq $Self->{UserID} ) {

                    # set monitoring state for this user
                    $Chat->{MonitoringState} = $ChatParticipant->{Monitoring};
                }

                # if chatter type is customer set flag that customer is participating
                # and set customer company if it's possible
                if ( $ChatParticipant->{ChatterType} eq 'Customer' ) {

                    $Chat->{CustomerChatter} = 1;

                    my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
                        User => $ChatParticipant->{ChatterID}
                    );

                    if ( %CustomerUser && $CustomerUser{CustomerID} && $CustomerUser{Config}->{CustomerCompanySupport} )
                    {
                        my %CustomerCompany = $Kernel::OM->Get('Kernel::System::CustomerCompany')->CustomerCompanyGet(
                            CustomerID => $CustomerUser{CustomerID},
                        );

                        $Chat->{CustomerCompany} = $CustomerCompany{CustomerCompanyName};
                        $Chat->{CustomerID}      = $CustomerCompany{CustomerID};
                    }

                    $ChatParticipant->{HasWebRTC} = $CustomerUser{VideoChatHasWebRTC} // '0';
                }
                elsif ( $ChatParticipant->{ChatterActive} eq 1 ) {
                    $ContributorsCount++;
                }

                if ( $ChatParticipant->{ChatterType} eq 'User' ) {
                    my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                        UserID => $ChatParticipant->{ChatterID},
                    );
                    $ChatParticipant->{HasWebRTC} = $User{VideoChatHasWebRTC} // '0';
                }
            }

            my @MessageList = $ChatObject->ChatMessageList(
                ChatID                 => $Chat->{ChatID},
                LastKnownChatMessageID => $LastKnownChatMessageIDs{ $Chat->{ChatID} },
                ExcludeCustomer        => 1,
            );

            for my $Message (@MessageList) {

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

            if (@MessageList) {
                $Chat->{Messages} = \@MessageList;
            }

            # Get first text message of chats
            if ( !$LastKnownChatMessageIDs{ $Chat->{ChatID} } ) {
                my ($FirstMessage) = $ChatObject->ChatMessageList(
                    ChatID          => $Chat->{ChatID},
                    FirstMessage    => 1,
                    ExcludeCustomer => 1,
                );

                if ($FirstMessage) {
                    $Chat->{FirstMessage} = $LayoutObject->Ascii2Html(
                        Text        => $FirstMessage->{MessageText},
                        LinkFeature => 1,
                    );
                }
            }

            my $PermissionLevel = "";

            if ( $Chat->{Status} eq 'request' ) {

                # if Channel is default User must have Owner permissions
                if ( $Chat->{ChannelID} == $DefaultChannelID ) {
                    $PermissionLevel = 'Owner';
                }
                else {
                    # Get permissions defined from chat_participant table
                    $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
                        ChatID => $Chat->{ChatID},
                        UserID => $Self->{UserID},
                    );

                    # if here is no permissions yet, get channel based permission level
                    if ( !$PermissionLevel ) {

                        # Get permissions by role
                        $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                            UserID        => $Self->{UserID},
                            ChatChannelID => $Chat->{ChannelID},
                        );
                    }
                }
            }

            # if chat is active
            # set permissions based on channel permissions ( role <=> channel)
            else {
                # if Channel is default User must have Owner permissions
                if ( $Chat->{ChannelID} && $Chat->{ChannelID} == $DefaultChannelID ) {
                    $PermissionLevel = 'Owner';
                }
                else {
                    # Get permissions defined from chat_participant table
                    $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
                        ChatID => $Chat->{ChatID},
                        UserID => $Self->{UserID},
                    );
                }
            }

            $Chat->{PermissionLevel} = $PermissionLevel;

            if ( $Type eq 'ActiveChats' ) {

                # always allow chat invite
                $Chat->{Invite} = 1;

                # Check if 'Change' and 'Leave' buttons should be displayed
                # if there is more than one agent PARTICIPATING in chat, leave chat will be enabled
                # if channel is default, channel change is not allowed
                if ( $PermissionLevel eq 'Participant' || $PermissionLevel eq 'Owner' ) {

                    # if Channel is default do not allow channel changes
                    if ( !$Chat->{ChannelID} || $Chat->{ChannelID} != $DefaultChannelID ) {
                        $Chat->{ChangeChannel} = 1;
                    }

                    # Check if there are other agents involved
                    my $ContributorCount = $ChatObject->ContributorsCount(
                        ChatID => $Chat->{ChatID},
                    );

                    if ( $ContributorCount > 1 ) {
                        $Chat->{LeaveChat} = 1;
                    }
                }
                else {
                    # can't change channel
                    # any time can leave a chat, since user is in Observer mode
                    $Chat->{ChangeChannel} = 0;
                    $Chat->{LeaveChat}     = 1;
                }

                # check is there TicketID
                if ( $Chat->{TicketID} ) {

                    # get ticket number from id
                    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
                        TicketID => $Chat->{TicketID},
                    );
                    $Chat->{TicketNumber} = $Ticket{TicketNumber};
                }

                # if user is invited to this chat
                if ( $Chat->{Invitation} ) {

                    # if there is a chat channel set permissions based on it
                    # otherwise give Participant permissions
                    my $PermissionLevel = 'Participant';

                    # if Channel is default User must have Owner permissions
                    if ( $Chat->{ChannelID} == $DefaultChannelID ) {
                        $PermissionLevel = 'Owner';
                    }
                    else {
                        $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                            UserID        => $Self->{UserID},
                            ChatChannelID => $Chat->{ChannelID},
                        );
                    }

                    # if user's current permission level is Observer
                    # and he has permission to be Participant or Owner in the channel
                    # user can switch to participant
                    if (
                        $Chat->{PermissionLevel} eq 'Observer'
                        && ( $PermissionLevel eq 'Owner' || $PermissionLevel eq 'Participant' )
                        )
                    {
                        # user can switch his state to participant
                        $Chat->{ParticipantSwitch} = 1;
                    }

                    # if user currently has Owner or Participant rights and there's is more than one contributor
                    # Switching to observer is allowed
                    elsif (
                        ( $Chat->{PermissionLevel} eq 'Owner' || $Chat->{PermissionLevel} eq 'Participant' )
                        && $ContributorsCount > 1
                        )
                    {
                        $Chat->{ObserverSwitch} = 1;
                    }
                }

                # else check is this chat invitation
                # chat invitation is chat opened only for inviting agent to a chat WITH CUSTOMER
                else {
                    # check is there a chat invitation pending
                    # invitation is current chat id
                    my $InvitationChatID = $ChatObject->ChatInvitesGet(
                        UserID           => $Self->{UserID},
                        InvitationChatID => $Chat->{ChatID},
                    );

                    # if this is a chat invitation
                    if ($InvitationChatID) {
                        $Chat->{InvitationChatID} = $InvitationChatID;

                        # get invited Chat data:
                        my %InvitedChat = $ChatObject->ChatGet(
                            ChatID => $Chat->{InvitationChatID},
                        );

                        # set related ticket_ID if it's defined
                        if ( $InvitedChat{TicketID} ) {
                            $Chat->{RelatedTicketID} = $InvitedChat{TicketID};

                            # get ticket number from id
                            my %RelatedTicket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
                                TicketID => $InvitedChat{TicketID},
                            );
                            $Chat->{RelatedTicketNumber} = $RelatedTicket{TicketNumber};
                        }

                        # get invited chat permission level
                        my $InvitedChatPermissionLevel;

                        # if InvitedChat Channel is default User must have Owner permissions
                        if ( $InvitedChat{ChannelID} && $InvitedChat{ChannelID} == $DefaultChannelID ) {
                            $PermissionLevel = 'Owner';
                        }

                        # otherwise find permssion level for the channel
                        else {
                            $InvitedChatPermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                                UserID        => $Self->{UserID},
                                ChatChannelID => $InvitedChat{ChatChannelID},
                            );
                        }

                        # user has only read access
                        if ( $InvitedChatPermissionLevel eq 'Observer' ) {
                            $Chat->{ObserverJoin} = 1;
                        }
                        if ( $InvitedChatPermissionLevel eq 'Participant' || $InvitedChatPermissionLevel eq 'Owner' ) {
                            $Chat->{ObserverJoin}    = 1;
                            $Chat->{ParticipantJoin} = 1;
                        }

                        # it might happen that user can't join a chat at all
                        # he does not have at least Observer permissions
                    }
                }
            }
        }
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Chats ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatRequestAccept {
    my ( $Self, %Param ) = @_;

    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    # if user is invited to the chat and have chose permissions
    my $DesiredPermType = $ParamObject->GetParam( Param => 'Type' );

    # if this is acceptance from chat invitation
    # user must pass an invitation if he's joining a chat
    # invitation will be later checked
    my $Invitation = $ParamObject->GetParam( Param => 'Invitation' );

    # get default chat channel
    # if chat channels are disabled on Customer or Agent interface => all agents are monitoring default chat channel
    my $DefaultChannelID = $ChatChannelObject->DefaultChatChannelGet();

    if ( !$Self->{ChatID} ) {

        # return chat already taken message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode(
                Data => {
                    Success => 0,
                    Error   => 'ChatTaken',
                },
            ),
            Type    => 'inline',
            NoCache => 1,
        );
    }

    my %Chat = $ChatObject->ChatGet( ChatID => $Self->{ChatID} );

    # set Monitoring to 0 by default ( it will be later set in database )
    # it's always set to 0 at start of the chat
    # we are doing this to decrease number of db requests
    # and it's by default set to 0
    $Chat{MonitoringState} = 0;

    # get chat participants to display on top of each box
    my @ParticipantList = $ChatObject->ChatParticipantList(
        ChatID => $Chat{ChatID},
    );

    if (@ParticipantList) {
        $Chat{Participants} = \@ParticipantList;
    }

    CHATPARTICIPANT:
    for my $ChatParticipant (@ParticipantList) {

        # if chatter type is customer set flag that customer is participating
        # and set customer company if it's possible
        next CHATPARTICIPANT if $ChatParticipant->{ChatterType} ne 'Customer';

        $Chat{CustomerChatter} = 1;

        my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $ChatParticipant->{ChatterID},
        );

        if ( %CustomerUser && $CustomerUser{Config}->{CustomerCompanySupport} ) {
            my %CustomerCompany = $Kernel::OM->Get('Kernel::System::CustomerCompany')->CustomerCompanyGet(
                CustomerID => $CustomerUser{CustomerID},
            );
            $Chat{CustomerCompany} = $CustomerCompany{CustomerCompanyName};
        }
    }

    my $PermissionLevel;

    # store channel based permission level
    my $ChannelBasedPermissionLevel;

    # if Channel is default User must have Owner permissions
    if ( $Chat{ChatChannelID} == $DefaultChannelID ) {
        $PermissionLevel = 'Owner';
    }
    else {

        $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
            UserID        => $Self->{UserID},
            ChatChannelID => $Chat{ChatChannelID},
        );

        $ChannelBasedPermissionLevel = $PermissionLevel;
    }

    $Chat{Channel} = $ChatChannelObject->ChannelLookup(
        ChannelID => $Chat{ChatChannelID},
    );

    # handler for the chat invitation
    my $InvitationChatID;

    # if user is not joining a chat with an invitation
    # check for an invitation to a chat
    if ( !$Invitation ) {

        # check is this an invitation for an existing chat
        $InvitationChatID = $ChatObject->ChatInvitesGet(
            UserID           => $Self->{UserID},
            InvitationChatID => $Self->{ChatID},
        );
    }

    # user is invited to this chat
    else {
        # check if invitation is valid
        if (
            !$ChatObject->ChatInvitesGet(
                UserID => $Self->{UserID},
                ChatID => $Self->{ChatID},
            )
            )
        {
            # if it's not valid, revoke it
            $Invitation = 0;
        }
    }

    # if Channel is default User must have Owner permissions
    if ( $Chat{ChatChannelID} == $DefaultChannelID ) {
        $PermissionLevel = 'Owner';
    }

    # if user has chose his own permission set permissions according to chosen
    if (
        $DesiredPermType &&
        $DesiredPermType eq 'Observer' &&
        $PermissionLevel
        )
    {
        $PermissionLevel = 'Observer';
    }
    elsif (
        $DesiredPermType &&
        $DesiredPermType eq 'Participant' &&
        (
            $PermissionLevel eq 'Participant'
            || $PermissionLevel eq 'Owner'
        )
        )
    {
        $PermissionLevel = 'Participant';
    }

    # Check if the chat is still free
    # also chat is active IF USER IS INVITED TO CHAT
    # here will be processed invitations for customer chats
    # also, here will be processed chats which contain chat invitations for other chats
    # customer must be present in this chat ( at least as inactive participant )
    if (
        ( $Chat{Status} ne 'request' || $Chat{TargetType} ne 'User' )
        && ( $Invitation || $InvitationChatID )
        && $ChatObject->CustomerPresent( ChatID => $Self->{ChatID} )
        )
    {
        # if user is joining a chat with an invitation
        if ($Invitation) {
            my $ChatPermissionLevel = $PermissionLevel;

            my $Success = $ChatObject->ChatParticipantAdd(
                ChatID          => $Self->{ChatID},
                ChatterType     => 'User',
                ChatterID       => $Self->{UserID},
                ChatterName     => $Self->_SenderName(),
                ChatterActive   => 1,
                PermissionLevel => $ChatPermissionLevel,
                Invitation      => 1,                      # note that user came with an invitation
                Monitoring      => 0,                      # do not monitor activity in the chat by default
            );

            # Check number of contributing agents
            my $ContributorCount = $ChatObject->ContributorsCount(
                ChatID => $Self->{ChatID},
            );

            if ( !$Success ) {
                return $LayoutObject->Attachment(
                    ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                    Content     => $LayoutObject->JSONEncode(
                        Data => {
                            Success => 0,
                            Error   => 'InternalError',
                        },
                    ),
                    Type    => 'inline',
                    NoCache => 1,
                );
            }
            else {
                my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                    "%s has joined this chat.",
                    $Self->_SenderName(),
                );
                my $Internal = $ChatPermissionLevel eq 'Observer' ? 1 : 0;

                # add additional explanation
                if ( $ChatPermissionLevel eq 'Observer' ) {
                    $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                        "%s has joined this chat as an observer.",
                        $Self->_SenderName(),
                    );
                }

                $ChatObject->ChatMessageAdd(
                    ChatID          => $Self->{ChatID},
                    ChatterID       => $Self->{UserID},
                    ChatterType     => 'User',
                    SystemGenerated => 1,
                    MessageText     => $JoinMessage,
                    Internal        => $Internal,
                );

                # Delete invitation
                $ChatObject->ChatInviteRemove(
                    UserID => $Self->{UserID},
                    ChatID => $Self->{ChatID},
                );

                # Check chat channel
                $Chat{PermissionLevel} = $ChatPermissionLevel;

                # always allow inviting to a chat
                $Chat{Invite} = 1;

                if ( $ChatPermissionLevel eq 'Participant' || $ChatPermissionLevel eq 'Owner' ) {

                    # if Channel is not default allow channel change
                    if ( $Chat{ChatChannelID} != $DefaultChannelID ) {
                        $Chat{ChangeChannel} = 1;
                    }

                    if ( $ContributorCount > 1 ) {
                        $Chat{LeaveChat} = 1;
                    }
                }
                elsif ( $ChatPermissionLevel eq 'Observer' ) {

                    # allow only leaving a chat
                    $Chat{LeaveChat} = 1;
                }

                # check does user has permissions to switch to observer / participants
                if ( $PermissionLevel eq 'Observer' ) {

                    # check original channel permissions
                    if (
                        $ChannelBasedPermissionLevel eq 'Owner'
                        || $ChannelBasedPermissionLevel eq 'Owner'
                        )
                    {
                        # allow switching to participant
                        $Chat{ParticipantSwitch} = 1;
                    }
                }

                # only if there's more than one contributor
                elsif (
                    ( $PermissionLevel eq 'Participant' || $PermissionLevel eq 'Owner' )
                    && $ContributorCount > 1
                    )
                {
                    $Chat{ObserverSwitch} = 1;

                    # if Channel is not default allow channel change
                    if ( $Chat{ChatChannelID} != $DefaultChannelID ) {
                        $Chat{ChangeChannel} = 1;
                    }
                }

                my %Result = (
                    Success => 1,
                    Chat    => {
                        %Chat,
                        Status => 'active',
                    },
                );

                return $LayoutObject->Attachment(
                    ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                    Content     => $LayoutObject->JSONEncode( Data => \%Result ),
                    Type        => 'inline',
                    NoCache     => 1,
                );
            }
        }

        # if user has invitation to other chat inside this chat
        elsif ($InvitationChatID) {

            # user is always participant in agent to agent chat
            my $ChatPermissionLevel = "Participant";

            my $Success = $ChatObject->ChatParticipantUpdate(
                ChatID        => $Self->{ChatID},
                ChatterID     => $Self->{UserID},
                ChatterType   => "User",
                ChatterActive => 1,
            );

            if ( !$Success ) {
                return $LayoutObject->Attachment(
                    ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                    Content     => $LayoutObject->JSONEncode(
                        Data => {
                            Success => 0,
                            Error   => 'InternalError',
                        },
                    ),
                    Type    => 'inline',
                    NoCache => 1,
                );
            }
            else {
                my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                    "%s has joined this chat.",
                    $Self->_SenderName(),
                );

                $ChatObject->ChatMessageAdd(
                    ChatID          => $Self->{ChatID},
                    ChatterID       => $Self->{UserID},
                    ChatterType     => 'User',
                    SystemGenerated => 1,
                    MessageText     => $JoinMessage,
                    Internal        => 0,
                );

                # Delete invitation
                $ChatObject->ChatInviteRemove(
                    UserID => $Self->{UserID},
                    ChatID => $Self->{ChatID},
                );

                # Check chat channel
                $Chat{PermissionLevel} = $ChatPermissionLevel;

                $Chat{Invite} = 1;

                # only allow if chat channel is not default
                if ( $Chat{ChatChannelID} != $DefaultChannelID ) {
                    $Chat{ChangeChannel} = 1;
                }

                # Check number of contributing agents
                my $ContributorCount = $ChatObject->ContributorsCount(
                    ChatID => $Self->{ChatID},
                );
                if ( $ContributorCount > 1 ) {
                    $Chat{LeaveChat} = 1;
                }

                my %Result = (
                    Success => 1,
                    Chat    => {
                        %Chat,
                        Status => 'active',
                    },
                );

                return $LayoutObject->Attachment(
                    ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                    Content     => $LayoutObject->JSONEncode( Data => \%Result ),
                    Type        => 'inline',
                    NoCache     => 1,
                );
            }
        }

        # otherwise return chat already taken message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode(
                Data => {
                    Success => 0,
                    Error   => 'ChatTaken',
                },
            ),
            Type    => 'inline',
            NoCache => 1,
        );
    }

    # It is a Chat request, check if user has 'Owner' permissions
    if ( $PermissionLevel ne 'Owner' ) {

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode(
                Data => {
                    Success => 0,
                    Error   => 'NoPermission',
                },
            ),
            Type    => 'inline',
            NoCache => 1,
        );
    }

    # Ok, take the chat
    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterType => 'User',
        ChatterID   => $Self->{UserID},
    );

    # See if this was a personal chat request - confirm
    if (%ChatParticipant) {
        $ChatObject->ChatParticipantUpdate(
            ChatID        => $Self->{ChatID},
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 1,
        );
    }

    # Public / Customer chat request, add the user
    else {
        my $Success = $ChatObject->ChatParticipantAdd(
            ChatID          => $Self->{ChatID},
            ChatterType     => 'User',
            ChatterID       => $Self->{UserID},
            ChatterName     => $Self->_SenderName(),
            ChatterActive   => 1,
            PermissionLevel => $PermissionLevel,
            Monitoring      => 0,                      # do not monitor activity in the chat by default
        );

        if ( !$Success ) {
            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $LayoutObject->JSONEncode(
                    Data => {
                        Success => 0,
                        Error   => 'InternalError',
                    },
                ),
                Type    => 'inline',
                NoCache => 1,
            );
        }
    }

    my $Success = $ChatObject->ChatUpdate(
        ChatID => $Self->{ChatID},
        Status => 'active',
    );

    if ( !$Success ) {
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode(
                Data => {
                    Success => 0,
                    Error   => 'InternalError',
                },
            ),
            Type    => 'inline',
            NoCache => 1,
        );
    }

    my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
        "%s has joined this chat.",
        $Self->_SenderName(),
    );

    $ChatObject->ChatMessageAdd(
        ChatID          => $Self->{ChatID},
        ChatterID       => $Self->{UserID},
        ChatterType     => 'User',
        SystemGenerated => 1,
        MessageText     => $JoinMessage,
    );

    # SPECIAL USECASE:
    # ANOTHERUSER STARTED A2C CHAT AND INVITED ADDITIONAL USERS BEFORE CUSTOMER ACCEPTED THE CHAT
    # THIS IS ADDITIONAL USER, CHECK HOW HE CAN JOIN THIS CHAT
    # if this is a chat invitation
    # chat with customer which is still not active
    # ( customer has not joined the chat yet )
    if ($InvitationChatID) {

        $Chat{InvitationChatID} = $InvitationChatID;

        # get invited Chat data:
        my %InvitedChat = $ChatObject->ChatGet(
            ChatID => $Chat{InvitationChatID},
        );

        # set related ticket_ID if it's defined
        if ( $InvitedChat{TicketID} ) {
            $Chat{RelatedTicketID} = $InvitedChat{TicketID};

            # get ticket number from id
            my %RelatedTicket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
                TicketID => $InvitedChat{TicketID},
            );
            $Chat{RelatedTicketNumber} = $RelatedTicket{TicketNumber};
        }

        my $InvitedChatPermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
            UserID        => $Self->{UserID},
            ChatChannelID => $InvitedChat{ChatChannelID},
        );

        # user has only read access
        if ( $InvitedChatPermissionLevel eq 'Observer' ) {
            $Chat{ObserverJoin} = 1;
        }
        elsif ( $InvitedChatPermissionLevel eq 'Participant' || $InvitedChatPermissionLevel eq 'Owner' ) {
            $Chat{ObserverJoin}    = 1;
            $Chat{ParticipantJoin} = 1;
        }
    }

    # check is there Ticket_ID
    if ( $Chat{TicketID} ) {

        # get ticket number from id
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID => $Chat{TicketID},
        );
        $Chat{TicketNumber} = $Ticket{TicketNumber};
    }

    # Check if 'Invite agent' and 'Change' buttons should be displayed
    if ( $PermissionLevel eq 'Participant' || $PermissionLevel eq 'Owner' ) {
        $Chat{Invite} = 1;

        # if Channel is not default allow channel change
        if ( $Chat{ChatChannelID} != $DefaultChannelID ) {
            $Chat{ChangeChannel} = 1;
        }
    }
    else {
        $Chat{Invite}        = 0;
        $Chat{ChangeChannel} = 0;
    }

    $Chat{PermissionLevel} = $PermissionLevel;

    my %Result = (
        Success => 1,
        Chat    => {
            %Chat,
            Status => 'active',
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Result ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatMessageAdd {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterType => 'User',
        ChatterID   => $Self->{UserID},
    );

    if ( !%ChatParticipant ) {

        # send chat closed message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => "ChatClosed" ),
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # Check if user has permission to write
    my $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
        ChatID => $Self->{ChatID},
        UserID => $Self->{UserID},
    );

    if ( $PermissionLevel ne 'Participant' && $PermissionLevel ne 'Owner' ) {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    my $Message = $ParamObject->GetParam( Param => 'Message' );

    if ( !$Message ) {
        return $LayoutObject->FatalError(
            Message => "Need Message.",
        );
    }
    elsif ( length $Message > 3800 ) {
        return $LayoutObject->FatalError(
            Message => "Message too long (max. 3800 characters).",
        );
    }

    my $Success = $ChatObject->ChatMessageAdd(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'User',
        MessageText => $Message,
    );

    my $LastKnownChatMessageID = $ParamObject->GetParam( Param => 'LastKnownChatMessageID' );

    my @ChatMessages = $ChatObject->ChatMessageList(
        ChatID                 => $Self->{ChatID},
        LastKnownChatMessageID => $LastKnownChatMessageID,
        ExcludeCustomer        => 1,
    );

    for my $Message (@ChatMessages) {

        # Localize time and apply time zone, if needed.
        $Message->{CreateTime}
            = $LayoutObject->{LanguageObject}->FormatTimeString( $Message->{CreateTime}, 'DateFormat' );

        # Convert the message text to HTML with link quoting option. Treat original message as plain
        #   text, in order to avoid possible code injection. See bug#12481 for more information.
        $Message->{MessageText} = $LayoutObject->Ascii2Html(
            Text        => $Message->{MessageText},
            LinkFeature => 1,
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \@ChatMessages ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatDiscard {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterType => 'User',
        ChatterID   => $Self->{UserID},
    );

    if ( !%ChatParticipant ) {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    my $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
        ChatID => $Self->{ChatID},
        UserID => $Self->{UserID},
    );

    # If user is observer, he can't discard chat
    if ( $PermissionLevel ne 'Participant' && $PermissionLevel ne 'Owner' ) {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    my $Message = $ParamObject->GetParam( Param => 'Message' );

    # check is customer actively present
    # it means customer has accepted this chat and not left it!
    my $CustomerPresent = $ChatObject->CustomerPresent(
        ChatID => $Self->{ChatID},
        Active => 1,
    );

    my $Success;

    # if there is no customer present in the chat
    # just remove the chat
    if ( !$CustomerPresent ) {
        $Success = $ChatObject->ChatDelete(
            ChatID => $Self->{ChatID},
        );

        # remove possible chat invitations from this chat
        $Success = $ChatObject->ChatInviteRemove(
            InvitationChatID => $Self->{ChatID},
        );
    }

    # otherwise set chat status to closed and inform other agents
    else {
        $Success = $ChatObject->ChatUpdate(
            ChatID     => $Self->{ChatID},
            Status     => 'closed',
            Deprecated => 1,
        );

        # get user data
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $Self->{UserID},
        );

        my $LeaveMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has left the chat.",
            $User{UserFullname},
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            MessageText     => $LeaveMessage,
            SystemGenerated => 1,
        );

        # time after chat will be removed
        my $ChatTTL = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatTTL');

        my $ChatClosedMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "This chat has been closed and will be removed in %s hours.",
            $ChatTTL,
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            MessageText     => $ChatClosedMessage,
            SystemGenerated => 1,
        );

        # remove all AGENT participants from chat
        my @ParticipantsList = $ChatObject->ChatParticipantList(
            ChatID => $Self->{ChatID},
        );
        CHATPARTICIPANT:
        for my $ChatParticipant (@ParticipantsList) {

            # skip it this participant is not agent
            next CHATPARTICIPANT if $ChatParticipant->{ChatterType} ne 'User';

            # remove this participants from the chat
            $Success = $ChatObject->ChatParticipantRemove(
                ChatID      => $Self->{ChatID},
                ChatterID   => $ChatParticipant->{ChatterID},
                ChatterType => 'User',
            );
        }

    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \$Success ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatGetOpenRequests {
    my ( $Self, %Param ) = @_;

    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    my $AvailableForChat = 0;
    if ( defined $Preferences{ChatAvailability} ) {
        $AvailableForChat = $Preferences{ChatAvailability};
    }

    # number of chats for which user is still not notified
    my $NotifyCustomerChats = 0;
    my $NotifyPublicChats   = 0;
    my $NotifyPersonalChats = 0;
    my @ChatsCustomer;
    my @ChatsPersonal;
    my @ChatsIntivations;
    my @ChatsPublic;

    my @ExternalChatChannels;

    # flag showing are chat channels enabled on Customer interface
    my $CustomerChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get(
        'ChatEngine::CustomerInterface::AllowChatChannels'
    );

    # check are public chat channels enabled
    # if they are, pass ExternalChatChannels for ChannellIDs when searching for public requests
    # otherwise all channels will be monitored
    my $PublicChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get(
        'ChatEngine::PublicInterface::AllowChatChannels'
    );

    # if chat channels are enabled on public or customer interface
    # get user's chat channels
    # otherwise just work with default chat channel
    if ( $CustomerChannelsEnabled || $PublicChannelsEnabled ) {
        @ExternalChatChannels = $ChatChannelObject->CustomChatChannelsGet(
            Key    => 'ExternalChannels',
            UserID => $Self->{UserID},
        );

        # check for the each channel does user has Owner or Participant permissions
        # if not, remove them
        for ( my $i = 0; $i < scalar @ExternalChatChannels; $i++ ) {
            my $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                UserID        => $Self->{UserID},
                ChatChannelID => $ExternalChatChannels[$i],
            );

            if ( !$PermissionLevel || $PermissionLevel ne 'Owner' ) {
                delete $ExternalChatChannels[$i];
            }
        }
    }

    # get default chat channel and put it in array
    # if chat channels are disabled on Customer or Agent interface => all agents are monitoring default chat channel
    my $DefaultChannelID    = $ChatChannelObject->DefaultChatChannelGet();
    my @DefaultChannelArray = ($DefaultChannelID);

    # if user is available for C2A and Public chat
    if ( $AvailableForChat > 1 ) {
        @ChatsCustomer = $ChatObject->ChatList(
            Status        => 'request',
            TargetType    => 'User',
            RequesterType => 'Customer',
            ChannelIDs    => $CustomerChannelsEnabled ? \@ExternalChatChannels : \@DefaultChannelArray,
        );

        my $PublicChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get(
            'ChatEngine::PublicInterface::AllowChatChannels'
        );

        @ChatsPublic = $ChatObject->ChatList(
            Status        => 'request',
            TargetType    => 'User',
            RequesterType => 'Public',
            ChannelIDs    => $PublicChannelsEnabled ? \@ExternalChatChannels : \@DefaultChannelArray,
        );
    }

    # if user is available for A2A chat
    if ( $AvailableForChat > 0 ) {
        @ChatsPersonal = $ChatObject->ChatList(
            Status        => "request",
            RequesterType => 'User',
            TargetType    => 'User',
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 0,
        );

        # get invitations for agent to agent chat
        @ChatsIntivations = $ChatObject->ChatList(
            Status        => "active",
            RequesterType => 'User',
            TargetType    => 'User',
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 0,
        );
    }

    # merge all personal chat requests arrays
    my @PersonalChats = ( @ChatsPersonal, @ChatsIntivations );

    for my $Chat (@ChatsCustomer) {
        my @Flags = $ChatObject->ChatFlagGet(
            ChatID => $Chat->{ChatID},
            UserID => $Self->{UserID},
            Key    => "NotificationNewChatSeen",
        );

        # if there are chats for which user is not notified
        if (
            !@Flags
            ||
            $Flags[0]->{Value} != 1
            )
        {
            $NotifyCustomerChats++;

            # set flag seen for this chat
            # it will prevent showing notifications for this chat again
            my $Success = $ChatObject->ChatFlagSet(
                ChatID => $Chat->{ChatID},
                Key    => 'NotificationNewChatSeen',
                Value  => 1,
                UserID => $Self->{UserID},
            );

        }
    }

    for my $Chat (@ChatsPublic) {
        my @Flags = $ChatObject->ChatFlagGet(
            ChatID => $Chat->{ChatID},
            UserID => $Self->{UserID},
            Key    => "NotificationNewChatSeen",
        );

        if (
            !@Flags
            ||
            $Flags[0]->{Value} != 1
            )
        {

            $NotifyPublicChats++;

            # set flag seen for this chat
            # it will prevent showing notifications for this chat again
            my $Success = $ChatObject->ChatFlagSet(
                ChatID => $Chat->{ChatID},
                Key    => 'NotificationNewChatSeen',
                Value  => 1,
                UserID => $Self->{UserID},
            );

        }
    }

    for my $Chat (@PersonalChats) {
        my @Flags = $ChatObject->ChatFlagGet(
            ChatID => $Chat->{ChatID},
            UserID => $Self->{UserID},
            Key    => "NotificationNewChatSeen",
        );

        if (
            !@Flags
            ||
            $Flags[0]->{Value} != 1
            )
        {

            $NotifyPersonalChats++;

            # set flag seen for this chat
            # it will prevent showing notifications for this chat again
            my $Success = $ChatObject->ChatFlagSet(
                ChatID => $Chat->{ChatID},
                Key    => 'NotificationNewChatSeen',
                Value  => 1,
                UserID => $Self->{UserID},
            );
        }
    }

    # not search within open chats
    # flags are also used for existing chats
    my @ExisitingChatFlags = $ChatObject->ChatFlagGet(
        UserID   => $Self->{UserID},
        ValueNot => 1,
        Key      => "NotificationChatUpdateSeen",
    );

    # set flags to seen
    for my $ChatFlag (@ExisitingChatFlags) {
        my $Success = $ChatObject->ChatFlagSet(
            ChatID => $ChatFlag->{ChatID},
            Key    => $ChatFlag->{Key},
            Value  => 1,
            UserID => $Self->{UserID},
        );
    }

    my $VideoChatAgentsGroup = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::VideoChatAgents');

    if ( $LayoutObject->{"UserIsGroup[$VideoChatAgentsGroup]"} ) {

        # Save WebRTC capabilities of user's web browser.
        $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
            Key    => 'VideoChatHasWebRTC',
            Value  => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'HasWebRTC' ) // '0',
            UserID => $Self->{UserID},
        );
    }

    # Get video chat invites.
    my $VideoChatInvite;
    my $Invites = $Kernel::OM->Get('Kernel::System::VideoChat')->ReceiveSignals(
        TargetID   => $Self->{UserID},
        TargetType => 'User',
        SignalKey  => 'VideoChatInvite',
    );

    if ( scalar @{ $Invites // [] } > 0 ) {

        INVITE:
        for my $Invite ( @{$Invites} ) {

            # Compose dialog text.
            my $DialogText;
            if ( $Invite->{RequesterType} eq 'Customer' ) {
                my $CustomerName = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
                    UserLogin => $Invite->{RequesterID},
                );
                $DialogText = $LayoutObject->{LanguageObject}->Translate(
                    $Invite->{SignalValue} eq '4'
                    ? "Customer <b>%s</b> invited you to an audio call."
                    : "Customer <b>%s</b> invited you to a video call.",
                    $CustomerName,
                );
            }
            elsif ( $Invite->{RequesterType} eq 'User' ) {
                my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                    UserID => $Invite->{RequesterID},
                );
                $DialogText = $LayoutObject->{LanguageObject}->Translate(
                    $Invite->{SignalValue} eq '4'
                    ? "User <b>%s</b> invited you to an audio call."
                    : "User <b>%s</b> invited you to a video call.",
                    $User{UserFullname},
                );
            }

            $DialogText .= '<br>'
                . '<br>'
                . $LayoutObject->{LanguageObject}->Translate(
                'If you accept, any active call you may have will be closed.',
                );

            $VideoChatInvite = {
                %{$Invite},
                DialogText => $DialogText,
            };

            # Process only first invite.
            last INVITE;
        }
    }

    my $Sum = scalar @ChatsCustomer + scalar @PersonalChats + scalar @ChatsPublic;

    my $Return = {
        Count               => $Sum,
        NotifyCustomerChats => $NotifyCustomerChats,
        NotifyPersonalChats => $NotifyPersonalChats,
        NotifyPublicChats   => $NotifyPublicChats,
        VideoChatInvite     => $VideoChatInvite,
        ExistingChats       => scalar @ExisitingChatFlags,
    };

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Return ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub GetInviteAgentList {
    my ( $Self, %Param ) = @_;

    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    # Check if there are actually chat agents online.
    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    # check is this chat A2A
    # if it is, than also show users which are only internally available
    my $ChatA2A = $Kernel::OM->Get('Kernel::System::Chat')->IsChatAgentToAgent( ChatID => $Self->{ChatID} );

    # get the chat
    my %Chat = $Kernel::OM->Get('Kernel::System::Chat')->ChatGet(
        ChatID => $Self->{ChatID},
    );

    if ( !%Chat ) {
        return $Kernel::OM->Get('Kernel::Output::HTML::Layout')->FatalError(
            Message => "Wrong Chat",
        );
    }

    my %SessionData = $Kernel::OM->Get('Kernel::System::Chat')->OnlineUserList(
        UserType => 'User',
        Group    => $ChatReceivingAgentsGroup,
        External => $ChatA2A ? 0 : 1,            # pass 0 if this is A2A chat, otherwise 1
    );

    my %OnlineAgents;
    for my $Session ( sort keys %SessionData ) {
        my $UserID      = $SessionData{$Session}->{UserID};
        my %Participant = $Kernel::OM->Get('Kernel::System::Chat')->ChatParticipantCheck(
            ChatID      => $Self->{ChatID},
            ChatterID   => $UserID,
            ChatterType => 'User',
        );

        if ( !%Participant ) {

            # Check if already invited
            my $ExistingInvite = $Kernel::OM->Get('Kernel::System::Chat')->ChatInvitesGet(
                UserID => $UserID,
                ChatID => $Self->{ChatID},
            );

            if ( !$ExistingInvite ) {

                # get default channel id
                my $DefaultChannelID = $ChatChannelObject->DefaultChatChannelGet();

                # if channel is not default, check permissions
                if ( $Chat{ChatChannelID} ne $DefaultChannelID ) {

                    # check permission level
                    my $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                        UserID        => $UserID,
                        ChatChannelID => $Chat{ChatChannelID},
                    );

                    # if user has any permission level for the chat
                    if ($PermissionLevel) {
                        $OnlineAgents{$UserID} = $SessionData{$Session}->{UserFullname};
                    }
                }
                else {
                    $OnlineAgents{$UserID} = $SessionData{$Session}->{UserFullname};
                }
            }
        }
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%OnlineAgents ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub InviteAgent {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Get required parameters
    my $TargetUserID    = $ParamObject->GetParam( Param => 'UserID' );
    my $PermissionLevel = $ParamObject->GetParam( Param => 'PermissionLevel' );

    # get default chat channel id
    my $DefaultChannelID = $Kernel::OM->Get('Kernel::System::ChatChannel')->DefaultChatChannelGet();

    # Check needed stuff
    if ( !$TargetUserID ) {
        return $LayoutObject->FatalError(
            Message => "Need TargetUserID!",
        );
    }

    my $TargetType = 'User';
    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToAgent') ) {
        return $LayoutObject->FatalError(
            Message => "Agent to agent chat is disabled.",
        );
    }

    # get original chat (the one where user is invited to)
    my %OriginalChat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    # check does this chat exist
    if ( !%OriginalChat ) {
        return $LayoutObject->FatalError(
            Message => "This chat is not existing any more.",
        );
    }

    # Check if already invited
    my $ExistingInvite = $ChatObject->ChatInvitesGet(
        UserID => $TargetUserID,
        ChatID => $Self->{ChatID},
    );

    if ($ExistingInvite) {
        return $LayoutObject->FatalError(
            Message => "Already invited to this chat.",
        );
    }

    # get the list of all chat participants ( search for original chat )
    my @ChatParticipants = $ChatObject->ChatParticipantList(
        ChatID => $Self->{ChatID},
    );

    # check is there Customer user in this chat
    my $CustomerParticipating = $ChatObject->CustomerPresent(
        ChatID => $Self->{ChatID},
    );

    my $StartMessage = $LayoutObject->{LanguageObject}->Translate(
        "New request for joining a chat",
    );

    my $SenderName = $Self->_SenderName();

    # get invited agent data:
    my %InvitedAgent = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $TargetUserID,
    );

    # if only agents are in this chat, directly call agent
    if ( !$CustomerParticipating ) {

        # add this user as inactive participant
        # immediately add to the chat
        $ChatObject->ChatParticipantAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $TargetUserID,
            ChatterType     => $TargetType,
            ChatterName     => $InvitedAgent{UserFullname},
            ChatterActive   => 0,
            PermissionLevel => 'Participant',
            Monitoring      => 0,                             # do not monitor activity in the chat by default
        );
    }

    # otherwise create a new chat between inviter and invited agent
    else {
        my $ChatID = $ChatObject->ChatAdd(
            Status        => 'request',
            RequesterID   => $Self->{UserID},
            RequesterName => $SenderName,
            RequesterType => 'User',
            TargetType    => $TargetType,
            ChannelID     => $DefaultChannelID,               # put in default chat channel
            TicketID      => $OriginalChat{TicketID},
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $ChatID,
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            ChatterName     => $SenderName,
            ChatterActive   => 1,
            PermissionLevel => 'Owner',
            Monitoring      => 0,                             # do not monitor activity in the chat by default
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $ChatID,
            ChatterID       => $TargetUserID,
            ChatterType     => $TargetType,
            ChatterName     => $InvitedAgent{UserFullname},
            ChatterActive   => 0,
            PermissionLevel => 'Owner',
            Monitoring      => 0,                             # do not monitor activity in the chat by default
        );

        my $Success = $ChatObject->ChatMessageAdd(
            ChatID      => $ChatID,
            ChatterID   => $Self->{UserID},
            ChatterType => 'User',
            MessageText => $StartMessage,
        );

        my $InviteSuccess = $ChatObject->ChatInvite(
            ChatID           => $Self->{ChatID},
            InviteUserID     => $TargetUserID,
            PermissionLevel  => $PermissionLevel,
            UserID           => $Self->{UserID},
            InvitationChatID => $ChatID,
        );

        if ($InviteSuccess) {
            $ChatObject->ChatMessageAdd(
                ChatID      => $Self->{ChatID},
                ChatterID   => $Self->{UserID},
                ChatterType => 'User',
                MessageText =>
                    $LayoutObject->{LanguageObject}->Translate( "Agent invited %s.", $InvitedAgent{UserFullname} ),
                SystemGenerated => 1,
                Internal        => 1,
            );
        }

        $Self->_ChatOrderUpdate(
            ChatID => $ChatID,
        );
    }

    # Display chat manager
    return $LayoutObject->Redirect(
        OP => "Action=AgentChat",
    );
}

sub PermissionLevel {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get default chat channel id
    my $DefaultChannelID = $Kernel::OM->Get('Kernel::System::ChatChannel')->DefaultChatChannelGet();

    # Get required parameters
    my $UserID = $ParamObject->GetParam( Param => 'UserID' );

    # Check needed stuff
    if ( !$UserID ) {
        return $LayoutObject->FatalError(
            Message => "Need UserID!",
        );
    }
    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    # Get chat details
    my %Chat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    my $Permissions;

    # if this is default channel, give Owner permissions
    if ( $Chat{ChatChannelID} == $DefaultChannelID ) {
        $Permissions = 'Owner';
    }
    else {
        $Permissions = $ChatChannelObject->ChatChannelPermissionGet(
            UserID        => $UserID,
            ChatChannelID => $Chat{ChatChannelID},
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Permissions ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub Channels {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Get all valid channels, where current agent has at least 'ho' permissions
    my @ChatChannels = $Self->_PossibleChatChannels();

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \@ChatChannels ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChangeChannel {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    # Get channelID
    my $ChatChannelID = $ParamObject->GetParam( Param => 'ChatChannelID' );

    # check should change be silent
    my $Silent = $ParamObject->GetParam( Param => 'Silent' );

    # Check needed stuff
    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }
    if ( !$ChatChannelID ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    # Get all valid channels, where current agent has at least 'Participant' permissions
    my @ChatChannels = $Self->_PossibleChatChannels();

    # Check if current user is allowed to change chat to this channel
    if ( grep { $_->{ChatChannelID} == $ChatChannelID } @ChatChannels ) {

        # Change chat channel
        $ChatObject->ChatChannelUpdate(
            UserID        => $Self->{UserID},
            ChatID        => $Self->{ChatID},
            ChatChannelID => $ChatChannelID,
            Silent        => $Silent,
        );

        if ( !$Silent ) {

            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                UserID => $Self->{UserID},
            );

            my $ChannelName = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChannelLookup(
                ChannelID => $ChatChannelID,
            );

            my $Success = $ChatObject->ChatMessageAdd(
                ChatID      => $Self->{ChatID},
                ChatterID   => $Self->{UserID},
                ChatterType => 'User',
                MessageText =>
                    $LayoutObject->{LanguageObject}
                    ->Translate( "%s changed chat channel to %s.", $User{UserFullname}, $ChannelName ),
                SystemGenerated => 1,
            );
        }

        # Refresh page
        return $LayoutObject->Redirect(
            OP => "Action=AgentChat",
        );
    }
    else {
        # Display error message
        return $LayoutObject->Redirect(
            OP => "Action=AgentChat;Msg=NoPermission",
        );
    }
}

sub LeaveChat {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    # Check needed stuff
    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    # Get chat permissions
    my $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
        ChatID => $Self->{ChatID},
        UserID => $Self->{UserID},
    );

    # Check if there are enough contributing participant
    my $ContributorCount = $ChatObject->ContributorsCount(
        ChatID => $Self->{ChatID},
    );

    if ( $ContributorCount < 2 && $PermissionLevel ne 'Observer' ) {
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => "NOK" ),
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    my %User = $UserObject->GetUserData(
        UserID => $Self->{UserID},
    );

    # decide is this message internal
    my $Internal = $PermissionLevel eq 'Observer' ? 1 : 0;

    my $LeaveMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
        "%s has left the chat.",
        $User{UserFullname},
    );
    my $Success = $ChatObject->ChatMessageAdd(
        ChatID          => $Self->{ChatID},
        ChatterID       => $Self->{UserID},
        ChatterType     => 'User',
        MessageText     => $LeaveMessage,
        SystemGenerated => 1,
        Internal        => $Internal,
    );

    $Success = $ChatObject->ChatParticipantRemove(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'User',
    );

    # if this is the last chat participant, remove chat
    if ( $ContributorCount == 0 ) {
        $Success = $ChatObject->ChatDelete(
            ChatID => $Self->{ChatID},
        );
    }

    # Return OK
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => "OK" ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatMonitorSwitch {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    # get NextState
    my $NextState = $ParamObject->GetParam( Param => 'NextState' );

    # Check needed stuff
    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    # check is NextState numberic and 0,1,2
    if (
        $NextState != 0
        && $NextState != 1
        && $NextState != 2
        )
    {
        return $LayoutObject->FatalError(
            Message => "Wrong NextState!",
        );
    }

    my $Success = $ChatObject->ChatParticipantUpdate(
        ChatID        => $Self->{ChatID},
        ChatterID     => $Self->{UserID},
        ChatterType   => "User",
        ChatterActive => 1,
        Monitoring    => $NextState,
    );

    # Return OK
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => "OK" ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ChatRoleSwitch {
    my ( $Self, %Param ) = @_;

    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    # get default chat channel id
    my $DefaultChannelID = $ChatChannelObject->DefaultChatChannelGet();

    # get new role for switching
    my $Role = $ParamObject->GetParam( Param => 'Role' );

    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }
    my %Chat = $ChatObject->ChatGet( ChatID => $Self->{ChatID} );

    my $PermissionLevel;

    if ( $Chat{ChatChannelID} == $DefaultChannelID ) {
        $PermissionLevel = 'Owner';
    }
    else {
        $Chat{Channel} = $ChatChannelObject->ChannelLookup(
            ChannelID => $Chat{ChatChannelID},
        );

        $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
            UserID        => $Self->{UserID},
            ChatChannelID => $Chat{ChatChannelID},
        );
    }

    # check is user participant of this chat
    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterType => 'User',
        ChatterID   => $Self->{UserID},
    );

    # if user is not participant of this chat, raise an error
    if ( !%ChatParticipant ) {

        # show error message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode(
                Data => {
                    Success => 0,
                    Error   => 'NoPermission',
                },
            ),
            Type    => 'inline',
            NoCache => 1,
        );
    }

    # check wanted permission level
    if (
        $Role eq 'Participant'
        && (
            $PermissionLevel eq 'Owner'
            || $PermissionLevel eq 'Participant'
        )
        )
    {
        # switch to observer
        my $Success = $ChatObject->AgentPermissionsUpdate(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterActive   => 1,
            PermissionLevel => 'Participant',
        );

        # show join message for the customer
        my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has joined this chat.",
            $Self->_SenderName(),
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            SystemGenerated => 1,
            MessageText     => $JoinMessage,
        );

        # show join message for the agent
        $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has switched to participant mode.",
            $Self->_SenderName(),
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            SystemGenerated => 1,
            Internal        => 1,
            MessageText     => $JoinMessage,
        );

        return $LayoutObject->Redirect(
            OP => "Action=AgentChat",
        );
    }
    elsif ( $Role eq 'Observer' ) {

        # switch to observer
        my $Success = $ChatObject->AgentPermissionsUpdate(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterActive   => 1,
            PermissionLevel => 'Observer',
        );

        # show leave message for the customer
        my $LeaveMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has left the chat.",
            $Self->_SenderName(),
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            SystemGenerated => 1,
            MessageText     => $LeaveMessage,
        );

        # show hide message for the agent
        $LeaveMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has switched to observer mode.",
            $Self->_SenderName(),
        );

        $Success = $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            SystemGenerated => 1,
            Internal        => 1,
            MessageText     => $LeaveMessage,
        );

        return $LayoutObject->Redirect(
            OP => "Action=AgentChat",
        );
    }
    else {
        # show error message
        return $LayoutObject->FatalError(
            Message => "No Permissions!",
        );
    }

    my %Result = (
        Success => 1,
        Chat    => {
            %Chat,
            Status => 'active',
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Result ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub UpdateChatOrder {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    # Get order
    my @Order = $ParamObject->GetArray(
        Param => 'ChatID[]',
    );

    # Save order
    $UserObject->SetPreferences(
        Key    => 'ChatOrder',
        Value  => join( ',', @Order ),
        UserID => $Self->{UserID},
    );

    # Return response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => 1 ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub DeclineRequest {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $Self->{UserID},
    );

    my $Result = $ChatObject->ChatDecline(
        UserID => $Self->{UserID},
        ChatID => $Self->{ChatID},
        Message =>
            $LayoutObject->{LanguageObject}->Translate( "%s has rejected the chat request.", $User{UserFullname} ),
    );

    # Return response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Result ),
        Type        => 'inline',
        NoCache     => 1,
    );

}

sub VideoChatRequest {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam;
    for my $Param (qw(UserType UserID NoVideo)) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );

        if ( !$GetParam{$Param} && $Param ne 'NoVideo' ) {
            return $LayoutObject->FatalError(
                Message => Translatable('Need') . ' ' . $Param . '.',
            );
        }
    }

    my $TargetType = 'User';
    if ( $GetParam{UserType} eq 'Customer' ) {
        $TargetType = 'Customer';
    }

    my %Data;
    my $Error = 0;

    # Check if agent-to-agent chat is enabled.
    if (
        $TargetType eq 'User'
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToAgent')
        )
    {
        $Error = 1;
    }

    # Check if agent-to-customer chat is enabled.
    if (
        $TargetType eq 'Customer'
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::AgentToCustomer')
        )
    {
        $Error = 1;
    }

    # Create an ad-hoc chat between two parties with a generic message. This is necessary because
    #   video call must be tied to an existing ChatID.
    if ( !$Error ) {
        my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');

        my $SenderName = $Self->_SenderName();
        my $TargetName;
        if ( $TargetType eq 'Customer' ) {
            $TargetName = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
                UserLogin => $GetParam{UserID},
            );
        }
        elsif ( $TargetType eq 'User' ) {
            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                UserID => $GetParam{UserID},
            );
            $TargetName = $User{UserFullname};
        }

        $Data{ChatID} = $ChatObject->ChatAdd(
            Status        => 'active',
            RequesterID   => $Self->{UserID},
            RequesterName => $SenderName,
            RequesterType => 'User',
            TargetType    => $TargetType,
            ChannelID     => $Kernel::OM->Get('Kernel::System::ChatChannel')->DefaultChatChannelGet(),
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $Data{ChatID},
            ChatterID       => $Self->{UserID},
            ChatterType     => 'User',
            ChatterName     => $SenderName,
            ChatterActive   => 1,
            PermissionLevel => 'Owner',
            Monitoring      => 0,
        );

        $ChatObject->ChatParticipantAdd(
            ChatID          => $Data{ChatID},
            ChatterID       => $GetParam{UserID},
            ChatterType     => $TargetType,
            ChatterName     => $TargetName,
            ChatterActive   => 1,
            PermissionLevel => 'Owner',
            Monitoring      => 0,
        );

        $ChatObject->ChatMessageAdd(
            ChatID      => $Data{ChatID},
            ChatterID   => $Self->{UserID},
            ChatterType => 'User',
            MessageText => $LayoutObject->{LanguageObject}->Translate(
                $GetParam{NoVideo}
                ? "%s has invited %s to an audio call"
                : "%s has invited %s to a video call",
                $SenderName,
                $TargetName
            ),
            SystemGenerated => 1,
        );

        $Self->_ChatOrderUpdate(
            ChatID => $Data{ChatID},
        );
    }

    # Return ChatID to the requester, so they can open the popup.
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Data ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub SetAvailability {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    my $Availability = $ParamObject->GetParam( Param => 'Availability' );

    # Update users availability
    $UserObject->SetPreferences(
        Key    => 'ChatAvailability',
        Value  => $Availability,
        UserID => $Self->{UserID},
    );

    my $Url = "";

    $ENV{HTTP_REFERER} =~ /.*?\?(.*)/;
    $Url = $1;

    # Return to referrer
    return $LayoutObject->Redirect(
        OP => $Url,
    );
}

sub GetAvailability {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    # Get user ID and type from parameters. If not found, use current user.
    my $UserID   = $ParamObject->GetParam( Param => 'UserID' )   || $Self->{UserID};
    my $UserType = $ParamObject->GetParam( Param => 'UserType' ) || 'User';

    my $ChatAvailability = 0;

    if ( $UserType eq 'User' ) {
        $ChatAvailability = $ChatObject->AgentAvailabilityGet(
            UserID => $UserID,
        );
    }
    else {
        $ChatAvailability = $ChatObject->CustomerAvailabilityGet(
            UserID => $UserID,
        );
    }

    # Return response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $ChatAvailability ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub UpdateOnlineUsers {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    my @Result;

    # Get all agent sessions
    my %OnlineSessions = $ChatObject->OnlineUserList(
        UserType      => 'User',
        Group         => $ChatReceivingAgentsGroup,
        External      => 0,
        IgnoreSuspend => 1,
    );

    SESSION:
    for my $Session ( sort keys %OnlineSessions ) {
        $OnlineSessions{$Session}{ChatAvailability} = $ChatObject->AgentAvailabilityGet(
            UserID   => $OnlineSessions{$Session}{UserID},
            External => 0,
        );

        if ( $OnlineSessions{$Session}{UserID} == $Self->{UserID} ) {
            $OnlineSessions{$Session}{CurrentUser} = 1;
        }

        # Check if user has other sessions
        my $Index = grep { $_->{UserID} == $OnlineSessions{$Session}{UserID} } @Result;

        if ($Index) {
            if ( $OnlineSessions{$Session}{ChatAvailability} > $Result[$Index]->{ChatAvailability} ) {

               # Note: It seams that this line is not working properly in some usecase (couldn't find out what is wrong)
                $Result[$Index]->{ChatAvailability} = $OnlineSessions{$Session}{ChatAvailability};
            }

            next SESSION;
        }

        push @Result, $OnlineSessions{$Session};
    }

    # Return response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \@Result ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _PossibleChatChannels {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');

    # check needed parameters
    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID!",
        );
    }

    # Get chat details
    my %Chat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    # Get all valid channels, where current agent has at least 'Participant' permissions
    my %AvailableChannels = $ChatChannelObject->ChatPermissionChannelGet(
        UserID     => $Self->{UserID},
        Permission => [ 'chat_participant', 'chat_owner' ],
    );

    # Remove current chat channel
    delete $AvailableChannels{ $Chat{ChatChannelID} // '' };

    my @Result;
    for my $ChatChannelID ( sort keys %AvailableChannels ) {
        push @Result, { $ChatChannelObject->ChatChannelGet( ChatChannelID => $ChatChannelID ) };
    }

    return @Result;
}

sub _SenderName {
    my ( $Self, %Param ) = @_;

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my %UserData   = $UserObject->GetUserData(
        UserID => $Self->{UserID},
    );

    my $RequesterName = $UserData{UserFullname};
    $RequesterName ||= $Self->{UserID};

    return $RequesterName;
}

sub _ChatOrderUpdate {
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

    # Get current user preferences
    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    my @ChatOrder = split( ',', $Preferences{ChatOrder} );
    if ( $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatOrder') ) {

        # Append
        push @ChatOrder, $Param{ChatID};
    }
    else {
        # Prepend
        unshift @ChatOrder, $Param{ChatID};
    }

    # Save chat order
    $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
        Key    => 'ChatOrder',
        Value  => join( ',', @ChatOrder ),
        UserID => $Self->{UserID},
    );
}

1;
