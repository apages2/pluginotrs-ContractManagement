# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NavBar::AgentChat;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
);

#
# This module hides the chat button in the agent
#   if chatting is not configured or the current agent is not in the chat group.
#

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    for (qw(UserID)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    return if !$ConfigObject->Get('CustomerFrontend::Module')->{CustomerChat};

    my %DisableChat = (
        'ItemArea0000500' => {},
        'ItemPre0000500'  => {},
    );

    return %DisableChat if !$ConfigObject->Get('ChatEngine::Active');

    my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    if ( !$ChatReceivingAgentsGroup && $Self->{UserID} != 1 ) {
        return %DisableChat;
    }

    my $ChatStartingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatStartingAgents');
    if ( !$ChatStartingAgentsGroup && $Self->{UserID} != 1 ) {
        return %DisableChat;
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if (
        !$LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
        && !$LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
        && $Self->{UserID} != 1
        )
    {
        return %DisableChat;
    }

    # Leave chat as active.
    return;
}

1;
