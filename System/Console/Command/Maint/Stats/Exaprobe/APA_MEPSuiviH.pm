# --
# Kernel/System/Console/Command/Maint/Stats/Exaprobe/APA_MEPSuiviH.pm - core module
# Copyright (C) (2018) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Stats::Exaprobe::APA_MEPSuiviH;

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

    $Self->Description('Calculates MEP statistics Weekly');

	# get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

	$Self->{UserDBSage} = $ConfigObject->Get('ContractManagement::Config')->{UserDBSage};
	$Self->{PasswordDBSage} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBSage};
	$Self->{UserDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{UserDBOTRS};
	$Self->{PasswordDBOTRS} = $ConfigObject->Get('ContractManagement::Config')->{PasswordDBOTRS};
	
	# create new db connect if DSN is given
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
	
	my $NbEnrStatJ=0;
	my $NbCaffNextYear, my $NbCaffActualYear, my $NbMEPNextYear, my $NbMEPActualYear;
	my $OffsetLast=0, my $Offset7d=0, my $Offset30d=0;
	my $AvgCaff7d, my $AvgCaff30d, my $AvgMEP7d, my $AvgMEP30d;
	my $NbCaffNextYear7d , my $NbCaffActualYear7d, my $NbMEPNextYear7d, my $NbMEPActualYear7d;
	my $NbCaffNextYear30d , my $NbCaffActualYear30d, my $NbMEPNextYear30d, my $NbMEPActualYear30d;
	
	
    $Self->Print("<yellow>Calculates MEP statistics Weekly...</yellow>\n");
	
	my @listeDate = localtime;
	my $Date = strftime "%Y-%m-%d %H:%M:%S", localtime;
	
	#Cherche la dernière ligne de la base de donnée et les offset pour les stats à J-5 et J-30
	
	my $SQLOtrsCountEnr = "select count(IDMepStatJ) from APA_mep_statJ";
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrsCountEnr
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbEnrStatJ = $Row[0];
	}
	
	$OffsetLast=$NbEnrStatJ-1;
	$Offset7d=$NbEnrStatJ-5;
	$Offset30d=$NbEnrStatJ-30;
	
	if ($Offset7d < 0) {
		$Offset7d=0;
	}
	
	if ($Offset30d < 0) {
		$Offset30d=0;
	}
	# Recupère les nombres de dossiers a J-1
	
	my $SQLOtrs = "select NextYearCaff,NextYearMEP,ActualYearCaff, ActualYearMEP from APA_mep_statJ LIMIT 1 OFFSET ".$OffsetLast;
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrs
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbCaffNextYear = $Row[0];
		$NbMEPNextYear = $Row[1];
		$NbCaffActualYear = $Row[2];
		$NbMEPActualYear = $Row[3];
	}
	
	# Recupère les nombres de dossiers a J-5
	
	my $SQLOtrs7d = "select NextYearCaff,NextYearMEP,ActualYearCaff, ActualYearMEP from APA_mep_statJ LIMIT 1 OFFSET ".$Offset7d;
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrs7d
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbCaffNextYear7d = $Row[0];
		$NbMEPNextYear7d = $Row[1];
		$NbCaffActualYear7d = $Row[2];
		$NbMEPActualYear7d = $Row[3];
	}
	
	# Recupère les nombres de dossiers a J-30
	
	my $SQLOtrs30d = "select NextYearCaff,NextYearMEP,ActualYearCaff, ActualYearMEP from APA_mep_statJ  LIMIT 1 OFFSET ".$Offset30d;
	$Self->{DBObjectotrs}->Prepare(
		SQL  => $SQLOtrs30d
	);

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$NbCaffNextYear30d = $Row[0];
		$NbMEPNextYear30d = $Row[1];
		$NbCaffActualYear30d = $Row[2];
		$NbMEPActualYear30d = $Row[3];
	}
	
	# Calcul les dossiers traités en J-5 et J-30
		
	# $Kernel::OM->Get('Kernel::System::Log')->Log(
           # Priority => 'error',
           # Message  => $NbMEPNextYear30d, 
    # );
	
	$AvgCaff7d= ($NbCaffNextYear-$NbCaffNextYear7d)+($NbCaffActualYear-$NbCaffActualYear7d);
	$AvgMEP7d= ($NbMEPNextYear-$NbMEPNextYear7d)+($NbMEPActualYear-$NbMEPActualYear7d);
	$AvgCaff30d= ($NbCaffNextYear-$NbCaffNextYear30d)+($NbCaffActualYear-$NbCaffActualYear30d);
	$AvgMEP30d= ($NbMEPNextYear-$NbMEPNextYear30d)+($NbMEPActualYear-$NbMEPActualYear30d);
	
	
	
	my $SQLOtrsStatH = "insert into APA_mep_statH (Date, CaffNextYear, CaffActualYear, MEPNextYear, MEPActualYear, AvgCaff7d, AvgMEP7d, AvgCaff30d, AvgMEP30d) VALUES (?,?,?,?,?,?,?,?,?)";
		$Self->{DBObjectotrs}->Prepare(
			SQL  => $SQLOtrsStatH,
			Bind => [\$Date,\$NbCaffNextYear, \$NbCaffActualYear, \$NbMEPNextYear, \$NbMEPActualYear, \$AvgCaff7d, \$AvgMEP7d, \$AvgCaff30d,  \$AvgMEP30d]
		);
	
	
    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}