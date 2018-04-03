# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Notification::ChatPreferredChannelsCheck;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::User',
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ChatChannel',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get UserID param
    $Self->{UserID} = $Param{UserID} || die "Got no UserID!";

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # Do not show notification if chat is turned off.
    return '' if !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active');

    # Do not show notification if chat channel feature is turned off.
    if (
        !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PublicInterface::AllowChatChannels')
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::CustomerInterface::AllowChatChannels')
        )
    {
        return '';
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    if (
        $Self->{UserID} != -1
        && $ChatReceivingAgentsGroup
        && $LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
        )
    {
        my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

        # Do not show notification if user does not have access to at least one chat channel.
        my %AvailableChatChannels = $ChatChannelObject->ChatPermissionChannelGet(
            UserID     => $Self->{UserID},
            Permission => 'chat_owner',
        );
        return '' if !%AvailableChatChannels;

        my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
            UserID => $Self->{UserID},
        );

        # Show notification only if user is available for external chats.
        if (
            defined $Preferences{ChatAvailability}
            && $Preferences{ChatAvailability} == 2
            )
        {
            my @ExternalChannels = $ChatChannelObject->CustomChatChannelsGet(
                Key    => 'ExternalChannels',
                UserID => $Self->{UserID},
            );

            # Show notification only if user does not have any chat channels set.
            if ( !@ExternalChannels ) {
                return $LayoutObject->Notify(
                    Priority => 'Notice',
                    Link     => $LayoutObject->{Baselink} . 'Action=AgentPreferences',
                    Data =>
                        $LayoutObject->{LanguageObject}
                        ->Translate("You don't have any external chat channel assigned."),
                );
            }
        }
    }

    return '';
}

1;
