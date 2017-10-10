# --
# Kernel/Modules/APA_AdminContractManagement.pm - frontend module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_AdminContractManagement;

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

	my $ContractManagement = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_AdminContractManagement');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $Output;
	
	
	if ( $Self->{Subaction} eq 'AJAXUpdate' ) {
		$Output .= $ContractManagement->Updatefollow();
	}
	
	elsif ( $Self->{Subaction} eq 'AJAXUpdateSelect' ) {
		$Output .= $ContractManagement->Updateselect();
	}
	
	elsif ( $Self->{Subaction} eq 'ViewAll' ) {
		$Data{contract} = $ContractManagement->GetSubscription();
		$Output .= $LayoutObject->Header(Title => "Contract Management");
		$Output .= $LayoutObject->NavigationBar();
		$Output .= $LayoutObject->Output(
                Data => \%Data,
				TemplateFile => 'Exaprobe/APA_AdminContractManagement',
        );
	
	$Output .= $LayoutObject->Footer();
	}
	
	else {
		$Data{contract} = $ContractManagement->GetSubscription();
		$Output .= $LayoutObject->Header(Title => "Contract Management");
		$Output .= $LayoutObject->NavigationBar();
		$Output .= $LayoutObject->Output(
                Data => \%Data,
				TemplateFile => 'Exaprobe/APA_AdminContractManagement',
        );
	
	$Output .= $LayoutObject->Footer();
		
	}
	
	return $Output;
}

1;
