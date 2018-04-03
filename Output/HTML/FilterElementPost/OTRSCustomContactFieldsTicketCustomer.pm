# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsTicketCustomer;

use strict;
use warnings;

use Mail::Address;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Web::Request',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::AgentTicketCustomer");

    # get 'Customer' DynamicFields
    # get the dynamic fields for this screen
    $Self->{DynamicField} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldType   => 'Customer',
        FieldFilter => $Self->{Config}->{DynamicField} || {},
    );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $TemplateName = $Param{TemplateFile} || '';
    return 1 if !$TemplateName;

    # get valid modules
    my $ValidTemplates = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Output::FilterElementPost')
        ->{'OTRSCustomContactFieldsTicketCustomer'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );
    return 1 if !$TicketID;

    # generate widget output
    my $AgentContactWidgetHTML = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'AgentContactWidget',
        Data         => {},
    );

    # place the contact widget in the side bar.
    my $StartPattern = '(</div> \s+ <div [ ] class="ContentColumn">)';

    if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
        ${ $Param{Data} } =~ s{ ($StartPattern) }{$AgentContactWidgetHTML$1}ixms;
    }

    # get dynamic field values form http request
    my %DynamicFieldValues;

    # get needed objects
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # extract the dynamic field value form the web request
        $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ParamObject        => $ParamObject,
            LayoutObject       => $LayoutObject,
        );
    }

    my %GetParam;

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldACLParameters;
    DYNAMICFIELD:
    for my $DynamicField ( sort keys %DynamicFieldValues ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField } = $DynamicFieldValues{$DynamicField};
    }
    $GetParam{DynamicField} = \%DynamicFieldACLParameters;

    my %Error;

    # create html strings for all dynamic fields
    my %DynamicFieldHTML;

    my $Subaction = $ParamObject->GetParam( Param => 'Subaction' ) || '';

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ( $Subaction eq 'Update' ) {

        # check needed data
        if ( !$ParamObject->GetParam( Param => 'CustomerUserID' ) ) {
            $Error{'CustomerUserIDInvalid'} = 'ServerError';
        }
        if ( !$ParamObject->GetParam( Param => 'CustomerID' ) ) {
            $Error{'CustomerIDInvalid'} = 'ServerError';
        }

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $PossibleValuesFilter;

            # check if field has PossibleValues property in its configuration
            if ( IsHashRefWithData( $DynamicFieldConfig->{Config}->{PossibleValues} ) ) {

                # convert possible values key => value to key => key for ACLs usign a Hash slice
                my %AclData = %{ $DynamicFieldConfig->{Config}->{PossibleValues} };
                @AclData{ keys %AclData } = keys %AclData;

                # set possible values filter from ACLs
                my $ACL = $TicketObject->TicketAcl(
                    %GetParam,
                    Action        => $Self->{Action},
                    TicketID      => $TicketID,
                    ReturnType    => 'Ticket',
                    ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data          => \%AclData,
                    UserID        => $Self->{UserID},
                );
                if ($ACL) {
                    my %Filter = $TicketObject->TicketAclData();

                    # convert Filer key => key back to key => value using map
                    %{$PossibleValuesFilter} = map { $_ => $DynamicFieldConfig->{Config}->{PossibleValues}->{$_} }
                        keys %Filter;
                }
            }

            my $ValidationResult = $DynamicFieldBackendObject->EditFieldValueValidate(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                ParamObject          => $ParamObject,
                Mandatory =>
                    $Self->{Config}->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
            );

            # propagate validation error to the Error variable to be detected by the frontend
            if ( $ValidationResult->{ServerError} ) {
                $Error{ $DynamicFieldConfig->{Name} } = ' ServerError';
            }

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } =
                $DynamicFieldBackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Mandatory =>
                    $Self->{Config}->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                ServerError  => $ValidationResult->{ServerError}  || '',
                ErrorMessage => $ValidationResult->{ErrorMessage} || '',
                LayoutObject => $LayoutObject,
                ParamObject  => $ParamObject,
                AJAXUpdate   => 1,
                UpdatableFields => $Self->_GetFieldsToUpdate(),
                );
        }

        # if there is no validation error  no changes to the output are needed
        return 1 if !%Error;
    }

    my $HTML = $Self->Form(
        TicketID => $TicketID,
        %Error,
        DynamicFieldHTML => \%DynamicFieldHTML,
    );

    return 1 if !$HTML;

    # place the dynamic fields HTML above the submit button. (consider also the comment)
    $StartPattern = '( \s+ <div [ ] class="Field"> \s+ (?:<!--[^>]+>\s+) <button )';

    my $Replace = << "END";

<!--STARTOTRSCustomContactFieldsTicketCustomer-->
$HTML
<!--ENDOTRSCustomContactFieldsTicketCustomer-->
END

    if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
        ${ $Param{Data} } =~ s{ ($StartPattern) }{$Replace$1}ixms;
    }

    return 1;
}

sub Form {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %DynamicFieldHTML;
    my @FieldsCustomer;
    if ( !IsHashRefWithData( $Param{DynamicFieldHTML} ) ) {

        # get ticket object
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $PossibleValuesFilter;

            # check if field has PossibleValues property in its configuration
            if ( IsHashRefWithData( $DynamicFieldConfig->{Config}->{PossibleValues} ) ) {

                # convert possible values key => value to key => key for ACLs using a Hash slice
                my %AclData = %{ $DynamicFieldConfig->{Config}->{PossibleValues} };
                @AclData{ keys %AclData } = keys %AclData;

                # set possible values filter from ACLs
                my $ACL = $TicketObject->TicketAcl(
                    %Param,
                    Action        => $Self->{Action},
                    TicketID      => $Param{TicketID},
                    ReturnType    => 'Ticket',
                    ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data          => \%AclData,
                    UserID        => $Self->{UserID},
                );
                if ($ACL) {
                    my %Filter = $TicketObject->TicketAclData();

                    # convert Filer key => key back to key => value using map
                    %{$PossibleValuesFilter} = map { $_ => $DynamicFieldConfig->{Config}->{PossibleValues}->{$_} }
                        keys %Filter;
                }
            }

            # get value stored on the database
            my $Value = $DynamicFieldBackendObject->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Param{TicketID},
            );

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Value                => $Value,
                Mandatory =>
                    $Self->{Config}->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                LayoutObject    => $LayoutObject,
                ParamObject     => $Kernel::OM->Get('Kernel::System::Web::Request'),
                AJAXUpdate      => 1,
                UpdatableFields => $Self->_GetFieldsToUpdate(),
            );

            if ( !IsHashRefWithData( $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } ) ) {
                return $LayoutObject->ErrorScreen(
                    Message => "Error while creating HTML for DynamicField '" . $DynamicFieldConfig->{Name} . "'!",
                    Comment => 'Please contact the admin.',
                );
            }
        }
    }
    else {
        %DynamicFieldHTML = %{ $Param{DynamicFieldHTML} }
    }

    # create the returning HTML structure for all the dynamic fields
    my $HTML;
    for my $CurrentDynamicFieldName ( sort keys %DynamicFieldHTML ) {
        $HTML .= << "END";
<div class="Row Row_DynamicField_$CurrentDynamicFieldName">
    $DynamicFieldHTML{ $CurrentDynamicFieldName }{Label}
    <div class="Field">
        $DynamicFieldHTML{ $CurrentDynamicFieldName }{Field}
    </div>
    <div class="Clear"></div>
</div>
END
    }
    return $HTML;
}

sub _GetFieldsToUpdate {
    my ( $Self, %Param ) = @_;

    my @UpdatableFields;

    # set the fields that can be updatable via AJAXUpdate
    if ( !$Param{OnlyDynamicFields} ) {
        @UpdatableFields = qw( TypeID Dest ServiceID SLAID NewUserID NewResponsibleID NextStateID PriorityID );
    }

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );
        next DYNAMICFIELD if !$IsACLReducible;

        push @UpdatableFields, 'DynamicField_' . $DynamicFieldConfig->{Name};
    }

    return \@UpdatableFields;
}

1;
