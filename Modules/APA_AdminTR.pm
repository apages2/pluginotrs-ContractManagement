# --
# Kernel/Modules/APA_AdminTR.pm - frontend module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_AdminTR;

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

	my $TR = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_TR');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	my $Search = $ParamObject->GetParam( Param => 'Search' );
	my $Output;

	if ( $Self->{Subaction} eq 'AJAXClickBoutonAdd' ) {
	
		$Output .= $TR->AddTR();
	} elsif ( $Self->{Subaction} eq 'AJAXSelectType' ) {
	
		$Output .= $TR->SelectTR();
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonDel' ) {
	
		$Output .= $TR->DelTR();
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonSave' ) {
		 
		$Output .= $TR->SaveTR(
			UserID => $Self->{UserID},
		);
	} elsif ( $Self->{Subaction} eq 'AJAXSelectPack') {
	
		$Output .= $TR->SelectPack();
	} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonApply') {
		
		$Output .= $TR->ApplyTR(
			UserID => $Self->{UserID},
		);
	} elsif ( $Self->{Subaction} eq 'AJAXDisableBdUO') {
		
		$Output .= $TR->DisableUO(
			UserID => $Self->{UserID},
		);
	}
	
	
	
	return $Output;
}

1;