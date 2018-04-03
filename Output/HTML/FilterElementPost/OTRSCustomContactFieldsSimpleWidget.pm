# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsSimpleWidget;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
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
        ->{'OTRSCustomContactFieldsSimpleWidget'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # generate widget output
    my $AgentContactWidgetHTML = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'AgentContactWidget',
        Data         => {},
    );

    my $StartPattern = '(<!--HookEndCustomerTable-->)';

    if ( ${ $Param{Data} } =~ m{ $StartPattern }ixms ) {
        ${ $Param{Data} } =~ s{ ($StartPattern) }{$1$AgentContactWidgetHTML}ixms;
    }

    return 1;
}

1;
