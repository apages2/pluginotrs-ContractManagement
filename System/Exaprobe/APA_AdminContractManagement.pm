# --
# Kernel/System/Exaprobe/APA_AdminContractManagement.pm - core module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Exaprobe::APA_AdminContractManagement;

use strict;
use warnings;

# list your object dependencies (e.g. Kernel::System::DB) here
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
    'Kernel::System::Valid',
);


sub new {
	my ( $Type, %Param ) = @_;

	# allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);
	
	# get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

	$Self->{UserDBSage} = $ConfigObject->Get('ContractManagement::Config')->{UserDBSage};
	$Self->{PasswordDBSage} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBSage};
	$Self->{UserDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{UserDBOTRS};
	$Self->{PasswordDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBOTRS};
	$Self->{RowNumber} = $ConfigObject->Get('ContractManagement::Config::Admin')->{RowNumber};
		
	# create new db connect if DSN is given
	$Self->{DBObjectsage} = Kernel::System::DB->new(
		DatabaseDSN  => 'DBI:ODBC:otrs',
	    DatabaseUser => $Self->{UserDBSage},
	    DatabasePw   => $Self->{PasswordDBSage},
	    Type         => 'mssql'
	) || die('Can\'t connect to database!');

	$Self->{DBObjectotrs} = Kernel::System::DB->new(
		DatabaseDSN => 'DBI:mysql:database=otrs;host=localhost;',
	    DatabaseUser => $Self->{UserDBOTRS},
		DatabasePw   => $Self->{PasswordDBOTRS},
		Type         => 'mysql',
	) || die('Can\'t connect to database!');

	
	return $Self;
}

sub GetSubscription {

	use POSIX qw(strftime); 

	my ( $Self, %Param ) = @_;
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	
	my $PageShown = $Self->{RowNumber};
	
	my $Subaction = $ParamObject->GetParam( Param => 'Subaction' );
	my $AboID = $ParamObject->GetParam( Param => 'AboID' );
	
	my $Zoom = 0;
	if ( $Subaction && $Subaction eq 'Zoom' ) {
        $Zoom = 1;
	} 

	my $Nav = $ParamObject->GetParam( Param => 'Nav' ) || 0;
	my $Search = $ParamObject->GetParam( Param => 'Search' );
	$Search
        ||= $ConfigObject->Get('AdminCustomerCompany::RunInitialWildcardSearch') ? '*' : '';
	my $SearchList = $ParamObject->GetParam( Param => 'SearchList' ) || 0;	
	my $IsTreated = $ParamObject->GetParam( Param => 'IsTreated' );
	my $Expired = $ParamObject->GetParam( Param => 'Expired' );
	my $Filter= $ParamObject->GetParam( Param => 'Filter' );
	my $StartHit = $ParamObject->GetParam( Param => 'StartHit' ) || 1;
	
	if (!$IsTreated) {
		$IsTreated ='off';
	}
	
	if (!$Expired) {
		$Expired ='off';
	}
	
	my $SearchSQL = $Search;
	$SearchSQL =~ s/\*/%/g;
	$Param{Search}=$Search;
	$Param{SearchList}=$SearchList;
	$Param{IsTreated}=$IsTreated;	
	$Param{Expired}=$Expired;	
	$LayoutObject->Block( Name => 'ActionList' );
	$LayoutObject->Block(
		Name => 'ActionSearch',
		Data => \%Param,
	);	
		
	my $DateFin;
	if ($Expired eq 'off') {
		$DateFin = strftime "%Y-%m-%d", localtime; 
	} else {
		$DateFin = '1970-01-01';
	}
	
	my $SQLOtrs = "SELECT AboIDSage, CustomerIDSage, Follow, DATE_FORMAT(AB_Fin, '%y%m%d'), CustomerIDOtrs, AB_Fin from APA_contract";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
	);



	my @ContractData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		
		$Data{AboIDSage} = $Row[0];
        $Data{CustID} = $Row[1];
        $Data{Follow} = $Row[2];
        $Data{AB_Fin} = $Row[3];
		$Data{CustIDOtrs} = $Row[4];
		$Data{Abo_AB_Fin} = $Row[5];
		$Data{IsTreated} = $IsTreated;
		$Data{Expired} = $Expired;
        push( @ContractData, \%Data );
	}
		
	# no data found...
    if ( !@ContractData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing OTRS",
        );
    }
	
	
	if ( $Search ne "*" && $SearchList == 0) {
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0 AND CT_NUM LIKE ? ORDER BY AB_Debut DESC";
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin,\$SearchSQL]
		);
			
	} elsif ( $Search ne "*" && $SearchList == 1) {
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0 AND AB_Intitule LIKE ? ORDER BY AB_Debut DESC";
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin,\$SearchSQL]
		);
			
	} elsif ( $Search ne "*" && $SearchList == 2) {
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0 AND AB_Debut = ?";
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin,\$SearchSQL]
		);
			
	} elsif ( $Search ne "*" && $SearchList == 3) {
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0 AND AB_Debut >= ? ORDER BY AB_Debut DESC";
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin,\$SearchSQL]
		);
			
	} elsif ( $Search ne "*" && $SearchList == 4) {
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0  AND AB_Debut <= ? ORDER BY AB_Debut DESC";
																																																																	
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin,\$SearchSQL]
		);
			
	} else {

		# build SQL request
		my $SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_Debut,AB_Fin,F_ABONNEMENT.AB_No,CONVERT(varchar(6),AB_Fin,12),AB_TypeDuree, F_COLLABORATEUR.CO_Prenom, F_COLLABORATEUR.CO_Nom from F_ABONNEMENT LEFT JOIN F_ABOENTETE ON F_ABONNEMENT.AB_No = F_ABOENTETE.AB_No LEFT JOIN F_COLLABORATEUR ON F_COLLABORATEUR.CO_No=F_ABOENTETE.CO_No where AB_Fin>= ? AND AB_Type=1 AND AB_TypeTiers=0 ORDER BY AB_Debut DESC";
		
		# get data
		$Self->{DBObjectsage}->Prepare(
				SQL   => $SQLSage,
				Encode => [1,0,1,1,1,1,1,1],
				Bind => [\$DateFin]
		);

	}

	my @AboData;
	my $count=0;
	my $DataItemC;
	my $AboAncDateFin;
	my $Custo;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		my %Data;
		my $Join=0;
		my $Renew=0;
		
		for $DataItemC (@ContractData) {
					
			if (${$DataItemC}{AboIDSage} == $Row[5]) {
				$Data{Follow} = ${$DataItemC}{Follow};
				$Data{CustomerIDOtrs} = ${$DataItemC}{CustIDOtrs};
			}
			
			if ((${$DataItemC}{AboIDSage} == $Row[5]) && (${$DataItemC}{AB_Fin} == $Row[6]) && ((${$DataItemC}{Follow} == 0 ) || ((${$DataItemC}{CustIDOtrs} ne 0 )&& (${$DataItemC}{Follow} == 1 ))) && ${$DataItemC}{IsTreated} eq 'off' )  {
				$Join=1;
			} elsif ((${$DataItemC}{AboIDSage} == $Row[5]) && (${$DataItemC}{AB_Fin} != $Row[6])) {
				$Join=0;
				$Renew=1;
				$AboAncDateFin = ${$DataItemC}{Abo_AB_Fin};
			} else {
				if ($Join==1) {
					$Join=1;
				} else {
					$Join=0;
				}
			}
			
		}
		
		if ($Join==0) {
			
			$Data{CustomerID} = $Row[0];
			$Data{AboIntitule} = $Row[1];
			$Data{AboDuree} = $Row[2];
			$Data{AboDateDebut} = $Row[3];
			$Data{AboDateFin} = $Row[4];
			$Data{AboAncDateFin} = $AboAncDateFin;
			$Data{AboIDSage} = $Row[5];
			$Data{AboTypeDuree} = $Row[7];
			$Data{Renew} = $Renew;
			$Data{etat} = $AboID;
			$Data{IDOtrs} = ${$DataItemC}{IDOtrs};
			if ($Row[8] && $Row[9]) { 
				$Data{IC} = $Row[8]." ".$Row[9];
			}
			$count++;
			
			
			push( @AboData, \%Data );
		}
	}

	# no data found...
    if ( !@AboData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing SAGE",
        );
        return;
    }

	
   # my $CustomerList = $LayoutObject->BuildSelection(
    #        Name         => 'Customer',
	#		Data         => {%CustomerCompanyList},
     #       PossibleNone => 1,
      #      Sort         => 'AlphanumericValue',
       #     Translation  => 0,
	#		TreeView     => 1,
     #   );
		
	# calculate max. shown per page
    if ( $StartHit > $count ) {
        my $Pages = int( ( $count / $PageShown ) + 0.99999 );
        $StartHit = ( ( $Pages - 1 ) * $PageShown ) + 1;
    }
	
	my $MaxItem=0;
	if ( ($StartHit+$PageShown) > $count ) {
        $MaxItem = $count-1;
    }
	else {
		$MaxItem =$StartHit+$PageShown-2;
	}
	
	my $WindowStart = sprintf( "%.0f", ( $StartHit / $PageShown ) );
    $WindowStart = int( ( $WindowStart / 5 ) ) + 1;
    $WindowStart = ( $WindowStart * 5 ) - (5);
	$Param{StartWindow}=$WindowStart;
	$Param{StartHit}=$StartHit;

	# build nav bar
	my %PageNav = $LayoutObject->PageNavBar(
		StartHit  => $StartHit,
		PageShown => $PageShown,
		WindowSize  => 5,
		AllHits   => $count,
		Action    => 'Action=' . $LayoutObject->{Action},
		Link        => 'IsTreated='.$IsTreated.';Expired='.$Expired.';Search='.$Search.';SearchList='.$SearchList.';',
		IDPrefix  => $LayoutObject->{Action},
	);

	if (%PageNav) {
        $LayoutObject->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );
	}

	my $SQLOtrsLink = "SELECT IDOtrs,IDSage, Changeable from APA_contract_sagetootrs";
			# get data
			$Self->{DBObjectotrs}->Prepare(
					SQL   => $SQLOtrsLink
			);
			
			
							
					
	
	my @CustLink;
	while ( my @Custo = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		$Data{IDOtrs}=$Custo[0];
		$Data{IDSage}=$Custo[1];
	
		push( @CustLink, \%Data );
		
	}
	
	
	if (@AboData) {
		for my $DataItem (@AboData[$StartHit-1..$MaxItem]) {			
			$LayoutObject->Block(
				Name => 'AboRow',
				Data => $DataItem,
			);
			
			my %Customer;
			
			if (@CustLink) {
				for my $CustLinkItem (@CustLink) {
					my %CustoLink;
					
					
					if (${$DataItem}{CustomerID} eq ${$CustLinkItem}{IDSage}) {
						$Customer{LinkOtrs}=${$CustLinkItem}{IDOtrs};
						
					}
					
				}
			}
					
			my %CustomerCompanyList = $CustomerCompanyObject->CustomerCompanyList(
				Limit => 0,
				Valid =>0,
			);
			
			for my $CustomerList ( sort keys %CustomerCompanyList ) {
				$Customer{Sage}=${$DataItem}{CustomerID};
				$Customer{CustomerIDOtrs}=${$DataItem}{CustomerIDOtrs};
				$Customer{CustID} = $CustomerList;
				my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
					CustomerID => $CustomerList,
				);
				$Customer{CustName} = $CustomerCompany{CustomerCompanyName};	
				
				$LayoutObject->Block(
					Name => 'Customer',
					Data => {%Customer},
				);
			}	
			
			if ($AboID) {
						if ($AboID == ${$DataItem}{AboIDSage}) {
							# build SQL request
							my $SQL = "SELECT AB_No,AR_Ref,AL_Design,CONVERT(DECIMAL(10,2),AL_Qte),CONVERT(DECIMAL(10,2),AL_PrixUnitaire) from F_ABOLIGNE where AB_No=?";

							# get data
							$Self->{DBObjectsage}->Prepare(
									SQL   => $SQL,
									Limit => 1000,
									Encode => [1,1,0,1,1],
									Bind   => [ \$AboID],
							);
							my @LineAbo;

						while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
							my %Data;
							$Data{AB_No} = $Row[0];
							$Data{AR_Ref} = $Row[1];
							$Data{AL_Design} = $Row[2];
							$Data{AL_Qte} = $Row[3];
							$Data{AL_PrixUnitaire} = $Row[4];
							$Data{AL_PrixTotal} = ($Row[4]*$Row[3]);
							push( @LineAbo, \%Data );
						}
							
						# no data found...
						if ( !@LineAbo) {
							$Kernel::OM->Get('Kernel::System::Log')->Log(
								Priority => 'error',
								Message  => "Nothing SAGE",
							);
							return;
						}
						
						if (@LineAbo) {
							$LayoutObject->Block(
									Name => 'ZoomTR',
							);
							for my $DataItem2 (@LineAbo) {			
								$LayoutObject->Block(
									Name => 'Zoom',
									Data => $DataItem2,
								);
								
							}	
							
							$LayoutObject->Block(
								Name => 'ZoomLast',
							);
						}
						}
					}
			
			
			
			
		}	
	}
	
	
	$LayoutObject->Block(
				Name => 'Abocount',
				Data => $count,
	);

 
	return 1;

		
}

sub Updatefollow {

	my ( $Self, %Param ) = @_;
	
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
	
	# get params
	my $CT_Num;
	my $AB_Fin;
	my $AB_Debut;
	my $AboIDSage = $ParamObject->GetParam( Param => 'AboIDSage' );
	my $Value = $ParamObject->GetParam( Param => 'Value' );
	my $CustomerIDOtrs = $ParamObject->GetParam( Param => 'CustomerIDOtrs' );
	
	#$Kernel::OM->Get('Kernel::System::Log')->Log(
    #        Priority => 'error',
    #        Message  => $Value,
    #);
	
	my $SQLSage = "select CT_Num, AB_Fin, AB_Debut from F_ABONNEMENT where AB_No=?";
		
	$Self->{DBObjectsage}->Prepare(
		SQL   => $SQLSage,
		Bind => [ \$AboIDSage],
		Limit => 1,
	);
		
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$CT_Num = $Row[0];
		$AB_Fin = $Row[1];
		$AB_Debut = $Row[2];
	}
			
	my $CheckFollow  = "select AboIDSage from APA_contract where AboIDSage=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $CheckFollow,
			Bind => [ \$AboIDSage],
			Limit => 1,
	);
	
	my @IsPresent;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		$Data{AboIDSage} = $Row[0];
        push( @IsPresent, \%Data );
	}
		
	# no data found...
    if ( !@IsPresent) {
									
		my $SQLotrs = "INSERT INTO APA_contract (AboIDSage, CustomerIDSage, CustomerIDOtrs, Follow, AB_Debut, AB_Fin) VALUES (?, ?, ?, ?, ?, ?)";
		
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [ \$AboIDSage,\$CT_Num,\$CustomerIDOtrs,\$Value,\$AB_Debut,\$AB_Fin],
		);
		
		# $Kernel::OM->Get('Kernel::System::Log')->Dumper($HashRef);
	
			
	} elsif ($Value=='2') {
		my $SQLotrs = "UPDATE APA_contract SET Renew=?, AB_Debut=?, AB_Fin=? WHERE AboIDSage=?";
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [ \$Value,\$AB_Debut,\$AB_Fin,\$AboIDSage],
		);
	} else {
		my $SQLotrs = "UPDATE APA_contract SET Follow=? WHERE AboIDSage=?";
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [ \$Value,\$AboIDSage],
		);
	}
	
	
	my $SQLSage2 = "SELECT AR_Ref from F_ABOLIGNE where AB_No=?";
		
	$Self->{DBObjectsage}->Prepare(
		SQL   => $SQLSage2,
		Bind => [ \$AboIDSage],
	);
	
	# $Kernel::OM->Get('Kernel::System::Log')->Log(
				# Priority => 'error',
				# Message  => $AboIDSage,
		# );
	
	my $Pack=0;
	my $RTC=0;
	my $Sup=0;
	my $Cog=0;
	my $Conc=0;
	my $Conf=0;
	my $AssTech=0;
	my $EvolLog=0;
	my $MajSecu=0;
	my $VFM=0;
	my $Go4collab=0;
	my $SupMet=0;
	my $SupRep=0;
		
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		 # $Kernel::OM->Get('Kernel::System::Log')->Log(
				 # Priority => 'error',
				 # Message  => $Row[0],
		 # );
		if ($Row[0]) {
			if ($Row[0] eq "PACK_BASIC" || $Row[0] eq "PACK_ESSENTIEL" || $Row[0] eq "PACK_PREMIER" || $Row[0] eq "PACK_GOLD") {
				$Pack=1;
			} elsif ($Row[0] eq "RTC_PIL-REP" || $Row[0] eq "RTC_EXP-TECH" || $Row[0] eq "SO_RTC-JOUR-1" || $Row[0] eq "SO_RTC-JOUR-2" || $Row[0] eq "SO_RTC-PAR") {
				$RTC=1;
			} elsif ($Row[0] eq "PRO_SUP-INFR" || $Row[0] eq "PRO_METRO" || $Row[0] eq "SO_SUP-HO" || $Row[0] eq "SO_SUP-HNO") {
				$Sup=1;
			} elsif ($Row[0] eq "COG_GEST-CHGT" || $Row[0] eq "COG_CHGT-INFRA" || $Row[0] eq "SO_COG-UO-1") {
				$Cog=1;
			} elsif ($Row[0] eq "COG_CHGT-CONC" || $Row[0] eq "SO_COG-UO-6") {
				$Conc=1;
			} elsif ($Row[0] eq "COG_GEST-CONF" || $Row[0] eq "SO_BACKUP-DEVICES") {
				$Conf=1;
			} elsif ($Row[0] eq "COG_ASS-TECH" || $Row[0] eq "SO_COG-UO-2" || $Row[0] eq "SO_COG-JOUR-2") {
				$AssTech=1;
			} elsif ($Row[0] eq "COG_EVOL-LOGIC" || $Row[0] eq "SO_COG-UO-4" || $Row[0] eq "SO_COG-JOUR-4" ) {
				$EvolLog=1;
			} elsif ($Row[0] eq "COG_MAJ-SECU" || $Row[0] eq "SO_COG-UO-3" || $Row[0] eq "SO_COG-JOUR-3") {
				$MajSecu=1;
			} elsif ($Row[0] eq "COG_VFM" || $Row[0] eq "SO_VFM") {
				$VFM=1;
			} elsif ($Row[0] eq "SO_SUP-METROLOGIE") {
				$SupMet=1;
			} elsif ($Row[0] eq "SO_SUP-REPORTING") {
				$SupRep=1;
			} elsif ($Row[0] =~ m/^CONC_.*/ || $Row[0] eq "SO_COG-UO-5") {
				$Go4collab=1;
			}
		}
		
		 # $Kernel::OM->Get('Kernel::System::Log')->Log(
				 # Priority => 'error',
				 # Message  => "$Pack $RTC $Sup $Cog $Conc $Conf $AssTech $EvolLog $MajSecu $VFM $Vidyo $Go4collab $SupMet $SupRep",
		 # );
		
	}
	
	if ($Pack==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::PACK'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($RTC==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::RTC'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($Sup==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::SUP'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($Cog==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::UO'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($Conc==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::CONC'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($Conf==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::CONF'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($AssTech==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::ASSTECH'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($EvolLog==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::EVOLLOG'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($MajSecu==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::MAJSECU'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($Go4collab==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::GO4'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	} 
	if ($VFM==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::VFM'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	}
	if ($SupRep==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::SUPREP'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
			);
		}
	}
	if ($SupMet==1) {
		my $ClassList = $GeneralCatalogObject->ItemList(
			Class         => 'ContractManagement::SUPMET'
		);

		 
		for my $ClassID ( sort keys %{$ClassList} ) {
			
			my $ItemDataRef = $GeneralCatalogObject->ItemGet(
				ItemID => $ClassID,
			);
			
			#$Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => $ItemDataRef->{Name});
			
			my $SQLotrs = "INSERT INTO APA_contract_mep (AboIDSage, Mep, DescMep) VALUES (?, ?, ?)";
			my $Mep=$ItemDataRef->{Name};
			my $DescMep=$ItemDataRef->{Comment};
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$AboIDSage,\$Mep,\$DescMep],
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

sub Updateselect {
	
	my ( $Self, %Param ) = @_;
	
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
	# get params
	my $CT_Num;
	my $AB_Fin;
	my $AB_Debut;
	my $AboIDSage = $ParamObject->GetParam( Param => 'AboIDSage' );
	my $Value = $ParamObject->GetParam( Param => 'Value' );
	
	#$Kernel::OM->Get('Kernel::System::Log')->Log(
    #        Priority => 'error',
    #        Message  => $Value,
    #);
	
	my $SQLSage = "select CT_Num, AB_Fin, AB_Debut from F_ABONNEMENT where AB_No=?";
		
	$Self->{DBObjectsage}->Prepare(
		SQL   => $SQLSage,
		Bind => [ \$AboIDSage],
		Limit => 1,
	);
		
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$CT_Num = $Row[0];
		$AB_Fin = $Row[1];
		$AB_Debut = $Row[2];
	}
			
	my $CheckFollow  = "select AboIDSage from APA_contract where AboIDSage=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $CheckFollow,
			Bind => [ \$AboIDSage],
			Limit => 1,
	);
	
	my @IsPresent;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		$Data{AboIDSage} = $Row[0];
        push( @IsPresent, \%Data );
	}
		
	# no data found...
    if ( !@IsPresent) {
							
		my $SQLotrs = "INSERT INTO APA_contract (AboIDSage, CustomerIDSage, CustomerIDOtrs, AB_Debut, AB_Fin) VALUES (?, ?, ?, ?,?)";
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [ \$AboIDSage,\$CT_Num,\$Value,\$AB_Debut,\$AB_Fin],
		);
	} else {
			my $SQLotrs = "UPDATE APA_contract SET CustomerIDOtrs=? WHERE AboIDSage=?";
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$Value,\$AboIDSage],
			);
	}
	
	my $CheckExist  = "select IDSage,Changeable from APA_contract_sagetootrs where IDSage=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $CheckExist,
			Bind => [ \$CT_Num],
			Limit => 1,
	);
	
	my @IsExist;
	my %Data;	
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		
		$Data{IDSage} = $Row[0];
		$Data{Changeable} = $Row[1];
        push( @IsExist, \%Data );
	}
	
	if ( !@IsExist) {
							
		my $SQLotrs = "INSERT INTO APA_contract_sagetootrs (IDSage, IDOtrs, Changeable) VALUES (?, ?, 1)";
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [\$CT_Num,\$Value],
		);
	} else {
			if ($Data{Changeable}==1) {
				my $SQLotrs = "UPDATE APA_contract_sagetootrs SET IDOtrs=?  WHERE IDSage=?";
				$Self->{DBObjectotrs}->Do(
					SQL  => $SQLotrs,
					Bind => [ \$Value,\$CT_Num],
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


1;