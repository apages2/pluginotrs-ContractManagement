# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminCustomContactFields;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Web::Request',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DynamicField',
    'Kernel::System::Valid',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    # get a local config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get configured object types
    $Self->{ObjectTypeConfig} = $ConfigObject->Get('DynamicFields::ObjectType');

    # get the fields config
    $Self->{FieldTypeConfig} = $ConfigObject->Get('DynamicFields::Driver') || {};

    # set possible values handling strings
    $Self->{EmptyString}     = '_DynamicFields_EmptyString_Dont_Use_It_String_Please';
    $Self->{DuplicateString} = '_DynamicFields_DuplicatedString_Dont_Use_It_String_Please';
    $Self->{DeletedString}   = '_DynamicFields_DeletedString_Dont_Use_It_String_Please';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'Add' ) {
        return $Self->_Add(
            %Param,
        );
    }
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_Action(
            %Param,
            Mode => 'Add',
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

        return $Self->_Action(
            %Param,
            Mode => 'Change',
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

            return $Kernel::OM->Get('Kernel::Output::HTML::Layout')->ErrorScreen(
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

sub _Change {
    my ( $Self, %Param ) = @_;

    # get a local param and layout object
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

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    $Param{DisplayFieldName} = 'New';

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # get all fields
    my $DynamicFieldList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }

    # when adding we need to create an extra order number for the new field
    if ( $Param{Mode} eq 'Add' ) {

        # get the last element form the order list and add 1
        my $LastOrderNumber = $DynamicfieldOrderList[-1];
        $LastOrderNumber++;

        # add this new order number to the end of the list
        push @DynamicfieldOrderList, $LastOrderNumber;
    }

    $Param{DynamicFieldOrderStrg} = $LayoutObject->BuildSelection(
        Data          => \@DynamicfieldOrderList,
        Name          => 'FieldOrder',
        SelectedValue => $Param{FieldOrder} || 1,
        PossibleNone  => 0,
        Class         => 'W50pc Validate_Number',
    );

    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

    # create the Validity select
    $Param{ValidityStrg} = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $Param{ValidID} || 1,
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'W50pc',
    );

    # create the InputType select
    $Param{InputTypeStrg} = $LayoutObject->BuildSelection(
        Data => {
            0 => 'Single contact',
            1 => 'Multiple contacts',
        },
        Name         => 'InputType',
        SelectedID   => $Param{InputType} || 0,
        PossibleNone => 0,
        Translation  => 1,
        Class        => "W50pc " . ( $Param{InputTypeServerError} || '' ),
    );

    # create the CustomerInterfaceTab select
    $Param{CustomerInterfaceTabStrg} = $LayoutObject->BuildSelection(
        Data => {
            0 => 'No',
            1 => 'Yes',
        },
        Name         => 'CustomerInterfaceTab',
        SelectedID   => $Param{CustomerInterfaceTab} || 0,
        PossibleNone => 0,
        Translation  => 1,
        Class        => "W50pc " . ( $Param{CustomerInterfaceTabServerError} || '' ),
    );

    # create the UseForCommunication select
    $Param{UseForCommunicationStrg} = $LayoutObject->BuildSelection(
        Data => {
            'To'  => 'To',
            'Cc'  => 'CC',
            'Bcc' => 'BCC',
            0     => 'No',
        },
        Name         => 'UseForCommunication',
        SelectedID   => $Param{UseForCommunication} || 0,
        PossibleNone => 0,
        Translation  => 1,
        Multiple     => 0,
        Class        => "W50pc " . ( $Param{UseForCommunicationServerError} || '' ),
    );

    # special handling for 'UseForNotification'
    my @UseForNotificationSelected;
    if ( $Param{UseForNotification} ) {
        @UseForNotificationSelected = split( /,/, $Param{UseForNotification} );
    }

    # create the UseForCommunication select
    $Param{UseForNotificationStrg} = $LayoutObject->BuildSelection(
        Data => {
            'To'  => 'To',
            'Cc'  => 'CC',
            'Bcc' => 'BCC',
        },
        Name         => 'UseForNotification',
        SelectedID   => \@UseForNotificationSelected,
        PossibleNone => 0,
        Translation  => 1,
        Multiple     => 1,
        Class        => "Modernize W50pc " . ( $Param{UseForNotificationServerError} || '' ),
    );

    # create the CustomerFilter select
    my @FilterFields = (
        {
            Key   => '0',
            Value => 'No',
        },
    );

    # get CustomerUser from Config.pm/Defaults.pm
    my $CustomerUserConfig = $Kernel::OM->Get('Kernel::Config')->Get('CustomerUser');
    if (
        IsHashRefWithData($CustomerUserConfig)
        && IsArrayRefWithData( $CustomerUserConfig->{Map} )
        )
    {

        CURRENTMAPFIELD:
        for my $CurrentMapField ( @{ $CustomerUserConfig->{Map} } ) {

            next CURRENTMAPFIELD if !IsArrayRefWithData($CurrentMapField);
            next CURRENTMAPFIELD if !$CurrentMapField->[0];
            next CURRENTMAPFIELD if !$CurrentMapField->[1];

            # push internal value as key (UserCustomerID, UserFirstname, CustomField123 etc.)
            # push display value as value (CustomerID, Firstname, Function etc.)
            push @FilterFields, {
                Key   => $CurrentMapField->[0],
                Value => $CurrentMapField->[1],
            };
        }
    }

    $Param{CustomerFilterStrg} = $LayoutObject->BuildSelection(
        Data         => \@FilterFields,
        Name         => 'CustomerFilter',
        SelectedID   => $Param{CustomerFilter} || 0,
        PossibleNone => 0,
        Translation  => 1,
        Class        => "W50pc " . ( $Param{CustomerFilterServerError} || '' ),
    );

    # hide CustomerFilterCriteria if CustomerFilter is disabled or 'CustomerID' is selected
    if ( !$Param{CustomerFilter} || $Param{CustomerFilter} eq 'UserCustomerID' ) {
        $Param{HideCSS} = ' style="display:none;"';
    }

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminCustomContactFields',
        Data         => {
            %Param,
            CustomerInterfaceTabName => $Param{CustomerInterfaceTabName} || $Param{Name} || '',
        },
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _Action {

    my ( $Self, %Param ) = @_;

    # get a local param and layout object
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %Errors;
    my %GetParam;

    for my $Needed (qw(Name Label FieldOrder)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
        }
    }

    if ( !$Param{Mode} || !grep { $Param{Mode} eq $_ } qw(Add Change) ) {

        my $ErrorMessage = 'Invalid Mode';
        if ( defined $Param{Mode} ) {
            $ErrorMessage .= " '$Param{Mode}'";
        }

        return $LayoutObject->ErrorScreen(
            Message => $ErrorMessage,
        );
    }

    my $FieldID = $ParamObject->GetParam( Param => 'ID' );
    if ( !$FieldID && $Param{Mode} eq 'Change' ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ID",
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
            $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
                )
        };

        if (
            $DynamicFieldsList{ $GetParam{Name} } &&
            (
                !$FieldID
                || $FieldID ne $DynamicFieldsList{ $GetParam{Name} }
            )
            )
        {
            # add server error class
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

    my @UseForNotification;

    for my $ConfigParam (
        qw(
        ObjectType ObjectTypeName FieldType FieldTypeName ValidID InputType CustomerInterfaceTab CustomerInterfaceTabName UseForCommunication UseForNotification CustomerFilter CustomerFilterCriteria
        )
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );

        # special handling for 'UseForNotification'
        if ( $ConfigParam eq 'UseForNotification' ) {
            @UseForNotification = $ParamObject->GetArray( Param => $ConfigParam );
            $GetParam{UseForNotification} = join ',', @UseForNotification;
        }
    }

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ValidID",
        );
    }

    # check if InputType is numeric
    if (
        !defined $GetParam{InputType}
        || $GetParam{InputType} !~ m{\A (?: \d )+ \z}xms
        )
    {
        $Errors{InputTypeServerError}        = 'ServerError';
        $Errors{InputTypeServerErrorMessage} = 'Invalid selection. Please choose between yes or no.';
    }

    # check if CustomerInterfaceTab is numeric
    if (
        !defined $GetParam{CustomerInterfaceTab}
        || $GetParam{CustomerInterfaceTab} !~ m{\A (?: \d )+ \z}xms
        )
    {
        $Errors{CustomerInterfaceTabServerError}        = 'ServerError';
        $Errors{CustomerInterfaceTabServerErrorMessage} = 'Invalid selection. Please choose between yes or no.';
    }

    # check if CustomerInterfaceTabName is alphanumeric
    if (
        $GetParam{CustomerInterfaceTabName}
        && $GetParam{CustomerInterfaceTabName} !~ m{\A (?: [\w\s] )+ \z}xms
        )
    {
        $Errors{CustomerInterfaceTabNameServerError}        = 'ServerError';
        $Errors{CustomerInterfaceTabNameServerErrorMessage} = 'Invalid input. Please only use alphanumeric values.';
    }

    # check if UseForCommunication is numeric
    if (
        !defined $GetParam{UseForCommunication}
        || !grep { $GetParam{UseForCommunication} eq $_ } qw(To Bcc Cc 0)
        )
    {
        $Errors{UseForCommunicationServerError}        = 'ServerError';
        $Errors{UseForCommunicationServerErrorMessage} = 'Invalid selection. Please choose between yes or no.';
    }

    # check if UseForNotification is numeric
    if ( !defined $GetParam{UseForNotification} )
    {
        $Errors{UseForNotificationServerError}        = 'ServerError';
        $Errors{UseForNotificationServerErrorMessage} = 'Invalid selection. Please choose between yes or no.';
    }

    # check if CustomerFilter is valid
    if ( !defined $GetParam{CustomerFilter} )
    {
        $Errors{CustomerFilterServerError}        = 'ServerError';
        $Errors{CustomerFilterServerErrorMessage} = 'Invalid selection. Please choose between yes or no.';
    }

    # check if CustomerFilterCriteria is alphanumeric
    if (
        $GetParam{CustomerFilter}
        && $GetParam{CustomerFilter} ne 'UserCustomerID'
        && (
            !$GetParam{CustomerFilterCriteria}
            || $GetParam{CustomerFilterCriteria} !~ m{\A (?: [\w\s] )+ \z}xms
        )
        )
    {
        $Errors{CustomerFilterCriteriaServerError}        = 'ServerError';
        $Errors{CustomerFilterCriteriaServerErrorMessage} = 'Invalid input. Please only use alphanumeric values.';
    }

    # return to screen if errors occur
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            ID => $FieldID || '',
            Mode => $Param{Mode},
        );
    }

    # set specific config
    my $FieldConfig = {
        InputType                => $GetParam{InputType},
        CustomerInterfaceTab     => $GetParam{CustomerInterfaceTab},
        CustomerInterfaceTabName => $GetParam{CustomerInterfaceTabName} || '',
        UseForCommunication      => $GetParam{UseForCommunication},
        UseForNotification       => $GetParam{UseForNotification},
        CustomerFilter           => $GetParam{CustomerFilter},
        CustomerFilterCriteria   => $GetParam{CustomerFilterCriteria} || '',
    };

    # get a local dynamic field object
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    if ( $Param{Mode} eq 'Change' ) {

        # get dynamic filed data
        my $DynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
            ID => $FieldID,
        );

        # check for valid dynamic field configuration
        if ( !IsHashRefWithData($DynamicFieldData) ) {

            return $LayoutObject->ErrorScreen(
                Message => "Could not get data for DynamicField with FieldID '$FieldID'",
            );
        }

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
                Message => "Could not update DynamicField '$GetParam{Label}' ($GetParam{Name})",
            );
        }
    }
    elsif ( $Param{Mode} eq 'Add' ) {

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
                Message => "Could not create new DynamicField '$GetParam{Label}' ($GetParam{Name})",
            );
        }
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminDynamicField",
    );
}

1;
