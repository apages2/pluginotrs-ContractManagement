# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ToolBar::ChatAvailability;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::Language',
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

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    if ( !$ConfigObject->Get('ChatEngine::Active') ) {
        return;
    }

    my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    my $ChatStartingAgentsGroup  = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatStartingAgents');

    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

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

    my $Class    = $Param{Config}->{CssClass};
    my $Icon     = $Param{Config}->{Icon};
    my $URL      = $LayoutObject->{Baselink};
    my $Priority = $Param{Config}->{Priority};
    my $Description;
    my %Return;

    # Get user preferences
    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    # Get current availability
    my $ChatAvailability = $Preferences{ChatAvailability} || 0;

    if ( $ChatAvailability == 0 ) {
        $Icon        = 'fa fa-circle-o';
        $Description = $LanguageObject->Translate('Unavailable for chat');
    }
    elsif ( $ChatAvailability == 1 ) {
        $Icon        = 'fa fa-check-circle-o';
        $Description = $LanguageObject->Translate('Available for internal chats only');
    }
    elsif ( $ChatAvailability == 2 ) {
        $Icon        = 'fa fa-check-circle';
        $Description = $LanguageObject->Translate('Available for chats');
    }

    $Return{$Priority} = {
        Block       => 'ToolBarItem',
        Description => $Description,
        Class       => $Class,
        Icon        => $Icon,
        Link        => '#',
        AccessKey   => $Param{Config}->{AccessKey} || '',
    };

    return %Return;
}

1;
