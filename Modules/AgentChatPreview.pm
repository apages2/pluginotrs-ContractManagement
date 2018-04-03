# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentChatPreview;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    # get needed objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get single params
    my %GetParam;

    $GetParam{FromChatID} = $ParamObject->GetParam( Param => "FromChatID" );

    # get related chat
    my %Chat = $Kernel::OM->Get('Kernel::System::Chat')->ChatGet(
        ChatID => $GetParam{FromChatID},
    );

    if ( !%Chat ) {
        return $LayoutObject->FatalError(
            Message => "No chat provided. This module works only as overlay",
        );
    }

    if ( $Self->{Subaction} eq 'AJAX' ) {

        my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

        # show AcceptAjax block
        $LayoutObject->Block(
            Name => 'AcceptAJAX',
            Data => {
                %Param,
                %GetParam,
            },
        );

        my @ChatMessages = $Kernel::OM->Get('Kernel::System::Chat')->ChatMessageList(
            ChatID => $GetParam{FromChatID},
        );

        for my $Message (@ChatMessages) {
            $Message->{MessageText} = $LayoutObject->Ascii2Html(
                Text        => $Message->{MessageText},
                LinkFeature => 1,
            );
        }

        $Param{ChatMessages} = \@ChatMessages;

        # display chat protocol
        $LayoutObject->Block(
            Name => 'ChatProtocol',
            Data => \%Param,
        );

        # get default channel id
        my $DefaultChannelID = $ChatChannelObject->DefaultChatChannelGet();

        # if chat channel is defined
        # and is not default channel id
        if (
            $Chat{ChatChannelID}
            && $Chat{ChatChannelID} != $DefaultChannelID
            )
        {

            my @AvailableChatChannels = $Self->_GetAvailableChannels(%Chat);

            my $ChannelsSelect = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->BuildSelection(
                Data         => \@AvailableChatChannels,
                Name         => 'ChannelID',
                PossibleNone => 1,
                Class        => 'Validate_Required',
                SelectedID   => $Chat{ChatChannelID},
            );

            # Get current channel data
            my %ChatChannel = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChatChannelGet(
                ChatChannelID => $Chat{ChatChannelID},
            );

            # display chat protocol
            $LayoutObject->Block(
                Name => 'ChatChannelChange',
                Data => {
                    ChatChannels => $ChannelsSelect,
                    Channel      => $ChatChannel{Name},
                },
            );

            # display ChannelUpdate button
            $LayoutObject->Block(
                Name => 'ChannelUpdate',
            );

            # get user permissions for this channel
            my $PermissionLevel = $ChatChannelObject->ChatChannelPermissionGet(
                UserID        => $Self->{UserID},
                ChatChannelID => $Chat{ChatChannelID},
            );

            # show accept button only if permission level is owner
            if ( $PermissionLevel eq 'Owner' ) {

                # display Accept chat button
                $LayoutObject->Block(
                    Name => 'AcceptChat',
                );
            }
        }

        # otherwise always show accept button
        else {
            # display Accept chat button
            $LayoutObject->Block(
                Name => 'AcceptChat',
            );
        }

        # Check if request is Agent to Agent
        if ( $Chat{RequesterType} eq 'User' ) {
            $LayoutObject->Block(
                Name => 'Decline',
                Data => {
                    FromChatID => $GetParam{FromChatID},
                },
            );
        }

        my $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentChatPreview',
            Data         => \%Param,
        );

        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output,
            Type        => 'inline',
        );
    }
    elsif ( $Self->{Subaction} eq 'GetAvailableChannels' ) {

        # get the list of available chat channels
        my @ChatChannelsData = $Self->_GetAvailableChannels(%Chat);

        # encode to JSON and return
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \@ChatChannelsData ),
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # show default preview screen
    $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $LayoutObject->Block(
        Name => 'Ticket Preview',
        Data => \%Param,
    );
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentChatPreview',
        Data         => \%Param,
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GetAvailableChannels {

    my ( $Self, %Param ) = @_;

    # Get channels data
    my @ChatChannelsData = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChatChannelsGet(
        Valid => 1,
    );

    my %AvailableUsers = $Kernel::OM->Get('Kernel::System::Chat')->AvailableUsersGet(
        Key => 'ExternalChannels',
    );

    # Chat channels to display
    my @DisplayChatChannels;

    # Get all valid channels, where current agent has at least 'Participant' permissions; otherwise there would be
    #   permission errors trying to move chats into these channels.
    my %UserPermissionChannels = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChatPermissionChannelGet(
        UserID     => $Self->{UserID},
        Permission => [ 'chat_participant', 'chat_owner' ],
    );

    # Rename hash keys: Name => Value, ChatChannelID => Key
    CHATCHANNEL:
    for my $ChatChannelData (@ChatChannelsData) {

        # Only show channels where the user has at least "Particiant" permission.
        next CHATCHANNEL if !$UserPermissionChannels{ $ChatChannelData->{ChatChannelID} };

        # skip to the next if current one is equal to the current ChatChannelID
        next CHATCHANNEL if $ChatChannelData->{ChatChannelID} eq $Param{ChatChannelID};
        $ChatChannelData->{Value} = delete $ChatChannelData->{Name};
        $ChatChannelData->{Key}   = delete $ChatChannelData->{ChatChannelID};

        # if current current chat channel id is current one
        if ( $Param{ChatChannelID} eq $ChatChannelData->{Key} ) {

            # set a flag indicating that this channel is selected
            $ChatChannelData->{Selected} = 1;
        }

        my $UserAvailable = 0;

        CHAT_CHANNEL:
        for my $ChatChannels ( sort keys %AvailableUsers ) {
            if ( grep( /^$ChatChannelData->{Key}$/, @{ $AvailableUsers{$ChatChannels} } ) ) {
                $UserAvailable = 1;
                last CHAT_CHANNEL;
            }
        }

        if ( !$UserAvailable ) {
            $ChatChannelData->{Disabled} = 1;
        }
        push @DisplayChatChannels, $ChatChannelData;
    }

    return @DisplayChatChannels;

}

1;
