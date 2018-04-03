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

	# get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	$Self->{DocorAbo} = $ConfigObject->Get('ContractManagement::Config::Admin')->{DocorAbo};
	
	return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;
	my %Data = ();

	my $ContractManagement = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_AdminContractManagement');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserID=$Self->{UserID};
	my $Output;
	
	if ($Self->{DocorAbo} eq 'Doc') {
		if ( $Self->{Subaction} eq 'AJAXUpdate' ) {
			$Output .= $ContractManagement->UpdatefollowDoc(UserID => $UserID);
		}
		
		elsif ( $Self->{Subaction} eq 'AJAXUpdateSelect' ) {
			$Output .= $ContractManagement->UpdateselectDoc(UserID => $UserID);
		}
		
		elsif ( $Self->{Subaction} eq 'ViewAll' ) {
			$Data{contract} = $ContractManagement->GetSubscriptionDoc();
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AdminContractManagement',
			);
		
		$Output .= $LayoutObject->Footer();
		}
		
		else {
			$Data{contract} = $ContractManagement->GetSubscriptionDoc();
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AdminContractManagement',
			);
		
		$Output .= $LayoutObject->Footer();
			
		}
	} elsif ($Self->{DocorAbo} eq 'Abo') {
		
		if ( $Self->{Subaction} eq 'AJAXUpdate' ) {
			$Output .= $ContractManagement->UpdatefollowAbo(UserID => $UserID);
		}
		
		elsif ( $Self->{Subaction} eq 'AJAXUpdateSelect' ) {
			$Output .= $ContractManagement->UpdateselectAbo(UserID => $UserID);
		}
		
		elsif ( $Self->{Subaction} eq 'ViewAll' ) {
			$Data{contract} = $ContractManagement->GetSubscriptionAbo();
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AdminContractManagement',
			);
		
		$Output .= $LayoutObject->Footer();
		}
		
		else {
			$Data{contract} = $ContractManagement->GetSubscriptionAbo();
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AdminContractManagement',
			);
		
		$Output .= $LayoutObject->Footer();
			
		}
	}
	
	
	return $Output;
}

1;
