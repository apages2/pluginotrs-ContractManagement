# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ToolBar::ChatRequests;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Chat',
    'Kernel::System::ChatChannel',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get other needed stuff
    for my $Needed (qw(UserID)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $ChatObject        = $Kernel::OM->Get('Kernel::System::Chat');
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    if ( !$ConfigObject->Get('ChatEngine::Active') ) {
        return;
    }

    my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    my $ChatStartingAgentsGroup  = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatStartingAgents');

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

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
        return;
    }

    # check needed stuff
    for (qw(Config)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    my $AvailableForChat = 0;
    if ( defined $Preferences{ChatAvailability} ) {
        $AvailableForChat = $Preferences{ChatAvailability};
    }

    # number of chats for which user is still not notified
    my $NotifyChats = 0;
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

    # if user is available for C2A chat
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
        my @ChatsIntivations = $ChatObject->ChatList(
            Status        => "active",
            RequesterType => 'User',
            TargetType    => 'User',
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 0,
        );
    }

    # merge all 3 arrays
    my @AllChats = ( @ChatsCustomer, @ChatsPersonal, @ChatsIntivations, @ChatsPublic );

    my $Count = scalar @AllChats;

    my $Class    = $Param{Config}->{CssClass};
    my $Icon     = $Param{Config}->{Icon};
    my $URL      = $LayoutObject->{Baselink};
    my $Priority = $Param{Config}->{Priority};
    my %Return;

    $Return{$Priority} = {
        Block       => 'ToolBarItem',
        Count       => $Count,
        Description => $LayoutObject->{LanguageObject}->Translate('Open Chat Requests'),
        Class       => $Count < 1 ? "$Class Hidden" : $Class,
        Icon        => $Icon,
        Link        => $URL . 'Action=AgentChat;ShowOpenRequests=' . $Count,
        Target      => 'OTRSAgentChat',
        AccessKey => $Param{Config}->{AccessKey} || '',
    };

    return %Return;
}

1;
