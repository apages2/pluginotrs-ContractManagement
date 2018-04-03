# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ContactWithData;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Search;
    my $Replace;

    # add info boxes in zoom
    if ( $Param{TemplateFile} eq 'AgentTicketZoom' ) {

        my $TicketID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'TicketID' );
        if ( !$TicketID ) {
            $TicketID = $Kernel::OM->Get('Kernel::System::Ticket')->TicketIDLookup(
                TicketNumber => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'TicketNumber' ),
            );
        }
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
        );

        # check if edit functionality should be available
        my $Edit;
        my $Groups = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Module')->{'AdminContactWithData'}
            ->{Group};
        if ( IsArrayRefWithData($Groups) ) {
            GROUP:
            for my $Group ( @{$Groups} ) {
                next GROUP
                    if !$Kernel::OM->Get('Kernel::Output::HTML::Layout')->{"UserIsGroup\[$Group\]"};
                $Edit = 1;
                last GROUP;
            }
        }

        # get df config for zoom
        my $DynamicFieldFilter = {
            %{
                $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::AgentTicketZoom")
                    ->{DynamicField}
                    || {}
            },
            %{
                $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::AgentTicketZoom")
                    ->{ProcessWidgetDynamicField}
                    || {}
            },
        };
        my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Ticket'],
            FieldFilter => $DynamicFieldFilter || {},
        );
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            next DYNAMICFIELD if $DynamicFieldConfig->{FieldType} ne 'ContactWithData';
            next DYNAMICFIELD if $DynamicFieldConfig->{ValidID} ne 1;
            my $Value = $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} };
            next DYNAMICFIELD if !$Value;

            $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Block(
                Name => 'OutputFilterPostContactWithDataZoom',
                Data => {
                    DynamicFieldConfig => $DynamicFieldConfig,
                    }
            );

            if ($Edit) {
                $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Block(
                    Name => 'OutputFilterPostContactWithDataZoomEdit',
                    Data => {
                        DynamicFieldConfig => $DynamicFieldConfig,
                        ContactID          => $Value,
                        }
                );
            }

            my $PossibleAttributes = $DynamicFieldConfig->{Config}->{PossibleValues};
            my $ContactAttributes  = $DynamicFieldConfig->{Config}->{ContactsWithData}->{$Value};
            my $SortOrder          = $DynamicFieldConfig->{Config}->{SortOrderComputed};
            ATTRIBUTE:
            for my $Attribute ( @{$SortOrder} ) {
                next ATTRIBUTE if !$ContactAttributes->{$Attribute};
                next ATTRIBUTE if $Attribute eq 'ValidID';
                $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Block(
                    Name => 'OutputFilterPostContactWithDataZoomAttribute',
                    Data => {
                        Attribute          => $Attribute,
                        ContactAttributes  => $ContactAttributes,
                        PossibleAttributes => $PossibleAttributes,
                        }
                );
            }
        }

        my $Replace = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
            TemplateFile => 'OutputFilterPostContactWithData',
        );

        ${ $Param{Data} } =~ s{(<!--HookEndCustomerTable-->)}{$1$Replace}xms;

        return 1;
    }

    # build contact search autocomplete field
    my $AutoCompleteConfig = $Kernel::OM->Get('Kernel::Config')->Get('AutoComplete::Agent')->{'Default'};

    if ( !IsHashRefWithData($AutoCompleteConfig) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Invalid configuration found for config item 'AutoComplete::Agent###Default'. Aborting.",
        );
        return 1;
    }

    return 1 if $Param{TemplateFile} eq 'ProcessManagement/ActivityDialogHeader';
    return 1 if $Param{TemplateFile} eq 'AgentTicketProcess';

    # create Replace to insert
    my $ActiveAutoComplete = $AutoCompleteConfig->{AutoCompleteActive};
    my $Code               = <<"END";
\$('.DynamicFieldContactWithData').each( function( index, element ) {
    Core.Agent.ContactWithDataSearch.Init( \$(this), $ActiveAutoComplete );
});
END

    $Kernel::OM->Get('Kernel::Output::HTML::Layout')->AddJSOnDocumentComplete(
        Code => $Code,
    );

    return 1;
}

1;
