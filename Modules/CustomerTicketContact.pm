# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerTicketContact;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::System::AuthSession',
    'Kernel::System::Web::Request',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::CustomerUser',
    'Kernel::System::User',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get a local config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # all static variables
    $Self->{ViewableSenderTypes} = $ConfigObject->Get('Ticket::ViewableSenderTypes')
        || $Kernel::OM->Get('Kernel::Output::HTML::Layout')->FatalError(
        Message => 'No Config entry "Ticket::ViewableSenderTypes"!'
        );

    $Self->{SmallViewColumnHeader} = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{ColumnHeader};

    $Self->{Owner} = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Owner};

    $Self->{Queue} = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverview')->{Queue};

    # get dynamic field config for frontend module
    $Self->{DynamicFieldFilter} = $ConfigObject->Get("Ticket::Frontend::CustomerTicketOverview")->{DynamicField};

    # get the dynamic fields for this screen
    $Self->{DynamicField} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Self->{DynamicFieldFilter} || {},
    );

    # get dynamicfield backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # reduce the dynamic fields to only the ones that are desinged for customer interface
    my @CustomerDynamicFields;
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsCustomerInterfaceCapable = $DynamicFieldBackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsCustomerInterfaceCapable',
        );
        next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

        push @CustomerDynamicFields, $DynamicFieldConfig;
    }
    $Self->{DynamicField} = \@CustomerDynamicFields;

    # get a local param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get params
    $Self->{Filter}  = $ParamObject->GetParam( Param => 'Filter' )  || 'Open';
    $Self->{SortBy}  = $ParamObject->GetParam( Param => 'SortBy' )  || 'Age';
    $Self->{OrderBy} = $ParamObject->GetParam( Param => 'OrderBy' ) || 'Down';
    $Self->{StartHit} = int( $ParamObject->GetParam( Param => 'StartHit' ) || 1 );
    $Self->{PageShown} = $Self->{UserShowTickets} || 1;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check DynamicField
    my $DynamicFieldID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ID' );
    if ( !$DynamicFieldID ) {

        return $Self->_DisplayError( Message => "DynamicField ID is Missing!" );
    }

    my $DynamicFieldContact
        = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet( ID => $DynamicFieldID );
    if (
        !IsHashRefWithData($DynamicFieldContact)
        || !$DynamicFieldContact->{Name}
        || !IsHashRefWithData( $DynamicFieldContact->{Config} )
        )
    {
        return $Self->_DisplayError( Message => 'Invalid DynamicField structure!' );
    }

    # check if we are allowed to be here
    if ( !$DynamicFieldContact->{Config}->{CustomerInterfaceTab} ) {

        return $Self->_DisplayError( Message => 'The overview is disabled for this contact field!' );
    }

    # check sub-action
    $Self->{Subaction} = 'MyTickets' if !$Self->{Subaction};

    # check needed CustomerID
    if ( !$Self->{UserCustomerID} ) {

        return $Self->_DisplayError( Message => 'Need CustomerID!' );
    }

    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenOverview',
        Value     => $Self->{RequestedURL},
    );

    # filter definition
    my %Filters = (
        MyTickets => {
            All => {
                Name   => 'All',
                Prio   => 1000,
                Search => {
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
            Open => {
                Name   => 'Open',
                Prio   => 1100,
                Search => {
                    StateType  => 'Open',
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
            Closed => {
                Name   => 'Closed',
                Prio   => 1200,
                Search => {
                    StateType  => 'Closed',
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
        },
        CompanyTickets => {
            All => {
                Name   => 'All',
                Prio   => 1000,
                Search => {
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
            Open => {
                Name   => 'Open',
                Prio   => 1100,
                Search => {
                    StateType  => 'Open',
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
            Closed => {
                Name   => 'Closed',
                Prio   => 1200,
                Search => {
                    StateType  => 'Closed',
                    OrderBy    => $Self->{OrderBy},
                    SortBy     => $Self->{SortBy},
                    Permission => 'ro',
                    UserID     => 1,
                },
            },
        },
    );

    # check if filter is valid
    if ( !$Filters{ $Self->{Subaction} }->{ $Self->{Filter} } ) {
        return $Self->_DisplayError( Message => "Invalid Filter: $Self->{Filter}!" );
    }

    # get a local config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check if archive search is allowed, otherwise search for all tickets
    my %SearchInArchive;
    if (
        $ConfigObject->Get('Ticket::ArchiveSystem')
        && !$ConfigObject->Get('Ticket::CustomerArchiveSystem')
        )
    {
        $SearchInArchive{ArchiveFlags} = [ 'y', 'n' ];
    }

    # limit the search to the requested DynamicField and store
    # it as a search param structure, so we can use it for all
    # following search requests
    my %ContactDFParameter;

    $ContactDFParameter{ 'DynamicField_' . $DynamicFieldContact->{Name} } = {
        Equals => $Self->{UserID},
    };

    # get a local ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my %NavBarFilter;
    my $Counter         = 0;
    my $AllTickets      = 0;
    my $AllTicketsTotal = 0;
    for my $Filter ( sort keys %{ $Filters{ $Self->{Subaction} } } ) {
        $Counter++;
        my $Count = $TicketObject->TicketSearch(
            %{ $Filters{ $Self->{Subaction} }->{$Filter}->{Search} },
            %SearchInArchive,
            %ContactDFParameter,
            Result => 'COUNT',
        );

        my $ClassLI = '';
        my $ClassA  = '';
        if ( $Filter eq $Self->{Filter} ) {
            $ClassA     = 'Selected';
            $AllTickets = $Count;
        }
        my $CounterTotal = keys %{ $Filters{ $Self->{Subaction} } };
        if ( $CounterTotal eq $Counter ) {
            $ClassLI = 'Last';
        }
        if ( $Filter eq 'All' ) {
            $AllTicketsTotal = $Count;
        }
        $NavBarFilter{ $Filters{ $Self->{Subaction} }->{$Filter}->{Prio} } = {
            %{ $Filters{ $Self->{Subaction} }->{$Filter} },
            Count   => $Count,
            Filter  => $Filter,
            ClassA  => $ClassA,
            ClassLI => $ClassLI,
        };
    }

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( !$AllTicketsTotal ) {
        $LayoutObject->Block(
            Name => 'Empty',
        );

        my $CustomTexts = $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverviewCustomEmptyText');

        if ( ref $CustomTexts eq 'HASH' ) {
            $LayoutObject->Block(
                Name => 'EmptyCustom',
                Data => $CustomTexts,
            );

            # only show button, if frontend module for NewTicket is registered
            # and button text is configured
            if (
                ref $ConfigObject->Get('CustomerFrontend::Module')->{CustomerTicketMessage}
                eq 'HASH'
                && defined $ConfigObject->Get('Ticket::Frontend::CustomerTicketOverviewCustomEmptyText')->{Button}
                )
            {
                $LayoutObject->Block(
                    Name => 'EmptyCustomButton',
                    Data => $CustomTexts,
                );
            }
        }
        else {
            $LayoutObject->Block(
                Name => 'EmptyDefault',
            );

            # only show button, if frontend module for NewTicket is registered
            if (
                ref $ConfigObject->Get('CustomerFrontend::Module')->{CustomerTicketMessage}
                eq 'HASH'
                )
            {
                $LayoutObject->Block(
                    Name => 'EmptyDefaultButton',
                );
            }
        }
    }
    else {

        # create & return output
        my $Link = 'SortBy=' . $LayoutObject->Ascii2Html( Text => $Self->{SortBy} )
            . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $Self->{OrderBy} )
            . ';Filter=' . $LayoutObject->Ascii2Html( Text => $Self->{Filter} )
            . ';Subaction=' . $LayoutObject->Ascii2Html( Text => $Self->{Subaction} )
            . ';';

        my %PageNav = $LayoutObject->PageNavBar(
            Limit     => 10000,
            StartHit  => $Self->{StartHit},
            PageShown => $Self->{PageShown},
            AllHits   => $AllTickets,
            Action    => 'Action=CustomerTicketContact',
            Link      => $Link,
            IDPrefix  => 'CustomerTicketContact',
        );

        my $OrderBy = 'Down';
        if ( $Self->{OrderBy} eq 'Down' ) {
            $OrderBy = 'Up';
        }
        my $Sort       = '';
        my $StateSort  = '';
        my $TicketSort = '';
        my $TitleSort  = '';
        my $AgeSort    = '';
        my $QueueSort  = '';

        # this sets the opposite to the $OrderBy
        if ( $OrderBy eq 'Down' ) {
            $Sort = 'SortAscending';
        }
        if ( $OrderBy eq 'Up' ) {
            $Sort = 'SortDescending';
        }

        if ( $Self->{SortBy} eq 'State' ) {
            $StateSort = $Sort;
        }
        elsif ( $Self->{SortBy} eq 'Ticket' ) {
            $TicketSort = $Sort;
        }
        elsif ( $Self->{SortBy} eq 'Title' ) {
            $TitleSort = $Sort;
        }
        elsif ( $Self->{SortBy} eq 'Age' ) {
            $AgeSort = $Sort;
        }
        elsif ( $Self->{SortBy} eq 'Queue' ) {
            $QueueSort = $Sort;
        }
        $LayoutObject->Block(
            Name => 'Filled',
            Data => {
                %Param,
                %PageNav,
                OrderBy    => $OrderBy,
                StateSort  => $StateSort,
                TicketSort => $TicketSort,
                TitleSort  => $TitleSort,
                AgeSort    => $AgeSort,
                Filter     => $Self->{Filter},
            },
        );

        if ( $Self->{Owner} ) {
            $LayoutObject->Block(
                Name => 'OverviewNavBarPageOwner',
            );
        }

        if ( $Self->{Queue} ) {
            $LayoutObject->Block(
                Name => 'OverviewNavBarPageQueue',
                Data => {
                    OrderBy   => $OrderBy,
                    QueueSort => $QueueSort,
                    Filter    => $Self->{Filter},
                },
            );
        }

        # show header filter
        for my $Key ( sort keys %NavBarFilter ) {
            $LayoutObject->Block(
                Name => 'FilterHeader',
                Data => {
                    DynamicFieldID => $DynamicFieldID,
                    %{ $NavBarFilter{$Key} },
                },
            );
        }

        # show footer filter - show only if more the one page is available
        if ( $AllTickets > $Self->{PageShown} ) {
            $LayoutObject->Block(
                Name => 'FilterFooter',
                Data => {
                    %Param,
                    %PageNav,
                },
            );
        }

        for my $Key ( sort keys %NavBarFilter ) {
            if ( $AllTickets > $Self->{PageShown} ) {
                $LayoutObject->Block(
                    Name => 'FilterFooterItem',
                    Data => {
                        DynamicFieldID => $DynamicFieldID,
                        %{ $NavBarFilter{$Key} },
                    },
                );
            }
        }

        # get dynamicfield backend object
        my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # Dynamic fields
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $Label = $DynamicFieldConfig->{Label};

            # get field sortable condition
            my $IsSortable = $DynamicFieldBackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsSortable',
            );

            if ($IsSortable) {
                my $CSS = '';
                if (
                    $Self->{SortBy}
                    && ( $Self->{SortBy} eq ( 'DynamicField_' . $DynamicFieldConfig->{Name} ) )
                    )
                {
                    if ( $Self->{OrderBy} && ( $Self->{OrderBy} eq 'Up' ) ) {
                        $OrderBy = 'Down';
                        $CSS .= ' SortDescending';
                    }
                    else {
                        $OrderBy = 'Up';
                        $CSS .= ' SortAscending';
                    }
                }

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField',
                    Data => {
                        %Param,
                        CSS => $CSS,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicFieldSortable',
                    Data => {
                        %Param,
                        OrderBy          => $OrderBy,
                        Label            => $Label,
                        DynamicFieldName => $DynamicFieldConfig->{Name},
                        Filter           => $Self->{Filter},
                    },
                );

                # example of dynamic fields order customization
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_' . $DynamicFieldConfig->{Name},
                    Data => {
                        %Param,
                        CSS => $CSS,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_'
                        . $DynamicFieldConfig->{Name}
                        . '_Sortable',
                    Data => {
                        %Param,
                        OrderBy          => $OrderBy,
                        Label            => $Label,
                        DynamicFieldName => $DynamicFieldConfig->{Name},
                        Filter           => $Self->{Filter},
                    },
                );
            }
            else {

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField',
                    Data => {
                        %Param,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicFieldNotSortable',
                    Data => {
                        %Param,
                        Label => $Label,
                    },
                );

                # example of dynamic fields order customization
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_' . $DynamicFieldConfig->{Name},
                    Data => {
                        %Param,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageDynamicField_'
                        . $DynamicFieldConfig->{Name}
                        . '_NotSortable',
                    Data => {
                        %Param,
                        Label => $Label,
                    },
                );
            }
        }

        my @ViewableTickets = $TicketObject->TicketSearch(
            %{ $Filters{ $Self->{Subaction} }->{ $Self->{Filter} }->{Search} },
            %SearchInArchive,
            %ContactDFParameter,
            Result => 'ARRAY',
            Limit  => 1_000,
        );

        # show tickets
        $Counter = 0;
        for my $TicketID (@ViewableTickets) {
            $Counter++;
            if (
                $Counter >= $Self->{StartHit}
                && $Counter < ( $Self->{PageShown} + $Self->{StartHit} )
                )
            {
                $Self->ShowTicketStatus( TicketID => $TicketID );
            }
        }
    }

    # create & return output
    my $Refresh = '';
    if ( $Self->{UserRefreshTime} ) {
        $Refresh = 60 * $Self->{UserRefreshTime};
    }

    my $Output = $LayoutObject->CustomerHeader(
        Title => $DynamicFieldContact->{Config}->{CustomerInterfaceTabName} || 'Contact Tickets',
        Refresh => $Refresh,
    );

    # build NavigationBar
    $Output .= $LayoutObject->CustomerNavigationBar();

    $Output .= $LayoutObject->Output(
        TemplateFile => 'CustomerTicketContact',
        Data         => {
            %Param,
            DynamicFieldID => $DynamicFieldID,
            }
    );

    # get page footer
    $Output .= $LayoutObject->CustomerFooter();

    # return page
    return $Output;
}

# ShowTicket
sub ShowTicketStatus {
    my ( $Self, %Param ) = @_;

    my $TicketID = $Param{TicketID} || return;

    # contains last article (non-internal)
    my %Article;

    # get a local ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # get whole article index
    my @ArticleIDs = $TicketObject->ArticleIndex(
        TicketID => $Param{TicketID},
    );

    # get article data
    if (@ArticleIDs) {
        my %LastNonInternalArticle;

        ARTICLEID:
        for my $ArticleID ( reverse @ArticleIDs ) {
            my %CurrentArticle = $TicketObject->ArticleGet(
                ArticleID => $ArticleID,
            );

            # check for non-internal article
            next ARTICLEID if $CurrentArticle{ArticleType} =~ m{internal}smx;

            # check for customer article
            if ( $CurrentArticle{SenderType} eq 'customer' ) {
                %Article = %CurrentArticle;
                last ARTICLEID;
            }

            # check for last non-internal article (sender type does not matter)
            if ( !%LastNonInternalArticle ) {
                %LastNonInternalArticle = %CurrentArticle;
            }
        }

        if ( !%Article && %LastNonInternalArticle ) {
            %Article = %LastNonInternalArticle;
        }
    }

    my $NoArticle;
    if ( !%Article ) {
        $NoArticle = 1;
    }

    # get ticket info
    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $TicketID,
        DynamicFields => 0,
    );

    my $Subject;

    # check if last customer subject or ticket title should be shown
    if ( $Self->{SmallViewColumnHeader} eq 'LastCustomerSubject' ) {
        $Subject = $Article{Subject} || '';
    }
    elsif ( $Self->{SmallViewColumnHeader} eq 'TicketTitle' ) {
        $Subject = $Ticket{Title};
    }

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # return ticket information if there is no article
    if ($NoArticle) {
        $Article{State}        = $Ticket{State};
        $Article{TicketNumber} = $Ticket{TicketNumber};
        $Article{CustomerAge}  = $LayoutObject->CustomerAge(
            Age   => $Ticket{Age},
            Space => ' '
        ) || 0;
        $Article{Body} = $Kernel::OM->Get('Kernel::Language')->Get('This item has no articles yet.');
    }

    # otherwise return article information
    else {
        $Article{CustomerAge} = $LayoutObject->CustomerAge(
            Age   => $Article{Age},
            Space => ' '
        ) || 0;
    }

    # customer info (customer name)
    if ( $Article{CustomerUserID} ) {
        $Param{CustomerName} = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
            UserLogin => $Article{CustomerUserID},
        );
        $Param{CustomerName} = '(' . $Param{CustomerName} . ')' if ( $Param{CustomerName} );
    }

    # if there is no subject try with Ticket title or set to Untitled
    if ( !$Subject ) {
        $Subject = $Ticket{Title} || 'Untitled!';
    }

    # condense down the subject
    $Subject = $TicketObject->TicketSubjectClean(
        TicketNumber => $Article{TicketNumber},
        Subject      => $Subject,
    );

    # add block
    $LayoutObject->Block(
        Name => 'Record',
        Data => {
            %Article,
            %Ticket,
            Subject => $Subject,
            %Param,
        },
    );

    if ( $Self->{Owner} ) {
        my $OwnerName = $Kernel::OM->Get('Kernel::System::User')->UserName(
            UserID => $Ticket{OwnerID},
        );
        $LayoutObject->Block(
            Name => 'RecordOwner',
            Data => {
                OwnerName => $OwnerName,
            },
        );
    }
    if ( $Self->{Queue} ) {
        $LayoutObject->Block(
            Name => 'RecordQueue',
            Data => {
                %Ticket,
            },
        );
    }

    # get dynamicfield backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # Dynamic fields
    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get field value
        my $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Ticket{TicketID},
        );

        my $ValueStrg = $DynamicFieldBackendObject->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            ValueMaxChars      => 20,
            LayoutObject       => $LayoutObject,
        );

        $LayoutObject->Block(
            Name => 'RecordDynamicField',
            Data => {
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );

        if ( $ValueStrg->{Link} ) {
            $LayoutObject->Block(
                Name => 'RecordDynamicFieldLink',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'RecordDynamicFieldPlain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }

        # example of dynamic fields order customization
        $LayoutObject->Block(
            Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name},
            Data => {
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );

        if ( $ValueStrg->{Link} ) {
            $LayoutObject->Block(
                Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name} . 'Link',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'RecordDynamicField' . $DynamicFieldConfig->{Name} . 'Plain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }
    }
}

sub _DisplayError {
    my ( $Self, %Param ) = @_;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = $LayoutObject->CustomerHeader( Title => 'Error' );
    $Output .= $LayoutObject->CustomerError(
        Message => $Param{Message} || '',
    );
    $Output .= $LayoutObject->CustomerFooter();

    return $Output;
}

1;
