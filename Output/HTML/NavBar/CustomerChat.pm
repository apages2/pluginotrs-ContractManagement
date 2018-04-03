# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NavBar::CustomerChat;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
);

#
# This module hides the chat button in the customer interface
#   if chatting is not configured.
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
        '0000200' => {},
    );

    return %DisableChat if !$ConfigObject->Get('ChatEngine::Active');
    return %DisableChat if !$ConfigObject->Get('ChatEngine::ChatDirection::CustomerToAgent');
    return %DisableChat if !$ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    return;
}

1;
