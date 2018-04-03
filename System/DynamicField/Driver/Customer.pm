# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::DynamicField::Driver::Customer;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use base qw(Kernel::System::DynamicField::Driver::BaseText);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::System::Log',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Main',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::CustomerUser',
);

=head1 NAME

Kernel::System::DynamicField::Driver::Customer

=head1 SYNOPSIS

DynamicFields Customer Driver delegate

=head1 PUBLIC INTERFACE

This module implements the public interface of L<Kernel::System::DynamicField::Backend>.
Please look there for a detailed reference of the functions.

=over 4

=item new()

usually, you want to create an instance of this
by using Kernel::System::DynamicField::Backend->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # set field behaviors
    $Self->{Behaviors} = {
        'IsACLReducible'               => 0,
        'IsNotificationEventCondition' => 1,
        'IsSortable'                   => 0,
        'IsFiltrable'                  => 0,
        'IsStatsCondition'             => 0,
        'IsCustomerInterfaceCapable'   => 1,
    };

    # get the Dynamic Field Backend custom extensions
    my $DynamicFieldDriverExtensions
        = $Kernel::OM->Get('Kernel::Config')->Get('DynamicFields::Extension::Driver::Text');

    EXTENSION:
    for my $ExtensionKey ( sort keys %{$DynamicFieldDriverExtensions} ) {

        # skip invalid extensions
        next EXTENSION if !IsHashRefWithData( $DynamicFieldDriverExtensions->{$ExtensionKey} );

        # create a extension config shortcut
        my $Extension = $DynamicFieldDriverExtensions->{$ExtensionKey};

        # check if extension has a new module
        if ( $Extension->{Module} ) {

            # check if module can be loaded
            if ( !$Kernel::OM->Get('Kernel::System::Main')->RequireBaseClass( $Extension->{Module} ) ) {
                die "Can't load dynamic fields backend module"
                    . " $Extension->{Module}! $@";
            }
        }

        # check if extension contains more behaviors
        if ( IsHashRefWithData( $Extension->{Behaviors} ) ) {

            %{ $Self->{Behaviors} } = (
                %{ $Self->{Behaviors} },
                %{ $Extension->{Behaviors} }
            );
        }
    }

    return $Self;
}

sub ValueGet {
    my ( $Self, %Param ) = @_;

    my $DFValue = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueGet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
    );

    return if !$DFValue;
    return if !IsArrayRefWithData($DFValue);
    return if !IsHashRefWithData( $DFValue->[0] );

    # extract real values
    my @ReturnData;
    for my $Item ( @{$DFValue} ) {
        push @ReturnData, $Item->{ValueText}
    }

    return \@ReturnData;
}

sub ValueSet {
    my ( $Self, %Param ) = @_;

    # check value
    my @Values;
    if ( ref $Param{Value} eq 'ARRAY' ) {
        @Values = @{ $Param{Value} };
    }
    else {
        @Values = ( $Param{Value} );
    }

    my $Success;
    if ( IsArrayRefWithData( \@Values ) ) {

        # if there is at least one value to set, this means one or more values are selected,
        #    set those values!
        my @ValueText;
        for my $Item (@Values) {
            push @ValueText, { ValueText => $Item };
        }

        $Success = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSet(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $Param{ObjectID},
            Value    => \@ValueText,
            UserID   => $Param{UserID},
        );
    }
    else {

        # otherwise no value was selected, then in fact this means that any value there should be
        # deleted
        $Success = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueDelete(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $Param{ObjectID},
            UserID   => $Param{UserID},
        );
    }

    return $Success;
}

sub ValueIsDifferent {
    my ( $Self, %Param ) = @_;

    # special cases where the values are different but they should be reported as equals
    if (
        !defined $Param{Value1}
        && ref $Param{Value2} eq 'ARRAY'
        && !IsArrayRefWithData( $Param{Value2} )
        )
    {
        return
    }
    if (
        !defined $Param{Value2}
        && ref $Param{Value1} eq 'ARRAY'
        && !IsArrayRefWithData( $Param{Value1} )
        )
    {
        return
    }

    # compare the results
    return DataIsDifferent(
        Data1 => \$Param{Value1},
        Data2 => \$Param{Value2}
    );
}

sub ValueValidate {
    my ( $Self, %Param ) = @_;

    # check value
    my @Values;
    if ( IsArrayRefWithData( $Param{Value} ) ) {
        @Values = @{ $Param{Value} };
    }
    else {
        @Values = ( $Param{Value} );
    }

    my $Success;
    for my $Item (@Values) {

        $Success = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueValidate(
            Value => {
                ValueText => $Item,
            },
            UserID => $Param{UserID}
        );
        return if !$Success
    }
    return $Success;
}

sub EditFieldRender {
    my ( $Self, %Param ) = @_;

    # take config from field config
    my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
    my $FieldName   = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};
    my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

    # set the field value or default
    my $Value = $Param{Value} // '';

    # check if a value in a template (GenericAgent etc.)
    # is configured for this dynamic field
    if (
        IsHashRefWithData( $Param{Template} )
        && defined $Param{Template}->{$FieldName}
        )
    {
        $Value = $Param{Template}->{$FieldName};
    }

    # extract the dynamic field value form the web request
    my $FieldValue = $Self->EditFieldValueGet(
        %Param,
    );

    # set values from ParamObject if present
    if ( IsArrayRefWithData($FieldValue) ) {
        $Value = $FieldValue;
    }

    # check and set class if necessary
    my $FieldClass = 'ContactAutoComplete W75pc';
    if ( defined $Param{Class} && $Param{Class} ne '' ) {
        $FieldClass .= ' ' . $Param{Class};
    }

    # set field as mandatory, but only for single contact type
    if ( $Param{Mandatory} && !$FieldConfig->{InputType} ) {
        $FieldClass .= ' Validate_Required';
    }

    # set error css class
    if ( $Param{ServerError} ) {
        $FieldClass .= ' ServerError';
    }

    # check value
    my $SelectedValuesArrayRef;
    if ($Value) {
        if ( ref $Value eq 'ARRAY' ) {
            $SelectedValuesArrayRef = $Value;
        }
        else {
            $SelectedValuesArrayRef = [$Value];
        }
    }

    my $HTMLString = '';

    # set additional class to mark this field as to filter by configured value
    if ( $FieldConfig->{CustomerFilter} ) {

        $FieldClass .= ' AutoComplete_Filter' . $FieldConfig->{CustomerFilter};

        if ( $FieldConfig->{CustomerFilter} ne 'UserCustomerID' ) {

            my $Filter = $FieldConfig->{CustomerFilterCriteria};
            $HTMLString .= <<"EOF";
<input type="hidden" id="${FieldName}Criteria" name="${FieldName}Criteria" value="$Filter" />
EOF
        }
    }

    # input type = 1 -> multiple type, otherwise single type
    if ( $FieldConfig->{InputType} ) {

        my $ContactCounter = 0;
        my $ContactEntries = '';
        my $ContactOptions = '';
        for my $Item ( @{$SelectedValuesArrayRef} ) {
            $ContactCounter++;

            my $DisplayValue = $Self->_CustomerUserRender(
                HTMLQuote => 1,
                Search    => $Item,
            ) || '';
            if ( !$DisplayValue ) {
                $Item = '';
            }

            $ContactEntries .= <<"EOF";
        <div class="SpacingTopSmall">
            <input name="${FieldName}Key_$ContactCounter" id="${FieldName}Key_$ContactCounter" class="CustomerKey" type="hidden" value="$Item"/>
            <input class="ContactTicketText" title="$FieldLabel" name="${FieldName}Text_$ContactCounter" id="${FieldName}Text_$ContactCounter" type="text" value="$DisplayValue" readonly="readonly" />
            <button id="${FieldName}RemoveCustomerTicket_$ContactCounter" name="${FieldName}RemoveCustomerTicket_$ContactCounter" class="Remove CustomerTicketRemove"><span><i class="fa fa-minus-square-o"></i></span></button>
        </div>
EOF

            $ContactOptions .= <<"EOF";
        <option value="$Item" selected="selected">$Item</option>
EOF
        }

        $HTMLString .= <<"EOF";
    <select class="Hidden" id="$FieldName" multiple="multiple" name="$FieldName">
$ContactOptions
    </select>
    <input type="text" class="$FieldClass DynamicFieldType_Customer MultipleContact" id="${FieldName}Autocomplete" name="${FieldName}Autocomplete" title="$FieldLabel" value="" />
EOF

        if ( $Param{Mandatory} ) {
            my $DivID = $FieldName . 'AutocompleteError';

            # for client side validation
            $HTMLString .= <<"EOF";
    <div id="$DivID" class="TooltipErrorMessage">
        <p>
            \$Text{"This field is required."}
        </p>
    </div>
EOF
        }

        if ( $Param{ServerError} ) {

            my $ErrorMessage = $Param{ErrorMessage} || 'This field is required.';
            my $DivID = $FieldName . 'AutocompleteServerError';

            # for server side validation
            $HTMLString .= <<"EOF";
    <div id="$DivID" class="TooltipErrorMessage">
        <p>
            [% Translate("$ErrorMessage") | html %]
        </p>
    </div>
EOF
        }

        my $HiddenContainer = '';
        if ( !$ContactCounter ) {
            $HiddenContainer = 'Hidden';
        }

        $HTMLString .= <<"EOF";
</div>
<div class="Clear"></div>

<div class="Field $HiddenContainer">
    <div class="CustomerTicketTemplate${FieldName} SpacingTopSmall Hidden">
        <input name="${FieldName}Key" id="${FieldName}Key" class="CustomerKey" type="hidden" value=""/>
        <input class="ContactTicketText" title="$FieldLabel" name="${FieldName}Text" id="${FieldName}Text" type="text" value="" readonly="readonly" />
        <button type="button" id="${FieldName}RemoveCustomerTicket" class="Remove CustomerTicketRemove"><span><i class="fa fa-minus-square-o"></i></span></button>
    </div>

    <div id="TicketCustomerContent${FieldName}" class="ContactCustomerContainer">
        <span class="BoxLabel">$FieldLabel</span>
$ContactEntries
    </div>
    <input name="CustomerTicketCounter${FieldName}" id="CustomerTicketCounter${FieldName}" type="hidden" value="$ContactCounter"/>
</div>
<div>  <!-- this div open is required to maintain the correct structure -->
EOF
    }

    # single entry
    else {
        my $DisplayValue   = '';
        my $ContactOptions = '';
        if ( $SelectedValuesArrayRef->[0] ) {
            $DisplayValue = $Self->_CustomerUserRender(
                HTMLQuote => 1,
                Search    => $SelectedValuesArrayRef->[0],
            ) || '';
            if ( !$DisplayValue ) {
                $SelectedValuesArrayRef->[0] = '';
            }
            $ContactOptions = <<"EOF";
        <option value="$SelectedValuesArrayRef->[0]" selected="selected">$SelectedValuesArrayRef->[0]</option>
EOF
        }

        my $TranslateEmpty = $Kernel::OM->Get('Kernel::Language')->Get('Empty');

        $HTMLString .= <<"EOF";
    <select class="Hidden" id="$FieldName" multiple="multiple" name="$FieldName">
$ContactOptions
    </select>
<input type="text" class="$FieldClass DynamicFieldType_Customer" id="${FieldName}Autocomplete" name="${FieldName}Autocomplete" title="$FieldLabel" value="$DisplayValue" />
<a href='#' class="EmptyCustomer" title="$TranslateEmpty"><i class="fa fa-times"></i></a>

EOF

        if ( $Param{Mandatory} ) {
            my $DivID = $FieldName . 'AutocompleteError';

            # for client side validation
            $HTMLString .= <<"EOF";
<div id="$DivID" class="TooltipErrorMessage">
    <p>
        [% Translate("This field is required.") | html %]
    </p>
</div>
EOF
        }

        if ( $Param{ServerError} ) {

            my $ErrorMessage = $Param{ErrorMessage} || 'This field is required.';
            my $DivID = $FieldName . 'ServerError';

            # for server side validation
            $HTMLString .= <<"EOF";
<div id="$DivID" class="TooltipErrorMessage">
    <p>
        [% Translate("$ErrorMessage") | html %]
    </p>
</div>
EOF
        }
    }

    # call EditLabelRender on the common Driver
    my $LabelString = $Self->EditLabelRender(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        Mandatory          => $Param{Mandatory} || '0',
        FieldName          => $FieldName . 'Autocomplete',
        LayoutObject       => $Kernel::OM->Get('Kernel::Output::HTML::Layout'),
    );
    my $AutoCompleteConfig = $Kernel::OM->Get('Kernel::Config')->Get('AutoComplete::Agent')->{'CustomerSearch'};
    my $ActiveAutoComplete = $AutoCompleteConfig->{AutoCompleteActive} || 0;

    my $Data = {
        Field => $HTMLString,
        Label => $LabelString,
    };

    return $Data;
}

sub EditFieldValueGet {
    my ( $Self, %Param ) = @_;

    my $FieldName = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};

    my $Value;

    # check if there is a Template and retrieve the dynamic field value from there
    if ( IsHashRefWithData( $Param{Template} ) ) {
        $Value = $Param{Template}->{$FieldName};
    }

    # otherwise get dynamic field value from the web request
    elsif (
        defined $Param{ParamObject}
        && ref $Param{ParamObject} eq 'Kernel::System::Web::Request'
        )
    {
        my @Data = $Param{ParamObject}->GetArray( Param => $FieldName );

        # delete empty values (can happen if the user has selected the "-" entry)
        my $Index = 0;
        ITEM:
        for my $Item ( sort @Data ) {

            if ( !$Item ) {
                splice( @Data, $Index, 1 );
                next ITEM;
            }
            $Index++;
        }

        $Value = \@Data;
    }

    if ( defined $Param{ReturnTemplateStructure} && $Param{ReturnTemplateStructure} eq 1 ) {
        return {
            $FieldName => $Value,
        };
    }

    # for this field the normal return an the ReturnValueStructure are the same
    return $Value;
}

sub EditFieldValueValidate {
    my ( $Self, %Param ) = @_;

    # get the field value from the http request
    my $Values = $Self->EditFieldValueGet(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        ParamObject        => $Param{ParamObject},

        # not necessary for this Driver but place it for consistency reasons
        ReturnValueStructure => 1,
    );

    my $ServerError;
    my $ErrorMessage;

    # perform necessary validations
    if ( $Param{Mandatory} && !IsArrayRefWithData($Values) ) {
        return {
            ServerError => 1,
        };
    }

    # create resulting structure
    my $Result = {
        ServerError  => $ServerError,
        ErrorMessage => $ErrorMessage,
    };

    return $Result;
}

sub DisplayValueRender {
    my ( $Self, %Param ) = @_;

    # set HTMLOutput as default if not specified
    if ( !defined $Param{HTMLOutput} ) {
        $Param{HTMLOutput} = 1;
    }

    # set Value and Title variables
    my $Value = '';
    my $Title = '';

    # check value
    my @Values;
    if ( ref $Param{Value} eq 'ARRAY' ) {
        @Values = @{ $Param{Value} };
    }
    else {
        @Values = ( $Param{Value} );
    }

    my @ReadableValues;
    my @ReadableTitles;

    VALUEITEM:
    for my $Item (@Values) {
        next VALUEITEM if !$Item;

        my $ReadableTitle = $Item;

        my $ReadableValue = $Self->_CustomerUserRender(
            HTMLQuote => 0,
            Search    => $Item,
        );

        # HTMLOuput transformations
        if ( $Param{HTMLOutput} ) {

            $ReadableValue = $Param{LayoutObject}->Ascii2Html(
                Text => $ReadableValue,
            );

            $ReadableTitle = $Param{LayoutObject}->Ascii2Html(
                Text => $ReadableTitle,
            );
        }

        if ( length $ReadableValue ) {
            push @ReadableValues, $ReadableValue;
        }
        if ( length $ReadableTitle ) {
            push @ReadableTitles, $ReadableTitle;
        }
    }

    # set new line separator
    my $ItemSeparator = ', ';

    $Value = join( $ItemSeparator, @ReadableValues );
    $Title = join( $ItemSeparator, @ReadableTitles );

    # this field type does not support the Link Feature
    my $Link;

    # create return structure
    my $Data = {
        Value => $Value,
        Title => $Title,
        Link  => $Link,
        Class => 'DynamicFieldType_Customer',
    };

    return $Data;
}

sub ReadableValueRender {
    my ( $Self, %Param ) = @_;

    # set Value and Title variables
    my $Value = '';
    my $Title = '';

    # check value
    my @Values;
    if ( ref $Param{Value} eq 'ARRAY' ) {
        @Values = @{ $Param{Value} };
    }
    else {
        @Values = ( $Param{Value} );
    }

    my @ReadableValues;

    VALUEITEM:
    for my $Item (@Values) {
        next VALUEITEM if !$Item;

        push @ReadableValues, $Item;
    }

    # set new line separator
    my $ItemSeparator = ', ';

    # Output transformations
    $Value = join( $ItemSeparator, @ReadableValues );
    $Title = $Value;

    # create return structure
    my $Data = {
        Value => $Value,
        Title => $Title,
    };

    return $Data;
}

sub ObjectMatch {
    my ( $Self, %Param ) = @_;

    my $FieldName = $Param{DynamicFieldConfig}->{Name};

    # not supported
    return 0;
}

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    my @Keys;
    if ( ref $Param{Key} eq 'ARRAY' ) {
        @Keys = @{ $Param{Key} };
    }
    else {
        @Keys = ( $Param{Key} );
    }

    # to store final values
    my @Values;

    KEYITEM:
    for my $Item (@Keys) {
        next KEYITEM if !$Item;

        # set the value as the key by default
        my $Value = $Item;

        push @Values, $Value;
    }

    return \@Values;
}

sub _CustomerUserRender {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Search} ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need parameter 'Search' to lookup CustomerUser data.",
        );
        return;
    }

    my %CustomerUserList = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerSearch(
        Search => $Param{Search} || '',
    );

    if ( !$CustomerUserList{ $Param{Search} } ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Couldn't find customer user data requested customer '$Param{Search}'.",
        );
        return;
    }

    my $DisplayValue = $CustomerUserList{ $Param{Search} };

    # html quoting
    if ( $Param{HTMLQuote} ) {
        $DisplayValue =~ s/&/&amp;/g;
        $DisplayValue =~ s/</&lt;/g;
        $DisplayValue =~ s/>/&gt;/g;
        $DisplayValue =~ s/"/&quot;/g;
    }

    return $DisplayValue;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
