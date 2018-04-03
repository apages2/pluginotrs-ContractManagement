# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ToolBar::NotificationView;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::NotificationView',
    'Kernel::System::Log',
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

    # check needed stuff
    if ( !$Param{Config} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Config!',
        );
        return;
    }

    # do nothing if transport is not enabled feature is not enabled
    my $TransportConfig = $Kernel::OM->Get('Kernel::Config')->Get('Notification::Transport');
    return if !$TransportConfig->{NotificationView};

    my $Count = $Kernel::OM->Get('Kernel::System::NotificationView')->NotificationSearch(
        Result  => 'COUNT',
        UserIDs => [ $Self->{UserID} ],
        Seen    => [0],
    );

    return if !$Count;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get item definition
    my $Text      = $LayoutObject->{LanguageObject}->Translate( $Param{Config}->{Name} );
    my $URL       = $LayoutObject->{Baselink} . $Param{Config}->{Link};
    my $Priority  = $Param{Config}->{Priority};
    my $AccessKey = $Param{Config}->{AccessKey};
    my $CssClass  = $Param{Config}->{CssClass};
    my $Icon      = $Param{Config}->{Icon};

    my %Return;
    $Return{$Priority} = {
        Block       => 'ToolBarItem',
        Description => $Text,
        Count       => $Count,
        Class       => $CssClass,
        Icon        => $Icon,
        Link        => $URL,
        AccessKey   => $AccessKey,
    };
    return %Return;
}

1;
