# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentChatPopup;

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

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    $Self->{ChatID} = $ParamObject->GetParam( Param => 'ChatID' );

    # check does this chat exist
    my %ChatHash = $ChatObject->ChatGet(
        ChatID => $Self->{ChatID},
    );
    if ( !%ChatHash ) {

        $ChatHash{Inactive} = 1;

        # return chat inactive message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \%ChatHash ),
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    else {
        $Self->{Chat} = \%ChatHash;
    }

    if ( !$Self->{ChatID} ) {
        return $LayoutObject->FatalError(
            Message => "Need ChatID.",
        );
    }

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

    # Check if user is chat participant
    my $Access = $ChatObject->ChatParticipantCheck(
        ChatID      => $Self->{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'User',
    );

    if ( !$Access ) {
        $ChatHash{Inactive} = 1;

        # return chat inactive message
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \%ChatHash ),
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    if ( $Self->{Subaction} eq 'ChatUpdate' ) {
        return $Self->ChatUpdate();
    }

    return $Self->_Mask();
}

sub ChatUpdate {
    my ( $Self, %Param ) = @_;

    # all data for the current chat
    my $Chat = $Self->{Chat};

    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    my %LastKnownChatMessageIDs = %{
        $Kernel::OM->Get('Kernel::System::JSON')->Decode(
            Data => $ParamObject->GetParam( Param => 'LastKnownChatMessageIDs' ) || '{}',
            ) // {}
    };

    # set chat channel if there is ChatChannelID
    if ( $Chat->{ChatChannelID} ) {
        my %ChatChannel = $ChatChannelObject->ChatChannelGet(
            ChatChannelID => $Chat->{ChatChannelID},
        );

        $Chat->{Channel} = $ChatChannel{Name};
    }

    # Localize time and apply time zone, if needed.
    $Chat->{CreateTime} = $LayoutObject->{LanguageObject}->FormatTimeString( $Chat->{CreateTime}, 'DateFormat' );

    # get chat participants to display on top of each box
    my @ParticipantList = $ChatObject->ChatParticipantList(
        ChatID => $Self->{ChatID},
    );
    if (@ParticipantList) {
        $Chat->{Participants} = \@ParticipantList;
    }

    my @MessageList = $ChatObject->ChatMessageList(
        ChatID                 => $Self->{ChatID},
        LastKnownChatMessageID => $LastKnownChatMessageIDs{ $Self->{ChatID} },
        ExcludeCustomer        => 1,
    );

    for my $Message (@MessageList) {

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

    if (@MessageList) {
        $Chat->{Messages} = \@MessageList;
    }

    # Get first text message of chats
    if ( !$LastKnownChatMessageIDs{ $Self->{ChatID} } ) {
        my ($FirstMessage) = $ChatObject->ChatMessageList(
            ChatID          => $Self->{ChatID},
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

    if ( $Chat->{Status} && $Chat->{Status} eq 'request' ) {

        # user is directly communicating to Customer or Agent
        # in that case User must have Owner permissions
        if ( !$Chat->{ChatChannelID} ) {
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
    else {
        # Get permissions defined from chat_participant table
        $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
            ChatID => $Self->{ChatID},
            UserID => $Self->{UserID},
        );
    }

    $Chat->{PermissionLevel} = $PermissionLevel;

    # check is there Ticket_ID
    if ( $Chat->{TicketID} ) {

        # get ticket number from id
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID => $Chat->{TicketID},
        );
        $Chat->{TicketNumber} = $Ticket{TicketNumber};
    }

    # add ChatID to this chat
    $Chat->{ChatID} = $Self->{ChatID};

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $Chat ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    my $Output = $LayoutObject->Header(
        Type => 'Small',
    );
    $Output .= $LayoutObject->Output(
        TemplateFile => "AgentChatPopup",
        Data         => {
            ChatID => $Self->{ChatID},
        },
    );
    $Output .= $LayoutObject->Footer();

    return $Output;
}

1;
