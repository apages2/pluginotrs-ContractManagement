# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsTicketZoom;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $TemplateName = $Param{TemplateFile} || '';
    return 1 if !$TemplateName;

    # get a local config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get valid modules
    my $ValidTemplates = $ConfigObject->Get('Frontend::Output::FilterElementPost')
        ->{'OTRSCustomContactFieldsTicketZoom'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # get needed objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );
    if ( !$TicketID ) {
        $TicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $ParamObject->GetParam( Param => 'TicketNumber' ),
        );
    }

    return 1 if !$TicketID;

    # get needed objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my @FieldsCustomer;

    if ( $TemplateName eq 'AgentTicketZoom' ) {

        # get link table view mode
        my $LinkTableViewMode = $ConfigObject->Get('LinkObject::ViewMode');

        if ( $LinkTableViewMode eq 'Simple' ) {

            # only execute once
            return 1 if ${ $Param{Data} } !~ m{(<!--HookStartLinkTableSimple-->)}imsx;
        }
        elsif ( $LinkTableViewMode eq 'Complex' ) {

            # only execute once
            return 1 if ${ $Param{Data} } !~ m{(<!--HookEndCustomerTable-->)}imsx;
        }

        # only display customer widget if the dynamic field is configured
        my $DynamicFieldFilter = {
            %{ $ConfigObject->Get("Ticket::Frontend::AgentTicketZoom")->{DynamicField} || {} },
            %{
                $ConfigObject->Get("Ticket::Frontend::AgentTicketZoom")
                    ->{ProcessWidgetDynamicField}
                    || {}
            },
        };

        # get the dynamic fields for ticket object
        my $DynamicFieldsCustomer = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Ticket'],
            FieldType   => 'Customer',
            FieldFilter => $DynamicFieldFilter || {},
        );

        return 1 if !IsArrayRefWithData($DynamicFieldsCustomer);

        # get ticket attributes
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
        );

        # get dynamic field backend object
        my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # create contact information widgets and place them before the LinkTableSimple
        # cycle trough the activated Dynamic Fields for ticket object
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicFieldsCustomer} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            next DYNAMICFIELD if !defined $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} };
            next DYNAMICFIELD if $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} } eq '';

            my $ValueStrg = $DynamicFieldBackendObject->DisplayValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
                LayoutObject       => $LayoutObject,
                ValueMaxChars      => $ConfigObject->
                    Get('Ticket::Frontend::DynamicFieldsZoomMaxSizeSidebar')
                    || 18,    # limit for sidebar display
            );

            # use translation here to be able to reduce the character length in the template
            my $Label = $LayoutObject->{LanguageObject}->Translate( $DynamicFieldConfig->{Label} );

            push @FieldsCustomer, {
                Name     => $DynamicFieldConfig->{Name},
                Value    => $ValueStrg->{Title},
                Label    => $Label,
                Multiple => $ValueStrg->{Multiple},
            };
        }

        if ( scalar @FieldsCustomer ) {

            my $FieldCounter = 0;

            # get customer user object
            my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

            FIELD:
            for my $Field (@FieldsCustomer) {
                next FIELD if !$Field->{Value};

                for my $Entry ( split ', ', $Field->{Value} ) {

                    my $RowClass = 'Hidden';
                    if ( $FieldCounter == 0 ) {
                        $RowClass = '';
                    }

                    my %ContactData = $CustomerUserObject->CustomerUserDataGet(
                        User => $Entry,
                    );
                    my $ContactTable = $LayoutObject->AgentCustomerViewTable(
                        Data   => \%ContactData,
                        Ticket => \%Ticket,
                        Max    => $ConfigObject->Get('Ticket::Frontend::CustomerInfoZoomMaxSize'),
                    );

                    $LayoutObject->Block(
                        Name => 'ContactRow',
                        Data => {
                            Title        => $Field->{Label},
                            Firstname    => $ContactData{UserFirstname},
                            Lastname     => $ContactData{UserLastname},
                            Class        => $RowClass,
                            ContactTable => $ContactTable,
                        },
                    );

                    $FieldCounter++;
                }
            }
        }
        else {
            $LayoutObject->Block(
                Name => 'ContactRowEmpty',
                Data => {},
            );
        }

        # generate widget output
        my $AgentContactWidgetHTML = $LayoutObject->Output(
            TemplateFile => 'AgentContactWidget',
            Data         => {},
        );

        my $StartPattern = '(<!--HookStartLinkTableSimple-->)';

        if ( $LinkTableViewMode eq 'Simple' ) {
            if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
                ${ $Param{Data} } =~ s{ ($StartPattern) }{$AgentContactWidgetHTML$1}ixms;
            }
        }
        elsif ( $LinkTableViewMode eq 'Complex' ) {
            my $StartPattern = '(<!--HookEndCustomerTable-->)';

            if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
                ${ $Param{Data} } =~ s{ ($StartPattern) }{$AgentContactWidgetHTML$1}ixms;
            }
        }

        return 1;
    }

    # otherwise continue with CustomerTicketZoom
    # only display customer widget if the dynamic field is configured
    my $FieldFilter = $ConfigObject->Get('Ticket::Frontend::CustomerTicketZoom')->{DynamicField};

    my $DynamicFieldsCustomer = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldType   => 'Customer',
        FieldFilter => $FieldFilter,
    );

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicFieldsCustomer} ) {

        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $TicketID,
        );
        next DYNAMICFIELD if !$Value;

        push @FieldsCustomer, {
            Name  => $DynamicFieldConfig->{Name},
            Value => $Value,
            Label => $DynamicFieldConfig->{Label},
        };
    }

    if ( scalar @FieldsCustomer ) {

        # get customer user object
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

        FIELD:
        for my $Field (@FieldsCustomer) {
            for my $Entry ( @{ $Field->{Value} } ) {
                my %ContactData = $CustomerUserObject->CustomerUserDataGet(
                    User => $Entry,
                );

                $LayoutObject->Block(
                    Name => 'ContactRow',
                    Data => {
                        Title     => $Field->{Label},
                        Firstname => $ContactData{UserFirstname},
                        Lastname  => $ContactData{UserLastname},
                        Email     => $ContactData{UserEmail},
                    },
                );
            }
        }

        # generate widget output
        my $CustomerContactWidgetHTML = $LayoutObject->Output(
            TemplateFile => 'CustomerContactWidget',
            Data         => {},
        );

        my $StartPattern = '(<!--HookStartNextActivities-->)';

        if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
            ${ $Param{Data} } =~ s{ ($StartPattern) }{$CustomerContactWidgetHTML$1}ixms;
        }
        else {
            $StartPattern = '(</div>\s+<!--HookStartFollowUp-->)';
            ${ $Param{Data} } =~ s{ ($StartPattern) }{$CustomerContactWidgetHTML$1}ixms;
        }
    }
    else {
        my $JS = << "END";
<script type="text/javascript">//<![CDATA[
//STARTOTRSCustomContactFieldsTicketZoom
    \$('.WidgetSimple > .Content.Accordeon > p.None.Hidden').removeClass('Hidden');
//ENDOTRSCustomContactFieldsTicketZoom
//]]></script>
END

        $LayoutObject->AddJSOnDocumentComplete(
            Code => $JS,
        );
    }

    return 1;
}

1;
