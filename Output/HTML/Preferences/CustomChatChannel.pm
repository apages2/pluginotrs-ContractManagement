# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Preferences::CustomChatChannel;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Cache',
    'Kernel::System::ChatChannel',
    'Kernel::System::DB',
    'Kernel::System::Group',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    for my $Needed (qw(UserID ConfigItem)) {
        die "Got no $Needed!" if ( !$Self->{$Needed} );
    }

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    my @Params = ();

    # check needed param, if no user id is given, do not show this box
    if ( !$Param{UserData}->{UserID} ) {
        return ();
    }

    # Do not show preference widget if chat is turned off.
    return if !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active');

    # Do not show preference widget if chat channel feature is turned off.
    if (
        !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PublicInterface::AllowChatChannels')
        && !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::CustomerInterface::AllowChatChannels')
        )
    {
        return;
    }

    my $ChatChannelObject     = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my %AvailableChatChannels = $ChatChannelObject->ChatPermissionChannelGet(
        UserID     => $Param{UserData}->{UserID},
        Permission => 'chat_owner',
    );

    # Show list of available channels if there is at least one user has permission to.
    if (%AvailableChatChannels) {
        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        my @CustomChatChannelIDs;
        if ( $ParamObject->GetArray( Param => $Self->{ConfigItem}->{PrefKey} ) ) {
            @CustomChatChannelIDs = $ParamObject->GetArray( Param => $Self->{ConfigItem}->{PrefKey} );
        }
        elsif ( $Param{UserData}->{UserID} && !defined $CustomChatChannelIDs[0] ) {
            @CustomChatChannelIDs = $ChatChannelObject->CustomChatChannelsGet(
                UserID => $Param{UserData}->{UserID},
                Key    => $Self->{ConfigItem}->{PrefKey},
            );
        }

        push @Params, {
            %Param,
            Option => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->BuildSelection(
                Data        => \%AvailableChatChannels,
                Size        => 5,
                Name        => $Self->{ConfigItem}->{PrefKey},
                SelectedID  => \@CustomChatChannelIDs,
                Multiple    => 1,
                Translation => 0,
                Class       => 'Modernize',
            ),
            Name => $Self->{ConfigItem}->{PrefKey},
        };
    }

    # Otherwise, show a friendly message informing them how they can get access.
    else {
        push @Params, {
            %Param,
            Block => 'RawHTML',
            HTML  => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{LanguageObject}->Translate(
                'You do not have access to any chat channels in the system. Please contact the administrator.'
            ),
        };
    }

    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get DB object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $ChatChannelObject     = $Kernel::OM->Get('Kernel::System::ChatChannel');
    my %AvailableChatChannels = $ChatChannelObject->ChatPermissionChannelGet(
        UserID     => $Param{UserData}->{UserID},
        Permission => 'chat_owner',
    );

    my @UserChannels;

    for my $Key ( sort keys %{ $Param{GetParam} } ) {

        my @Parameters = @{ $Param{GetParam}->{$Key} };
        for my $Value (@Parameters) {

            # check permissions
            if ( $AvailableChatChannels{$Value} ) {
                push @UserChannels, $Value;
            }
        }
    }

    $ChatChannelObject->CustomChatChannelsSet(
        Key          => $Self->{ConfigItem}->{PrefKey},
        UserChannels => \@UserChannels,
        UserID       => $Param{UserData}->{UserID},
    );

    $Self->{Message} = 'Preferences updated successfully!';
    return 1;
}

sub Error {
    my ( $Self, %Param ) = @_;

    return $Self->{Error} || '';
}

sub Message {
    my ( $Self, %Param ) = @_;

    return $Self->{Message} || '';
}

1;
