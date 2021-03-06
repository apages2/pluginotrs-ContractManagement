# --
# Kernel/Modules/APA_UpdateUO.pm - frontend module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::APA_UpdateUO;

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

	
	$Self->{UserDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{UserDBOTRS};
	$Self->{PasswordDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBOTRS};
		
	$Self->{DBObjectotrs} = Kernel::System::DB->new(
		DatabaseDSN => 'DBI:mysql:database=otrs;host=localhost;',
	    DatabaseUser => $Self->{UserDBOTRS},
		DatabasePw   => $Self->{PasswordDBOTRS},
		Type         => 'mysql',
	) || die('Can\'t connect to database!');

	return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;
	my %Data = ();

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TicketID =  $ParamObject->GetParam( Param => 'TicketID' );
	my $DecompteUO = $ParamObject->GetParam( Param => 'DecompteUO' );
	my $TR_ID = $ParamObject->GetParam( Param => 'TR_ID' );
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	
	my %Ticket = $TicketObject->TicketGet(
		TicketID      => $TicketID,
		DynamicFields => 0,
		Silent        => 0,
	);
	
	use POSIX qw(strftime);
	my $Date = strftime "%Y-%m-%d", localtime;
	
	if ( $Self->{Subaction} eq 'UOUpdate' ) {
	
		
		if ($DecompteUO !=0) {

			my $CheckUO = "SELECT ticket_id, UO_unit, TR_ID from APA_TR_UO_decompte where ticket_id=?";
			
			$Self->{DBObjectotrs}->Prepare(
				SQL => $CheckUO, 
				Bind => [\$TicketID]
			); 
			
			my @UOData;
			my $OldDecompte;
			my $OldTRID;
			while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
				my %Data;
				$Data{ticket_id} = $Row[0];
				$OldDecompte = $Row[1];
				$OldTRID = $Row[2];
				push( @UOData, \%Data );
			}
			
			# $Kernel::OM->Get('Kernel::System::Log')->Log(
					# Priority => 'error',
					# Message  => $DecompteUO
				# );
			
			
			if ( !@UOData) {
					
				my $Addrow  = "INSERT INTO APA_TR_UO_decompte (ticket_id,TR_ID,date,owner,subject,UO_unit) VALUES (?,?,?,?,?,?)";
	
				$Self->{DBObjectotrs}->Do(
							SQL   => $Addrow,
							Bind => [\$TicketID,\$TR_ID,\$Date,\$Ticket{OwnerID},\$Ticket{Title},\$DecompteUO],
					);
				
				my $CheckSolde = "SELECT TR_Option2 from APA_TR where TR_ID=?";
	
				$Self->{DBObjectotrs}->Prepare(
					SQL => $CheckSolde, 
					Bind => [\$TR_ID],
					Limit => 1
				); 
				
				my $UOSolde;
				while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
					$UOSolde = $Row[0];
				}
				
				my $NewSolde = $UOSolde+$OldDecompte-$DecompteUO;
				
				my $SQLUpdate = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";
		
				$Self->{DBObjectotrs}->Do(
					SQL  => $SQLUpdate,
					Bind => [ \$NewSolde,\$TR_ID]
				);

			
			} else {
				my $Addrow  = "UPDATE APA_TR_UO_decompte SET ticket_id=?, TR_ID=?, date=?, owner=?, subject=?, UO_unit=? where ticket_id=?";
		
				$Self->{DBObjectotrs}->Do(
							SQL   => $Addrow,
							Bind => [\$TicketID,\$TR_ID,\$Date,\$Ticket{OwnerID},\$Ticket{Title},\$DecompteUO,\$TicketID],
					);
					
				if ($TR_ID == $OldTRID) {
					
					my $CheckSolde = "SELECT TR_Option2 from APA_TR where TR_ID=?";
			
					$Self->{DBObjectotrs}->Prepare(
						SQL => $CheckSolde, 
						Bind => [\$TR_ID],
						Limit => 1
					); 
						
					my $UOSolde;
					while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
						$UOSolde = $Row[0];
					}
					
					my $NewSolde = $UOSolde+$OldDecompte-$DecompteUO;
					
					my $SQLUpdate = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";
			
					$Self->{DBObjectotrs}->Do(
						SQL  => $SQLUpdate,
						Bind => [ \$NewSolde,\$TR_ID]
					);
				} else {
				
					my $CheckSoldeNewTR = "SELECT TR_Option2 from APA_TR where TR_ID=?";
			
					$Self->{DBObjectotrs}->Prepare(
						SQL => $CheckSoldeNewTR, 
						Bind => [\$TR_ID],
						Limit => 1
					); 
						
					my $UOSoldeNewTR;
					while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
						$UOSoldeNewTR = $Row[0];
					}
					
					my $CheckSoldeOldTR = "SELECT TR_Option2 from APA_TR where TR_ID=?";
			
					$Self->{DBObjectotrs}->Prepare(
						SQL => $CheckSoldeOldTR, 
						Bind => [\$OldTRID],
						Limit => 1
					); 
						
					my $UOSoldeOldTR;
					while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
						$UOSoldeOldTR = $Row[0];
					}
					
					my $NewSoldeNewTR = $UOSoldeNewTR-$DecompteUO;
					
					my $SQLUpdate = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";
			
					$Self->{DBObjectotrs}->Do(
						SQL  => $SQLUpdate,
						Bind => [ \$NewSoldeNewTR,\$TR_ID]
					);
					
					my $NewSoldeOldTR = $UOSoldeOldTR+$OldDecompte;
					
					my $SQLUpdate = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";
			
					$Self->{DBObjectotrs}->Do(
						SQL  => $SQLUpdate,
						Bind => [ \$NewSoldeOldTR,\$OldTRID]
					);
				}
				
			}
			
			 my $JSON = $LayoutObject->BuildSelectionJSON(
				[
					{
						Name         => 'Result',
						Data         => 'OK',
					},
				],
			);

			return $LayoutObject->Attachment(
				ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
				Content     => $JSON,
				Type        => 'inline',
				NoCache     => 1,
			);
		}
	} 
	
}

1;