# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Layout::NotificationView;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

=head1 NAME

Kernel::Output::HTML::LayoutTicket - all Notification View related HTML functions

=head1 SYNOPSIS

All Notification View related HTML functions

=head1 PUBLIC INTERFACE

=over 4

=cut

sub NotificationViewListShow {
    my ( $Self, %Param ) = @_;

    # take object ref to local, remove it from %Param (prevent memory leak)
    my $Env = $Param{Env};
    delete $Param{Env};

    # lookup latest used view mode
    if ( !$Param{View} && $Self->{ 'UserNotificationView' . $Env->{Action} } ) {
        $Param{View} = $Self->{ 'UserNotificationView' . $Env->{Action} };
    }

    # set default view mode to 'small'
    my $View = $Param{View} || 'Small';

    # store latest view mode
    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'UserNotificationView' . $Env->{Action},
        Value     => $View,
    );

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # update preferences if needed
    my $Key = 'UserNotificationView' . $Env->{Action};

    if ( !$ConfigObject->Get('DemoSystem') && $Self->{$Key} ne $View ) {
        $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
            UserID => $Self->{UserID},
            Key    => $Key,
            Value  => $View,
        );
    }

    # check back-ends
    my $Backends = $ConfigObject->Get('NotificationView::Frontend::Overview');
    if ( !$Backends ) {
        return $Self->FatalError(
            Message => 'Need config option NotificationView::Frontend::Overview',
        );
    }
    if ( ref $Backends ne 'HASH' ) {
        return $Self->FatalError(
            Message => 'Config option NotificationView::Frontend::Overview need to be HASH ref!',
        );
    }

    # check if selected view is available
    if ( !$Backends->{$View} ) {

        # try to find fall-back, take first configured view mode
        KEY:
        for my $Key ( sort keys %{$Backends} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "No Config option found for view mode $View, took $Key instead!",
            );
            $View = $Key;
            last KEY;
        }
    }

    # load overview backend module
    if ( !$Kernel::OM->Get('Kernel::System::Main')->Require( $Backends->{$View}->{Module} ) ) {
        return $Self->FatalError();
    }
    my $Object = $Backends->{$View}->{Module}->new( %{$Env} );
    return if !$Object;

    # retrieve filter values
    if ( $Param{FilterContentOnly} ) {
        return $Object->FilterContent(
            %Param,
        );
    }

    # run action row backend module
    $Param{ActionRow} = $Object->ActionRow(
        %Param,
        Config => $Backends->{$View},
    );

    # run overview backend module
    $Param{SortOrderBar} = $Object->SortOrderBar(
        %Param,
        Config => $Backends->{$View},
    );

    # check start option, if higher then tickets available, set
    # it to the last ticket page (Thanks to Stefan Schmidt!)
    my $StartHit = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'StartHit' ) || 1;

    # get personal page shown count
    my $PageShownPreferencesKey = 'UserNotificationView' . $View . 'PageShown';
    my $PageShown               = $Self->{$PageShownPreferencesKey} || 10;
    my $Group                   = 'NotificationView' . $View . 'PageShown';

    # get data selection
    my %Data;
    my $Config = $ConfigObject->Get('PreferencesGroups');
    if ( $Config && $Config->{$Group} && $Config->{$Group}->{Data} ) {
        %Data = %{ $Config->{$Group}->{Data} };
    }

    # calculate max. shown per page
    if ( $StartHit > $Param{Total} ) {
        my $Pages = int( ( $Param{Total} / $PageShown ) + 0.99999 );
        $StartHit = ( ( $Pages - 1 ) * $PageShown ) + 1;
    }

    # build nav bar
    my $Limit = $Param{Limit} || 20_000;
    my %PageNav = $Self->PageNavBar(
        Limit     => $Limit,
        StartHit  => $StartHit,
        PageShown => $PageShown,
        AllHits   => $Param{Total} || 0,
        Action    => 'Action=' . $Self->{Action},
        Link      => $Param{LinkPage},
        IDPrefix  => $Self->{Action},
    );

    # build shown ticket per page
    $Param{RequestedURL}    = $Param{RequestedURL} || "Action=$Self->{Action}";
    $Param{Group}           = $Group;
    $Param{PreferencesKey}  = $PageShownPreferencesKey;
    $Param{PageShownString} = $Self->BuildSelection(
        Name        => $PageShownPreferencesKey,
        SelectedID  => $PageShown,
        Translation => 0,
        Data        => \%Data,
        Sort        => 'NumericValue',
    );

    # nav bar at the beginning of a overview
    $Param{View} = $View;
    $Self->Block(
        Name => 'OverviewNavBar',
        Data => \%Param,
    );

    # back link
    if ( $Param{LinkBack} ) {
        $Self->Block(
            Name => 'OverviewNavBarPageBack',
            Data => \%Param,
        );
    }

    # filter selection
    if ( $Param{Filters} ) {
        my @NavBarFilters;
        for my $Prio ( sort keys %{ $Param{Filters} } ) {
            push @NavBarFilters, $Param{Filters}->{$Prio};
        }
        $Self->Block(
            Name => 'OverviewNavBarFilter',
            Data => {
                %Param,
            },
        );
        my $Count = 0;
        for my $Filter (@NavBarFilters) {
            $Count++;
            if ( $Count == scalar @NavBarFilters ) {
                $Filter->{CSS} .= ' Last';
            }
            $Self->Block(
                Name => 'OverviewNavBarFilterItem',
                Data => {
                    %Param,
                    %{$Filter},
                },
            );
            if ( $Filter->{Filter} eq $Param{Filter} ) {
                $Self->Block(
                    Name => 'OverviewNavBarFilterItemSelected',
                    Data => {
                        %Param,
                        %{$Filter},
                    },
                );
            }
            else {
                $Self->Block(
                    Name => 'OverviewNavBarFilterItemSelectedNot',
                    Data => {
                        %Param,
                        %{$Filter},
                    },
                );
            }
        }
    }

    # view mode
    for my $Backend (
        sort { $Backends->{$a}->{ModulePriority} <=> $Backends->{$b}->{ModulePriority} }
        keys %{$Backends}
        )
    {

        $Self->Block(
            Name => 'OverviewNavBarViewMode',
            Data => {
                %Param,
                %{ $Backends->{$Backend} },
                Filter => $Param{Filter},
                View   => $Backend,
            },
        );
        if ( $View eq $Backend ) {
            $Self->Block(
                Name => 'OverviewNavBarViewModeSelected',
                Data => {
                    %Param,
                    %{ $Backends->{$Backend} },
                    Filter => $Param{Filter},
                    View   => $Backend,
                },
            );
        }
        else {
            $Self->Block(
                Name => 'OverviewNavBarViewModeNotSelected',
                Data => {
                    %Param,
                    %{ $Backends->{$Backend} },
                    Filter => $Param{Filter},
                    View   => $Backend,
                },
            );
        }
    }

    if (%PageNav) {
        $Self->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );

        # don't show context settings in AJAX case (e. g. in customer ticket history),
        #   because the submit with page reload will not work there
        if ( !$Param{AJAX} ) {
            $Self->Block(
                Name => 'ContextSettings',
                Data => {
                    %PageNav,
                    %Param,
                },
            );

            # show column filter preferences
            if ( $View eq 'Small' ) {

                # set preferences keys
                my $PrefKeyColumns = 'UserFilterColumnsEnabled' . '-' . $Env->{Action};

                # create extra needed objects
                my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

                # configure columns
                my @ColumnsEnabled = @{ $Object->{ColumnsEnabled} };
                my @ColumnsAvailable;

                for my $ColumnName ( sort { $a cmp $b } @{ $Object->{ColumnsAvailable} } ) {
                    if ( !grep { $_ eq $ColumnName } @ColumnsEnabled ) {
                        push @ColumnsAvailable, $ColumnName;
                    }
                }

                my %Columns;
                for my $ColumnName ( sort @ColumnsAvailable ) {
                    $Columns{Columns}->{$ColumnName} = ( grep { $ColumnName eq $_ } @ColumnsEnabled ) ? 1 : 0;
                }

                $Self->Block(
                    Name => 'FilterColumnSettings',
                    Data => {
                        Columns          => $JSONObject->Encode( Data => \%Columns ),
                        ColumnsEnabled   => $JSONObject->Encode( Data => \@ColumnsEnabled ),
                        ColumnsAvailable => $JSONObject->Encode( Data => \@ColumnsAvailable ),
                        NamePref         => $PrefKeyColumns,
                        Desc             => 'Shown Columns',
                        Name             => $Env->{Action},
                        View             => $View,
                        GroupName        => 'NotificationViewFilterSettings',
                        %Param,
                    },
                );
            }
        }    # end show column filters preferences

        # check if there was stored filters, and print a link to delete them
        if ( IsHashRefWithData( $Object->{StoredFilters} ) ) {
            $Self->Block(
                Name => 'DocumentActionRowRemoveColumnFilters',
                Data => {
                    CSS => "ContextSettings RemoveFilters",
                    %Param,
                },
            );
        }
    }

    if ( $Param{NavBar} ) {
        if ( $Param{NavBar}->{MainName} ) {
            $Self->Block(
                Name => 'OverviewNavBarMain',
                Data => $Param{NavBar},
            );
        }
    }

    my $OutputNavBar = $Self->Output(
        TemplateFile => 'AgentNotificationViewNavBar',
        Data         => { %Param, },
    );
    my $OutputRaw = '';
    if ( !$Param{Output} ) {
        $Self->Print( Output => \$OutputNavBar );
    }
    else {
        $OutputRaw .= $OutputNavBar;
    }

    # run overview backend module
    my $Output = $Object->Run(
        %Param,
        Config    => $Backends->{$View},
        Limit     => $Limit,
        StartHit  => $StartHit,
        PageShown => $PageShown,
        AllHits   => $Param{Total} || 0,
        Output    => $Param{Output} || '',
    );
    if ( !$Param{Output} ) {
        $Self->Print( Output => \$Output );
    }
    else {
        $OutputRaw .= $Output;
    }

    return $OutputRaw;
}

sub NotificationViewMetaItemsCount {
    my ( $Self, %Param ) = @_;
    return ('Seen');
}

sub NotificationViewMetaItems {
    my ( $Self, %Param ) = @_;

    if ( ref $Param{Notification} ne 'HASH' ) {
        $Self->FatalError( Message => 'Need Hash ref in Notification param!' );
    }

    # return attributes
    my @Result;

    my %Notification = %{ $Param{Notification} };

    $Notification{Seen} //= 0;

    # Show if notification has been seen
    if ( $Notification{Seen} == 1 ) {
        push @Result, undef;
    }
    else {
        push @Result, {
            Image      => 'meta-new.png',
            Title      => 'Unseen',
            Class      => 'UnreadNotifications',
            ClassSpan  => 'UnreadNotifications Remarkable',
            ClassTable => 'UnreadNotifications',
        };
    }

    return @Result;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
