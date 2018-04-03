# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentNotificationView;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'Dismiss' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_NotificationDismiss();
    }

    if ( $Self->{Subaction} eq 'MarkAsSeen' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_NotificationMarkAsSeen();
    }

    # get needed object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get config
    my $Config = $ConfigObject->Get("NotificationView::Frontend::$Self->{Action}");

    my $SortBy = $ParamObject->GetParam( Param => 'SortBy' )
        || $Config->{'SortBy::Default'}
        || 'Age';
    my $OrderBy = $ParamObject->GetParam( Param => 'OrderBy' )
        || $Config->{'Order::Default'}
        || 'Up';

    # store last queue screen
    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenOverview',
        Value     => $Self->{RequestedURL},
    );

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # get filters stored in the user preferences
    my %Preferences = $UserObject->GetPreferences(
        UserID => $Self->{UserID},
    );

    my $StoredFiltersKey = 'UserStoredFilterColumns-' . $Self->{Action};
    my $JSONObject       = $Kernel::OM->Get('Kernel::System::JSON');
    my $StoredFilters    = $JSONObject->Decode(
        Data => $Preferences{$StoredFiltersKey},
    );

    # delete stored filters if needed
    if ( $ParamObject->GetParam( Param => 'DeleteFilters' ) ) {
        $StoredFilters = {};
    }

    # get the column filters from the web request or user preferences
    my %ColumnFilter;
    my %GetColumnFilter;
    COLUMNNAME:
    for my $ColumnName (qw(Name ObjectReference ObjectType)) {

        # get column filter from web request
        my $FilterValue = $ParamObject->GetParam( Param => 'ColumnFilter' . $ColumnName )
            || '';

        next COLUMNNAME if $FilterValue eq '';
        next COLUMNNAME if $FilterValue eq 'DeleteFilter';

        if ( $ColumnName eq 'ObjectReference' ) {
            push @{ $ColumnFilter{ObjectReferences} }, $FilterValue;
            $GetColumnFilter{$ColumnName} = $FilterValue;
        }
        else {
            push @{ $ColumnFilter{$ColumnName} }, $FilterValue;
            $GetColumnFilter{$ColumnName} = $FilterValue;
        }
    }

    # starting with page ...
    my $Refresh = '';
    if ( $Self->{UserRefreshTime} ) {
        $Refresh = 60 * $Self->{UserRefreshTime};
    }
    my $Output;

    if ( $Self->{Subaction} ne 'AJAXFilterUpdate' ) {
        $Output = $LayoutObject->Header(
            Refresh => $Refresh,
        );
        $Output .= $LayoutObject->NavigationBar();
    }

    # define filter
    my %Filters = (
        All => {
            Name   => $LayoutObject->{LanguageObject}->Translate('All Notifications'),
            Prio   => 1000,
            CSS    => 'FilterAll',
            Search => {
                OrderBy => $OrderBy,
                SortBy  => $SortBy,
                UserIDs => [ $Self->{UserID} ],
            },
        },
        Seen => {
            Name   => $LayoutObject->{LanguageObject}->Translate('Seen Notifications'),
            Prio   => 1001,
            CSS    => 'FilterSeen',
            Search => {
                Seen    => [1],
                OrderBy => $OrderBy,
                SortBy  => $SortBy,
                UserIDs => [ $Self->{UserID} ],
            },
        },
        Unseen => {
            Name   => $LayoutObject->{LanguageObject}->Translate('Unseen Notifications'),
            Prio   => 1002,
            CSS    => 'FilterUnseen',
            Search => {
                Seen    => [0],
                OrderBy => $OrderBy,
                SortBy  => $SortBy,
                UserIDs => [ $Self->{UserID} ],
            },
        },
    );

    # get object type settings
    my $ObjectTypeConfig = $ConfigObject->Get('NotificationView::ObjectType') || {};

    my $ObjectTypeCounter = scalar keys %{$ObjectTypeConfig};

    # add enabled object types to the static filters (only if there are more than one)
    if ( $ObjectTypeCounter > 1 ) {
        for my $ObjectType (
            sort { $ObjectTypeConfig->{$a}->{FilterPrio} <=> $ObjectTypeConfig->{$b}->{FilterPrio} }
            keys %{$ObjectTypeConfig}
            )
        {
            $Filters{$ObjectType} = {
                Name   => "$ObjectType Notifications",
                Prio   => $ObjectTypeConfig->{$ObjectType}->{FilterPrio},
                CSS    => "Filter$ObjectType",
                Search => {
                    ObjectTypes => [$ObjectType],
                    OrderBy     => $OrderBy,
                    SortBy      => $SortBy,
                    UserIDs     => [ $Self->{UserID} ],
                },
            };
        }
    }

    my $Filter = $ParamObject->GetParam( Param => 'Filter' ) || 'All';

    # check if filter is valid
    if ( !$Filters{$Filter} ) {
        $LayoutObject->FatalError( Message => "Invalid Filter: $Filter!" );
    }

    # do shown notification lookup
    my $Limit = 10_000;

    my $ElementChanged = $ParamObject->GetParam( Param => 'ElementChanged' ) || '';
    my $HeaderColumn = $ElementChanged;
    $HeaderColumn =~ s{\A ColumnFilter }{}msxg;
    my @OriginalViewableNotifications;
    my @ViewableNotifications;
    my $ViewableNotificationCount = 0;

    # get notification view object
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

    # get notification values
    if (
        !IsStringWithData($HeaderColumn)
        || (
            IsStringWithData($HeaderColumn)
            && (
                $ConfigObject->Get('OnlyValuesOnTicket')
            )
        )
        )
    {

        @OriginalViewableNotifications = $NotificationViewObject->NotificationSearch(
            %{ $Filters{$Filter}->{Search} },
            Limit  => $Limit,
            Result => 'ARRAY',
        );

        @ViewableNotifications = $NotificationViewObject->NotificationSearch(
            %{ $Filters{$Filter}->{Search} },
            %ColumnFilter,
            Limit  => $Limit,
            Result => 'ARRAY',
        );

        $ViewableNotificationCount = $NotificationViewObject->NotificationSearch(
            %{ $Filters{$Filter}->{Search} },
            %ColumnFilter,
            Result => 'COUNT',
        );
    }

    my $View = $ParamObject->GetParam( Param => 'View' ) || '';

    if ( $Self->{Subaction} eq 'AJAXFilterUpdate' ) {

        my $FilterContent = $LayoutObject->NotificationViewListShow(
            FilterContentOnly       => 1,
            HeaderColumn            => $HeaderColumn,
            ElementChanged          => $ElementChanged,
            OriginalNotificationIDs => \@OriginalViewableNotifications,
            Action                  => 'AgentNotificationView',
            Env                     => $Self,
            View                    => $View,
            EnableColumnFilters     => 1,
        );

        if ( !$FilterContent ) {
            $LayoutObject->FatalError(
                Message => "Can't get filter content data of $HeaderColumn!",
            );
        }

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $FilterContent,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    else {

        # store column filters
        my $StoredFilters = \%ColumnFilter;

        my $StoredFiltersKey = 'UserStoredFilterColumns-' . $Self->{Action};
        $UserObject->SetPreferences(
            UserID => $Self->{UserID},
            Key    => $StoredFiltersKey,
            Value  => $JSONObject->Encode( Data => $StoredFilters ),
        );
    }

    if ( $ViewableNotificationCount > $Limit ) {
        $ViewableNotificationCount = $Limit;
    }

    # do nav bar lookup
    my %NavBarFilter;
    for my $Filter ( sort keys %Filters ) {
        my $Count = $NotificationViewObject->NotificationSearch(
            %{ $Filters{$Filter}->{Search} },
            %ColumnFilter,
            Result => 'COUNT',
        );
        if ( $Count > $Limit ) {
            $Count = $Limit;
        }

        $NavBarFilter{ $Filters{$Filter}->{Prio} } = {
            Count  => $Count,
            Filter => $Filter,
            %{ $Filters{$Filter} },
        };
    }

    my $ColumnFilterLink = '';
    COLUMNNAME:
    for my $ColumnName ( sort keys %GetColumnFilter ) {
        next COLUMNNAME if !$ColumnName;
        next COLUMNNAME if !$GetColumnFilter{$ColumnName};
        $ColumnFilterLink
            .= ';' . $LayoutObject->Ascii2Html( Text => 'ColumnFilter' . $ColumnName )
            . '=' . $LayoutObject->Ascii2Html( Text => $GetColumnFilter{$ColumnName} )
    }

    # show notification's
    my $LinkPage = 'Filter='
        . $LayoutObject->Ascii2Html( Text => $Filter )
        . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
        . ';SortBy=' . $LayoutObject->Ascii2Html( Text => $SortBy )
        . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $OrderBy )
        . $ColumnFilterLink
        . ';';

    my $LinkSort = 'Filter='
        . $LayoutObject->Ascii2Html( Text => $Filter )
        . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
        . $ColumnFilterLink

        . ';';
    my $FilterLink = 'SortBy=' . $LayoutObject->Ascii2Html( Text => $SortBy )
        . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $OrderBy )
        . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
        . ';';

    my $LastColumnFilter = $ParamObject->GetParam( Param => 'LastColumnFilter' ) || '';

    if ( !$LastColumnFilter && $ColumnFilterLink ) {

        # is planned to have a link to go back here
        $LastColumnFilter = 1;
    }

    $Output .= $LayoutObject->NotificationViewListShow(
        NotificationIDs         => \@ViewableNotifications,
        OriginalNotificationIDs => \@OriginalViewableNotifications,
        GetColumnFilter         => \%GetColumnFilter,
        LastColumnFilter        => $LastColumnFilter,
        Action                  => 'AgentNotificationView',
        RequestedURL            => $Self->{RequestedURL},

        Total      => $ViewableNotificationCount,
        Env        => $Self,
        LinkPage   => $LinkPage,
        LinkSort   => $LinkSort,
        View       => $View,
        Bulk       => 1,
        Limit      => $Limit,
        TitleName  => $LayoutObject->{LanguageObject}->Translate('Notification Web View'),
        TitleValue => $Filters{$Filter}->{Name},

        Filter     => $Filter,
        Filters    => \%NavBarFilter,
        FilterLink => $FilterLink,

        OrderBy             => $OrderBy,
        SortBy              => $SortBy,
        EnableColumnFilters => 1,
        ColumnFilterForm    => {
            Filter => $Filter || '',
        },

        # do not print the result earlier, but return complete content
        Output => 1,
    );

    # get page footer
    $Output .= $LayoutObject->Footer();

    # return page
    return $Output;
}

sub _NotificationDismiss {

    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ParamObject            = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject           = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

    my @NotificationIDs = $ParamObject->GetArray( Param => 'NotificationID' );

    my $OverallSuccess = 1;

    NOTIFICATION:
    for my $NotificationID (@NotificationIDs) {

        next NOTIFICATION if !$NotificationID;

        my $Success = $NotificationViewObject->NotificationDelete(
            NotificationID => $NotificationID,
            UserID         => $Self->{UserID},
        );

        if ( !$Success ) {
            $OverallSuccess = 0;
        }
    }

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => {
            Success => $OverallSuccess,
        },
    );

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _NotificationMarkAsSeen {

    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ParamObject            = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject           = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

    my $NotificationID = $ParamObject->GetParam( Param => 'NotificationID' );

    my $Success;
    if ($NotificationID) {
        $Success = $NotificationViewObject->NotificationSeenSet(
            NotificationID => $NotificationID,
            Seen           => 1,
            UserID         => $Self->{UserID},
        );
    }

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => {
            Success => $Success,
        },
    );

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}
1;
