# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentContactSearch;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Web::Request',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::CustomerUser',
    'Kernel::System::DB',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get config
    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $JSON = '';

    # get a local objects
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # search customers
    if ( !$Self->{Subaction} ) {

        # get needed params
        my $Search = $ParamObject->GetParam( Param => 'Term' ) || '';
        my $MaxResults = int( $ParamObject->GetParam( Param => 'MaxResults' ) || 20 );

        for my $Needed (qw(FilterAttribute FilterValue)) {

            $Param{$Needed} = $ParamObject->GetParam( Param => $Needed );

            if ( !$Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Need $Needed!",
                );

                return $Self->_Return( Data => {} );
            }
        }

        # get customer list
        my %CustomerUserList = $CustomerUserObject->CustomerSearch(
            Search => $Search,
        );

        # build data
        my @Data;
        my $MaxResultCount = $MaxResults;
        CUSTOMERUSERID:
        for my $CustomerUserID (
            sort { $CustomerUserList{$a} cmp $CustomerUserList{$b} }
            keys %CustomerUserList
            )
        {
            my %TmpUser = $CustomerUserObject->CustomerUserDataGet(
                User => $CustomerUserID,
            );
            if (
                !%TmpUser
                || !$TmpUser{ $Param{FilterAttribute} }
                || $TmpUser{ $Param{FilterAttribute} } ne $Param{FilterValue}
                )
            {
                next CUSTOMERUSERID;
            }

            push @Data, {
                CustomerKey   => $CustomerUserID,
                CustomerValue => $CustomerUserList{$CustomerUserID},
            };

            $MaxResultCount--;
            last CUSTOMERUSERID if $MaxResultCount <= 0;
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => \@Data,
        );
    }

    # get customer info
    elsif ( $Self->{Subaction} eq 'CustomerInfo' ) {

        # get params
        my $CustomerUserID = $ParamObject->GetParam( Param => 'CustomerUserID' ) || '';

        my $CustomerID              = '';
        my $CustomerTableHTMLString = '';

        # get customer data
        my %CustomerData = $CustomerUserObject->CustomerUserDataGet(
            User => $CustomerUserID,
        );

        # get customer id
        if ( $CustomerData{UserCustomerID} ) {
            $CustomerID = $CustomerData{UserCustomerID};
        }

        # get config object
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # build html for customer info table
        if ( $ConfigObject->Get('Ticket::Frontend::CustomerInfoCompose') ) {

            $CustomerTableHTMLString = $LayoutObject->AgentCustomerViewTable(
                Data => {%CustomerData},
                Max  => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
            );
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                CustomerID              => $CustomerID,
                CustomerTableHTMLString => $CustomerTableHTMLString,
            },
        );
    }

    # get customer tickets
    elsif ( $Self->{Subaction} eq 'CustomerTickets' ) {

        # get params
        my $CustomerUserID = $ParamObject->GetParam( Param => 'CustomerUserID' ) || '';
        my $CustomerID     = $ParamObject->GetParam( Param => 'CustomerID' )     || '';

        # get secondary customer ids
        my @CustomerIDs;
        if ($CustomerUserID) {
            @CustomerIDs = $CustomerUserObject->CustomerIDs(
                User => $CustomerUserID,
            );
        }

        # add own customer id
        if ($CustomerID) {
            push @CustomerIDs, $CustomerID;
        }

        my $View    = $ParamObject->GetParam( Param => 'View' )    || '';
        my $SortBy  = $ParamObject->GetParam( Param => 'SortBy' )  || 'Age';
        my $OrderBy = $ParamObject->GetParam( Param => 'OrderBy' ) || 'Down';

        my @ViewableTickets;
        if (@CustomerIDs) {

            # get db object
            my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

            my @CustomerIDsEscaped;
            for my $CustomerID (@CustomerIDs) {
                push @CustomerIDsEscaped,
                    $DBObject->QueryStringEscape( QueryString => $CustomerID );
            }

            @ViewableTickets = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSearch(
                Result     => 'ARRAY',
                Limit      => 250,
                SortBy     => [$SortBy],
                OrderBy    => [$OrderBy],
                CustomerID => \@CustomerIDsEscaped,
                UserID     => $Self->{UserID},
                Permission => 'ro',
            );
        }

        my $LinkSort = 'Subaction=' . $Self->{Subaction}
            . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';
        my $LinkPage = 'Subaction=' . $Self->{Subaction}
            . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
            . ';SortBy=' . $LayoutObject->Ascii2Html( Text => $SortBy )
            . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $OrderBy )
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';
        my $LinkFilter = 'Subaction=' . $Self->{Subaction}
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';

        my $CustomerTicketsHTMLString = '';
        if (@ViewableTickets) {
            $CustomerTicketsHTMLString .= $LayoutObject->TicketListShow(
                TicketIDs  => \@ViewableTickets,
                Total      => scalar @ViewableTickets,
                Env        => $Self,
                View       => $View,
                TitleName  => 'Customer history',
                LinkPage   => $LinkPage,
                LinkSort   => $LinkSort,
                LinkFilter => $LinkFilter,
                Output     => 'raw',

                OrderBy => $OrderBy,
                SortBy  => $SortBy,
                AJAX    => 1,
            );
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                CustomerTicketsHTMLString => $CustomerTicketsHTMLString,
            },
        );
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );

}

sub _Return {
    my ( $Self, %Param ) = @_;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => [],
    );

    if ( IsArrayRefWithData( $Param{Data} ) ) {
        $JSON = $LayoutObject->JSONEncode(
            Data => $Param{Data},
        );
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
