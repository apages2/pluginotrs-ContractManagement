# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NotificationView::Small;

use strict;
use warnings;

use Kernel::System::JSON;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::HTMLUtils',
    'Kernel::System::JSON',
    'Kernel::System::Log',
    'Kernel::System::NotificationView',
    'Kernel::System::Time',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = \%Param;
    bless( $Self, $Type );

    # set pref for columns key
    $Self->{PrefKeyColumns} = 'UserFilterColumnsEnabled' . '-' . $Self->{Action};

    # load backend config
    my $BackendConfigKey = 'NotificationView::Frontend::' . $Self->{Action};
    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get($BackendConfigKey);

    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    # get JSONObject
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # set stored filters if present
    my $StoredFiltersKey = 'UserStoredFilterColumns-' . $Self->{Action};
    if ( $Preferences{$StoredFiltersKey} ) {
        my $StoredFilters = $JSONObject->Decode(
            Data => $Preferences{$StoredFiltersKey},
        );
        $Self->{StoredFilters} = $StoredFilters;
    }

    # check for default settings specific for this screen,
    my %DefaultColumns = %{ $Self->{Config}->{DefaultColumns} || {} };

    # configure columns
    my @ColumnsAvailable = grep { $DefaultColumns{$_} ne '0' } sort keys %DefaultColumns;
    my @ColumnsEnabled   = grep { $DefaultColumns{$_} eq '2' } sort _DefaultColumnSort keys %DefaultColumns;

    # if preference settings are available, take them
    if ( $Preferences{ $Self->{PrefKeyColumns} } ) {

        my $ColumnsEnabled = $JSONObject->Decode(
            Data => $Preferences{ $Self->{PrefKeyColumns} },
        );

        @ColumnsEnabled = @{$ColumnsEnabled};
    }

    # always set Notification Name
    if ( !grep { $_ eq 'Name' } @ColumnsEnabled ) {
        unshift @ColumnsEnabled, 'Name';
    }

    # always set Dismiss columns
    if ( !grep { $_ eq 'Dismiss' } @ColumnsEnabled ) {
        push @ColumnsEnabled, 'Dismiss';
    }

    $Self->{ColumnsEnabled}   = \@ColumnsEnabled;
    $Self->{ColumnsAvailable} = \@ColumnsAvailable;

    # hash with all valid sortable columns (taken from NotificationSearch)
    # SortBy  => 'Age',   # Name|Subject|ObjectType|
    $Self->{ValidSortableColumns} = {
        'Age'             => 1,
        'Name'            => 1,
        'Subject'         => 1,
        'ObjectType'      => 1,
        'ObjectReference' => 1,
    };

    $Self->{AvailableFilterableColumns} = {
        'Name'            => 1,
        'ObjectType'      => 1,
        'ObjectReference' => 1,
    };

    return $Self;
}

sub ActionRow {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check if bulk feature is enabled
    my $BulkFeature = 0;
    if ( $Param{Bulk} && $ConfigObject->Get('NotificationView::Frontend::BulkFeature') ) {
        my @Groups;
        if ( $ConfigObject->Get('NotificationView::Frontend::BulkFeatureGroup') ) {
            @Groups = @{ $ConfigObject->Get('NotificationView::Frontend::BulkFeatureGroup') };
        }
        if ( !@Groups ) {
            $BulkFeature = 1;
        }
        else {
            GROUP:
            for my $Group (@Groups) {
                next GROUP if !$LayoutObject->{"UserIsGroup[$Group]"};
                if ( $LayoutObject->{"UserIsGroup[$Group]"} eq 'Yes' ) {
                    $BulkFeature = 1;
                    last GROUP;
                }
            }
        }
    }

    $LayoutObject->Block(
        Name => 'DocumentActionRow',
        Data => \%Param,
    );

    if ($BulkFeature) {
        $LayoutObject->Block(
            Name => 'DocumentActionRowBulk',
            Data => {
                %Param,
                Name => $LayoutObject->{LanguageObject}->Translate('Dismiss Selected'),
            },
        );
    }

    # check if there was a column filter and no results, and print a link to back
    if ( scalar @{ $Param{NotificationIDs} } == 0 && $Param{LastColumnFilter} ) {
        $LayoutObject->Block(
            Name => 'DocumentActionRowLastColumnFilter',
            Data => {
                %Param,
            },
        );
    }

    # TODO: cant find where is this block, apparently looks like in the NabVar, but ViewSmall is called

    # add translations for the allocation lists for regular columns
    my $Columns = $Self->{Config}->{DefaultColumns} || {};
    if ( $Columns && IsHashRefWithData($Columns) ) {

        # manually add 'Dismiss' vor translation
        if ( !$Columns->{Dismiss} ) {
            $Columns->{Dismiss} = 2;
        }

        my $ColumnNumber = scalar keys %{$Columns};
        my $Counter      = 0;
        COLUMN:
        for my $Column ( sort keys %{$Columns} ) {

            $Counter++;

            my $TranslatedWord = $Column;
            if ( $Column eq 'ObjectType' ) {
                $TranslatedWord = 'Object Type';
            }
            elsif ( $Column eq 'ObjectReference' ) {
                $TranslatedWord = 'Related To';
            }

            $LayoutObject->Block(
                Name => 'ColumnTranslation',
                Data => {
                    ColumnName      => $Column,
                    TranslateString => $TranslatedWord,
                },
            );

            if ( $Counter < $ColumnNumber ) {
                $LayoutObject->Block(
                    Name => 'ColumnTranslationSeparator',
                );
            }
        }
    }

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentNotificationViewSmall',
        Data         => \%Param,
    );

    return $Output;
}

sub SortOrderBar {
    my ( $Self, %Param ) = @_;

    return '';
}

sub Run {
    my ( $Self, %Param ) = @_;

    # If $Param{EnableColumnFilters} is not sent, we want to disable all filters
    #   for the current screen. We localize the setting for this sub and change it
    #   after that, if needed. The original value will be restored after this function.
    local $Self->{AvailableFilterableColumns} = $Self->{AvailableFilterableColumns};
    if ( !$Param{EnableColumnFilters} ) {
        $Self->{AvailableFilterableColumns} = {};    # disable all column filters
    }

    # check needed stuff
    for my $Needed (qw(NotificationIDs PageShown StartHit)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check if bulk feature is enabled
    my $BulkFeature = 0;
    if ( $Param{Bulk} && $ConfigObject->Get('NotificationView::Frontend::BulkFeature') ) {
        my @Groups;
        if ( $ConfigObject->Get('NotificationView::Frontend::BulkFeatureGroup') ) {
            @Groups = @{ $ConfigObject->Get('NotificationView::Frontend::BulkFeatureGroup') };
        }
        if ( !@Groups ) {
            $BulkFeature = 1;
        }
        else {
            GROUP:
            for my $Group (@Groups) {
                next GROUP if !$LayoutObject->{"UserIsGroup[$Group]"};
                if ( $LayoutObject->{"UserIsGroup[$Group]"} eq 'Yes' ) {
                    $BulkFeature = 1;
                    last GROUP;
                }
            }
        }
    }

    # get notification view object
    my $NotificationViewObject = $Kernel::OM->Get('Kernel::System::NotificationView');

    my $Counter = 0;
    my @Notifications;
    NOTIFICATION:
    for my $NotificationID ( @{ $Param{NotificationIDs} } ) {
        $Counter++;
        if ( $Counter >= $Param{StartHit} && $Counter < ( $Param{PageShown} + $Param{StartHit} ) ) {

            my %Notification = $NotificationViewObject->NotificationGet(
                NotificationID => $NotificationID,
            );

            next NOTIFICATION if !%Notification;

            push @Notifications, \%Notification;
        }
    }

    # check if SysConfig is a hash reference
    if ( IsArrayRefWithData( $Self->{ColumnsEnabled} ) ) {

        # check if column is really filterable
        COLUMNNAME:
        for my $ColumnName ( @{ $Self->{ColumnsEnabled} } ) {
            next COLUMNNAME if !grep { $_ eq $ColumnName } @{ $Self->{ColumnsEnabled} };
            next COLUMNNAME if !$Self->{AvailableFilterableColumns}->{$ColumnName};
            $Self->{ValidFilterableColumns}->{$ColumnName} = 1;
        }
    }

    my $ColumnValues = $Self->_GetColumnValues(
        OriginalNotificationIDs => $Param{OriginalNotificationIDs},
    );

    $LayoutObject->Block(
        Name => 'DocumentContent',
        Data => \%Param,
    );

    # array to save the column names to do the query
    my @Col = @{ $Self->{ColumnsEnabled} };

    # define special notification columns
    my %SpecialColumns = (
        Dismiss         => 1,
        Name            => 1,
        ObjectReference => 1,
    );

    my $NotificationData = scalar @{ $Param{NotificationIDs} };

    if ($NotificationData) {

        $LayoutObject->Block( Name => 'OverviewTable' );
        $LayoutObject->Block( Name => 'TableHeader' );

        if ($BulkFeature) {
            $LayoutObject->Block(
                Name => 'GeneralOverviewHeader',
            );
            $LayoutObject->Block(
                Name => 'BulkNavBar',
                Data => \%Param,
            );
        }

        # meta items
        my @NotificationMetaItems = $LayoutObject->NotificationViewMetaItemsCount();
        for my $Item (@NotificationMetaItems) {

            $LayoutObject->Block(
                Name => 'GeneralOverviewHeader',
            );

            my $CSS = '';
            my $OrderBy;
            my $Link;
            my $Title = $Item;

            if ( $Param{SortBy} && ( $Param{SortBy} eq $Item ) ) {
                if ( $Param{OrderBy} && ( $Param{OrderBy} eq 'Up' ) ) {
                    $OrderBy = 'Down';
                    $CSS .= ' SortAscendingLarge';
                }
                else {
                    $OrderBy = 'Up';
                    $CSS .= ' SortDescendingLarge';
                }

                # set title description
                my $TitleDesc = $OrderBy eq 'Down' ? 'sorted descending' : 'sorted ascending';
                $TitleDesc = $LayoutObject->{LanguageObject}->Translate($TitleDesc);
                $Title .= ', ' . $TitleDesc;
            }

            $LayoutObject->Block(
                Name => 'OverviewNavBarPageFlag',
                Data => {
                    CSS => $CSS,
                },
            );

            if ( $Item ne 'Seen' ) {
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageFlagEmpty',
                    Data => {
                        Name => $Item,
                    },
                );
            }
            else {
                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageFlagLink',
                    Data => {
                        %Param,
                        Name    => $Item,
                        CSS     => $CSS,
                        OrderBy => $OrderBy,
                        Title   => $Title,
                    },
                );
            }
        }

        my $CSS = '';
        my $OrderBy;

        # show special notification columns, if needed
        COLUMN:
        for my $Column (@Col) {

            $LayoutObject->Block(
                Name => 'GeneralOverviewHeader',
            );

            $CSS = $Column;
            my $Title = $Column;

            # output overall block so notification name as well as other columns can be ordered
            $LayoutObject->Block(
                Name => 'OverviewNavBarPageNotificationHeader',
                Data => {},
            );

            if ( $SpecialColumns{$Column} ) {

                if ( $Param{SortBy} && ( $Param{SortBy} eq $Column ) ) {
                    if ( $Param{OrderBy} && ( $Param{OrderBy} eq 'Up' ) ) {
                        $OrderBy = 'Down';
                        $CSS .= ' SortAscendingLarge';
                    }
                    else {
                        $OrderBy = 'Up';
                        $CSS .= ' SortDescendingLarge';
                    }

                    # add title description
                    my $TitleDesc = $OrderBy eq 'Down' ? 'sorted ascending' : 'sorted descending';
                    $TitleDesc = $LayoutObject->{LanguageObject}->Translate($TitleDesc);
                    $Title .= ', ' . $TitleDesc;
                }

                my $StoredFilterColumn = $Column;

                # translate the column name to write it in the current language
                my $TranslatedWord;

                if ( $Column eq 'ObjectReference' ) {
                    $TranslatedWord     = $LayoutObject->{LanguageObject}->Translate('Related To');
                    $StoredFilterColumn = 'ObjectReferences';
                }
                else {
                    $TranslatedWord = $LayoutObject->{LanguageObject}->Translate($Column);
                }

                my $FilterTitle     = $Column;
                my $FilterTitleDesc = 'filter not active';
                if (
                    $Self->{StoredFilters} &&
                    (
                        $Self->{StoredFilters}->{$StoredFilterColumn} ||
                        $Self->{StoredFilters}->{ $StoredFilterColumn . 's' }
                    )
                    )
                {
                    $CSS .= ' FilterActive';
                    $FilterTitleDesc = 'filter active';
                }
                $FilterTitleDesc = $LayoutObject->{LanguageObject}->Translate($FilterTitleDesc);
                $FilterTitle .= ', ' . $FilterTitleDesc;

                if ( $Column eq 'Name' || $Column eq 'ObjectReference' ) {

                    my $Css;

                    # variable to save the filter's HTML code
                    my $ColumnFilterHTML = $Self->_InitialColumnFilter(
                        ColumnName    => $Column,
                        Label         => $TranslatedWord || $Column,
                        ColumnValues  => $ColumnValues->{$Column},
                        SelectedValue => $Param{GetColumnFilter}->{$Column} || '',
                        Css           => $Css,
                    );

                    $LayoutObject->Block(
                        Name => "OverviewNavBarPage$Column",
                        Data => {
                            %Param,
                            ColumnName           => $Column,
                            CSS                  => $CSS,
                            ColumnNameTranslated => $TranslatedWord || $Column,
                            ColumnFilterStrg     => $ColumnFilterHTML,
                            OrderBy              => $OrderBy,
                            Title                => $Title,
                            FilterTitle          => $FilterTitle,
                        },
                    );
                    next COLUMN;
                }

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageColumn',
                    Data => {
                        %Param,
                        OrderBy              => $OrderBy,
                        ColumnName           => $Column || '',
                        CSS                  => $CSS || '',
                        ColumnNameTranslated => $TranslatedWord || $Column,
                        Title                => $Title,
                    },
                );

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageColumnEmpty',
                    Data => {
                        %Param,
                        ColumnName           => $Column,
                        CSS                  => $CSS,
                        ColumnNameTranslated => $TranslatedWord || $Column,
                        Title                => $Title,
                    },
                );
                next COLUMN;

            }
            else {

                my $TranslatedWord;
                if ( $Column eq 'ObjectType' ) {
                    $TranslatedWord = $LayoutObject->{LanguageObject}->Translate('Object Type');
                }
                elsif ( $Column eq 'ObjectReference' ) {
                    $TranslatedWord = $LayoutObject->{LanguageObject}->Translate('Related To');
                }
                else {
                    $TranslatedWord = $LayoutObject->{LanguageObject}->Translate($Column);
                }

                if ( $Param{SortBy} && ( $Param{SortBy} eq $Column ) ) {
                    if ( $Param{OrderBy} && ( $Param{OrderBy} eq 'Up' ) ) {
                        $OrderBy = 'Down';
                        $CSS .= ' SortAscendingLarge';
                    }
                    else {
                        $OrderBy = 'Up';
                        $CSS .= ' SortDescendingLarge';
                    }

                    # add title description
                    my $TitleDesc = $OrderBy eq 'Down' ? 'sorted ascending' : 'sorted descending';
                    $TitleDesc = $LayoutObject->{LanguageObject}->Translate($TitleDesc);
                    $Title .= ', ' . $TitleDesc;
                }

                # translate the column name to write it in the current language
                my $FilterTitle     = $Column;
                my $FilterTitleDesc = 'filter not active';
                if ( $Self->{StoredFilters} && $Self->{StoredFilters}->{$Column} ) {
                    $CSS .= ' FilterActive';
                    $FilterTitleDesc = 'filter active';
                }
                $FilterTitleDesc = $LayoutObject->{LanguageObject}->Translate($FilterTitleDesc);
                $FilterTitle .= ', ' . $FilterTitleDesc;

                $LayoutObject->Block(
                    Name => 'OverviewNavBarPageColumn',
                    Data => {
                        %Param,
                        ColumnName           => $Column,
                        CSS                  => $CSS,
                        ColumnNameTranslated => $TranslatedWord || $Column,
                    },
                );

                # verify if column is filterable and sortable
                if (
                    $Self->{ValidFilterableColumns}->{$Column}
                    && $Self->{ValidSortableColumns}->{$Column}
                    )
                {
                    my $Css;

                    # variable to save the filter's html code
                    my $ColumnFilterHTML = $Self->_InitialColumnFilter(
                        ColumnName    => $Column,
                        Label         => $TranslatedWord || $Column,
                        ColumnValues  => $ColumnValues->{$Column},
                        SelectedValue => $Param{GetColumnFilter}->{$Column} || '',
                        Css           => $Css,
                    );

                    $LayoutObject->Block(
                        Name => 'OverviewNavBarPageColumnFilterLink',
                        Data => {
                            %Param,
                            ColumnName           => $Column,
                            CSS                  => $CSS,
                            ColumnNameTranslated => $TranslatedWord || $Column,
                            ColumnFilterStrg     => $ColumnFilterHTML,
                            OrderBy              => $OrderBy,
                            Title                => $Title,
                            FilterTitle          => $FilterTitle,
                        },
                    );
                }

                # verify if column is sortable
                elsif ( $Self->{ValidSortableColumns}->{$Column} ) {
                    $LayoutObject->Block(
                        Name => 'OverviewNavBarPageColumnLink',
                        Data => {
                            %Param,
                            ColumnName           => $Column,
                            CSS                  => $CSS,
                            ColumnNameTranslated => $TranslatedWord || $Column,
                            OrderBy              => $OrderBy,
                            Title                => $Title,
                        },
                    );
                }
            }
        }

        $LayoutObject->Block( Name => 'TableBody' );

    }
    else {
        $LayoutObject->Block( Name => 'NoNotificationFound' );
    }

    # get needed objects
    my $TimeObject      = $Kernel::OM->Get('Kernel::System::Time');
    my $HTMLUtilsObject = $Kernel::OM->Get('Kernel::System::HTMLUtils');

    # get object type settings
    my $ObjectTypeConfig = $ConfigObject->Get('NotificationView::ObjectType') || {};

    # to store the notification data with sanitized body
    my %NotificationDetails;

    for my $Notification (@Notifications) {

        my %Notification = %{$Notification};

        $LayoutObject->Block(
            Name => 'Record',
            Data => {%Notification},
        );

        # check if bulk feature is enabled
        if ($BulkFeature) {
            $LayoutObject->Block(
                Name => 'GeneralOverviewRow',
            );
            $LayoutObject->Block(
                Name => 'Bulk',
                Data => {%Notification},
            );
        }

        # show notification seen
        my @NotificationMetaItems = $LayoutObject->NotificationViewMetaItems(
            Notification => \%Notification,
        );
        for my $Item (@NotificationMetaItems) {
            $LayoutObject->Block(
                Name => 'GeneralOverviewRow',
            );
            $LayoutObject->Block(
                Name => 'ContentLargeNotificationGenericRowMeta',
                Data => $Item,
            );
            if ($Item) {
                $LayoutObject->Block(
                    Name => 'ContentLargeNotificationGenericRowMetaImage',
                    Data => $Item,
                );
            }
        }

        # save column content
        my $DataValue;

        # show all needed columns
        NOTIFICATIONCOLUMN:
        for my $NotificationColumn (@Col) {
            $LayoutObject->Block(
                Name => 'GeneralOverviewRow',
            );
            $LayoutObject->Block(
                Name => 'RecordNotificationData',
                Data => {%Notification},
            );

            if ( $SpecialColumns{$NotificationColumn} ) {
                if ( $NotificationColumn eq 'ObjectReference' ) {

                    my $Config = $ObjectTypeConfig->{ $Notification{ObjectType} };
                    $Notification{Link} = $Config->{Link} || '';
                    $Notification{Hook} = $Config->{Hook} || '#';

                    if ( $Notification{Link} ) {
                        $LayoutObject->Block(
                            Name => 'Record' . $NotificationColumn . 'Link',
                            Data => {%Notification},
                        );

                        next NOTIFICATIONCOLUMN;
                    }
                }

                $LayoutObject->Block(
                    Name => 'Record' . $NotificationColumn,
                    Data => {%Notification},
                );

                next NOTIFICATIONCOLUMN;
            }

            # age column
            if ( $NotificationColumn eq 'Age' ) {
                my $SystemTime = $TimeObject->SystemTime();
                my $Age        = $SystemTime - $Notification{CreateTimeUnix};
                $Notification{Age} = $LayoutObject->CustomerAgeInHours(
                    Age   => $Age,
                    Space => ' ',
                );
            }

            $LayoutObject->Block(
                Name => "RecordNotificationColumn",
                Data => {
                    GenericValue => $Notification{$NotificationColumn} || '',
                    Class => '',
                },
            );
        }

        # prepare notification body to be displayed
        my $HTMLString = $HTMLUtilsObject->DocumentStrip(
            String => $Notification{Body},
        );
        $HTMLString = $HTMLUtilsObject->LinkQuote(
            String => $HTMLString,

        );
        my %Safe = $HTMLUtilsObject->Safety(
            String       => $HTMLString,
            NoApplet     => 1,
            NoObject     => 1,
            NoEmbed      => 1,
            NoSVG        => 1,
            NoIntSrcLoad => 0,
            NoExtSrcLoad => 1,
            NoJavaScript => 1,
        );

        $NotificationDetails{ $Notification{NotificationID} } = {
            %Notification,
            Body => $Safe{String},
        };
    }

    # initialization for table control
    $LayoutObject->Block(
        Name => 'DocumentReadyStart',
        Data => {
            %Param,
            NotificationDetails => \%NotificationDetails,
        },
    );

    # set column filter form, to correctly fill the column filters is necessary to pass each
    #    overview some information in the AJAX call, for example the fixed Filters or NavBarFilters
    #    and also other values like the Queue in AgentTicketQueue, otherwise the filters will be
    #    filled with default restrictions, resulting in more options than the ones that the
    #    available tickets should provide, see Bug#9902
    if ( IsHashRefWithData( $Param{ColumnFilterForm} ) ) {
        $LayoutObject->Block(
            Name => 'DocumentColumnFilterForm',
            Data => {},
        );
        for my $Element ( sort keys %{ $Param{ColumnFilterForm} } ) {
            $LayoutObject->Block(
                Name => 'DocumentColumnFilterFormElement',
                Data => {
                    ElementName  => $Element,
                    ElementValue => $Param{ColumnFilterForm}->{$Element},
                },
            );
        }
    }

    # use template
    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentNotificationViewSmall',
        Data         => {
            %Param,
            Type                => $Self->{ViewType},
            NotificationDetails => \%NotificationDetails,
        },
    );

    return $Output;
}

sub _GetColumnValues {
    my ( $Self, %Param ) = @_;

    return if !IsStringWithData( $Param{HeaderColumn} );

    my $HeaderColumn = $Param{HeaderColumn};
    my %ColumnFilterValues;
    my $NotificationIDs;

    if ( IsArrayRefWithData( $Param{OriginalNotificationIDs} ) ) {
        $NotificationIDs = $Param{OriginalNotificationIDs};
    }

    my $FunctionName = $HeaderColumn . 'FilterValuesGet';

    $ColumnFilterValues{$HeaderColumn} = $Kernel::OM->Get('Kernel::System::NotificationView')->$FunctionName(
        NotificationIDs => $NotificationIDs,
        HeaderColumn    => $HeaderColumn,
        UserID          => $Self->{UserID},
    );

    return \%ColumnFilterValues;
}

sub _InitialColumnFilter {
    my ( $Self, %Param ) = @_;

    return if !$Param{ColumnName};
    return if !$Self->{ValidFilterableColumns}->{ $Param{ColumnName} };

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Label = $Param{Label} || $Param{ColumnName};
    $Label = $LayoutObject->{LanguageObject}->Translate($Label);

    # set fixed values
    my $Data = [
        {
            Key   => '',
            Value => uc $Label,
        },
    ];

    # define if column filter values should be translatable
    my $TranslationOption = 0;

    if ( $Param{ColumnName} eq 'ObjectType' ) {
        $TranslationOption = 1;
    }

    my $Class = 'ColumnFilter';
    if ( $Param{Css} ) {
        $Class .= ' ' . $Param{Css};
    }

    # build select HTML
    my $ColumnFilterHTML = $LayoutObject->BuildSelection(
        Name        => 'ColumnFilter' . $Param{ColumnName},
        Data        => $Data,
        Class       => $Class,
        Translation => $TranslationOption,
        SelectedID  => '',
    );
    return $ColumnFilterHTML;
}

sub FilterContent {
    my ( $Self, %Param ) = @_;

    return if !$Param{HeaderColumn};

    my $HeaderColumn = $Param{HeaderColumn};

    # get column values for to build the filters later
    my $ColumnValues = $Self->_GetColumnValues(
        OriginalNotificationIDs => $Param{OriginalNotificationIDs},
        HeaderColumn            => $HeaderColumn,
    );

    my $SelectedValue  = '';
    my $SelectedColumn = $HeaderColumn;
    if ( $HeaderColumn eq 'ObjectReference' ) {
        $SelectedColumn = 'ObjectReferences';
    }

    my $LabelColumn = $HeaderColumn;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    if ( $HeaderColumn eq 'ObjectReference' ) {
        $LabelColumn = $LayoutObject->{LanguageObject}->Translate('Related To');
    }
    elsif ( $HeaderColumn eq 'ObjectType' ) {
        $LabelColumn = $LayoutObject->{LanguageObject}->Translate('Object Type');
    }

    if ( $SelectedColumn && $Self->{StoredFilters}->{$SelectedColumn} ) {

        if ( IsArrayRefWithData( $Self->{StoredFilters}->{$SelectedColumn} ) ) {
            $SelectedValue = $Self->{StoredFilters}->{$SelectedColumn}->[0];
        }
        elsif ( IsHashRefWithData( $Self->{StoredFilters}->{$SelectedColumn} ) ) {
            $SelectedValue = $Self->{StoredFilters}->{$SelectedColumn}->{Equals};
        }
    }

    # variable to save the filter's HTML code
    my $ColumnFilterJSON = $Self->_ColumnFilterJSON(
        ColumnName    => $HeaderColumn,
        Label         => $LabelColumn,
        ColumnValues  => $ColumnValues->{$HeaderColumn},
        SelectedValue => $SelectedValue,
    );

    return $ColumnFilterJSON;
}

=over

=item _ColumnFilterJSON()

    creates a JSON select filter for column header

    my $ColumnFilterJSON = $ViewSmallObject->_ColumnFilterJSON(
        ColumnName => 'ObjectType',
        Label      => 'Object Type',
        ColumnValues => {
            'Ticket' => 'Tiket',
            'Other'  => 'Other',
        },
        SelectedValue 'Ticket',
    );

=cut

sub _ColumnFilterJSON {
    my ( $Self, %Param ) = @_;

    if (
        !$Self->{AvailableFilterableColumns}->{ $Param{ColumnName} } &&
        !$Self->{AvailableFilterableColumns}->{ $Param{ColumnName} . 's' }
        )
    {
        return;
    }

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Label = $Param{Label};
    $Label = $LayoutObject->{LanguageObject}->Translate($Label);

    # set fixed values
    my $Data = [
        {
            Key   => 'DeleteFilter',
            Value => uc $Label,
        },
        {
            Key      => '-',
            Value    => '-',
            Disabled => 1,
        },
    ];

    if ( $Param{ColumnValues} && ref $Param{ColumnValues} eq 'HASH' ) {

        my %Values = %{ $Param{ColumnValues} };

        # set possible values
        for my $ValueKey ( sort { lc $Values{$a} cmp lc $Values{$b} } keys %Values ) {
            push @{$Data}, {
                Key   => $ValueKey,
                Value => $Values{$ValueKey}
            };
        }
    }

    # define if column filter values should be translatable
    my $TranslationOption = 0;

    if ( $Param{ColumnName} eq 'ObjectType' ) {
        $TranslationOption = 1;
    }

    # build select HTML
    my $JSON = $LayoutObject->BuildSelectionJSON(
        [
            {
                Name         => 'ColumnFilter' . $Param{ColumnName},
                Data         => $Data,
                Class        => 'ColumnFilter',
                Sort         => 'AlphanumericKey',
                TreeView     => 1,
                SelectedID   => $Param{SelectedValue},
                Translation  => $TranslationOption,
                AutoComplete => 'off',
            },
        ],
    );

    return $JSON;
}

sub _DefaultColumnSort {

    my %DefaultColumns = (
        Name       => 100,
        Age        => 110,
        Subject    => 120,
        ObjectType => 130,
        Dismiss    => 200,

    );

    # when a another field is compared to a notification attribute it must be higher
    if ( !$DefaultColumns{$a} ) {
        return 1;
    }

    # when a notification attribute is compared to another field it must be lower
    elsif ( !$DefaultColumns{$b} ) {
        return -1;
    }

    # otherwise do a numerical comparison with the notification attributes
    return $DefaultColumns{$a} <=> $DefaultColumns{$b};
}

1;

=back
