# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::SLASelectionDialog;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::HTMLUtils',
    'Kernel::System::SLA',
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

    # get template name
    my $TemplateName = $Param{TemplateFile} || '';
    return 1 if !$TemplateName;

    # get valid modules
    my $ValidTemplates = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Output::FilterElementPost')
        ->{'OutputFilterPostSLASelectionDialog'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # gather the data
    my %DialogData;

    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');

    # get all valid SLAs
    my %SLAList = $SLAObject->SLAList(
        Valid  => 1,
        UserID => 1,
    );

    # check all valid SLAs if they got a stored FieldSelectionDialogText to show
    SLA:
    for my $CurrentSLAID ( sort keys %SLAList ) {

        my %TmpSLAData = $SLAObject->SLAGet(
            SLAID  => $CurrentSLAID,
            UserID => 1,
        );

        # only add SLAs with a FieldSelectionDialogText to show
        next SLA if !%TmpSLAData;
        next SLA if !$TmpSLAData{FieldSelectionDialogText};

        # do translation
        $TmpSLAData{FieldSelectionDialogText}
            = $Kernel::OM->Get('Kernel::Language')->Translate( $TmpSLAData{FieldSelectionDialogText} );

        # convert text to HTML (textarea '\n' => <br>)
        $DialogData{$CurrentSLAID} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
            String => $TmpSLAData{FieldSelectionDialogText},
        );
    }

    return if !%DialogData;

    # Inject JS code
    $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'OutputFilterPostSLASelectionDialog',
        Data         => {
            DialogData => \%DialogData,
        },
    );

    return 1;
}

1;
