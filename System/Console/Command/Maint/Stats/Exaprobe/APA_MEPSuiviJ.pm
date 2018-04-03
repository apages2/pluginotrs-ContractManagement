# --
# Kernel/System/Console/Command/Maint/Stats/Exaprobe/APA_MEPSuiviJ.pm - core module
# Copyright (C) (2018) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Stats::Exaprobe::APA_MEPSuiviJ;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

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

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Synchronise Data MEP Sage/OTRS and Calculates MEP statistics Daily');

    $Self->AddOption(
        Name        => 'year',
        Description => "Forces data synchronization for one year from Sage to OTRS.",
        Required    => 0,
        HasValue    => 0,
        ValueRegex  => qr/\d{4}/smx,
    );
	
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

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;
	use POSIX qw(strftime);
	
	my $NbCaffActualYear;
	my $NbMEPActualYear;
	my $NbCaffNextYear;
	my $NbMEPNextYear;
	my $DE;
	my $NbEnrStatJ=0;
	my $Offset=0;
	my $NbMEPNextYear1d, my $NbMEPActualYear1d, my $NbCaffNextYear1d, my $NbCaffActualYear1d;
	my $AvgCaff1d, my $AvgMEP1d;
	
    $Self->Print("<yellow>Synchronise Data MEP Sage/OTRS...</yellow>\n");
	
	my @listeDate = localtime;
	my $Date = strftime "%Y-%m-%d %H:%M:%S", localtime;
	my $Year = $Self->GetOption('year');
	
	
	# Calcul du nombre de dossier saisie dans Sage et du nombre de MEP terminé dans OTRS pour l'année saisie ou l'année en cours
	if ($Year) {
		$DE = 'DE'.substr($Year, 2, 4);
		
	} else {
		$DE = strftime "%y", localtime;
		my $DENext = $DE-1;
		$DENext = $Self->{DBObjectsage}->Quote('DE'.$DENext.'%');
		$DE = $Self->{DBObjectsage}->Quote('DE'.$DE.'%');
		
		my $SQLCaffNext = "select count(distinct DO_Piece) from F_DOCLIGNE WHERE DO_Piece like ? and (AR_Ref like 'CONC_%' OR AR_ref like 'PACK_%' OR AR_Ref like 'SO_%' OR AR_Ref like 'PRO_SUP%' OR AR_Ref like 'SUPINF%' OR AR_Ref like 'RTC%' OR AR_Ref like 'COG%')";
		$Self->{DBObjectsage}->Prepare(
			SQL  => $SQLCaffNext, 
			Bind => [\$DENext]
		);
	
		while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
			$NbCaffNextYear = $Row[0];
		}
		
	
		my $SQLMEPNext = "select count(distinct EnrIDSage) from APA_contract_mep where EnrIDSage like ? and avancement=100";
			$Self->{DBObjectotrs}->Prepare(
				SQL  => $SQLMEPNext,
				Bind => [\$DENext]
			);
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
			$NbMEPNextYear = $Row[0];
		}	
		
	}
	
	# Calcul du nombre de dossier saisie dans Sage et du nombre de MEP terminé dans OTRS pour l'année saisie ou l'année N-1
	
	my $SQLCaffActual = "select count(distinct DO_Piece) from F_DOCLIGNE WHERE DO_Piece like ? and (AR_Ref like 'CONC_%' OR AR_ref like 'PACK_%' OR AR_Ref like 'SO_%' OR AR_Ref like 'PRO_SUP%' OR AR_Ref like 'SUPINF%' OR AR_Ref like 'RTC%' OR AR_Ref like 'COG%')";
		$Self->{DBObjectsage}->Prepare(
			SQL  => $SQLCaffActual,
			Bind => [\$DE]
		);
	
	while ( my @Row = $Self->{DBObjectsage}->FetchrowArray() ) {
		$NbCaffActualYear = $Row[0];
	}
		
	my $SQLMEPActual = "select count(distinct EnrIDSage) from APA_contract_mep where EnrIDSage like ? and avancement=100";
		$Self->{DBObjectotrs}->Prepare(
			SQL  => $SQLMEPActual,
			Bind => [\$DE]
		);
	
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbMEPActualYear = $Row[0];
	}
	# $Kernel::OM->Get('Kernel::System::Log')->Log(
           # Priority => 'error',
           # Message  => $DEOtrs, 
    # );
	
	$Self->Print("<yellow>Calculates MEP statistics Daily...</yellow>\n");
	
	# Calcul du nombre de dossiers Saisie par l'adv et traité par les CM ce jour
	
	my $SQLOtrsCountEnr = "select count(IDMepStatJ) from APA_mep_statJ";
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrsCountEnr
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbEnrStatJ = $Row[0];
	}
	
	$Offset=$NbEnrStatJ-1;
	
	my $SQLOtrs1d = "select NextYearCaff, NextYearMEP, ActualYearCaff, ActualYearMEP from APA_mep_statJ LIMIT 1 OFFSET ".$Offset;
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrs1d
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbCaffNextYear1d = $Row[0];
		$NbMEPNextYear1d = $Row[1];
		$NbCaffActualYear1d = $Row[2];
		$NbMEPActualYear1d = $Row[3];
	}
	
	# $Kernel::OM->Get('Kernel::System::Log')->Log(
           # Priority => 'error',
           # Message  => $NbCaffNextYear1d, 
    # );
	
	$AvgCaff1d = ($NbCaffNextYear-$NbCaffNextYear1d)+ ($NbCaffActualYear-$NbCaffActualYear1d);
	$AvgMEP1d = ($NbMEPNextYear-$NbMEPNextYear1d) + ($NbMEPActualYear-$NbMEPActualYear1d);	
		
	# Insert des données dans la base de donnée OTRS
	
	my $SQLOtrs = "insert into APA_mep_statJ (Date, NextYearCaff, ActualYearCaff, NextYearMEP, ActualYearMEP, AvgCaff1d, AvgMEP1d) VALUES (?,?,?,?,?,?,?)";
		$Self->{DBObjectotrs}->Prepare(
			SQL  => $SQLOtrs,
			Bind => [\$Date,\$NbCaffNextYear, \$NbCaffActualYear, \$NbMEPNextYear, \$NbMEPActualYear, \$AvgCaff1d, \$AvgMEP1d]
		);
	
	
    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}