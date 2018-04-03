# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsJS;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Main',
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
        ->{'OTRSCustomContactFieldsJS'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # build customer search autocomplete field
    my $AutoCompleteConfig = $ConfigObject->Get('AutoComplete::Agent')->{'CustomerSearch'};

    if ( !IsHashRefWithData($AutoCompleteConfig) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message =>
                "Invalid configuration found for config item 'AutoComplete::Agent###CustomerSearch'. Aborting.",
        );
        return 1;
    }

    my $InsertID = '#FromCustomer';
    if ( $TemplateName eq 'AgentTicketEmail' ) {
        $InsertID =
            $ConfigObject->Get('CustomContactFieldsEmailInsertAfter') || '#ToCustomer';
    }

    # create HTML to insert
    my $ActiveAutoComplete = $AutoCompleteConfig->{AutoCompleteActive};

    # translate some strings
    my $TitleText   = $Kernel::OM->Get('Kernel::Language')->Get('Duplicated entry');
    my $ContentText = $Kernel::OM->Get('Kernel::Language')->Get('This address already exists on the address list.');
    my $RemoveText
        = $Kernel::OM->Get('Kernel::Language')->Get('It is going to be deleted from the field, please try again.');

    # modify template name appropriately if OTRSCICustomerInterface is installed
    my $OTRSCICustomerInterfaceIntalled = $Kernel::OM->Get('Kernel::System::Main')->Require(
        'Kernel::Modules::CustomerITSMConfigItem',
        Silent => 1,
    );

    my $CustomerTicketMessageTemplate
        = $OTRSCICustomerInterfaceIntalled ? 'OTRSCICustomerInterfaceCustomerTicketMessage' : 'CustomerTicketMessage';
    my $CustomerTicketZoomTemplate
        = $OTRSCICustomerInterfaceIntalled ? 'OTRSCICustomerInterfaceCustomerTicketZoom' : 'CustomerTicketZoom';

    my $JS = << "END";
<script type="text/javascript">//<![CDATA[
//STARTOTRSCustomContactFieldsJS
    Core.Config.Set('Duplicated.TitleText', "$TitleText");
    Core.Config.Set('Duplicated.ContentText', "$ContentText");
    Core.Config.Set('Duplicated.RemoveText', "$RemoveText");
END

    if (
        $TemplateName ne $CustomerTicketMessageTemplate
        && $TemplateName ne $CustomerTicketZoomTemplate
        && $Self->{Action} ne 'CustomerTicketProcess'
        )
    {
        $JS .= <<"END";
    if (\$('$InsertID').length) {
        jQuery.fn.reverse = [].reverse;
        \$('.DynamicFieldType_Customer').reverse().each(function() {
            var \$FieldObj = \$(this).closest('.Row').detach();
            \$('$InsertID').parent().next().next('.Field').next().after(\$FieldObj);
        });
    }

    \$.each(\$(".ContactAutoComplete"), function() {
        Core.Agent.ContactSearch.Init(\$(this), $ActiveAutoComplete);
    });
//ENDOTRSCustomContactFieldsJS
//]]></script>
END
    }
    else {
        if ( $TemplateName eq $CustomerTicketZoomTemplate ) {

            $JS .= <<"END";
    \$('#ReplyButton').off('click');
    \$('#ReplyButton').click(function(Event){
        Event.preventDefault();
        \$('#FollowUp').addClass('Visible');
        \$('html').css({scrollTop: \$('#Body').height()});
        Core.UI.RichTextEditor.Focus(\$('#RichText'));
    });
    if (\$('#Subject').length) {
        jQuery.fn.reverse = [].reverse;
        \$('.DynamicFieldType_Customer').reverse().each(function() {
            var \$FieldObj = \$(this).closest('.Row').detach();
            \$('#Subject').parent().before(\$FieldObj);
         });
    }

END
        }
        elsif ( $TemplateName eq $CustomerTicketMessageTemplate ) {

            $JS .= <<END;
    if (\$('#Dest').length) {
        jQuery.fn.reverse = [].reverse;
        \$('.DynamicFieldType_Customer').reverse().each(function() {
            var \$FieldObj = \$(this).closest('.Row').detach();
            \$('#Dest').parent().after(\$FieldObj);
         });
    }
END
        }

        $JS .= <<"END";
    \$.each(\$(".ContactAutoComplete"), function() {
        Core.Customer.ContactSearch.Init(\$(this), $ActiveAutoComplete);
    });
//ENDOTRSCustomContactFieldsJS
//]]></script>
END
    }

    if ( $TemplateName ne 'ProcessManagement/ActivityDialogFooter' ) {

        $Kernel::OM->Get('Kernel::Output::HTML::Layout')->AddJSOnDocumentComplete(
            Code => $JS,
        );

    }

    return 1;
}

1;
