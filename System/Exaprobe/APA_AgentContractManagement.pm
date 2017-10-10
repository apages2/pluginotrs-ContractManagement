# --
# Kernel/System/Exaprobe/APA_AgentContractManagement.pm - core module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Exaprobe::APA_AgentContractManagement;

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
	my $Self = {%Param};
	bless ($Self, $Type);
	
	# get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	
	$Self->{UserDBSage} = $ConfigObject->Get('ContractManagement::Config')->{UserDBSage};
	$Self->{PasswordDBSage} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBSage};
	$Self->{UserDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{UserDBOTRS};
	$Self->{PasswordDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBOTRS};
	$Self->{RowNumber} = $ConfigObject->Get('ContractManagement::Config::Agent')->{RowNumber};
	$Self->{MailExp} = $ConfigObject->Get('ContractManagement::Config')->{MailExpediteur};
	$Self->{MailBody} = $ConfigObject->Get('ContractManagement::Config')->{MailBodyFR};
	$Self->{MailSubject} = $ConfigObject->Get('ContractManagement::Config')->{MailSubjectFR};
	
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
	
	$Self->{Group} = $ConfigObject->Get('ContractManagement::Config')->{Group};
	
	return $Self;
}


sub GetSubscriptionFollowed {

	my ( $Self, %Param ) = @_;
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
	
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	my $PageShown = $Self->{RowNumber};
	
	my $Subaction = $ParamObject->GetParam( Param => 'Subaction' );
	my $AboID = $ParamObject->GetParam( Param => 'AboID' );
	
	
	my $mep = 0;
	if ( $Subaction && $Subaction eq 'MEP' ) {
        $mep = 1;
	} 
	
	my $UserID = $Param{UserID};
	
	
	# get the group id which is allowed to Edit the UO
	my $UOGroupID = $GroupObject->GroupLookup(
		Group => $Self->{Group},
	);
	
	my %GroupList = $GroupObject->PermissionUserGroupGet(
        UserID => $UserID,
        Type    => 'rw',  # ro|move_into|priority|create|rw
    );
	
	my $IsAdminGroup;
	if ($GroupList{$UOGroupID}) {
		$IsAdminGroup=1;
	}
	
	my %RoleList = $GroupObject->PermissionGroupRoleGet(
        GroupID => $UOGroupID,
        Type    => 'rw',  # ro|move_into|priority|create|rw
    );
	
	my $IsAdmin;
	for my $RoleID ( sort keys %RoleList ) {
		my %RoleUserList = $GroupObject->PermissionRoleUserGet(
			RoleID => $RoleID,
		);
		
		if ($RoleUserList{$UserID}) {
			$IsAdmin =1 ;
		}
		
	}
	
	my $Nav = $ParamObject->GetParam( Param => 'Nav' ) || 0;
	my $Search = $ParamObject->GetParam( Param => 'Search' );
	my $SearchList = $ParamObject->GetParam( Param => 'SearchList' ) || 0;
	 $Search
        ||= $ConfigObject->Get('AdminCustomerCompany::RunInitialWildcardSearch') ? '*' : '';
	my $Filter= $ParamObject->GetParam( Param => 'Filter' );
	my $StartHit = $ParamObject->GetParam( Param => 'StartHit' ) || 1;
	
	my $SearchSQL = $Search;
	$SearchSQL =~ s/\*/%/g;
	$Param{Search}=$Search;
	$Param{SearchList}=$SearchList;
	$LayoutObject->Block( Name => 'ActionList' );
	$LayoutObject->Block(
        Name => 'ActionSearch',
        Data => \%Param,
    );	
	
	
	if ( $Search ne "*" && $SearchList == 0) {
		my $SQLOtrs = "SELECT AboIDSage, CustomerIDOtrs, AB_Debut, AB_Fin, Avancement from APA_contract where Follow=1 and Avancement!=100 and CustomerIDOtrs LIKE ? ORDER BY Avancement ASC"; 
		 
		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLOtrs,
				Bind => [\$SearchSQL]
		);
	} elsif ( $Search ne "*" && $SearchList == 2 ) {
		my $SQLOtrs = "SELECT AboIDSage, CustomerIDOtrs, AB_Debut, AB_Fin, Avancement from APA_contract where Follow=1 and Avancement!=100 and AB_Debut = ? ORDER BY Avancement ASC"; 
		 
		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLOtrs,
				Bind => [\$SearchSQL]
		);
	} elsif ( $Search ne "*" && $SearchList == 3 ) {
		my $SQLOtrs = "SELECT AboIDSage, CustomerIDOtrs, AB_Debut, AB_Fin, Avancement from APA_contract where Follow=1 and Avancement!=100 and AB_Debut >= ? ORDER BY Avancement ASC"; 
		 
		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLOtrs,
				Bind => [\$SearchSQL]
		);
	} elsif ( $Search ne "*" && $SearchList == 4 ) {
		my $SQLOtrs = "SELECT AboIDSage, CustomerIDOtrs, AB_Debut, AB_Fin, Avancement from APA_contract where Follow=1 and Avancement!=100 and AB_Debut <= ? ORDER BY Avancement ASC"; 
		 
		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLOtrs,
				Bind => [\$SearchSQL]
		);
	} else {
		my $SQLOtrs = "SELECT AboIDSage, CustomerIDOtrs, AB_Debut, AB_Fin, Avancement from APA_contract WHERE Follow=1 and Avancement!=100 ORDER BY Avancement ASC";
		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLOtrs
		);
	}
	
	
	my $ClassMEP = $GeneralCatalogObject->ItemList(
        Class         => 'ContractManagement::MEP',
    );
	

	my @ItemMEP;
	for my $ClassID ( sort keys %{$ClassMEP} ) {
		my %Data;
		my $ClassList = $GeneralCatalogObject->ItemGet(
					ItemID => $ClassID,
				);
				
				$Data{Name}=$ClassList->{Name};
				
				push( @ItemMEP, \%Data );
				 
	}


	#$Kernel::OM->Get('Kernel::System::Log')->Log(
     #       Priority => 'error',
      #      Message  => $SQLOtrs,
    #);
	
	my @ContractData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		$Data{AboIDSage} = $Row[0];
		$Data{CustIDOtrs} = $Row[1];
		$Data{AB_Debut} = $Row[2];
		$Data{AB_Fin} = $Row[3];
		$Data{AvancementG} = $Row[4];
		
		push( @ContractData, \%Data );
	}
		
	# no data found...
    if ( !@ContractData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing OTRS",
        );
    }
	
	
	
	my $count=0;
	my $countmep=0;
	my @AboData;
	my @AboMep;
	
	if (@ContractData) {
    
		for my $DataItem (@ContractData) {
			# build SQL request
			my $SQLSage;
			if ( $SearchList == 1) {
				$SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_TypeDuree from F_ABONNEMENT where AB_No= ? and AB_Intitule LIKE ?";
				$Self->{DBObjectsage}->Prepare(
					SQL   => $SQLSage,
					Encode => [1,0,1,1],
					Bind => [\${$DataItem}{AboIDSage},\$SearchSQL]
				);
			} else {
				$SQLSage = "SELECT CT_Num,AB_Intitule,AB_Duree,AB_TypeDuree from F_ABONNEMENT where AB_No= ?";
				# get data
				$Self->{DBObjectsage}->Prepare(
						SQL   => $SQLSage,
						Encode => [1,0,1,1],
						Bind => [\${$DataItem}{AboIDSage}]
				);
			}
			
			while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
				my %Data;
				$Data{CustIDSage} = $Row[0];
				$Data{AboIntitule} = $Row[1];
				$Data{AboDuree} = $Row[2];
				$Data{AboTypeDuree} = $Row[3];
				$Data{AboDateDebut} = ${$DataItem}{AB_Debut};
				$Data{AboDateFin} = ${$DataItem}{AB_Fin};
				$Data{CustIDOtrs} = ${$DataItem}{CustIDOtrs};
				$Data{AboIDSage} = ${$DataItem}{AboIDSage};
				$Data{AvancementG} = ${$DataItem}{AvancementG};
				$count++;
				$Data{etat} = $AboID;
				#$Kernel::OM->Get('Kernel::System::Log')->Log(
				#	Priority => 'error',
				#	Message  => $Data{CustIDSage},
				#);
				push( @AboData, \%Data );
			}
		}
	}		
	
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
		Link        => 'Search='.$Search.';SearchList='.$SearchList.';',
        IDPrefix  => $LayoutObject->{Action},
    );

	if (%PageNav) {
        $LayoutObject->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );
	}
	
	my %ResponsibleList = $UserObject->UserList(
		Type => 'Long',
	);
		
	
	my %Responsible;
	for my $RespListID ( sort keys %ResponsibleList ) {
		my $RespFullname=$ResponsibleList{$RespListID};
		$Responsible{$RespFullname}=$RespListID;
		
	}
	
	my %Resp;
	my @UserData;
	for my $RespTri ( sort keys %Responsible ) {
		
		my $RespIDTri=$Responsible{$RespTri};
		push @UserData, { RespFullName=>$RespTri, RespID=>$RespIDTri };
		
		}
	

					
					# $Kernel::OM->Get('Kernel::System::Log')->Dumper(@AboData);
					
	if (@AboData) {
				for my $DataItem (@AboData[$StartHit-1..$MaxItem]) {			
					$LayoutObject->Block(
						Name => 'AboOtrsRow',
						Data => $DataItem,
					);
					
						# $Kernel::OM->Get('Kernel::System::Log')->Log(
						# Priority => 'error',
						# Message  => ${$DataItem}{AboIDSage},
						# );
					
			
					if ($AboID) {
						if ($AboID == ${$DataItem}{AboIDSage}) {
							my $SQLOtrs = "SELECT MEPID, AboIDSage, Mep, DescMep, Proprietaire, Avancement, Notif, NbNotif from APA_contract_mep where AboIDSage= ?";

							# get data
							$Self->{DBObjectotrs}->Prepare(
									SQL   => $SQLOtrs,
									Bind => [\$AboID]
							);
							while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
								my %Data;
								$Data{MEPID} = $Row[0];
								$Data{MepAboIDSage} = $Row[1];
								$Data{Mep} = $Row[2];
								$Data{DescMep} = $Row[3];
								$Data{ProprietaireID} = $Row[4];
								if ($Row[4]!=0) {
									my %User = $UserObject->GetUserData(
										UserID => $Row[4],
									);
									
									$Data{Proprietaire} = $User{'UserFullname'};
									
								}
								$Data{Avancement} = $Row[5];
								$Data{AboIDSage} = ${$DataItem}{AboIDSage};
								
								
						
								if (defined($Row[6])) {
									$Data{Notif} = $Row[6];
								}
								
								if ($Row[7]!=0) {
									$Data{NbNotif} = $Row[7];
								}
								
								$countmep++;
								push( @AboMep, \%Data );
							}
							if (@AboMep) {
								$LayoutObject->Block(
										Name => 'AboMEPTR',
								);
								for my $DataItem2 (@AboMep) {			
									if ($IsAdminGroup || $IsAdmin) {
										$LayoutObject->Block(
											Name => 'AboMEPAdmin',
											Data => $DataItem2,
										);

									} else {
										$LayoutObject->Block(
											Name => 'AboMEP',
											Data => $DataItem2,
										);
									}
									
									for my $DataItem3 (@UserData) {
										$LayoutObject->Block(
											Name => 'ResponsibleRW',
											Data => $DataItem3,
										);
									}
									
									for my $DataItem4 (@ItemMEP) {
										$LayoutObject->Block(
											Name => 'AboMEPSelect',
											Data => $DataItem4,
										);
									}
								}	
								
														
								if ($IsAdminGroup || $IsAdmin) {
									$LayoutObject->Block(
										Name => 'AboMEPLastAdmin'
									);

								} else {
									$LayoutObject->Block(
										Name => 'AboMEPLast'
									);
								}
								
								
								
							}
						}
					}
				}
	}	
	
	
			
$LayoutObject->Block(
	Name => 'AboOtrscount',
	Data => $count,
);
	
	
}

sub Updateselect {

	my ( $Self, %Param ) = @_;
	use POSIX qw(strftime); 

	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
	
	# get params

	my $MEPID = $ParamObject->GetParam( Param => 'MEPID' );
	my $Value = $ParamObject->GetParam( Param => 'Value' );
	my $Champ = $ParamObject->GetParam( Param => 'Champ' );
	
	
	my $CheckFollow  = "select MEPID from APA_contract_mep where MEPID=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $CheckFollow,
			Bind => [ \$MEPID],
			Limit => 1,
	);
	
	my @IsExist;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		$Data{MEPID} = $Row[0];
        push( @IsExist, \%Data );
	}
		
	# no data found...
    if ( !@IsExist) {
							
		my $SQLotrs = "INSERT INTO APA_contract_mep (MEPID) VALUES (?)";
		$Self->{DBObjectotrs}->Do(
			SQL  => $SQLotrs,
			Bind => [ \$MEPID],
		);
	} else {
		if ($Champ eq 'Responsible') {
			my $SQLotrs = "UPDATE APA_contract_mep SET Proprietaire=?,Notif=NULL, NbNotif='0' WHERE MEPID=?";
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$Value,\$MEPID],
			);
		} elsif ($Champ eq 'MEPList') {
			
			my $ClassMEP = $GeneralCatalogObject->ItemGet(
				Class => 'ContractManagement::MEP',
				Name  => $Value,
			);
			
			my $Comment = $ClassMEP->{Comment};
	
			
			my $SQLotrs = "UPDATE APA_contract_mep SET MEP=?, DescMep=? WHERE MEPID=?";
			$Self->{DBObjectotrs}->Do(
				SQL  => $SQLotrs,
				Bind => [ \$Value,\$Comment,\$MEPID],
			);
		}
	}
		

	my $JSON = $LayoutObject->JSONEncode(
			Data => {
				'MEPID' => $MEPID,
				},
			NoQuotes    => 0,
		);
		
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ClickAvancement {
	
	my ( $Self, %Param ) = @_;
	use POSIX qw(floor);
	
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
			
	my @AboMep;
	
	# get params
	
	my $MEPID = $ParamObject->GetParam( Param => 'MEPID' );
	my $Value = $ParamObject->GetParam( Param => 'Value' );
	
	my $State;
	if ($Value eq 'false') {
		$State=100;
	} elsif ($Value eq 'true') {
		$State=0;
	}
	my $UpdateAvanc  = "UPDATE APA_contract_mep SET Avancement=? WHERE MEPID=?";
		
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $UpdateAvanc,
		Bind => [\$State,\$MEPID],
	);
	
	my $AboIDSageR = "SELECT AboIDSage from APA_contract_mep WHERE MEPID=?";
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $AboIDSageR,
		Bind => [\$MEPID],
	);
	
	my $AboIDSage;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$AboIDSage = $Row[0];
	}
	
	my $CalculAvancement  = "SELECT Avancement from APA_contract_mep WHERE AboIDSage=?";
		
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $CalculAvancement,
		Bind => [\$AboIDSage],
	);
	
	my $SAvancement=0;
	my $count=0;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$SAvancement = $SAvancement+$Row[0];
		$count=$count+1;
	}
	
	my $UpdateAvancG  = "UPDATE APA_contract SET Avancement=? WHERE AboIDSage=?";
		
	my $ValueAv = floor(($SAvancement/$count));
	
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $UpdateAvancG,
		Bind => [\$ValueAv,\$AboIDSage],
	);
	
	my $JSON = $LayoutObject->JSONEncode(
			Data => {
				'Avancement' => $ValueAv,
				'AboIDSage' => $AboIDSage,
				},
			NoQuotes    => 0,
		);
		
		
	return $LayoutObject->Attachment(
		ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
		Content     => $JSON,
		Type        => 'inline',
		NoCache     => 1,
	);

}

sub ClickDel {
		
	my ( $Self, %Param ) = @_;
	use POSIX qw(floor);
	
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
	# get params

	my $MEPID = $ParamObject->GetParam( Param => 'MEPID' );

	my $AboIDSageR = "SELECT AboIDSage from APA_contract_mep WHERE MEPID=?";
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $AboIDSageR,
		Bind => [\$MEPID],
	);
	
	my $AboIDSage;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$AboIDSage = $Row[0];
	}
	
	my $Deleterow  = "DELETE from APA_contract_mep where MEPID=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $Deleterow,
			Bind => [\$MEPID],
			Limit => 1,
	);
	
	my $CalculAvancement  = "SELECT Avancement from APA_contract_mep WHERE AboIDSage=?";
		
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $CalculAvancement,
		Bind => [\$AboIDSage],
	);
	
	my $SAvancement=0;
	my $count=0;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$SAvancement = $SAvancement+$Row[0];
		$count=$count+1;
	}
	
	my $UpdateAvancG  = "UPDATE APA_contract SET Avancement=? WHERE AboIDSage=?";
		
	my $ValueAv = floor($SAvancement/$count);
	
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $UpdateAvancG,
		Bind => [\$ValueAv,\$AboIDSage],
	);
	
	my $JSON = $LayoutObject->JSONEncode(
		Data => {
			'Avancement' => $ValueAv,
			'AboIDSage' => $AboIDSage,
			},
		NoQuotes    => 0,
	);
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ClickAdd {
	
	my ( $Self, %Param ) = @_;
	use POSIX qw(floor);
	
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
	
	my $AboIDSage = $ParamObject->GetParam( Param => 'AboIDSage' );

					
	my $Addrow  = "INSERT INTO APA_contract_mep (AboIDSage) VALUES (?)";
	
	
	if ($AboIDSage !=0) {
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $Addrow,
				Bind => [\$AboIDSage],
		);
	}
	
	my $CheckID = "SELECT LAST_INSERT_ID()";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $CheckID,
		);
		
	my $MEPID;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$MEPID = $Row[0];
	}
	
	my $CalculAvancement  = "SELECT Avancement from APA_contract_mep WHERE AboIDSage=?";
		
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $CalculAvancement,
		Bind => [\$AboIDSage],
	);
	
	my $SAvancement=0;
	my $count=0;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$SAvancement = $SAvancement+$Row[0];
		$count=$count+1;
	}
	
	my $UpdateAvancG  = "UPDATE APA_contract SET Avancement=? WHERE AboIDSage=?";
		
	my $ValueAv = floor($SAvancement/$count);
	
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $UpdateAvancG,
		Bind => [\$ValueAv,\$AboIDSage],
	);
	
	
	my %ResponsibleList = $UserObject->UserList(
		Type => 'Long',
	);
		
	
	my %Responsible;
	for my $RespListID ( sort keys %ResponsibleList ) {
		my $RespFullname=$ResponsibleList{$RespListID};
		$Responsible{$RespFullname}=$RespListID;
		
	}
	
	
	my @UserData;
	for my $RespTri ( sort keys %Responsible ) {
		
		my $RespIDTri=$Responsible{$RespTri};
		
		
			
		
		push @UserData, {
						RespIDTri => $RespIDTri,
						RespFullName => $RespTri,
					};	 
			
	}
	

	
	
	my $ClassMEP = $GeneralCatalogObject->ItemList(
        Class         => 'ContractManagement::MEP',
    );
	

	my @ItemMEP;
	for my $ClassID ( sort keys %{$ClassMEP} ) {
		my %Data;
		my $ClassList = $GeneralCatalogObject->ItemGet(
					ItemID => $ClassID,
				);
				
				$Data{Name}=$ClassList->{Name};
				
				push @ItemMEP, {
					MEPName => $Data{Name},
				}
				 
	}
	
	my $LastMEP  = "SELECT Avancement from APA_contract_mep WHERE AboIDSage=?";
		
	$Self->{DBObjectotrs}->Prepare(
		SQL   => $CalculAvancement,
		Bind => [\$AboIDSage],
	);
	
	my $JSONString = $LayoutObject->JSONEncode(
		Data => {
			'Tache' =>\@ItemMEP,
			'Responsable' =>\@UserData,
			'InsertID' => $MEPID,
			'Avancement' => $ValueAv,
			'AboIDSage' => $AboIDSage,
			},
		NoQuotes    => 0,
	);
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper($JSONString);
           
	
	
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSONString,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub Sendmail {

	my ( $Self, %Param ) = @_;
		
	# get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $EmailObject = $Kernel::OM->Get('Kernel::System::Email');
	
	my $MEPID = $ParamObject->GetParam( Param => 'MEPID' );

	my $Propietaire;
	my $MEP;
	my $AboIDSage;
	my $NbNotif;
	my $SQLOtrs = "SELECT proprietaire, MEP, AboIDSage, NbNotif from APA_contract_mep where MEPID=?	 ";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
			Bind => [\$MEPID],
			Limit => 1,
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$Propietaire = $Row[0];
        $MEP = $Row[1];
        $AboIDSage = $Row[2];
		$NbNotif = $Row[3];
	}
	
	my $Abo_Intitule;
	my $Client;
	my $SQLSage = "SELECT AB_Intitule, CT_Num from F_ABONNEMENT where AB_No=?	 ";

	# get data
	$Self->{DBObjectsage}->Prepare(
			SQL   => $SQLSage,
			Bind => [\$AboIDSage],
			Limit => 1,
	);
	
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$Abo_Intitule = $Row[0];
        $Client = $Row[1];
	}

	my %User = $UserObject->GetUserData(
        UserID => $Propietaire,
    );
	
	my $Mail = $User{UserEmail};
		
	$Self->{MailSubject} =~ s/\$Abo_Intitule/$Abo_Intitule/;
	$Self->{MailSubject} =~ s/\$Client/$Client/;
	$Self->{MailSubject} =~ s/\$MEP/$MEP/;
	
	$Self->{MailBody} =~ s/\$Abo_Intitule/$Abo_Intitule/;
	$Self->{MailBody} =~ s/\$Client/$Client/;
	$Self->{MailBody} =~ s/\$MEP/$MEP/;
	
	my $Sent = $EmailObject->Send(
			From          => $Self->{MailExp},
			To            => $Mail,                        # required if both Cc and Bcc are not present
			Subject       => $Self->{MailSubject},
			Charset       => 'iso-8859-15',
			MimeType      => 'text/html', # "text/plain" or "text/html"
			Body          => $Self->{MailBody},
			Loop          => 1, # not required, removes smtp from
		);
		
	# my $Date = date(); 
	# my $Notif = $Date->{date};
	
	
	
		
	my $JSON;	
	if ($Sent) {
	
		my $Notif = strftime "%d/%m/%Y", localtime; 
		my $NotifDB = strftime "%Y/%m/%d", localtime; 
		$NbNotif = $NbNotif+1;
		my $UpdateNotif = "UPDATE APA_contract_mep SET Notif=?, NbNotif=? WHERE MEPID=?";

		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $UpdateNotif,
				Bind => [\$NotifDB,\$NbNotif,\$MEPID],
		);

		$JSON = $LayoutObject->JSONEncode(
			Data => {
				'Notif' =>$Notif,
				'NbNotif' =>$NbNotif,
				'MEPID' => $MEPID,
				},
			NoQuotes    => 0,
		);
			
    }
    else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Envoi de mail impossible : $Body à destination de $Mail' ,
		);
		$JSON = $LayoutObject->BuildSelectionJSON(
			[
				{
					Name         => 'Result',
					Data         => 'ERROR',
				},
			],
		);
    }
	
	 return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}
1;