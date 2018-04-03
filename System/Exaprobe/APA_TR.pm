# --
# Kernel/System/Exaprobe/APA_TR.pm - core module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Exaprobe::APA_TR;

use strict;
use warnings;

use Digest::MD5;

use vars qw(@ISA);

use Kernel::System::VariableCheck qw(:all);
use Kernel::System::EventHandler;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Group',
	'Kernel::System::CustomerUser',
    'Kernel::System::User',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
);

=head1 NAME

Kernel::System::Exaprobe::APA_TR - Library Tableau Recap

=head1 SYNOPSIS

Tableau Récap Librairie

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TRObject = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_TR');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    @ISA = qw(
        Kernel::System::EventHandler
    );

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

sub GetTR {

	use POSIX qw(strftime); 

	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerID = $ParamObject->GetParam( Param => 'CustomerID' ) || '';	
	my $ServiceType = $ParamObject->GetParam( Param => 'ServiceType' ) || '';	
	
	
	
	my $SQLOtrs = "SELECT TR_ID, TR_Caff, TR_Type, TR_Option1, TR_Option2, TR_Perimetre, TR_Description, TR_DateDebut, TR_DateFin, TR_Commentaire, TR_Option3, TR_Option4  from APA_TR where TR_CustID = ? and TR_valid_id=1 and TR_Type LIKE ?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
			Bind => [\$Param{CustomerID},\$Param{ServiceType}]
	);



	my @TRData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		
		$Data{TR_ID} = $Row[0];
        $Data{TR_Caff} = $Row[1];
		
		if ($Row[2] eq 'MCO_P-BAS') {
			$Data{TR_Type}='PACK_BASIC';
		} elsif ($Row[2] eq 'MCO_P-ESS') {
			$Data{TR_Type}='PACK_ESSENTIEL';
		} elsif ($Row[2] eq 'MCO_P-PRE') {
			$Data{TR_Type}='PACK_PREMIER';
		} elsif ($Row[2] eq 'MCO_P-GLD') {
			$Data{TR_Type}='PACK_GOLD';
		} elsif ($Row[2] eq 'COG_GEST-CHGT' || $Row[2] eq 'COG_CHGT-INFRA' || $Row[2] eq 'SO_COG-UO-1') {
			$Data{TR_Type}='INFRA';
		} elsif ( $Row[2] eq 'COG_CHGT-CONC' || $Row[2] eq 'SO_COG-UO-6') {
			$Data{TR_Type}='CONCIERGERIE';
		} elsif ( $Row[2] eq 'COG_CHGT-GO4' || $Row[2] eq 'SO_COG-UO-5') {
			$Data{TR_Type}='GO4COLLAB';
		} elsif ( $Row[2] eq 'SO_COG-UO-2') {
			$Data{TR_Type}='ASSISTANCE TECHNIQUE';
		} elsif ( $Row[2] eq 'SO_COG-UO-3') {
			$Data{TR_Type}='MAJ SECU';
		} elsif ( $Row[2] eq 'SO_COG-UO-4') {
			$Data{TR_Type}='EVOL LOGICIELLES';  
		} elsif ( $Row[2] eq 'SO_RTC-JOUR-1') {
			$Data{TR_Type}='Comitologie et Veille Techno';  
		} elsif ( $Row[2] eq 'SO_RTC-JOUR-2') {
			$Data{TR_Type}='Expertise Technique';  
		} elsif ( $Row[2] eq 'SO_RTC-PAR') {
			$Data{TR_Type}='RTC sous traité';  
		} else 	{
			$Data{TR_Type} = $Row[2];
		}		
        
		$Data{TR_Option1} = $Row[3];
		$Data{TR_Option2} = $Row[4];
		$Data{TR_Option3} = $Row[10];
		$Data{TR_Option4} = $Row[11];
		$Data{TR_Perimetre} = $Row[5];
		$Data{TR_Description} = $Row[6];
        $Data{TR_DateDebut} = $Row[7];
		$Data{TR_DateFin} = $Row[8];
		$Data{TR_Commentaire} = $Row[9];
        push( @TRData, \%Data );
	}
		
	# no data found...
    if ( !@TRData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing $Param{ServiceType}",
        );
	}
	
	return @TRData;
}
	
sub AddTR {

	my ( $Self, %Param ) = @_;
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	
	
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

sub DelTR {

	my ( $Self, %Param ) = @_;
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TRID= $ParamObject->GetParam( Param => 'TRID' );
	
	my $Deleterow  = "DELETE from APA_TR where TR_ID=?";
	
	$Self->{DBObjectotrs}->Prepare(
        	SQL   => $Deleterow,
			Bind => [\$TRID],
			Limit => 1,
	);
	
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Result' =>1,
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

	use POSIX qw(strftime); 
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
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
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
	my $UserID = $Param{UserID};
	
	my $Customer = $ParamObject->GetParam( Param => 'Customer' );

	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $Annee;
	my $mois;
	my $jour;
	my $Dated;
	my $Datef;
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
	my $Addrow  = "INSERT INTO APA_TR (TR_CustID, TR_Caff, TR_Type, TR_Option1, TR_Option2, TR_Perimetre, TR_Description, TR_DateDebut, TR_DateFin, TR_Commentaire, TR_Option3, TR_Option4, create_time, create_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $Addrow,
				Bind => [\$Customer,\$Caff,\$Type,\$Option1,\$Option2,\$Perimeter,\$Description,\$Dated,\$Datef,\$Commentaire,\$Option3,\$Option4,\$createtime, \$UserID],
		);
	
	my $CheckID = "SELECT LAST_INSERT_ID()";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $CheckID,
		);
		
	my $InsertID;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$InsertID = $Row[0];
	}
	
	my %User = $UserObject->GetUserData(
			UserID => $UserID,
		);

	if ($Type eq 'SO_COG-UO-1' || $Type eq 'SO_COG-UO-2' || $Type eq 'SO_COG-UO-3' || $Type eq 'SO_COG-UO-4' || $Type eq 'SO_COG-UO-5' || $Type eq 'SO_COG-UO-6') {
		my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Création";
			
		my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";

		$Self->{DBObjectotrs}->Do(
			SQL   => $AddLog,
			Bind => [\$Message,\$InsertID],
		);
	}
		
		
	my $SQLOtrs = "SELECT TR_Caff, TR_Type, TR_Option1, TR_Option2, TR_Perimetre, TR_Description, TR_DateDebut, TR_DateFin, TR_Commentaire, TR_Option3, TR_Option4 from APA_TR where TR_ID = ?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
			Bind => [\$InsertID]
	);
	
	my $JSONString;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my $TR_Type;
		if ($Row[1] eq 'MCO_P-BAS') {
			$TR_Type='PACK_BASIC';
		} elsif ($Row[1] eq 'MCO_P-ESS') {
			$TR_Type='PACK_ESSENTIEL';
		} elsif ($Row[1] eq 'MCO_P-PRE') {
			$TR_Type='PACK_PREMIER';
		} elsif ($Row[1] eq 'MCO_P-GLD') {
			$TR_Type='PACK_GOLD';
		} elsif ($Row[1] eq 'COG_GEST-CHGT' || $Row[1] eq 'COG_CHGT-INFRA' || $Row[1] eq 'SO_COG-UO-1') {
			$TR_Type='INFRA';
		} elsif ( $Row[1] eq 'COG_CHGT-CONC' || $Row[1] eq 'SO_COG-UO-6') {
			$TR_Type='CONCIERGERIE';
		} elsif ( $Row[1] eq 'COG_CHGT-GO4' || $Row[1] eq 'SO_COG-UO-5') {
			$TR_Type='GO4COLLAB';
		} elsif ( $Row[1] eq 'SO_COG-UO-2') {
			$TR_Type='ASSISTANCE TECHNIQUE';
		} elsif ( $Row[1] eq 'SO_COG-UO-3') {
			$TR_Type='MAJ SECU';
		} elsif ( $Row[1] eq 'SO_COG-UO-4') {
			$TR_Type='EVOL LOGICIELLES';  
		} else 	{
			$TR_Type = $Row[1];
		}		
		
		$JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Caff' => $Row[0],
				'Type' => $TR_Type,
				'Option1' => $Row[2],
				'Option2' => $Row[3],
				'Perimeter' => $Row[4],
				'Description' => $Row[5],
				'DateDebut' => $DateDebut,
				'DateFin' => $DateFin,
				'Commentaire' => $Row[8],
				'InsertID' => $InsertID,
				'Option3' => $Row[9],
				'Option4' => $Row[10],
				},
		);
		
	}
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper($JSONString);
	
	
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);	

}

sub SelectTR {

	my ( $Self, %Param ) = @_;
			
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TypeTR= $ParamObject->GetParam( Param => 'Type' );
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
	
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'TypeTR' =>$TypeTR,
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

sub SelectPack {
	my ( $Self, %Param ) = @_;
			
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $Pack= $ParamObject->GetParam( Param => 'Pack' );
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
		
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Pack' =>$Pack,
				'TR_ID' =>$TR_ID,
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

sub ApplyTR {

	 my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID!",
        );
        return;
    }

	use POSIX qw(strftime); 
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
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
	my $UserID = $Param{UserID};

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

	# $Kernel::OM->Get('Kernel::System::Log')->Log(
            # Priority => 'error',
            # Message  =>"$Dated:$TR_ID",
    # );
	
	
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
	
	
	if ($Type eq 'INFRA') {
		$Type='SO_COG-UO-1';
	} elsif ($Type eq 'ASSISTANCE TECHNIQUE') {
			$Type='SO_COG-UO-2';
	} elsif ($Type eq 'MAJ SECU') {
			$Type='SO_COG-UO-3';
	} elsif ($Type eq 'EVOL LOGICIELLES') {
			$Type='SO_COG-UO-4';
	} elsif ($Type eq 'GO4COLLAB') {
			$Type='SO_COG-UO-5';
	} elsif ($Type eq 'CONCIERGERIE') {
			$Type='SO_COG-UO-6';
	}
	my $changetime=strftime "%Y-%m-%d", localtime;
	my $Updaterow  = "UPDATE APA_TR SET TR_Caff=?, TR_Type=?, TR_Option1=?, TR_Option2=?, TR_Perimetre=?, TR_Description=?, TR_DateDebut=?, TR_DateFin=?, TR_Commentaire=?, TR_Option3=?, TR_Option4=?, change_time=?, change_by=? WHERE TR_ID=?";
	
	$Self->{DBObjectotrs}->Prepare(
				SQL   => $Updaterow,
				Bind => [\$Caff,\$Type,\$Option1,\$Option2,\$Perimeter,\$Description,\$Dated,\$Datef,\$Commentaire,\$Option3,\$Option4, \$changetime, \$UserID,\$TR_ID],
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

sub DisableUO {

	my ( $Self, %Param ) = @_;
		
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	my $UserID = $Param{UserID};
		
	my $DisableUO  = "UPDATE APA_TR SET TR_valid_id=0 where TR_ID=?";
	
	$Self->{DBObjectotrs}->Do(
        	SQL   => $DisableUO,
			Bind => [\$TR_ID],
	);
	
	my %User = $UserObject->GetUserData(
		UserID => $UserID,
	);
	
	my $SQLAbonnement = "SELECT TR_Log from APA_TR WHERE TR_ID=?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLAbonnement,
			Bind   => [\$TR_ID],
	);

	my $TR_Log;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$TR_Log = $Row[0];
	}

	my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Désactivation de la Banque d\'UO"."\r".$TR_Log;
			
	my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";

	$Self->{DBObjectotrs}->Do(
		SQL   => $AddLog,
		Bind => [\$Message,\$TR_ID],
	);
		
	my $JSONString = $LayoutObject->JSONEncode(
			Data => {
				'Result' =>1,
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
