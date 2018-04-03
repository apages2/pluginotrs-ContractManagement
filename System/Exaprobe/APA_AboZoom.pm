# --
# Kernel/System/Exaprobe/APA_AboZoom.pm - core module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Exaprobe::APA_AboZoom;

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

sub GetLine {

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	
	my ( $Self, %Param ) = @_;
	
	#Get Params
	my $AboID= $ParamObject->GetParam( Param => 'AboID' );
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
	
	my $SQLCustomer = "SELECT CustomerIDOtrs from APA_contract where AboIDSage=?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $SQLCustomer,
			Bind   => [\$AboID],
	);
	
	my $Customer;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$Customer = $Row[0];
	}
	
	my $SQLAbonnement = "SELECT AB_Debut, AB_Fin,AB_TypePeriod from F_ABONNEMENT where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLAbonnement,
			Bind   => [\$AboID],
	);
	
	my $AB_Debut;
	my $AB_Fin;
	my $Multipl;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$AB_Debut = $Row[0];
		$AB_Fin= $Row[1];
		if ($Row[2]==0) {
			$Multipl=365;
		} elsif ($Row[2]==1) {
			$Multipl=52;
		} elsif ($Row[2]==2) {
			$Multipl=12;
		} elsif ($Row[2]==3) {
			$Multipl=1;
		} elsif ($Row[2]==4) {
			$Multipl=12;
		} elsif ($Row[2]==5) {
			$Multipl=1;
		}
	}
	
	
	# build SQL request
	my $SQL = "SELECT AB_No,AR_Ref,AL_Design,CONVERT(DECIMAL(10,2),AL_Qte),CONVERT(DECIMAL(10,2),AL_MontantHT),AL_Ligne,Debut,Fin from F_ABOLIGNE where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQL,
			Limit => 1000,
			Encode => [1,1,0,1,1,1],
			Bind   => [ \$AboID],
	);
	
	my @LineAbo;

	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		my %Data;
		
		my $SQLAbo_Ligne = "SELECT TR_Sage_Ligne,TR_Type, TR_DateFin, TR_Type_Sage from APA_TR where TR_EnrIDSage=? and TR_Sage_Ligne=?";

		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLAbo_Ligne,
				Bind   => [\$Row[0],\$Row[5]],
		);
		
		
		
		$Data{TR_Type} = $Row[1];
		
		
		$Data{Exist}=0;
		$Data{Renew}=0;
		while ( my @Row2 = $Self->{DBObjectotrs}->FetchrowArray() ) {
			if ($Row2[0] && $Row2[3] eq $Data{TR_Type}) {
				
				$Data{Exist} =1;
				if ($Row2[2] ne $AB_Fin) {
					$Data{Renew} =1;	
					
				}
			} 
		}
		$Data{AB_No} = $Row[0];
		$Data{AR_Ref} = $Row[1];
		$Data{AL_Design} = $Row[2];
		$Data{AL_Qte} = $Row[3];
		$Data{AL_PrixUnitaire} = $Row[4];
		$Data{AL_Ligne} = $Row[5];
		$Data{DateDebut} = $AB_Debut;
		$Data{DateFin} = $AB_Fin;
		$Data{Customer} = $Customer;
		$Data{AL_PrixUnitaire} = $Row[4]*$Multipl;
		
        push( @LineAbo, \%Data );
	}
		
	# no data found...
    if ( !@LineAbo) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing SAGE",
        );
        return;
	} else {
		if ( $IsAdminGroup || $IsAdmin) {
			for my $DataItem (@LineAbo) {
				$LayoutObject->Block(
					Name => 'LineAboAdmin',
					Data => $DataItem,
				);
			}
		} else {
			for my $DataItem (@LineAbo) {
				$LayoutObject->Block(
					Name => 'LineAbo',
					Data => $DataItem,
				);
			}
		}
	}	
		
	return 1;
	
}

sub AddTR {

	my ( $Self, %Param ) = @_;
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	
	#Get Params
	my $AB_No= $ParamObject->GetParam( Param => 'AB_No' );
	my $AL_Ligne= $ParamObject->GetParam( Param => 'AL_Ligne' );
	my $UserID = $Param{UserID};
	
	my $SQLAbonnement = "SELECT AB_Intitule,AB_TypePeriod from F_ABONNEMENT where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLAbonnement,
			Encode => [0],
			Bind   => [\$AB_No],
	);
	
	my $AB_Intitule;
	my $Multipl;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$AB_Intitule = $Row[0];
		if ($Row[1]==0) {
			$Multipl=365;
		} elsif ($Row[1]==1) {
			$Multipl=52;
		} elsif ($Row[1]==2) {
			$Multipl=12;
		} elsif ($Row[1]==3) {
			$Multipl=1;
		} elsif ($Row[1]==4) {
			$Multipl=12;
		} elsif ($Row[1]==5) {
			$Multipl=1;
		}
	}
	
	my $SQLentete = "SELECT Refrence_libre,CO_No from F_ABOENTETE where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLentete,
			Encode => [0,1],
			Bind   => [\$AB_No],
	);
	
	my $RefLibre;
	my $CO_No;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$RefLibre = $Row[0];
		$CO_No		= $Row[1];
	}
	
	
	my $SQLIC = "SELECT CO_Prenom, CO_Nom from F_COLLABORATEUR WHERE CO_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLIC,
			Encode => [0,0],
			Bind   => [\$CO_No],
	);
	
	my $IC;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$IC = $Row[0].' '.$Row[1];
	}
		
	# build SQL request
	my $SQLligne = "SELECT AR_Ref,AL_Design,CA_Num,CONVERT(DECIMAL(10,2),AL_Qte),CONVERT(DECIMAL(10,2),AL_MontantHT) from F_ABOLIGNE where AB_No=? AND AL_Ligne=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLligne,
			Encode => [0,0,1,1,1],
			Bind   => [\$AB_No,\$AL_Ligne],
	);
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $JSONString;
	
	
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		
			
		if ($Row[0] eq 'COG_GEST-CHGT'|| $Row[0] eq 'COG_CHGT-INFRA' || $Row[0] eq 'COG_CHGT-CONC' || $Row[0] eq 'COG_CHGT-GO4' || $Row[0] eq 'COG_MAJ-SECU' || $Row[0] eq 'SO_COG-UO-1'  || $Row[0] eq 'SO_COG-UO-2'  || $Row[0] eq 'SO_COG-UO-3'  || $Row[0] eq 'SO_COG-UO-4'  || $Row[0] eq 'SO_COG-UO-5'  || $Row[0] eq 'SO_COG-UO-6') {
			$JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $Row[2],
					'Type' => $Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $Row[1],
					'Option1' =>$Row[3],
					'Option2' =>$Row[3],
					'Commentaire' => $RefLibre,
					'Montant' => $Row[4]*$Multipl,
					'IC' => $IC,
					'Type_Sage' => $Row[0],
				},
			);
				
		} elsif ($Row[0] eq 'PRO_SUP-INFR' || $Row[0] eq 'SO_SUP-HO' || $Row[0] eq 'SO_SUP-HNO') {
			$JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $Row[2],
					'Type' => $Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $Row[1],
					'Option1' =>$Row[3],
					'Option2' =>$Row[3],
					'Commentaire' => $RefLibre,
					'Montant' => $Row[4]*$Multipl,
					'IC' => $IC,
					'Type_Sage' => $Row[0],
				},
			);
		} elsif ($Row[0] eq 'COG_GEST-CONF' || $Row[0] eq 'SO_BACKUP-DEVICES') {
			$JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $Row[2],
					'Type' => $Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $Row[1],
					'Option1' =>$Row[3],
					'Option2' =>$Row[3],
					'Commentaire' => $RefLibre,
					'Montant' => $Row[4]*$Multipl,
					'IC' => $IC,
					'Type_Sage' => $Row[0],
				},
			);
		} elsif ($Row[0] eq 'RTC_PIL-REP'  || $Row[0] eq 'RTC_EXP-TECH' || $Row[0] eq 'SO_RTC-JOUR-1' || $Row[0] eq 'SO_RTC-JOUR-2' || $Row[0] eq 'SO_RTC-PAR') {
			$JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $Row[2],
					'Type' => $Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $Row[1],
					'Option1' => '',
					'Option2' =>$Row[3],
					'Commentaire' => $RefLibre,
					'Montant' => $Row[4]*$Multipl,
					'IC' => $IC,
					'Type_Sage' => $Row[0],
				},
			);
		} else {
			$JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $Row[2],
					'Type' => $Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $Row[1],
					'Commentaire' => $RefLibre,
					'Montant' => $Row[4]*$Multipl,
					'IC' => $IC,
					'Type_Sage' => $Row[0],
				},
			);
		}
	}
	   
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

sub TRCancel {

	my ( $Self, %Param ) = @_;
		
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Result' => 1,
				},
			NoQuotes    => 0,
		);

	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

sub SaveTR {

	my ( $Self, %Param ) = @_;
	use POSIX qw(strftime);
	# check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID!",
        );
        return;
    }
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $Caff= $ParamObject->GetParam( Param => 'Caff' );
	my $Type= $ParamObject->GetParam( Param => 'Type' );
	my $Option1= $ParamObject->GetParam( Param => 'Option1' );
	my $Option2= $ParamObject->GetParam( Param => 'Option2' );
	my $Option3= $ParamObject->GetParam( Param => 'Option3' );
	my $Option4= $ParamObject->GetParam( Param => 'Option4' );
	my $Perimeter= $ParamObject->GetParam( Param => 'Perimeter' );
	my $Description= $ParamObject->GetParam( Param => 'Description' );
	my $DateDebut= $ParamObject->GetParam( Param => 'DateDebut' );
	my $DateFin= $ParamObject->GetParam( Param => 'DateFin' );
	my $Commentaire= $ParamObject->GetParam( Param => 'Commentaire' );
	my $Customer= $ParamObject->GetParam( Param => 'Customer' );
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	my $TR_Ligne= $ParamObject->GetParam( Param => 'TR_Ligne' );
	my $Montant = $ParamObject->GetParam( Param => 'Montant' );
	my $IC = $ParamObject->GetParam( Param => 'IC' );
	my $Type_Sage = $ParamObject->GetParam( Param => 'Type_Sage' );
	
	my $UserID = $Param{UserID};
	
	 # $Kernel::OM->Get('Kernel::System::Log')->Log(
            # Priority => 'error',
            # Message  => $Type_Sage,
        # );
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $Annee;
	my $mois;
	my $jour;
	my $Dated;
	if( $DateDebut =~ m/\// ) {
		if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
			($mois,$jour,$Annee)  = split /\//, $DateDebut;
		} elsif ($Preferences{UserLanguage} eq 'ja') {
			($Annee,$mois,$jour)  = split /\//, $DateDebut;
		} else {
			($jour,$mois,$Annee)  = split /\//, $DateDebut;
		}
		$Dated = $Annee.'-'.$mois.'-'.$jour;
	} elsif( $DateDebut =~ m/\./ ) {
		if ($Preferences{UserLanguage} eq 'zh_CN' || $Preferences{UserLanguage} eq 'zh_TW') {
			($Annee,$mois,$jour) = split /\./, $DateDebut ;
		} else {
			($jour,$mois,$Annee) = split /\./, $DateDebut ;
		}
		$Dated = $Annee.'-'.$mois.'-'.$jour;
	} else {
		$Dated = $DateDebut;
	}
	
	my $Datef;
	if( $DateFin =~ m/\// ) {
		if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
			($mois,$jour,$Annee)  = split /\//, $DateFin;
		} elsif ($Preferences{UserLanguage} eq 'ja') {
			($Annee,$mois,$jour)  = split /\//, $DateFin;
		} else {
			($jour,$mois,$Annee)  = split /\//, $DateFin;
		}
		$Datef = $Annee.'-'.$mois.'-'.$jour;
	} elsif( $DateFin =~ m/\./ ) {
		if ($Preferences{UserLanguage} eq 'zh_CN' || $Preferences{UserLanguage} eq 'zh_TW') {
			($Annee,$mois,$jour) = split /\./, $DateFin ;
		} else {
			($jour,$mois,$Annee) = split /\./, $DateFin ;
		}
		$Datef = $Annee.'-'.$mois.'-'.$jour;
	} else {
		$Datef = $DateFin;
	}
	
	my $createtime=strftime "%Y-%m-%d", localtime;
	my $Addrow  = "INSERT INTO APA_TR (TR_CustID, TR_Caff, TR_Type, TR_Option1, TR_Option2, TR_Perimetre, TR_Description, TR_DateDebut, TR_DateFin, TR_Commentaire, TR_Sage_Ligne, TR_IC, TR_Montant, TR_EnrIDSage, TR_Type_Sage, TR_Option3, TR_Option4, create_time, create_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $Addrow,
				Bind => [\$Customer,\$Caff,\$Type,\$Option1,\$Option2,\$Perimeter,\$Description,\$Dated,\$Datef,\$Commentaire,\$TR_Ligne,\$IC,\$Montant,\$TR_ID,\$Type_Sage,\$Option3,\$Option4, \$createtime, \$UserID],
		);
		
	if ($Type eq 'SO_COG-UO-1' || $Type eq 'SO_COG-UO-2' || $Type eq 'SO_COG-UO-3' || $Type eq 'SO_COG-UO-4' || $Type eq 'SO_COG-UO-5' || $Type eq 'SO_COG-UO-6') {
		my %User = $UserObject->GetUserData(
			UserID => $UserID,
		);

		my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Creation";
		
		my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_EnrIDSage=?";
	
		$Self->{DBObjectotrs}->Do(
			SQL   => $AddLog,
			Bind => [\$Message,\$TR_ID],
		);
	}
	
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Result' => 1,
				},
		);
		
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

sub RenewTR {

	my ( $Self, %Param ) = @_;
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	
	#Get Params
	my $AB_No= $ParamObject->GetParam( Param => 'AB_No' );
	my $AL_Ligne= $ParamObject->GetParam( Param => 'AL_Ligne' );
	my $Report= $ParamObject->GetParam( Param => 'Report' );
	my $UserID = $Param{UserID};
	
	my $SQLTypePeriod = "SELECT AB_TypePeriod from F_ABONNEMENT where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLTypePeriod,
			Encode => [0],
			Bind   => [\$AB_No],
	);
	
	
	my $Multipl;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		if ($Row[0]==0) {
			$Multipl=365;
		} elsif ($Row[0]==1) {
			$Multipl=52;
		} elsif ($Row[0]==2) {
			$Multipl=12;
		} elsif ($Row[0]==3) {
			$Multipl=1;
		} elsif ($Row[0]==4) {
			$Multipl=12;
		} elsif ($Row[0]==5) {
			$Multipl=1;
		}
	}
	
	my $SQLAbonnement = "SELECT TR_Perimetre,TR_Commentaire,TR_Caff,TR_Type,TR_Description,TR_Option1, TR_Option2, TR_Option3, TR_Option4 from APA_TR where TR_EnrIDSage=? AND TR_Sage_Ligne=?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $SQLAbonnement,
			Bind   => [\$AB_No,\$AL_Ligne],
	);
	
	my $AB_Intitule;
	my $RefLibre;
	my $TR_Caff;
	my $TR_Type;
	my $TR_Description;
	my $TR_Option1;
	my $TR_Option2;
	my $TR_Option3;
	my $TR_Option4;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$AB_Intitule = $Row[0];
		$RefLibre = $Row[1];
		$TR_Caff = $Row[2];
		$TR_Type = $Row[3];
		$TR_Description = $Row[4];
		$TR_Option1 = $Row[5];
		$TR_Option2 = $Row[6];
		$TR_Option3 = $Row[7];
		$TR_Option4 = $Row[8];
	}
	
	my $SQLentete = "SELECT CO_No from F_ABOENTETE where AB_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLentete,
			Bind   => [\$AB_No],
	);
	
	
	my $CO_No;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$CO_No		= $Row[0];
	}
	
	my $SQLIC = "SELECT CO_Prenom, CO_Nom from F_COLLABORATEUR WHERE CO_No=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLIC,
			Encode => [0,0],
			Bind   => [\$CO_No],
	);
	
	my $IC;
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$IC = $Row[0].' '.$Row[1];
	}
		
	# build SQL request
	my $SQLligne = "SELECT AR_Ref,CONVERT(DECIMAL(10,2),AL_Qte),CONVERT(DECIMAL(10,2),AL_MontantHT) from F_ABOLIGNE where AB_No=? AND AL_Ligne=?";

	# get data
	$Self->{DBObjectsage}->Prepare(
        	SQL   => $SQLligne,
			Bind   => [\$AB_No,\$AL_Ligne],
	);
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $JSONString;
	my $qte;
	my $New_TR_Option2;
	
	 
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		if ($Row[0] eq 'COG_GEST-CHGT'|| $Row[0] eq 'COG_CHGT-INFRA' || $Row[0] eq 'COG_MAJ-SECU' || $Row[0] eq 'COG_CHGT-CONC' || $Row[0] eq 'COG_CHGT-GO4' || $Row[0] eq 'SO_COG-UO-1'  || $Row[0] eq 'SO_COG-UO-2'  || $Row[0] eq 'SO_COG-UO-3'  || $Row[0] eq 'SO_COG-UO-4'  || $Row[0] eq 'SO_COG-UO-5'  || $Row[0] eq 'SO_COG-UO-6') {
			if ($Report==1) {
				$qte = $Row[1];
				
				$New_TR_Option2 = $TR_Option2+$Row[1];
				$JSONString = $LayoutObject->JSONEncode(
					Data => {
						'Caff' => $TR_Caff,
						'Type' => $TR_Type,
						'Type_Sage' =>$Row[0],
						'Perimeter' => $AB_Intitule,
						'Description' => $TR_Description,
						'Option1' =>$Row[1],
						'Option2' =>$New_TR_Option2,
						'Commentaire' => $RefLibre,
						'Montant' => $Row[2]*$Multipl,
						'IC' => $IC,
						'SoldeActuel' => $TR_Option2,
						'Report' => $Report,
					},
				);
			} elsif ($Report==2) {
				$JSONString = $LayoutObject->JSONEncode(
					Data => {
						'Caff' => $TR_Caff,
						'Type' => $TR_Type,
						'Type_Sage' =>$Row[0],
						'Perimeter' => $AB_Intitule,
						'Description' => $TR_Description,
						'Option1' =>$Row[1],
						'Option2' =>$Row[1],
						'Commentaire' => $RefLibre,
						'Montant' => $Row[2]*$Multipl,
						'IC' => $IC,
						'SoldeActuel' => $TR_Option2,
						'Report' => $Report,
					},
				);
			}
				
		} else {
		
			 $JSONString = $LayoutObject->JSONEncode(
				Data => {
					'Caff' => $TR_Caff,
					'Type' => $TR_Type,
					'Type_Sage' =>$Row[0],
					'Perimeter' => $AB_Intitule,
					'Description' => $TR_Description,
					'Commentaire' => $RefLibre,
					'Montant' => $Row[2]*$Multipl,
					'Option1' =>$TR_Option1,
					'Option2' =>$TR_Option2,
					'Option3' =>$TR_Option3,
					'Option4' =>$TR_Option4,
					'IC' => $IC,
				},
			);
		}
	}
	
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

sub ApplyTR {
	use POSIX 'strftime';
	my ( $Self, %Param ) = @_;
	
	# check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID!",
        );
        return;
    }
	
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $Caff= $ParamObject->GetParam( Param => 'Caff' );
	my $Type= $ParamObject->GetParam( Param => 'Type' );
	my $Type_Sage= $ParamObject->GetParam( Param => 'Type_Sage' );
	my $Option1= $ParamObject->GetParam( Param => 'Option1' );
	my $Option2= $ParamObject->GetParam( Param => 'Option2' );
	my $Option3= $ParamObject->GetParam( Param => 'Option3' );
	my $Option4= $ParamObject->GetParam( Param => 'Option4' );
	my $Perimeter= $ParamObject->GetParam( Param => 'Perimeter' );
	my $Description= $ParamObject->GetParam( Param => 'Description' );
	my $DateDebut= $ParamObject->GetParam( Param => 'DateDebut' );
	my $DateFin= $ParamObject->GetParam( Param => 'DateFin' );
	my $Commentaire= $ParamObject->GetParam( Param => 'Commentaire' );
	my $Customer= $ParamObject->GetParam( Param => 'Customer' );
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	my $TR_Ligne= $ParamObject->GetParam( Param => 'TR_Ligne' );
	my $Montant = $ParamObject->GetParam( Param => 'Montant' );
	my $IC = $ParamObject->GetParam( Param => 'IC' );
	my $Report = $ParamObject->GetParam( Param => 'Report' );
	my $UserID = $Param{UserID};
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $Date = strftime "%Y-%m-%d", localtime;
	my $Solde;
	my $UO_ID;
	my $Renew;
	my $Subject;
	my $TR_Log;
	if ($Report== 1 || $Report== 2) {
		$Renew=$Option1*-1;
		my $SQLAbonnement = "SELECT TR_Option2,TR_ID,TR_Log from APA_TR WHERE TR_EnrIDSage=? AND TR_Sage_Ligne=?";

		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLAbonnement,
				Bind   => [\$TR_ID,\$TR_Ligne],
		);
	
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
			$Solde = $Row[0];
			$UO_ID = $Row[1];
			$TR_Log = $Row[2];
		}
	}
	if ($Report == 1) {
		$Subject = "Renew";
		my $Addrenew  = "INSERT INTO APA_TR_UO_decompte (UO_unit, date, owner, subject, TR_ID) VALUES (?,?,?,?,?)";
		
		$Self->{DBObjectotrs}->Do(
			SQL   => $Addrenew,
			Bind => [\$Renew,\$Date,\$UserID,\$Subject,\$UO_ID],
		);
		
		my %User = $UserObject->GetUserData(
			UserID => $UserID,
		);

		my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Renew avec Report"."\r".$TR_Log;
		
		my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";
	
		$Self->{DBObjectotrs}->Do(
			SQL   => $AddLog,
			Bind => [\$Message,\$UO_ID],
		);
	
		
	} elsif ($Report == 2) {
	
		
		$Subject = "Expiration de la banque d'UO";
		my $Expire  = "INSERT INTO APA_TR_UO_decompte (UO_unit, date, owner, subject, TR_ID) VALUES (?,?,?,?,?)";
		
		$Self->{DBObjectotrs}->Do(
			SQL   => $Expire,
			Bind => [\$Solde,\$Date,\$UserID,\$Subject,\$UO_ID],
		);	
		
		$Subject = "Renew";
		my $Addrenew  = "INSERT INTO APA_TR_UO_decompte (UO_unit, date, owner, subject, TR_ID) VALUES (?,?,?,?,?)";
		
		$Self->{DBObjectotrs}->Do(
			SQL   => $Addrenew,
			Bind => [\$Renew,\$Date,\$UserID,\$Subject,\$UO_ID],
		);
		
		my %User = $UserObject->GetUserData(
			UserID => $UserID,
		);

		my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Renew sans Report"."\r".$TR_Log;
		
		my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";
	
		$Self->{DBObjectotrs}->Do(
			SQL   => $AddLog,
			Bind => [\$Message,\$UO_ID],
		);
	}
	
	my $Annee;
	my $mois;
	my $jour;
	my $Dated;
	if( $DateDebut =~ m/\// ) {
		if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
			($mois,$jour,$Annee)  = split /\//, $DateDebut;
		} elsif ($Preferences{UserLanguage} eq 'ja') {
			($Annee,$mois,$jour)  = split /\//, $DateDebut;
		} else {
			($jour,$mois,$Annee)  = split /\//, $DateDebut;
		}
		$Dated = $Annee.'-'.$mois.'-'.$jour;
	} elsif( $DateDebut =~ m/\./ ) {
		if ($Preferences{UserLanguage} eq 'zh_CN' || $Preferences{UserLanguage} eq 'zh_TW') {
			($Annee,$mois,$jour) = split /\./, $DateDebut ;
		} else {
			($jour,$mois,$Annee) = split /\./, $DateDebut ;
		}
		$Dated = $Annee.'-'.$mois.'-'.$jour;
	} else {
		$Dated = $DateDebut;
	}
	
	my $Datef;
	if( $DateFin =~ m/\// ) {
		if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
			($mois,$jour,$Annee)  = split /\//, $DateFin;
		} elsif ($Preferences{UserLanguage} eq 'ja') {
			($Annee,$mois,$jour)  = split /\//, $DateFin;
		} else {
			($jour,$mois,$Annee)  = split /\//, $DateFin;
		}
		$Datef = $Annee.'-'.$mois.'-'.$jour;
	} elsif( $DateFin =~ m/\./ ) {
		if ($Preferences{UserLanguage} eq 'zh_CN' || $Preferences{UserLanguage} eq 'zh_TW') {
			($Annee,$mois,$jour) = split /\./, $DateFin ;
		} else {
			($jour,$mois,$Annee) = split /\./, $DateFin ;
		}
		$Datef = $Annee.'-'.$mois.'-'.$jour;
	} else {
		$Datef = $DateFin;
	}
	
	my $changetime=strftime "%Y-%m-%d", localtime;
	my $Addrow  = "UPDATE APA_TR set TR_CustID=?, TR_Caff=?, TR_Type=?, TR_Option1=?, TR_Option2=?, TR_Perimetre=?, TR_Description=?, TR_DateDebut=?, TR_DateFin=?, TR_Commentaire=?, TR_IC=?, TR_Montant=?, TR_Type_Sage=?, TR_Option3=?, TR_Option4=?, change_time=?, change_by=?  WHERE TR_EnrIDSage=? AND TR_Sage_Ligne=?";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $Addrow,
				Bind => [\$Customer,\$Caff,\$Type,\$Option1,\$Option2,\$Perimeter,\$Description,\$Dated,\$Datef,\$Commentaire,\$IC,\$Montant,\$Type_Sage,\$Option3,\$Option4,\$changetime, \$UserID,\$TR_ID,\$TR_Ligne],
		);
		
	
	
	
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Result' => 1,
				},
		);
	
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

1;