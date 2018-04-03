# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# $origin: otrs - 4610a83fd5c61d87c5bc35e41703416235eeb4f9 - Kernel/Output/HTML/Layout.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Layout::CustomerNavBarFix;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

# disable redefine warnings in this scope
{
    no warnings 'redefine';

    sub Kernel::Output::HTML::Layout::CustomerNavigationBar {
        my ( $Self, %Param ) = @_;

        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # create menu items
        my %NavBarModule;
        my $FrontendModuleConfig = $ConfigObject->Get('CustomerFrontend::Module');

        MODULE:
        for my $Module ( sort keys %{$FrontendModuleConfig} ) {
            my %Hash = %{ $FrontendModuleConfig->{$Module} };
            next MODULE if !$Hash{NavBar};
            next MODULE if ref $Hash{NavBar} ne 'ARRAY';

            my @Items = @{ $Hash{NavBar} };

            ITEM:
            for my $Item (@Items) {
                next ITEM if !$Item;

                # check permissions
                my $Shown = 0;

                # get permissions from module if no permissions are defined for the icon
                if ( !$Item->{GroupRo} && !$Item->{Group} ) {
                    if ( $Hash{GroupRo} ) {
                        $Item->{GroupRo} = $Hash{GroupRo};
                    }
                    if ( $Hash{Group} ) {
                        $Item->{Group} = $Hash{Group};
                    }
                }

                # check shown permission
                PERMISSION:
                for my $Permission (qw(GroupRo Group)) {

                    # array access restriction
                    if ( $Item->{$Permission} && ref $Item->{$Permission} eq 'ARRAY' ) {
                        for my $Type ( @{ $Item->{$Permission} } ) {
                            my $Key = 'UserIs' . $Permission . '[' . $Type . ']';
                            if ( $Self->{$Key} && $Self->{$Key} eq 'Yes' ) {
                                $Shown = 1;
                                last PERMISSION;
                            }
                        }
                    }

                    # scalar access restriction
                    elsif ( $Item->{$Permission} ) {
                        my $Key = 'UserIs' . $Permission . '[' . $Item->{$Permission} . ']';
                        if ( $Self->{$Key} && $Self->{$Key} eq 'Yes' ) {
                            $Shown = 1;
                            last PERMISSION;
                        }
                    }

                    # no access restriction
                    elsif ( !$Item->{GroupRo} && !$Item->{Group} ) {
                        $Shown = 1;
                        last PERMISSION;
                    }
                }
                next ITEM if !$Shown;

                # set prio of item
                my $Key = sprintf( "%07d", $Item->{Prio} );
                COUNT:
                for ( 1 .. 51 ) {
                    last COUNT if !$NavBarModule{$Key};

                    $Item->{Prio}++;
                }

                if ( $Item->{Type} eq 'Menu' ) {
                    $NavBarModule{ sprintf( "%07d", $Item->{Prio} ) } = $Item;
                }

                # show as sub of main menu
                elsif ( $Item->{Type} eq 'Submenu' ) {
                    $NavBarModule{Sub}->{ $Item->{NavBar} }->{ sprintf( "%07d", $Item->{Prio} ) } = $Item;
                }
                else {
                    $NavBarModule{ sprintf( "%07d", $Item->{Prio} ) } = $Item;
                }
            }
        }

        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

        # run menu item modules
        if ( ref $ConfigObject->Get('CustomerFrontend::NavBarModule') eq 'HASH' ) {
            my %Jobs = %{ $ConfigObject->Get('CustomerFrontend::NavBarModule') };
            for my $Job ( sort keys %Jobs ) {

                # load module
                if ( !$MainObject->Require( $Jobs{$Job}->{Module} ) ) {
                    $Self->FatalError();
                }
                my $Object = $Jobs{$Job}->{Module}->new(
                    %{$Self},
                    LayoutObject => $Self,
                    UserID       => $Self->{UserID},
                    Debug        => $Self->{Debug},
                );

# ---
# OTRSCustomContactFields
# ---
#                # run module
#                %NavBarModule = (
#                    %NavBarModule,
#                    $Object->Run(
#                        %Param,
#                        Config       => $Jobs{$Job},
#                        NavBarModule => \%NavBarModule || {},
#                    ),
#                );

                # run module and merge results
                my %Result = $Object->Run(
                    %Param,
                    Config       => $Jobs{$Job},
                    NavBarModule => \%NavBarModule || {},
                );

                RESULTKEY:
                for my $CurrentKey ( sort keys %Result ) {

                    if ( $CurrentKey ne 'Sub' ) {
                        $NavBarModule{$CurrentKey} = $Result{$CurrentKey};
                        next RESULTKEY;
                    }

                    # loop over the sub menus and merge them
                    for my $CurrentSubMenu ( sort keys %{ $Result{$CurrentKey} } ) {

                        # now merge the sub-menu results
                        %{ $NavBarModule{$CurrentKey}->{$CurrentSubMenu} } = (
                            %{ $NavBarModule{$CurrentKey}->{$CurrentSubMenu} },
                            %{ $Result{$CurrentKey}->{$CurrentSubMenu} }
                        );
                    }
                }
# ---
            }
        }

        my $Total   = keys %NavBarModule;
        my $Counter = 0;

        if ( $NavBarModule{Sub} ) {
            $Total = int($Total) - 1;
        }

        # Only highlight the first matched navigation entry. If there are several entries
        #   with the same Action and Subaction, it cannot be determined which one was used.
        #   Therefore we just highlight the first one.
        my $SelectedFlag;

        ITEM:
        for my $Item ( sort keys %NavBarModule ) {
            next ITEM if !%{ $NavBarModule{$Item} };
            next ITEM if $Item eq 'Sub';
            $Counter++;
            my $Sub;
            if ( $NavBarModule{$Item}->{NavBar} ) {
                $Sub = $NavBarModule{Sub}->{ $NavBarModule{$Item}->{NavBar} };
            }

            # highlight active link
            $NavBarModule{$Item}->{Class} = '';
            if ( $NavBarModule{$Item}->{Link} ) {
                if (
                    !$SelectedFlag
                    && $NavBarModule{$Item}->{Link} =~ /Action=$Self->{Action}/
                    && $NavBarModule{$Item}->{Link} =~ /$Self->{Subaction}/    # Subaction can be empty
                    )
                {
                    $NavBarModule{$Item}->{Class} .= ' Selected';
                    $SelectedFlag = 1;
                }
            }
            if ( $Counter == $Total ) {
                $NavBarModule{$Item}->{Class} .= ' Last';
            }
            $Self->Block(
                Name => $NavBarModule{$Item}->{Block} || 'Item',
                Data => $NavBarModule{$Item},
            );

            # show sub menu
            next ITEM if !$Sub;
            $Self->Block(
                Name => 'ItemAreaSub',
                Data => $Item,
            );
            for my $Key ( sort keys %{$Sub} ) {
                my $ItemSub = $Sub->{$Key};
                $ItemSub->{NameForID} = $ItemSub->{Name};
                $ItemSub->{NameForID} =~ s/[ &;]//ig;
                $ItemSub->{NameTop} = $NavBarModule{$Item}->{NameForID};

                # check if we must mark the parent element as selected
                if ( $ItemSub->{Link} ) {
                    if (
                        $ItemSub->{Link} =~ /Action=$Self->{Action}/
                        && $ItemSub->{Link} =~ /$Self->{Subaction}/    # Subaction can be empty
                        )
                    {
                        $NavBarModule{$Item}->{Class} .= ' Selected';
                        $ItemSub->{Class} .= ' SubSelected';
                        $SelectedFlag = 1;
                    }
                }

                $Self->Block(
                    Name => 'ItemAreaSubItem',
                    Data => {
                        %$ItemSub,
                        AccessKeyReference => $ItemSub->{AccessKey} ? " ($ItemSub->{AccessKey})" : '',
                    },
                );
            }
        }

        # run notification modules
        my $FrontendNotifyModuleConfig = $ConfigObject->Get('CustomerFrontend::NotifyModule');
        if ( ref $FrontendNotifyModuleConfig eq 'HASH' ) {
            my %Jobs = %{$FrontendNotifyModuleConfig};

            NOTIFICATIONMODULE:
            for my $Job ( sort keys %Jobs ) {

                # load module
                next NOTIFICATIONMODULE if !$MainObject->Require( $Jobs{$Job}->{Module} );
                my $Object = $Jobs{$Job}->{Module}->new(
                    %{$Self},
                    LayoutObject => $Self,
                );
                next NOTIFICATIONMODULE if !$Object;

                # run module
                $Param{Notification} .= $Object->Run( %Param, Config => $Jobs{$Job} );
            }
        }

        # create the customer user login info (usually at the right side of the navigation bar)
        if ( !$Self->{UserLoginIdentifier} ) {
            $Param{UserLoginIdentifier} = $Self->{UserEmail} ne $Self->{UserCustomerID}
                ?
                "( $Self->{UserEmail} / $Self->{UserCustomerID} )"
                : $Self->{UserEmail};
        }
        else {
            $Param{UserLoginIdentifier} = $Self->{UserLoginIdentifier};
        }

        # only on valid session
        if ( $Self->{UserID} ) {

            # show logout button (if registered)
            if ( $FrontendModuleConfig->{Logout} ) {
                $Self->Block(
                    Name => 'Logout',
                    Data => \%Param,
                );
            }

            # show preferences button (if registered)
            if ( $FrontendModuleConfig->{CustomerPreferences} ) {
                if ( $Self->{Action} eq 'CustomerPreferences' ) {
                    $Param{Class} = 'Selected';
                }
                $Self->Block(
                    Name => 'Preferences',
                    Data => \%Param,
                );
            }

            # Show open chat requests (if chat engine is active).
            if ( $Kernel::OM->Get('Kernel::System::Main')->Require( 'Kernel::System::Chat', Silent => 1 ) ) {
                if ( $ConfigObject->Get('ChatEngine::Active') ) {
                    my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');
                    my $Chats      = $ChatObject->ChatList(
                        Status        => 'request',
                        TargetType    => 'Customer',
                        ChatterID     => $Self->{UserID},
                        ChatterType   => 'Customer',
                        ChatterActive => 0,
                    );

                    my $Count = scalar $Chats;

                    $Self->Block(
                        Name => 'ChatRequests',
                        Data => {
                            Count => $Count,
                            Class => ($Count) ? '' : 'Hidden',
                        },
                    );
                }
            }
        }

        # create & return output
        return $Self->Output(
            TemplateFile => 'CustomerNavigationBar',
            Data         => \%Param
        );
    }
}

1;
