# --
# Kernel/Modules/APA_DocZoom.pm - frontend module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_DocZoom;

use strict;
use warnings;

# Frontend modules are not handled by the ObjectManager.
our $ObjectManagerDisabled = 1;



sub new {
	my ( $Type, %Param ) = @_;
	
	# allocate new hash for object
	my $Self = {%Param};
	bless ($Self, $Type);

	return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;
	my %Data = ();

	my $ContractManagement = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_DocZoom');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');	
	my $Output;
	
	if ( $Self->{Subaction} eq 'AJAXClickBoutonAdd' ) {
	
		$Output .= $ContractManagement->AddTR(UserID => $Self->{UserID},);
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonSave' ) {
	
		$Output .= $ContractManagement->SaveTR(UserID => $Self->{UserID},);
	} elsif ( $Self->{Subaction} eq 'AJAXCancel' ) {
	
		$Output .= $ContractManagement->TRCancel();
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonRenewTR' ) {
	
		$Output .= $ContractManagement->RenewTR(UserID => $Self->{UserID},);
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonApply' ) {
	
		$Output .= $ContractManagement->ApplyTR(UserID => $Self->{UserID},);
	} else {
		
		$Data{Contract}	= $ContractManagement->GetLine(UserID => $Self->{UserID},);
	
		$Output .= $LayoutObject->Header(Title => "Contract Management");
		$Output .= $LayoutObject->NavigationBar();
		$Output .= $LayoutObject->Output(
            Data => \%Data,
			TemplateFile => 'Exaprobe/APA_DocZoom',
        );
	
		$Output .= $LayoutObject->Footer();
	}
	
	return $Output;
}

1;
