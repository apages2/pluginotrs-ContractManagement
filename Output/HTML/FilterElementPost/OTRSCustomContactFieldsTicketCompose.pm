# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsTicketCompose;

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
    'Kernel::System::Ticket',
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

    # get valid modules
    my $ValidTemplates = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Output::FilterElementPost')
        ->{'OTRSCustomContactFieldsTicketCompose'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # get a local param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # just add addresses on initial page load
    return 1 if $ParamObject->GetParam( Param => 'Subaction' );

    return 1 if !$ParamObject->GetParam( Param => 'ReplyAll' );

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );
    return 1 if !$TicketID;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $LayoutObject->{DBObject} ) {
        $Self->{DBObject} = $LayoutObject->{DBObject};
    }

    my $CustomerDynamicFields = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
        FieldType  => 'Customer',    # here is the magic
    );

    # nothing to do here
    return 1 if !IsArrayRefWithData($CustomerDynamicFields);

    my %Recipients;
    my %ContactData;

    # get needed objects
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    CUSTOMERDF:
    for my $CurrentDynamicField ( @{$CustomerDynamicFields} ) {
        if (
            !IsHashRefWithData($CurrentDynamicField)
            || !IsHashRefWithData( $CurrentDynamicField->{Config} )
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Unsupported DynamicField format!'
            );
            next CUSTOMERDF;
        }

        # for better code reading
        my %CurrentDynamicField       = %{$CurrentDynamicField};
        my %CurrentDynamicFieldConfig = %{ $CurrentDynamicField->{Config} };

        next CUSTOMERDF if !$CurrentDynamicFieldConfig{UseForCommunication};

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
            UserID        => $Self->{UserID},
        );

        next CUSTOMERDF if !$Ticket{ 'DynamicField_' . $CurrentDynamicField{Name} };

        ENTRY:
        for my $Entry ( @{ $Ticket{ 'DynamicField_' . $CurrentDynamicField{Name} } } ) {

            my %TmpCustomerData = $CustomerUserObject->CustomerUserDataGet(
                User => $Entry,
            );

            if ( !%TmpCustomerData ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Couldn't get CustomerUserData for Customer '$Entry'!",
                );
                next ENTRY;
            }

            if ( !$TmpCustomerData{UserEmail} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Couldn't get UserEmail for Customer '$Entry'!",
                );
                next ENTRY;
            }

            next ENTRY
                if grep { $_ eq $TmpCustomerData{UserEmail} }
                @{ $ContactData{ $CurrentDynamicFieldConfig{UseForCommunication} } };

            push(
                @{ $ContactData{ $CurrentDynamicFieldConfig{UseForCommunication} } },
                $TmpCustomerData{UserEmail}
            );
        }
    }

    CURRENTFIELD:
    for my $CurrentField ( sort keys %ContactData ) {

        next CURRENTFIELD if !@{ $ContactData{$CurrentField} };

        my $AddStr;
        if ( @{ $ContactData{$CurrentField} } eq '1' ) {
            $AddStr = shift @{ $ContactData{$CurrentField} };
        }
        else {
            $AddStr = join( ', ', @{ $ContactData{$CurrentField} } );
        }

        CONTACTEMAIL:
        for my $Email ( Mail::Address->parse($AddStr) ) {

            my $EmailAddress = $Email->address();

            if (
                IsArrayRefWithData( $Recipients{$CurrentField} )
                && grep { $_ eq $EmailAddress } @{ $Recipients{$CurrentField} }
                )
            {
                next CONTACTEMAIL;
            }

            next CONTACTEMAIL if ${ $Param{Data} } =~ m{ $EmailAddress }xms;

            push @{ $Recipients{$CurrentField} }, $EmailAddress;
        }
    }

    my $CustomContactRecipients = $LayoutObject->JSONEncode(
        Data     => \%Recipients,
        NoQuotes => 0,
    );

    my $JS = <<"END";
<script type="text/javascript">//<![CDATA[
//STARTOTRSCustomContactFieldsTicketCompose
    var CustomContactRecipients = $CustomContactRecipients;

    // check for duplicated entries
    \$.each( CustomContactRecipients, function(FieldName, Addresses) {

        \$.each( Addresses, function(MailAddressIndex, MailAddress) {

            var NewAddress = true;
            \$('[class*=ContactTicketText]').each(function(index) {
                if ( \$(this).val() === MailAddress ) {
                    NewAddress = false;
                    return false;
                }
            });

            if ( NewAddress === false ) {
                return false;
            }

            Core.Agent.CustomerSearch.AddTicketCustomer( FieldName + 'Customer', MailAddress );
        });
    });
//STOPOTRSCustomContactFieldsTicketCompose
//]]></script>
END

    $LayoutObject->AddJSOnDocumentComplete(
        Code => $JS
    );

    return 1;
}

1;
