# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::PublicChat;

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
    $Self->{IsIframe} = ( $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'IsIframe' ) ) ? 1 : 0;

    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
        return $Self->ErrorResponse(
            Message => "Chat is not active.",
        );
    }

    if ( !$Self->{Subaction} || $Self->{Subaction} eq 'CreateChatRequest' ) {
        if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatDirection::PublicToAgent') ) {
            return $Self->ErrorResponse(
                Message => "Chat is not active.",
            );
        }
        return $Self->CreateChatRequest();
    }

    if ( $Self->{Subaction} eq 'ChatCompleted' ) {
        return $Self->ChatCompleted();
    }
    elsif ( $Self->{Subaction} eq 'ChatLeave' ) {
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

    return $Self->ErrorResponse(
        Message => "Unkown Subaction.",
    );
}

sub CreateChatRequest {
    my ( $Self, %Param ) = @_;

    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Ok, now check if there are actually chat agents online.
    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    my @OnlineUsers = $ChatObject->OnlineUserList(
        UserType => 'User',
        Group    => $ChatReceivingAgentsGroup,
    );

    # check are Chat Channels enabled on Customer interface
    my $ChatChannelsEnabled = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PublicInterface::AllowChatChannels');

    if ( !$ChatReceivingAgentsGroup || !@OnlineUsers ) {
        my $Output = $LayoutObject->CustomerHeader(
            Type => ( $Self->{IsIframe} ) ? 'Small' : '',
        );

        $LayoutObject->Block(
            Name => 'NoChatUsersAvailable',
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => "PublicChat",
        );
        $Output .= $LayoutObject->CustomerFooter(
            Type => ( $Self->{IsIframe} ) ? 'Small' : '',
        );

        return $Output;
    }

    my %Errors;

    if ( $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'CreateAction' ) ) {

        # Set chat channel
        my $ChannelID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ChannelID' );

        # if still there is no chat channel, use default chat channel
        # for this chat channels must not be enabled
        if ( !$ChannelID && !$ChatChannelsEnabled ) {
            $ChannelID = $ChatChannelObject->DefaultChatChannelGet();
        }

        my $Name    = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Name' );
        my $Message = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Message' );
        my $RandomID = $Kernel::OM->Get('Kernel::System::Main')->GenerateRandomString(
            Length => 32,
        );

        if ( !$Name ) {
            $Errors{NameError} = 'ServerError';
        }

        if ( !$Message ) {
            $Errors{MessageError} = 'ServerError';
        }
        elsif ( length $Message > 3800 ) {
            $Errors{MessageError} = 'ServerError';
        }

        my $RequesterName = $Name;

        if ( !%Errors ) {

            $Self->{ChatID} = $ChatObject->ChatAdd(
                Status        => 'request',
                RequesterID   => $Self->{UserID},
                RequesterName => $RequesterName,
                RequesterType => 'Public',
                TargetType    => 'User',
                ChannelID     => $ChannelID,
            );

            my $GrantSuccess = $ChatObject->ChatParticipantAdd(
                ChatID        => $Self->{ChatID},
                ChatterID     => $RandomID,
                ChatterType   => 'Public',
                ChatterName   => $RequesterName,
                ChatterActive => 1,
            );

            my $JoinMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                "%s has joined this chat.",
                $RequesterName,
            );

            $ChatObject->ChatMessageAdd(
                ChatID          => $Self->{ChatID},
                ChatterID       => $RandomID,
                ChatterType     => 'Public',
                SystemGenerated => 1,
                MessageText     => $JoinMessage,
            );

            $ChatObject->ChatMessageAdd(
                ChatID      => $Self->{ChatID},
                ChatterID   => $RandomID,
                ChatterType => 'Public',
                MessageText => $Message,
            );

            return $LayoutObject->Redirect(
                OP =>
                    "Action=$Self->{Action};Subaction=ChatScreen;ChatID=$Self->{ChatID};IsIframe=$Self->{IsIframe};RandomID=$RandomID",
            );
        }
    }

    my $Output = $LayoutObject->CustomerHeader(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    # Get channels data
    my @ChatChannelsData;

    if ($ChatChannelsEnabled) {
        @ChatChannelsData = $ChatChannelObject->ChatChannelsGet(
            Valid => 1,
        );
    }

    my $AvailabilityCheck
        = $Kernel::OM->Get('Kernel::Config')->Get("ChatEngine::PublicInterface::AvailabilityCheck") || 0;
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

    my $Channel;

    # show channels block only if chat channels are enabled
    if ($ChatChannelsEnabled) {
        $Channel = $LayoutObject->BuildSelection(
            Data         => \@ChatChannelsData,
            Name         => 'ChannelID',
            PossibleNone => 1,
            Class        => 'Validate_Required',
        );
    }

    $LayoutObject->Block(
        Name => 'CreateChatRequest',
        Data => {
            %Errors,
            IsIframe => $Self->{IsIframe},
            Channel  => $Channel,
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
        $LayoutObject->Block(
            Name => 'ChatNotAvailable',
            Data => {
            },
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => "PublicChat",
    );
    $Output .= $LayoutObject->CustomerFooter(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    return $Output;
}

sub ChatScreen {
    my ( $Self, %Param ) = @_;

    # get random id
    $Param{RandomID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'RandomID' ) || '';

    if ( !$Param{RandomID} ) {
        return $Self->ErrorResponse(
            Message => "Got no valid ID.",
        );
    }

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get chat data
    my %Chat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    if ( !%Chat ) {
        return $Self->ErrorResponse(
            Message => "Got no valid ChatID.",
        );
    }

    # General access was checked before, now we want to know if we re-enter the chat.
    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Param{RandomID},
        ChatterType => 'Public',
    );

    if ( !$ChatParticipant{ChatterActive} ) {

        my $Message = $Kernel::OM->Get('Kernel::Language')->Translate(
            "%s has joined this chat.",
            $Chat{RequesterName},
        );

        $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $Param{RandomID},
            ChatterType     => 'Public',
            SystemGenerated => 1,
            MessageText     => $Message,
        );

        $ChatObject->ChatParticipantUpdate(
            ChatID        => $Self->{ChatID},
            ChatterID     => $Param{RandomID},
            ChatterType   => 'Public',
            ChatterActive => 1,
        );
    }

    my $Output = $LayoutObject->CustomerHeader(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    $LayoutObject->Block(
        Name => 'ChatScreen',
        Data => {
            ChatID     => $Self->{ChatID},
            SenderName => $Chat{RequesterName},
            IsIframe   => $Self->{IsIframe},
            RandomID   => $Param{RandomID},
        },
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => "PublicChat",
    );
    $Output .= $LayoutObject->CustomerFooter(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    return $Output;
}

sub ChatMessageAdd {
    my ( $Self, %Param ) = @_;

    my $Message  = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Message' );
    my $RandomID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'RandomID' );

    my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');

    if ( $Message && length $Message <= 3800 ) {
        $ChatObject->ChatMessageAdd(
            ChatID      => $Self->{ChatID},
            ChatterID   => $RandomID,
            ChatterType => 'Public',
            MessageText => $Message,
        );
    }

    return $Self->ChatUpdate();
}

sub ChatLeave {
    my ( $Self, %Param ) = @_;

    my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');

    my %Chat = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    if ( !%Chat ) {
        return $Self->ErrorResponse(
            Message => "Got no valid ChatID.",
        );
    }

    my $RandomID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'RandomID' );

    my $SenderName = $Chat{RequesterName};

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
            $SenderName,
        );

        $ChatObject->ChatMessageAdd(
            ChatID          => $Self->{ChatID},
            ChatterID       => $RandomID,
            ChatterType     => 'Public',
            SystemGenerated => 1,
            MessageText     => $Message,
        );

        $ChatObject->ChatParticipantUpdate(
            ChatID        => $Self->{ChatID},
            ChatterID     => $RandomID,
            ChatterType   => 'Public',
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

    my $Output = $LayoutObject->CustomerHeader(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    $LayoutObject->Block(
        Name => 'ChatCompleted',
        Data => {
            IsIframe => $Self->{IsIframe},
            }
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => "PublicChat",
    );
    $Output .= $LayoutObject->CustomerFooter(
        Type => ( $Self->{IsIframe} ) ? 'Small' : '',
    );

    return $Output;
}

sub ChatUpdate {
    my ( $Self, %Param ) = @_;

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %ChatData = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );

    if ( !%ChatData ) {
        return $Self->ErrorResponse(
            Message => "Chat is no longer active.",
        );
    }

    @{ $ChatData{ChatMessages} } = $ChatObject->ChatMessageList(
        ChatID        => $Self->{ChatID},
        MaskAgentName => 1,
        LastKnownChatMessageID =>
            $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'LastKnownChatMessageID' ),
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

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%ChatData ),
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
            Redirect => "?Action=PublicChat;Subaction=ChatCompleted;IsIframe=$Self->{IsIframe}",
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

1;
