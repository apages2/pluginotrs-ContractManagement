# --
# Kernel/Modules/APA_AgentContractManagement.pm - frontend module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_AgentContractManagement;

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

	my $ContractManagement = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_AgentContractManagement');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	my $Search = $ParamObject->GetParam( Param => 'Search' );
	my $Output;
	
	my $UserID=$Self->{UserID};

	if ($Self->{DocorAbo} eq 'Doc') {
		if ( $Self->{Subaction} eq 'AJAXUpdateSelect' ) {
			$Output .= $ContractManagement->Updateselect(UserID => $UserID);
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonDel' ) {
			$Output .= $ContractManagement->ClickDel(UserID => $UserID);
		}  elsif ( $Self->{Subaction} eq 'AJAXAvancement' ) {
			$Output .= $ContractManagement->ClickAvancement(UserID => $UserID);
			
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonAdd' ) {
			$Output .= $ContractManagement->ClickAdd(UserID => $UserID);
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonNotif') {
			$Output .= $ContractManagement->SendmailDoc();
		} elsif ( $Self->{Subaction} eq 'AJAXUpdateDate') {
			$Output .= $ContractManagement->UpdateDate(UserID => $UserID);
		} elsif ( $Self->{Subaction} eq 'AJAXResponsible') {
			$Output .= $ContractManagement->Responsible();
		} else {
		
			$Data{contract} = $ContractManagement->GetSubscriptionFollowedDoc(UserID => $UserID);
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AgentContractManagement',
			);
			
			$Output .= $LayoutObject->Footer();
		
		}
	} elsif ($Self->{DocorAbo} eq 'Abo') {
		if ( $Self->{Subaction} eq 'AJAXUpdateSelect' ) {
			$Output .= $ContractManagement->Updateselect(UserID => $UserID);
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonDel' ) {
			$Output .= $ContractManagement->ClickDel(UserID => $UserID);
		}  elsif ( $Self->{Subaction} eq 'AJAXAvancement' ) {
			$Output .= $ContractManagement->ClickAvancement(UserID => $UserID);
			
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonAdd' ) {
			$Output .= $ContractManagement->ClickAdd(UserID => $UserID);
		} elsif ( $Self->{Subaction} eq 'AJAXClickBoutonNotif') {
			$Output .= $ContractManagement->SendmailAbo();
		} else {
		
			$Data{contract} = $ContractManagement->GetSubscriptionFollowedAbo(UserID => $UserID);
			$Output .= $LayoutObject->Header(Title => "Contract Management");
			$Output .= $LayoutObject->NavigationBar();
			$Output .= $LayoutObject->Output(
					Data => \%Data,
					TemplateFile => 'Exaprobe/APA_AgentContractManagement',
			);
				
			$Output .= $LayoutObject->Footer();
		}
	}
		
	
	
	return $Output;
}

1;
