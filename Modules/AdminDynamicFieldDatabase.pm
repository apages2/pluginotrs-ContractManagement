# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminDynamicFieldDatabase;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    # get configured object types and fields config
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    $Self->{ObjectTypeConfig} = $ConfigObject->Get('DynamicFields::ObjectType');
    $Self->{FieldTypeConfig} = $ConfigObject->Get('DynamicFields::Driver') || {};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'Add' ) {
        return $Self->_Add(
            %Param,
        );
    }
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AddAction(
            %Param,
        );
    }
    if ( $Self->{Subaction} eq 'Change' ) {
        return $Self->_Change(
            %Param,
        );
    }
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_ChangeAction(
            %Param,
        );
    }
    return $LayoutObject->ErrorScreen(
        Message => "Undefined subaction.",
    );
}

sub _Add {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    for my $Needed (qw(ObjectType FieldType FieldOrder)) {
        $GetParam{$Needed} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Needed );
        if ( !$Needed ) {
            return $Kernel::OM->Get('Kernel::System::Layout')->ErrorScreen(
                Message => "Need $Needed",
            );
        }
    }

    # get the object type and field type display name
    my $ObjectTypeName = $Self->{ObjectTypeConfig}->{ $GetParam{ObjectType} }->{DisplayName} || '';
    my $FieldTypeName  = $Self->{FieldTypeConfig}->{ $GetParam{FieldType} }->{DisplayName}   || '';

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        Mode           => 'Add',
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _AddAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Needed (qw(Name Label FieldOrder)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
        }
    }

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    if ( $GetParam{Name} ) {

        # check if name is alphanumeric
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                'The field does not contain only ASCII letters and numbers.';
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $DynamicFieldObject->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
                )
        };

        %DynamicFieldsList = reverse %DynamicFieldsList;

        if ( $DynamicFieldsList{ $GetParam{Name} } ) {

            # add server error error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
        }
    }

    for my $ConfigParam (
        qw(
        ObjectType ObjectTypeName FieldType FieldTypeName ValidID Link DBType Server Port
        DBName DBTable User Password Identifier Multiselect CacheTTL Searchprefix Searchsuffix
        SID Driver ResultLimit CaseSensitive
        )
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    # prepare the multiselect and case-sensitive parameters
    if ( defined $GetParam{Multiselect} ) {
        $GetParam{Multiselect} = 'checked=checked';
    }

    if ( defined $GetParam{CaseSensitive} ) {
        $GetParam{CaseSensitive} = 'checked=checked';
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ValidID",
        );
    }

    my $PossibleValues = $Self->_GetPossibleValues();

    # return to add screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            Mode => 'Add',
        );
    }

    # set specific config
    my $FieldConfig = {
        PossibleValues => $PossibleValues,
        Link           => $GetParam{Link},
        DBType         => $GetParam{DBType},
        SID            => $GetParam{SID},
        Driver         => $GetParam{Driver},
        Server         => $GetParam{Server},
        Port           => $GetParam{Port},
        DBName         => $GetParam{DBName},
        DBTable        => $GetParam{DBTable},
        User           => $GetParam{User},
        Password       => $GetParam{Password},
        Identifier     => $GetParam{Identifier},
        CacheTTL       => $GetParam{CacheTTL} || 0,
        Multiselect    => $GetParam{Multiselect},
        Searchprefix   => $GetParam{Searchprefix},
        Searchsuffix   => $GetParam{Searchsuffix},
        ResultLimit    => $GetParam{ResultLimit},
        CaseSensitive  => $GetParam{CaseSensitive},
    };

    # create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
        Name       => $GetParam{Name},
        Label      => $GetParam{Label},
        FieldOrder => $GetParam{FieldOrder},
        FieldType  => $GetParam{FieldType},
        ObjectType => $GetParam{ObjectType},
        Config     => $FieldConfig,
        ValidID    => $GetParam{ValidID},
        UserID     => $Self->{UserID},
    );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not create the new field",
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminDynamicField",
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam;
    for my $Needed (qw(ObjectType FieldType)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$Needed ) {
            return $LayoutObject->ErrorScreen(
                Message => "Need $Needed",
            );
        }
    }

    # get the object type and field type display name
    my $ObjectTypeName = $Self->{ObjectTypeConfig}->{ $GetParam{ObjectType} }->{DisplayName} || '';
    my $FieldTypeName  = $Self->{FieldTypeConfig}->{ $GetParam{FieldType} }->{DisplayName}   || '';

    my $FieldID = $ParamObject->GetParam( Param => 'ID' );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ID",
        );
    }

    # get dynamic field data
    my $DynamicFieldData = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not get data for dynamic field $FieldID",
        );
    }

    my %Config = ();

    # extract configuration
    if ( IsHashRefWithData( $DynamicFieldData->{Config} ) ) {
        %Config = %{ $DynamicFieldData->{Config} };
    }

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        %${DynamicFieldData},
        %Config,
        ID             => $FieldID,
        Mode           => 'Change',
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    for my $Needed (qw(Name Label FieldOrder)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
        }
    }

    my $FieldID = $ParamObject->GetParam( Param => 'ID' );
    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ID",
        );
    }

    # get dynamic field data
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldData   = $DynamicFieldObject->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not get data for dynamic field $FieldID",
        );
    }

    if ( $GetParam{Name} ) {

        # check if name is lowercase
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                'The field does not contain only ASCII letters and numbers.';
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $DynamicFieldObject->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
                )
        };

        %DynamicFieldsList = reverse %DynamicFieldsList;

        if (
            $DynamicFieldsList{ $GetParam{Name} } &&
            $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
            )
        {

            # add server error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
        }

        # if it's an internal field, it's name should not change
        if (
            $DynamicFieldData->{InternalField} &&
            $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
            )
        {

            # add server error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'The name for this field should not change.';
            $Param{InternalField}           = $DynamicFieldData->{InternalField};
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
        }
    }

    for my $ConfigParam (
        qw(
        ObjectType ObjectTypeName FieldType FieldTypeName ValidID Link DBType Server Port
        DBName DBTable User Password Identifier Multiselect CacheTTL Searchprefix Searchsuffix
        SID Driver ResultLimit CaseSensitive
        )
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    # prepare the multiselect and case-sensitive parameters
    if ( defined $GetParam{Multiselect} ) {
        $GetParam{Multiselect} = 'checked=checked';
    }

    if ( defined $GetParam{CaseSensitive} ) {
        $GetParam{CaseSensitive} = 'checked=checked';
    }

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ValidID",
        );
    }

    my $PossibleValues = $Self->_GetPossibleValues();

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            PossibleValues => $PossibleValues,
            ID             => $FieldID,
            Mode           => 'Change',
        );
    }

    # set specific config
    my $FieldConfig = {
        PossibleValues => $PossibleValues,
        Link           => $GetParam{Link},
        DBType         => $GetParam{DBType},
        SID            => $GetParam{SID},
        Driver         => $GetParam{Driver},
        Server         => $GetParam{Server},
        Port           => $GetParam{Port},
        DBName         => $GetParam{DBName},
        DBTable        => $GetParam{DBTable},
        User           => $GetParam{User},
        Password       => $GetParam{Password},
        Identifier     => $GetParam{Identifier},
        CacheTTL       => $GetParam{CacheTTL} || 0,
        Multiselect    => $GetParam{Multiselect},
        Searchprefix   => $GetParam{Searchprefix},
        Searchsuffix   => $GetParam{Searchsuffix},
        ResultLimit    => $GetParam{ResultLimit},
        CaseSensitive  => $GetParam{CaseSensitive},
    };

    # update dynamic field (FieldType and ObjectType cannot be changed; use old values)
    my $UpdateSuccess = $DynamicFieldObject->DynamicFieldUpdate(
        ID         => $FieldID,
        Name       => $GetParam{Name},
        Label      => $GetParam{Label},
        FieldOrder => $GetParam{FieldOrder},
        FieldType  => $DynamicFieldData->{FieldType},
        ObjectType => $DynamicFieldData->{ObjectType},
        Config     => $FieldConfig,
        ValidID    => $GetParam{ValidID},
        UserID     => $Self->{UserID},
    );

    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not update the field $GetParam{Name}",
        );
    }

    # cleanup the cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'DynamicFieldDatabase',
    );

    return $LayoutObject->Redirect(
        OP => "Action=AdminDynamicField",
    );
}

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    $Param{DisplayFieldName} = 'New';

    $Param{Name} //= '';

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    $Param{DeletedString} = $Self->{DeletedString};

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # get all fields
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldList   = $DynamicFieldObject->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    my %DynamicfieldNamesList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
        $DynamicfieldNamesList{ $Dynamicfield->{FieldOrder} } = $Dynamicfield->{Label};
    }

    # when adding we need to create an extra order number for the new field
    if ( $Param{Mode} eq 'Add' ) {

        # get the last element form the order list and add 1
        my $LastOrderNumber = $DynamicfieldOrderList[-1];
        $LastOrderNumber++;

        # add this new order number to the end of the list
        push @DynamicfieldOrderList, $LastOrderNumber;
    }

    # show the names of the other fields to ease ordering
    my %OrderNamesList;
    my $CurrentlyText = $LayoutObject->{LanguageObject}->Get('Currently') . ': ';
    for my $OrderNumber ( sort @DynamicfieldOrderList ) {
        $OrderNamesList{$OrderNumber} = $OrderNumber;
        if ( $DynamicfieldNamesList{$OrderNumber} && $OrderNumber ne $Param{FieldOrder} ) {
            $OrderNamesList{$OrderNumber} = $OrderNumber . ' - '
                . $CurrentlyText
                . $DynamicfieldNamesList{$OrderNumber}
        }
    }

    my $DynamicFieldOrderStrg = $LayoutObject->BuildSelection(
        Data          => \%OrderNamesList,
        Name          => 'FieldOrder',
        SelectedValue => $Param{FieldOrder} || 1,
        PossibleNone  => 0,
        Translation   => 0,
        Sort          => 'NumericKey',
        Class         => 'W75pc Validate_Number',
    );

    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

    # create the Validity select
    my $ValidityStrg = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $Param{ValidID} || 1,
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'W50pc',
    );

    # define as 0 to get the real value in the HTML
    my $ValueCounter = 0;

    # set PossibleValues
    my %PossibleValues;
    if ( IsHashRefWithData( $Param{PossibleValues} ) ) {
        %PossibleValues = %{ $Param{PossibleValues} };
    }

    # prepare the possible values hash based on the
    # sequential number of any item
    my $PreparedPossibleValues = {};

    KEY:
    for my $Key ( sort keys %PossibleValues ) {

        next KEY if !$Key;

        if ( $Key =~ m/^\w+_(\d+)$/ ) {

            if ( !IsHashRefWithData( $PreparedPossibleValues->{$1} ) ) {
                $PreparedPossibleValues->{$1} = {
                    "$Key" => $PossibleValues{$Key},
                };
            }
            else {
                $PreparedPossibleValues->{$1}->{$Key} = $PossibleValues{$Key};
            }
        }
    }

    # prepare the available datatypes and filters
    my %DataTypes = (
        DATE    => 'Date',
        INTEGER => 'Integer',
        TEXT    => 'Text',
    );

    my %Filters = (
        CustomerID     => 'CustomerID',
        CustomerUserID => 'CustomerUserID',
        TicketNumber   => 'TicketNumber',
        Title          => 'Title',
        Type           => 'Type',
        TypeID         => 'TypeID',
        Service        => 'Service',
        ServiceID      => 'ServiceID',
        Owner          => 'Owner',
        OwnerID        => 'OwnerID',
        Responsible    => 'Responsible',
        ResponsibleID  => 'ResponsibleID',
        Queue          => 'Queue',
        QueueID        => 'QueueID',
        Priority       => 'Priority',
        PriorityID     => 'PriorityID',
        SLA            => 'SLA',
        SLAID          => 'SLAID',
        State          => 'State',
        StateID        => 'StateID',
        StateType      => 'StateType',
    );

    # get a list of available dynamic fields for use as filters
    my %DynamicFieldList = %{
        $DynamicFieldObject->DynamicFieldList(
            Valid      => 1,
            ResultType => 'HASH',
            )
    };

    # add the dynamic fields to the hash
    DYNAMICFIELDKEY:
    for my $DynamicFieldKey ( sort keys %DynamicFieldList ) {

        # ignore the own field
        if ( IsStringWithData( $Param{Name} ) ) {
            next DYNAMICFIELDKEY if $DynamicFieldList{$DynamicFieldKey} eq $Param{Name};
        }

        my $DynamicFieldName = 'DynamicField_' . $DynamicFieldList{$DynamicFieldKey};
        $Filters{$DynamicFieldName} = $DynamicFieldName;
    }

    # prepare the identifier data for the dropdown menu
    my %IdentifierData;

    # output the possible values and errors within (if any)
    KEY:
    for my $Key ( sort keys %{$PreparedPossibleValues} ) {

        next KEY if !$Key;
        next KEY if !IsHashRefWithData( $PreparedPossibleValues->{$Key} );

        $ValueCounter++;

        # needed for server side validation
        my $KeyError;
        my $KeyErrorStrg;
        my $ValueError;

        # to set the correct original value
        my $KeyClone = $Key;

        # check for errors
        if ( $Param{'PossibleValueErrors'} ) {

            # check for errors on original value (empty)
            if ( $Param{'PossibleValueErrors'}->{'KeyEmptyError'}->{$Key} ) {

                # if the original value was empty it has been changed in _GetParams to a predefined
                # string and need to be set to empty again
                $KeyClone = '';

                # set the error class
                $KeyError     = 'ServerError';
                $KeyErrorStrg = 'This field is required.'
            }

            # check for errors on original value (duplicate)
            elsif ( $Param{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key} ) {

                # if the original value was empty it has been changed in _GetParams to a predefined
                # string and need to be set to the original value again
                $KeyClone = $Param{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key};

                # set the error class
                $KeyError     = 'ServerError';
                $KeyErrorStrg = 'This field value is duplicated.'
            }

            # check for error on value
            if ( $Param{'PossibleValueErrors'}->{'ValueEmptyError'}->{$Key} ) {

                # set the error class
                $ValueError = 'ServerError';
            }
        }

        my %NormalizedPossibleValueNames;

        OLDKEY:
        for my $OldKey ( sort keys %{ $PreparedPossibleValues->{$Key} } ) {

            next OLDKEY if !$OldKey;

            if (
                $OldKey =~ m/^(\w+)_(\d+)$/
                && IsStringWithData( $PreparedPossibleValues->{$Key}->{$OldKey} )
                )
            {

                my $NewKey           = $1;
                my $SequentialNumber = $2;

                if ( $OldKey =~ m/(?:Searchfield|Listfield)/ ) {
                    $NormalizedPossibleValueNames{$NewKey} = 'checked=checked';
                }
                elsif ( $OldKey =~ m/FieldName/ ) {
                    $NormalizedPossibleValueNames{$NewKey} = $PreparedPossibleValues->{$Key}->{$OldKey};

                    # fill the identifier data hash
                    $IdentifierData{$SequentialNumber} = $PreparedPossibleValues->{$Key}->{$OldKey};
                }
                else {
                    $NormalizedPossibleValueNames{$NewKey} = $PreparedPossibleValues->{$Key}->{$OldKey};
                }
            }
        }

        # build the datatype field
        $Param{Datatype} = $LayoutObject->BuildSelection(
            Data         => \%DataTypes,
            Name         => "FieldDatatype_$ValueCounter",
            ID           => "FieldDatatype_$ValueCounter",
            Class        => 'Validate_Required',
            SelectedID   => $NormalizedPossibleValueNames{FieldDatatype},
            Translation  => 1,
            PossibleNone => 1,
        );

        # build the select field for the filters
        $Param{SelectFilter} = $LayoutObject->BuildSelection(
            Data         => \%Filters,
            Name         => "FieldFilter_$ValueCounter",
            SelectedID   => $NormalizedPossibleValueNames{FieldFilter},
            Translation  => 1,
            PossibleNone => 1,
        );

        # create a value map row
        $LayoutObject->Block(
            Name => 'ValueRow',
            Data => {
                %NormalizedPossibleValueNames,
                ValueCounter => $ValueCounter,
                Datatype     => $Param{Datatype},
                SelectFilter => $Param{SelectFilter},
            },
        );
    }

    # build the datatype and filter field
    $Param{Datatype} = $LayoutObject->BuildSelection(
        Data         => \%DataTypes,
        Name         => 'FieldDatatype',
        ID           => 'FieldDatatype',
        Translation  => 1,
        PossibleNone => 1,
    );

    $Param{SelectFilter} = $LayoutObject->BuildSelection(
        Data         => \%Filters,
        Name         => 'FieldFilter',
        ID           => 'FieldFilter',
        Translation  => 1,
        PossibleNone => 1,
    );

    # create the possible values template
    $LayoutObject->Block(
        Name => 'ValueTemplate',
        Data => {
            %Param,
        },
    );

    # define config field specific settings
    my $DefaultValue = ( defined $Param{DefaultValue} ? $Param{DefaultValue} : '' );

    # create the default value element
    $LayoutObject->Block(
        Name => 'DefaultValue' . $Param{FieldType},
        Data => {
            %Param,
            DefaultValue => $DefaultValue,
        },
    );

    # define config field specific settings
    my $Link = $Param{Link} || '';

    if ( $Param{FieldType} eq 'Database' ) {

        # create the default link element
        $LayoutObject->Block(
            Name => 'Link',
            Data => {
                %Param,
                Link => $Link,
            },
        );
    }

    # prepare available database types
    my %Databases = (
        mysql      => "MySQL",
        postgresql => "PostgreSQL",
        mssql      => "SQL Server (Microsoft)",
        ODBC       => "SQL Server (ODBC)",
        oracle     => "Oracle",
    );

    # OTRS can only use the native SQL Server driver
    # if OTRS runs on Windows as well
    if ( $^O ne 'MSWin32' ) {
        delete $Databases{mssql};
    }

    # build the select field for the InstallerDBStart.tt
    $Param{SelectDBType} = $LayoutObject->BuildSelection(
        Data         => \%Databases,
        Name         => 'DBType',
        Class        => 'Validate_Required',
        SelectedID   => $Param{DBType} || 'mysql',
        PossibleNone => 1,
        ID           => 'Type',
    );

    # build the select field for the identifier
    $Param{Identifier} = $LayoutObject->BuildSelection(
        Data         => \%IdentifierData,
        Name         => 'Identifier',
        ID           => 'Identifier',
        Class        => 'Validate_Required',
        SelectedID   => $Param{Identifier},
        PossibleNone => 1,
        Translation  => 0,
    );

    my $ReadonlyInternalField = '';

    # Internal fields can not be deleted and name should not change.
    if ( $Param{InternalField} ) {
        $LayoutObject->Block(
            Name => 'InternalField',
            Data => {%Param},
        );
        $ReadonlyInternalField = 'readonly="readonly"';
    }

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminDynamicFieldDatabase',
        Data         => {
            %Param,
            ValueCounter          => $ValueCounter,
            ValidityStrg          => $ValidityStrg,
            DynamicFieldOrderStrg => $DynamicFieldOrderStrg,
            DefaultValue          => $DefaultValue,
            ReadonlyInternalField => $ReadonlyInternalField,
            Link                  => $Link,
            }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _GetPossibleValues {
    my ( $Self, %Param ) = @_;

    my $PossibleValueConfig;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get ValueCounter
    my $ValueCounter = $ParamObject->GetParam( Param => 'ValueCounter' ) || 0;

    # get possible values
    my $Values;

    VALUEINDEX:
    for my $ValueIndex ( 1 .. $ValueCounter ) {

        # get possible keys and related values
        my $KeyFieldName     = 'FieldName' . '_' . $ValueIndex;
        my $KeyFieldLabel    = 'FieldLabel' . '_' . $ValueIndex;
        my $KeyFieldDatatype = 'FieldDatatype' . '_' . $ValueIndex;
        my $KeyFieldFilter   = 'FieldFilter' . '_' . $ValueIndex;
        my $KeySearchfield   = 'Searchfield' . '_' . $ValueIndex;
        my $KeyListfield     = 'Listfield' . '_' . $ValueIndex;

        my $ValueFieldName     = $ParamObject->GetParam( Param => $KeyFieldName );
        my $ValueFieldLabel    = $ParamObject->GetParam( Param => $KeyFieldLabel );
        my $ValueFieldDatatype = $ParamObject->GetParam( Param => $KeyFieldDatatype );
        my $ValueFieldFilter   = $ParamObject->GetParam( Param => $KeyFieldFilter );
        my $ValueSearchfield   = $ParamObject->GetParam( Param => $KeySearchfield );
        my $ValueListfield     = $ParamObject->GetParam( Param => $KeyListfield );

        $ValueFieldName     = ( defined $ValueFieldName     ? $ValueFieldName     : '' );
        $ValueFieldLabel    = ( defined $ValueFieldLabel    ? $ValueFieldLabel    : '' );
        $ValueFieldDatatype = ( defined $ValueFieldDatatype ? $ValueFieldDatatype : '' );
        $ValueFieldFilter   = ( defined $ValueFieldFilter   ? $ValueFieldFilter   : '' );
        $ValueSearchfield   = ( defined $ValueSearchfield   ? $ValueSearchfield   : '' );
        $ValueListfield     = ( defined $ValueListfield     ? $ValueListfield     : '' );

        # check for removed values
        next VALUEINDEX if !IsStringWithData($ValueFieldName);
        next VALUEINDEX if !IsStringWithData($ValueFieldLabel);
        next VALUEINDEX if !IsStringWithData($ValueFieldDatatype);

        $PossibleValueConfig->{$KeyFieldName}     = $ValueFieldName;
        $PossibleValueConfig->{$KeyFieldLabel}    = $ValueFieldLabel;
        $PossibleValueConfig->{$KeyFieldDatatype} = $ValueFieldDatatype;
        $PossibleValueConfig->{$KeyFieldFilter}   = $ValueFieldFilter;
        $PossibleValueConfig->{$KeySearchfield}   = $ValueSearchfield;
        $PossibleValueConfig->{$KeyListfield}     = $ValueListfield;
        $PossibleValueConfig->{ValueCounter}      = $ValueCounter;
    }

    return $PossibleValueConfig;
}

1;
