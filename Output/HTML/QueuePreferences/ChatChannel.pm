# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::QueuePreferences::ChatChannel;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Cache',
    'Kernel::System::ChatChannel',
    'Kernel::System::Web::Request',
    'Kernel::System::Queue',
    'Kernel::Language',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    my @Params = ();
    my $GetParam
        = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );

    if ( !defined($GetParam) ) {
        $GetParam = defined( $Param{QueueData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{QueueData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }

    # create ChatChannel object
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    # get the list of all available chat channels
    my @AllChatChannels = $ChatChannelObject->ChatChannelsGet(
        Valid => 1,
    );

    my %ChatChannels;

    for my $ChannelRef (@AllChatChannels) {
        my %ChatChannel = %$ChannelRef;
        $ChatChannels{ $ChatChannel{ChatChannelID} } = $ChatChannel{Name};
    }

    # get Queue to ChatChannel relations
    my %Relations = $ChatChannelObject->ChatChannelQueuesGet();

    my $Channels = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->BuildSelection(
        Data         => \%ChatChannels,
        Name         => $Self->{ConfigItem}->{PrefKey},
        ID           => $Self->{ConfigItem}->{PrefKey},
        Multiple     => 0,
        SelectedID   => $Relations{ $Param{QueueData}->{QueueID} } ? $Relations{ $Param{QueueData}->{QueueID} } : '',
        Translation  => 1,
        PossibleNone => 1,
        TreeView     => 0,
        Class        => 'Modernize',
    );

    push(
        @Params,
        {
            %Param,
            Name   => $Self->{ConfigItem}->{PrefKey},
            Option => $Channels,
        },
    );
    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get Queue to ChatChannel relations list
    my %Relations = $Kernel::OM->Get('Kernel::System::ChatChannel')->ChatChannelQueuesGet();

    for my $Key ( sort keys %{ $Param{GetParam} } ) {
        my @Array = @{ $Param{GetParam}->{$Key} };
        for (@Array) {

            # pref update db
            $Kernel::OM->Get('Kernel::System::Queue')->QueuePreferencesSet(
                QueueID => $Param{QueueData}->{QueueID},
                Key     => $Key,
                Value   => $_,
            );

            # check should cash be deleted
            # it should be deleted if old values for chat channels are changed
            if (
                !$Relations{ $Param{QueueData}->{QueueID} }
                || (
                    $Relations{ $Param{QueueData}->{QueueID} }
                    && $Relations{ $Param{QueueData}->{QueueID} } != $_
                )
                )
            {

                my $CacheKey  = 'ChatChannelQueue';
                my $CacheType = 'ChatChannel';

                # reset cache
                $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
                    Type => $CacheType,
                    Key  => $CacheKey,
                );
            }
        }
    }

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
