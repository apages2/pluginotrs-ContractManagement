# --
# Kernel/Modules/APA_AgentUO.pm - frontend module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_AgentUO;

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

	my $UOObject = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_UO');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $Output;
	
	if ( $Self->{Subaction} eq 'AJAXClickBoutonAdd' ) {
	
		$Output .= $UOObject->AddTR();
		
	} elsif ( $Self->{Subaction} eq 'AJAXUpdateUO' ) {
	
		$Output .= $UOObject->UpdateUO(
			UserID => $Self->{UserID},
		);
	
		
	} elsif ( $Self->{Subaction} eq 'AJAXAddDecompte' ) {
	
		$Output .= $UOObject->AddDecompte(
			UserID => $Self->{UserID},
		);
	
		
	} elsif ( $Self->{Subaction} eq 'AJAXRenewUO' ) {
	
		$Output .= $UOObject->RenewUO(
			UserID => $Self->{UserID},
		);
	
		
	} else {
	
		$Data{UO} = $UOObject->GetUO();
		
		$Output .= $LayoutObject->Header(Title => "UO Pool");
		$Output .= $LayoutObject->NavigationBar();
		$Output .= $LayoutObject->Output(
				Data => \%Data,
				TemplateFile => 'Exaprobe/APA_AgentUO',
		);
			
		$Output .= $LayoutObject->Footer();
	
	}
	return $Output;
}

1;