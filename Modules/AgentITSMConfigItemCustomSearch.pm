# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMConfigItemCustomSearch;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get config of normal search front-end module
    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get("ITSMConfigItem::Frontend::AgentITSMConfigItemSearch");

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $SearchProfileObject  = $Kernel::OM->Get('Kernel::System::SearchProfile');

    # prepare output container
    my $Output;

    # get config data
    $Self->{StartHit} = int( $ParamObject->GetParam( Param => 'StartHit' ) || 1 );
    $Self->{SearchLimit} = $Self->{Config}->{SearchLimit} || 10000;
    $Self->{SortBy} = $ParamObject->GetParam( Param => 'SortBy' )
        || $Self->{Config}->{'SortBy::Default'}
        || 'Number';
    $Self->{OrderBy} = $ParamObject->GetParam( Param => 'OrderBy' )
        || $Self->{Config}->{'Order::Default'}
        || 'Down';
    $Self->{Profile}     = $ParamObject->GetParam( Param => 'Profile' )     || '';
    $Self->{SaveProfile} = $ParamObject->GetParam( Param => 'SaveProfile' ) || '';
    $Self->{TakeLastSearch} = $ParamObject->GetParam( Param => 'TakeLastSearch' );

    # get class ids
    my @ClassIDs = $ParamObject->GetArray( Param => 'ClassID' );
    my $ClassIDString = join ':', @ClassIDs;

    # get single params
    my %GetParam;

    # load profiles string params
    if ( ( @ClassIDs && $Self->{Profile} ) && $Self->{TakeLastSearch} ) {
        %GetParam = $SearchProfileObject->SearchProfileGet(
            Base      => 'ConfigItemSearch' . $ClassIDString,
            Name      => $Self->{Profile},
            UserLogin => $Self->{UserLogin},
        );
    }

    # get class list
    my $ClassList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );

    # check for access rights on the classes
    for my $ClassID ( sort keys %{$ClassList}, @ClassIDs ) {
        my $HasAccess = $ConfigItemObject->Permission(
            Type    => $Self->{Config}->{Permission},
            Scope   => 'Class',
            ClassID => $ClassID,
            UserID  => $Self->{UserID},
        );

        delete $ClassList->{$ClassID} if !$HasAccess;
    }

    # ------------------------------------------------------------ #
    # show the search form
    # ------------------------------------------------------------ #
    if ( !$Self->{Subaction} ) {

        # if no classes were selected, set all classes as default
        if ( !@ClassIDs ) {
            @ClassIDs = sort keys %{$ClassList};
        }

        # generate drop-down for selecting the classes
        my $ClassOptionStrg = $LayoutObject->BuildSelection(
            Data        => $ClassList,
            Name        => 'ClassID',
            SelectedID  => \@ClassIDs,
            Translation => 0,
            Size        => 5,
            Multiple    => 1,
        );

        # get deployment state list
        my $DeplStateList = $GeneralCatalogObject->ItemList(
            Class => 'ITSM::ConfigItem::DeploymentState',
        );

        # generate drop-down for selecting the wanted deployment states
        my $CurDeplStateOptionStrg = $LayoutObject->BuildSelection(
            Data       => $DeplStateList,
            Name       => 'DeplStateIDs',
            SelectedID => $GetParam{DeplStateIDs} || [],
            Size       => 5,
            Multiple   => 1,
        );

        # get incident state list
        my $InciStateList = $GeneralCatalogObject->ItemList(
            Class => 'ITSM::Core::IncidentState',
        );

        # generate drop-down for selecting the wanted incident states
        my $CurInciStateOptionStrg = $LayoutObject->BuildSelection(
            Data       => $InciStateList,
            Name       => 'InciStateIDs',
            SelectedID => $GetParam{InciStateIDs} || [],
            Size       => 5,
            Multiple   => 1,
        );

        # build customer search auto-complete field
        my $AutoCompleteConfig = $ConfigObject->Get('AutoComplete::Agent')->{CustomerSearch};

        $LayoutObject->Block(
            Name => 'CustomerSearchAutoComplete',
            Data => {
                minQueryLength      => $AutoCompleteConfig->{MinQueryLength}      || 2,
                queryDelay          => $AutoCompleteConfig->{QueryDelay}          || 100,
                typeAhead           => $AutoCompleteConfig->{TypeAhead}           || 'false',
                maxResultsDisplayed => $AutoCompleteConfig->{MaxResultsDisplayed} || 20,
                dynamicWidth        => $AutoCompleteConfig->{DynamicWidth}        || 1,
            },
        );

        # get the configured xml search fields
        my $ConfiguredXMLFields = $ConfigObject->Get('ITSMConfigItem::CustomSearchXMLFields');

        my @XMLAttributes;
        my %InputKeyCounter;
        CLASSID:
        for my $ClassID ( sort @ClassIDs ) {

            # get current definition
            my $XMLDefinition = $ConfigItemObject->DefinitionGet(
                ClassID => $ClassID,
            );

            # abort, if no definition is defined
            if ( !$XMLDefinition->{DefinitionID} ) {
                return $LayoutObject->ErrorScreen(
                    Message => "No Definition was defined for class $ClassID!",
                    Comment => 'Please contact the admin.',
                );
            }

            # output xml search form
            if ( $XMLDefinition->{Definition} ) {
                $Self->_XMLSearchFormOutput(
                    XMLDefinition       => $XMLDefinition->{DefinitionRef},
                    XMLAttributes       => \@XMLAttributes,
                    GetParam            => \%GetParam,
                    ActiveAutoComplete  => $AutoCompleteConfig->{Active},
                    ConfiguredXMLFields => $ConfiguredXMLFields,
                    InputKeyCounter     => \%InputKeyCounter,
                );

                # get the unique xml attributes
                my %UniqueXMLAttributes = map { $_->{Key} => $_->{Value} } @XMLAttributes;
                @XMLAttributes = map {
                    {
                        Key   => $_,
                        Value => $UniqueXMLAttributes{$_},
                    }
                } sort keys %UniqueXMLAttributes;
            }
        }

        # build output format string
        my $ResultFormStrg = $LayoutObject->BuildSelection(
            Name => 'ResultForm',
            Data => {
                Normal => 'Normal',
                CSV    => 'CSV',
            },
            SelectedID => $GetParam{ResultForm} || 'Normal',
            Translation => 1,
        );

        # show default search screen
        $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # output template
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentITSMConfigItemCustomSearch',
            Data         => {
                ClassOptionStrg        => $ClassOptionStrg,
                CurDeplStateOptionStrg => $CurDeplStateOptionStrg,
                CurInciStateOptionStrg => $CurInciStateOptionStrg,
                ResultFormStrg         => $ResultFormStrg,
            },
        );

        # output footer
        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # perform search
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Search' ) {

        my $SearchDialog = $ParamObject->GetParam( Param => 'SearchDialog' );

        $GetParam{ResultForm} = $ParamObject->GetParam( Param => 'ResultForm' );

        # fill up profile name (e.g. with last-search)
        if ( !$Self->{Profile} || !$Self->{SaveProfile} ) {
            $Self->{Profile} = 'last-search';
        }

        # ClassIDs is required for the search mask and for actual searching
        if ( !@ClassIDs ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No ClassIDs are given!',
                Comment => 'Please contact the admin.',
            );
        }

        # store last overview screen
        my $URL = "Action=AgentITSMConfigItemCustomSearch;Profile=$Self->{Profile};"
            . "TakeLastSearch=1;StartHit=$Self->{StartHit}";

        my $ClassIDParamString = '';
        for my $ClassID (@ClassIDs) {
            $ClassIDParamString .= ";ClassID=$ClassID";
        }
        $URL .= $ClassIDParamString;

        # get session object
        my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

        $SessionObject->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastScreenOverview',
            Value     => $URL,
        );
        $SessionObject->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastScreenView',
            Value     => $URL,
        );

        # get xml search form
        my $XMLFormData = [];
        my $XMLGetParam = [];

        my %InputKeyCounter;
        for my $ClassID (@ClassIDs) {

            # check if user is allowed to search class
            my $HasAccess = $ConfigItemObject->Permission(
                Type    => $Self->{Config}->{Permission},
                Scope   => 'Class',
                ClassID => $ClassID,
                UserID  => $Self->{UserID},
            );

            # show error screen
            if ( !$HasAccess ) {
                return $LayoutObject->ErrorScreen(
                    Message => 'No access rights for this class given!',
                    Comment => 'Please contact the admin.',
                );
            }

            # get current definition
            my $XMLDefinition = $ConfigItemObject->DefinitionGet(
                ClassID => $ClassID,
            );

            # abort, if no definition is defined
            if ( !$XMLDefinition->{DefinitionID} ) {
                return $LayoutObject->ErrorScreen(
                    Message => "No Definition was defined for class $ClassID!",
                    Comment => 'Please contact the admin.',
                );
            }

            $Self->_XMLSearchFormGet(
                XMLDefinition   => $XMLDefinition->{DefinitionRef},
                XMLFormData     => $XMLFormData,
                XMLGetParam     => $XMLGetParam,
                InputKeyCounter => \%InputKeyCounter,
                %GetParam,
            );
        }

        if ( @{$XMLFormData} ) {
            $GetParam{What} = $XMLFormData;
        }

        # get array search attributes
        FORMARRAY:
        for my $FormArray (qw(DeplStateIDs InciStateIDs)) {

            my @Array = $ParamObject->GetArray( Param => $FormArray );

            next FORMARRAY if !@Array;

            $GetParam{$FormArray} = \@Array;
        }

        # get name search attribute
        $GetParam{Name} = $ParamObject->GetParam( Param => 'Name' ) || '';
        $GetParam{Name} = '*' . $GetParam{Name} . '*';

        # save search profile (under last-search or real profile name)
        $Self->{SaveProfile} = 1;

        # remember last search values only if search is called from a search dialog
        # not from results page
        if ( $Self->{SaveProfile} && $Self->{Profile} && $SearchDialog ) {

            # remove old profile stuff
            $SearchProfileObject->SearchProfileDelete(
                Base      => 'ConfigItemSearch' . $ClassIDString,
                Name      => $Self->{Profile},
                UserLogin => $Self->{UserLogin},
            );

            # insert new profile params
            for my $Key ( sort keys %GetParam ) {
                if ( $GetParam{$Key} && $Key ne 'What' ) {
                    $SearchProfileObject->SearchProfileAdd(
                        Base      => 'ConfigItemSearch' . $ClassIDString,
                        Name      => $Self->{Profile},
                        Key       => $Key,
                        Value     => $GetParam{$Key},
                        UserLogin => $Self->{UserLogin},
                    );
                }
            }

            # insert new profile params also from XMLform
            if ( @{$XMLGetParam} ) {
                for my $Parameter ( @{$XMLGetParam} ) {
                    for my $Key ( sort keys %{$Parameter} ) {
                        if ( $Parameter->{$Key} ) {
                            $SearchProfileObject->SearchProfileAdd(
                                Base      => 'ConfigItemSearch' . $ClassIDString,
                                Name      => $Self->{Profile},
                                Key       => $Key,
                                Value     => $Parameter->{$Key},
                                UserLogin => $Self->{UserLogin},
                            );

                        }
                    }
                }
            }
        }

        my $SearchResultList = [];

        # start search if called from a search dialog or from a results page
        if ( $SearchDialog || $Self->{TakeLastSearch} ) {

            # start search
            $SearchResultList = $ConfigItemObject->ConfigItemSearchExtended(
                %GetParam,
                OrderBy          => [ $Self->{SortBy} ],
                OrderByDirection => [ $Self->{OrderBy} ],
                Limit            => $Self->{SearchLimit},
                ClassIDs         => \@ClassIDs,
            );
        }

        # CSV output
        if ( $GetParam{ResultForm} eq 'CSV' ) {
            my @CSVData;
            my @CSVHead;

            CONFIGITEMID:
            for my $ConfigItemID ( @{$SearchResultList} ) {

                # check for access rights
                my $HasAccess = $ConfigItemObject->Permission(
                    Scope  => 'Item',
                    ItemID => $ConfigItemID,
                    UserID => $Self->{UserID},
                    Type   => $Self->{Config}->{Permission},
                );

                next CONFIGITEMID if !$HasAccess;

                # get version
                my $LastVersion = $ConfigItemObject->VersionGet(
                    ConfigItemID => $ConfigItemID,
                    XMLDataGet   => 0,
                );

                # csv quote
                if ( !@CSVHead ) {
                    @CSVHead = @{ $Self->{Config}->{SearchCSVData} };
                }

                # store data
                my @Data;
                for my $Attribute (qw(Class InciState Name Number DeplState VersionID CreateTime)) {
                    push @Data, $LastVersion->{$Attribute};
                }
                push @CSVData, \@Data;
            }

            # csv quote
            # translate non existing header may result in a garbage file
            if ( !@CSVHead ) {
                @CSVHead = @{ $Self->{Config}->{SearchCSVData} };
            }

            # translate headers
            for my $Header (@CSVHead) {

                # replace FAQNumber header with the current FAQHook from config
                if ( $Header eq 'ConfigItemNumber' ) {
                    $Header = $ConfigObject->Get('ITSMConfigItem::Hook');
                }
                else {
                    $Header = $LayoutObject->{LanguageObject}->Translate($Header);
                }
            }

            # CSV data
            my $CSV = $Kernel::OM->Get('Kernel::System::CSV')->Array2CSV(
                Head      => \@CSVHead,
                Data      => \@CSVData,
                Separator => $Self->{UserCSVSeparator},
            );

            # get time object
            my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

            # return csv to download
            my $CSVFile = 'configitem_search';
            my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->SystemTime(),
            );
            $M = sprintf( "%02d", $M );
            $D = sprintf( "%02d", $D );
            $h = sprintf( "%02d", $h );
            $m = sprintf( "%02d", $m );
            return $LayoutObject->Attachment(
                Filename    => $CSVFile . "_" . "$Y-$M-$D" . "_" . "$h-$m.csv",
                ContentType => "text/csv; charset=" . $LayoutObject->{UserCharset},
                Content     => $CSV,
            );
        }

        # normal HTML output
        else {

            # start html page
            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $LayoutObject->Print( Output => \$Output );
            $Output = '';

            $Self->{Filter} = $ParamObject->GetParam( Param => 'Filter' ) || '';
            $Self->{View}   = $ParamObject->GetParam( Param => 'View' )   || '';

            # show config items
            my $LinkPage = 'Filter='
                . $LayoutObject->Ascii2Html( Text => $Self->{Filter} )
                . ';View=' . $LayoutObject->Ascii2Html( Text => $Self->{View} )
                . ';SortBy=' . $LayoutObject->Ascii2Html( Text => $Self->{SortBy} )
                . ';OrderBy='
                . $LayoutObject->Ascii2Html( Text => $Self->{OrderBy} )
                . ';Profile=' . $Self->{Profile} . ';TakeLastSearch=1;Subaction=Search'
                . $ClassIDParamString
                . ';';
            my $LinkSort = 'Filter='
                . $LayoutObject->Ascii2Html( Text => $Self->{Filter} )
                . ';View=' . $LayoutObject->Ascii2Html( Text => $Self->{View} )
                . ';Profile=' . $Self->{Profile} . ';TakeLastSearch=1;Subaction=Search'
                . $ClassIDParamString
                . ';';
            my $LinkFilter = 'TakeLastSearch=1;Subaction=Search;Profile='
                . $LayoutObject->Ascii2Html( Text => $Self->{Profile} )
                . $ClassIDParamString
                . ';';
            my $LinkBack = 'Subaction=LoadProfile;Profile='
                . $LayoutObject->Ascii2Html( Text => $Self->{Profile} )
                . $ClassIDParamString
                . ';TakeLastSearch=1;';

            # find out which columns should be shown
            my @ShowColumns;
            if ( $Self->{Config}->{ShowColumns} ) {

                # get all possible columns from config
                my %PossibleColumn = %{ $Self->{Config}->{ShowColumns} };

                # add the class column
                $PossibleColumn{Class} = 1;

                # get the column names that should be shown
                COLUMNNAME:
                for my $Name ( sort keys %PossibleColumn ) {
                    next COLUMNNAME if !$PossibleColumn{$Name};
                    push @ShowColumns, $Name;
                }
            }

            my $Title = $LayoutObject->{LanguageObject}->Translate('Config Item Search Results');

            $Output .= $LayoutObject->ITSMConfigItemListShow(
                ConfigItemIDs => $SearchResultList,
                Total         => scalar @{$SearchResultList},
                View          => $Self->{View},
                Env           => $Self,
                LinkPage      => $LinkPage,
                LinkSort      => $LinkSort,
                LinkFilter    => $LinkFilter,
                Profile       => $Self->{Profile},
                TitleName     => $Title,
                ShowColumns   => \@ShowColumns,
                SortBy        => $LayoutObject->Ascii2Html( Text => $Self->{SortBy} ),
                OrderBy       => $LayoutObject->Ascii2Html( Text => $Self->{OrderBy} ),
                Filter => 'placeholder',    # required to allow headers of xml attributes
            );

            # build footer
            $Output .= $LayoutObject->Footer();

            return $Output;
        }
    }
}

sub _XMLSearchFormOutput {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam = %{ $Param{GetParam} };

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if !$Param{ConfiguredXMLFields};
    return if !$Param{InputKeyCounter};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLAttributes} ne 'ARRAY';
    return if ref $Param{ConfiguredXMLFields} ne 'HASH';
    return if ref $Param{InputKeyCounter} ne 'HASH';

    $Param{Level} ||= 0;
    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # set prefix
        my $InputKey = $Item->{Key};
        my $Name     = $Item->{Name};
        my $Optional = 0;
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
            $Name     = $Param{PrefixName} . '::' . $Name;
        }

        # output attribute, if marked as researchable
        if ( $Item->{Searchable} ) {

            # render only configured input search fields
            next ITEM if !$Param{ConfiguredXMLFields}->{$InputKey};

            # the field was already rendered
            next ITEM if $Param{InputKeyCounter}->{$InputKey};

            # increase a counter of how often this field was rendered
            $Param{InputKeyCounter}->{$InputKey}++;

            my $Value;

            # date type fields must to get all date parameters
            if ( $Item->{Input}->{Type} eq 'Date' ) {
                $Value = {
                    $InputKey                        => $GetParam{$InputKey},
                    $InputKey . '::TimeStart::Day'   => $GetParam{ $InputKey . '::TimeStart::Day' },
                    $InputKey . '::TimeStart::Month' => $GetParam{ $InputKey . '::TimeStart::Month' },
                    $InputKey . '::TimeStart::Year'  => $GetParam{ $InputKey . '::TimeStart::Year' },
                    $InputKey . '::TimeStop::Day'    => $GetParam{ $InputKey . '::TimeStop::Day' },
                    $InputKey . '::TimeStop::Month'  => $GetParam{ $InputKey . '::TimeStop::Month' },
                    $InputKey . '::TimeStop::Year'   => $GetParam{ $InputKey . '::TimeStop::Year' },
                } || '';
                $Optional = 1;
            }

            # date-time type fields must get all date and time parameters
            elsif ( $Item->{Input}->{Type} eq 'DateTime' ) {
                $Value = {
                    $InputKey                         => $GetParam{$InputKey},
                    $InputKey . '::TimeStart::Minute' => $GetParam{ $InputKey . '::TimeStart::Minute' },
                    $InputKey . '::TimeStart::Hour'   => $GetParam{ $InputKey . '::TimeStart::Hour' },
                    $InputKey . '::TimeStart::Day'    => $GetParam{ $InputKey . '::TimeStart::Day' },
                    $InputKey . '::TimeStart::Month'  => $GetParam{ $InputKey . '::TimeStart::Month' },
                    $InputKey . '::TimeStart::Year'   => $GetParam{ $InputKey . '::TimeStart::Year' },
                    $InputKey . '::TimeStop::Minute'  => $GetParam{ $InputKey . '::TimeStop::Minute' },
                    $InputKey . '::TimeStop::Hour'    => $GetParam{ $InputKey . '::TimeStop::Hour' },
                    $InputKey . '::TimeStop::Day'     => $GetParam{ $InputKey . '::TimeStop::Day' },
                    $InputKey . '::TimeStop::Month'   => $GetParam{ $InputKey . '::TimeStop::Month' },
                    $InputKey . '::TimeStop::Year'    => $GetParam{ $InputKey . '::TimeStop::Year' },
                } || '';
                $Optional = 1;
            }

            # other kinds of fields can get its value directly
            else {
                $Value = $GetParam{$InputKey} || '';
            }

            if ( $Item->{Input}->{Type} eq 'Customer' ) {

                $LayoutObject->Block(
                    Name => 'CustomerSearchInit',
                    Data => {
                        ItemID             => $InputKey,
                        ActiveAutoComplete => $Param{ActiveAutoComplete},
                    },
                );
            }

            # create search input element
            my $InputString = $LayoutObject->ITSMConfigItemSearchInputCreate(
                Key      => $InputKey,
                Item     => $Item,
                Value    => $Value,
                Optional => $Optional,
            );

            # output attribute row
            $LayoutObject->Block(
                Name => 'AttributeRow',
                Data => {
                    Key         => $InputKey,
                    Name        => $Name,
                    Description => $Item->{Description} || $Item->{Name},
                    InputString => $InputString,
                },
            );

            push @{ $Param{XMLAttributes} }, {
                Key   => $InputKey,
                Value => $Name,
            };
        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchFormOutput(
            XMLDefinition       => $Item->{Sub},
            XMLAttributes       => $Param{XMLAttributes},
            Level               => $Param{Level} + 1,
            Prefix              => $InputKey,
            PrefixName          => $Name,
            GetParam            => \%GetParam,
            ActiveAutoComplete  => $Param{ActiveAutoComplete},
            ConfiguredXMLFields => $Param{ConfiguredXMLFields},
            InputKeyCounter     => $Param{InputKeyCounter},
        );
    }

    return 1;
}

sub _XMLSearchFormGet {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if !$Param{XMLFormData};
    return if !$Param{XMLGetParam};
    return if !$Param{InputKeyCounter};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLFormData} ne 'ARRAY';
    return if ref $Param{XMLGetParam} ne 'ARRAY';
    return if ref $Param{InputKeyCounter} ne 'HASH';

    $Param{Level} ||= 0;

    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # create input-key
        my $InputKey = $Item->{Key};
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
        }

        # the field was already rendered
        next ITEM if $Param{InputKeyCounter}->{$InputKey};

        # increase a counter of how often this field was rendered
        $Param{InputKeyCounter}->{$InputKey}++;

        # get search form data
        my $Values = $LayoutObject->ITSMConfigItemSearchFormDataGet(
            Key   => $InputKey,
            Item  => $Item,
            Value => $Param{$InputKey},
        );

        # create search key
        my $SearchKey = $InputKey;
        $SearchKey =~ s{ :: }{\'\}[%]\{\'}xmsg;
        $SearchKey = "[1]{'Version'}[1]{'$SearchKey'}[%]{'Content'}";

        # ITSMConfigItemSearchFormDataGet() can return string, arrayref or hashref
        if ( ref $Values eq 'ARRAY' ) {

            # filter empty elements
            my @SearchValues = grep {$_} @{$Values};

            if (@SearchValues) {
                push @{ $Param{XMLFormData} }, {
                    $SearchKey => \@SearchValues,
                };

                push @{ $Param{XMLGetParam} }, {
                    $InputKey => \@SearchValues,
                };
            }

        }
        elsif ($Values) {

            # e.g. for Date between searches
            push @{ $Param{XMLFormData} }, {
                $SearchKey => $Values,
            };

            if ( ref $Values eq 'HASH' ) {
                if ( $Item->{Input}->{Type} eq 'Date' ) {
                    if ( $Values->{'-between'} ) {

                        # get time element values
                        my ( $StartDate, $StopDate ) = @{ $Values->{'-between'} };
                        my ( $StartYear, $StartMonth, $StartDay ) = split( /-/, $StartDate );
                        my ( $StopYear,  $StopMonth,  $StopDay )  = split( /-/, $StopDate );

                        # store time element values
                        push @{ $Param{XMLGetParam} }, {
                            $InputKey                        => 1,
                            $InputKey . '::TimeStart::Day'   => $StartDay,
                            $InputKey . '::TimeStart::Month' => $StartMonth,
                            $InputKey . '::TimeStart::Year'  => $StartYear,
                            $InputKey . '::TimeStop::Day'    => $StopDay,
                            $InputKey . '::TimeStop::Month'  => $StopMonth,
                            $InputKey . '::TimeStop::Year'   => $StopYear,
                        };
                    }
                }
                elsif ( $Item->{Input}->{Type} eq 'DateTime' ) {
                    if ( $Values->{'-between'} ) {

                        # get time element values
                        my ( $StartDateTime, $StopDateTime ) = @{ $Values->{'-between'} };
                        my ( $StartDate, $StartTime ) = split( /\s/, $StartDateTime );
                        my ( $StartYear, $StartMonth,  $StartDay )    = split( /-/,  $StartDate );
                        my ( $StartHour, $StartMinute, $StartSecond ) = split( /\:/, $StartTime );

                        my ( $StopDate, $StopTime ) = split( /\s/, $StopDateTime );
                        my ( $StopYear, $StopMonth,  $StopDay )    = split( /-/,  $StopDate );
                        my ( $StopHour, $StopMinute, $StopSecond ) = split( /\:/, $StopTime );

                        # store time element values
                        push @{ $Param{XMLGetParam} }, {
                            $InputKey                         => 1,
                            $InputKey . '::TimeStart::Minute' => $StartMinute,
                            $InputKey . '::TimeStart::Hour'   => $StartHour,
                            $InputKey . '::TimeStart::Day'    => $StartDay,
                            $InputKey . '::TimeStart::Month'  => $StartMonth,
                            $InputKey . '::TimeStart::Year'   => $StartYear,
                            $InputKey . '::TimeStop::Minute'  => $StopMinute,
                            $InputKey . '::TimeStop::Hour'    => $StopHour,
                            $InputKey . '::TimeStop::Day'     => $StopDay,
                            $InputKey . '::TimeStop::Month'   => $StopMonth,
                            $InputKey . '::TimeStop::Year'    => $StopYear,
                        };
                    }
                }
            }
            else {
                push @{ $Param{XMLGetParam} }, {
                    $InputKey => $Values,
                };
            }

        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchFormGet(
            XMLDefinition   => $Item->{Sub},
            XMLFormData     => $Param{XMLFormData},
            XMLGetParam     => $Param{XMLGetParam},
            Level           => $Param{Level} + 1,
            Prefix          => $InputKey,
            InputKeyCounter => $Param{InputKeyCounter},
        );
    }

    return 1;
}

sub _XMLSearchAttributesGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLAttributes} ne 'ARRAY';

    $Param{Level} ||= 0;
    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # set prefix
        my $InputKey = $Item->{Key};
        my $Name     = $Item->{Name};
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
            $Name     = $Param{PrefixName} . '::' . $Name;
        }

        # store attribute, if marked as researchable
        if ( $Item->{Searchable} ) {
            push @{ $Param{XMLAttributes} }, {
                Key   => $InputKey,
                Value => $Name,
            };
        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchAttributesGet(
            XMLDefinition => $Item->{Sub},
            XMLAttributes => $Param{XMLAttributes},
            Level         => $Param{Level} + 1,
            Prefix        => $InputKey,
            PrefixName    => $Name,
        );
    }

    return 1;
}

1;
