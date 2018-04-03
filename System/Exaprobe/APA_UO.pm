# --
# Kernel/System/Exaprobe/APA_UO.pm - core module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Exaprobe::APA_UO;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Group',
	'Kernel::System::CustomerUser',
    'Kernel::System::User',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
	'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::Exaprobe::APA_UO - Library POOL UO

=head1 SYNOPSIS

POOL UO Librairie

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $UOObject = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_UO');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    # my $Self = {%Param};
	my $Self = {};
    bless( $Self, $Type );

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

	$Self->{Group} = $ConfigObject->Get('Pool::Config')->{Group};
	
    return $Self;
}

sub GetUO {


	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');	
	
	
	
	my $SQLOtrs = "SELECT TR_ID, TR_CustID, TR_Caff, TR_Option2, TR_DateFin, TR_IC, TR_Montant, UO_CustomerMail, TR_DateDebut from APA_TR where (TR_Type='COG_GEST-CHGT' OR TR_Type='COG_CHGT-INFRA' OR TR_Type = 'COG_CHGT-CONC' OR TR_Type = 'COG_CHGT-GO4' OR TR_Type = 'SO_COG-UO-1' OR TR_Type = 'SO_COG-UO-2' OR TR_Type = 'SO_COG-UO-3' OR TR_Type = 'SO_COG-UO-4' OR TR_Type = 'SO_COG-UO-5' OR TR_Type = 'SO_COG-UO-6') AND TR_valid_id=1 ORDER BY TR_CustID";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
	);



	my @UOData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		
		my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
        CustomerID => $Row[1]
		);
		
		
		$Data{TR_ID} = $Row[0];
		$Data{TR_Customer} = $CustomerCompany{CustomerCompanyName};
        $Data{TR_Caff} = $Row[2];
		$Data{TR_Option2} = $Row[3];
		$Data{TR_DateFin} = $Row[4];
		$Data{TR_IC} = $Row[5];
		$Data{TR_Montant} = $Row[6];
		$Data{UO_CustomerMail} = $Row[7];
		$Data{TR_DateDebut} = $Row[8];
        push( @UOData, \%Data );
	}
		
		
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper(@UOData);
	# no data found...
    if ( !@UOData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing POOL UO",
        );
		return;
	} else {
		for my $DataItem (@UOData) {
			$LayoutObject->Block(
				Name => 'LineUO',
				Data => $DataItem,
			);
		}
	}
	
	return 1;
}

sub GetUOZoom {


	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');	
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	 
	my $TR_ID= $ParamObject->GetParam( Param => 'TRID' );
	
	my $UserID = $Param{UserID};
	
	# get the group id which is allowed to Edit the UO
	my $UOGroupID = $GroupObject->GroupLookup(
		Group => $Self->{Group},
	);
	
	my %GroupList = $GroupObject->PermissionUserGroupGet(
        UserID => $UserID,
        Type    => 'rw',  # ro|move_into|priority|create|rw
    );
	
	
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

	my $SQLOtrs = "SELECT TR_CustID, TR_Option2, TR_DateFin, TR_IC, TR_Montant, UO_CustomerMail, TR_Caff, TR_DateDebut, TR_Log from APA_TR where TR_ID=?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrs,
			Bind => [\$TR_ID],
	);

	my @UOData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		
		my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
        CustomerID => $Row[0]
		);
		
		
		$Data{TR_ID} = $TR_ID;
		$Data{TR_Customer} = $CustomerCompany{CustomerCompanyName};
		$Data{TR_Option2} = $Row[1];
		$Data{TR_DateFin} = $Row[2];
		$Data{TR_IC} = $Row[3];
		$Data{TR_Montant} = $Row[4];
		$Data{UO_CustomerMail} = $Row[5];
		$Data{TR_Caff} = $Row[6];
		
		$Data{TR_DateDebut} = $Row[7];
		$Data{TR_Log} = $Row[8];
        push( @UOData, \%Data );
	}
		
	# no data found...
    if ( !@UOData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing POOL UO",
        );
		return;
	} else {
		if ( $GroupList{$UOGroupID} || $IsAdmin ) {
			$LayoutObject->Block(
					Name => 'BoutonAdmin',
				);
			for my $DataItem (@UOData) {
				$LayoutObject->Block(
					Name => 'LineUOAdmin',
					Data => $DataItem,
				);
			}
		} else {
			for my $DataItem (@UOData) {
				$LayoutObject->Block(
					Name => 'LineUOAgent',
					Data => $DataItem,
				);
			}
		}
	}
	
	my $SQLOtrsInfoDecompte = "SELECT ticket_id, UO_unit, date, owner, subject, id from APA_TR_UO_decompte where TR_ID=? ORDER BY date DESC";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrsInfoDecompte,
			Bind => [\$TR_ID]
	);



	my @UOZoomData;

	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		my %Data;
		
		my %User = $UserObject->GetUserData(
			UserID => $Row[3],
		);
		
		my %Ticket = $TicketObject->TicketGet(
			TicketID      => $Row[0],
			DynamicFields => 1,
			Silent        => 0,         # Optional, default 0. To suppress the warning if the ticket does not exist.
		);
		
		# $Kernel::OM->Get('Kernel::System::Log')->Dumper(%Ticket);
		$Data{ticket_id} = $Row[0];
		$Data{ticket_number} = $Ticket{TicketNumber};
		$Data{UO_unit} = $Row[1];
        $Data{date} = $Row[2];
		$Data{owner} = $User{UserFirstname}.' '.$User{UserLastname};
		$Data{Subject} = $Row[4];
		$Data{OwnerID} = $Row[3];
		$Data{ID} = $Row[5];
		
        push( @UOZoomData, \%Data );
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
		
	# no data found...
    if ( !@UOZoomData) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Nothing UO ZOOM",
        );
		return;
	} else {
	
		if ( $GroupList{$UOGroupID} || $IsAdmin ) {
		
			for my $DataItem (@UOZoomData) {
				$LayoutObject->Block(
					Name => 'LineUOZoomAdmin',
					Data => $DataItem,
				);
				for my $DataItem3 (@UserData) {
					$LayoutObject->Block(
						Name => 'Responsible',
						Data => $DataItem3,
					);
				}
			}
			
			
		
		} else {
		
			for my $DataItem (@UOZoomData) {
				$LayoutObject->Block(
					Name => 'LineUOZoomAgent',
					Data => $DataItem,
				);
			}
		}
	}
	
	return 1;
}

sub GetUOList {

	use POSIX 'strftime';
	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');	
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	 
	my $TR_IDs= $Param{TR_ID};
	my $Limit= $Param{Limit};
	my $UserID = $Param{UserID};
	my $UOCreateTimeNewerDate= $Param{UOCreateTimeNewerDate};
	my $UOCreateTimeOlderDate= $Param{UOCreateTimeOlderDate};
	
	# get the group id which is allowed to Edit the UO
	my $UOGroupID = $GroupObject->GroupLookup(
		Group => $Self->{Group},
	);
	
	my %GroupList = $GroupObject->PermissionUserGroupGet(
        UserID => $UserID,
        Type    => 'rw',  # ro|move_into|priority|create|rw
    );
	
	
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
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper($TR_IDs);
		
	my @UOZoomData;
	
    for my $TR_ID (  @{$TR_IDs} ) {	
		# $Kernel::OM->Get('Kernel::System::Log')->Log(
            # Priority => 'error',
            # Message  => $TR_ID,
        # );
		
		my @UODetail = $Self->GetUODetail(
				TR_ID=>[$TR_ID],
				UserID=>1
			);
		
		my $SQLOtrsInfoDecompte = "SELECT ticket_id, UO_unit, DATE_FORMAT(date, \"%Y-%m-%d\"), owner, subject, id, TR_ID from APA_TR_UO_decompte ";
		
		if ($UOCreateTimeNewerDate || $UOCreateTimeOlderDate || $TR_ID) {
		
			$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " WHERE ";
			
			if ($TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . "TR_ID=".$TR_ID;
			}
				
			if ($UOCreateTimeNewerDate && $UOCreateTimeOlderDate && $TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " AND date BETWEEN \"".$UOCreateTimeNewerDate."\" AND \"".$UOCreateTimeOlderDate."\"";
			}	elsif ($UOCreateTimeNewerDate && $UOCreateTimeOlderDate && !$TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . "date BETWEEN \"".$UOCreateTimeNewerDate."\" AND \"".$UOCreateTimeOlderDate."\"";
			}
		}
		if ($Limit) {
		
			$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " LIMIT 0,".$Limit;
		}
		
		# get data
		$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrsInfoDecompte,
		);
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
			my %Data;
			
			
			my %User = $UserObject->GetUserData(
				UserID => $Row[3],
			);
			
			my %Ticket = $TicketObject->TicketGet(
				TicketID      => $Row[0],
				DynamicFields => 1,
				Silent        => 0,         # Optional, default 0. To suppress the warning if the ticket does not exist.
			);
			
			$Data{TR_ID} = $UODetail[0]{TR_Caff};
			$Data{date} = $Row[2];
			$Data{ticket_id} = $Row[0];
			$Data{ticket_number} = $Ticket{TicketNumber};
			$Data{UO_unit} = $Row[1];
			
			$Data{owner} = $User{UserFirstname}.' '.$User{UserLastname};
			$Data{Subject} = $Row[4];
			$Data{OwnerID} = $Row[3];
			$Data{ID} = $Row[5];
			
			push( @UOZoomData, \%Data );
		}
	}
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper(@UOZoomData);
	return @UOZoomData;
}

sub GetUODetail {

	use POSIX 'strftime';
	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');	
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	 
	my $TR_IDs= $Param{TR_ID};
	my $Limit= $Param{Limit};
	my $UserID = $Param{UserID};
	my $UODetailFinNewerDate= $Param{UODetailFinNewerDate};
	my $UODetailFinOlderDate= $Param{UODetailFinOlderDate};
	
	# get the group id which is allowed to Edit the UO
	my $UOGroupID = $GroupObject->GroupLookup(
		Group => $Self->{Group},
	);
	
	my %GroupList = $GroupObject->PermissionUserGroupGet(
        UserID => $UserID,
        Type    => 'rw',  # ro|move_into|priority|create|rw
    );
	
	
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
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper($TR_IDs);
		
	my @UODetailData;
	
    for my $TR_ID (  @{$TR_IDs} ) {	
		# $Kernel::OM->Get('Kernel::System::Log')->Log(
            # Priority => 'error',
            # Message  => $TR_ID,
        # );
		
		my $SQLOtrsInfoDecompte = "SELECT TR_ID, TR_CustID, TR_Option2, DATE_FORMAT(TR_DateFin, \"%Y-%m-%d\"), TR_Caff, TR_Montant, TR_IC from APA_TR ";
		
		if ($UODetailFinNewerDate || $UODetailFinOlderDate || $TR_ID) {
		
			$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " WHERE ";
			
			if ($TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . "TR_ID=".$TR_ID;
			}
				
			if ($UODetailFinNewerDate && $UODetailFinOlderDate && $TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " AND TR_DateFin BETWEEN \"".$UODetailFinNewerDate."\" AND \"".$UODetailFinOlderDate."\"";
			}	elsif ($UODetailFinNewerDate && $UODetailFinOlderDate && !$TR_ID) {
				$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . "TR_DateFin BETWEEN \"".$UODetailFinNewerDate."\" AND \"".$UODetailFinOlderDate."\"";
			}
		}
		if ($Limit) {
		
			$SQLOtrsInfoDecompte = $SQLOtrsInfoDecompte . " LIMIT 0,".$Limit;
		}
		
		# get data
		$Self->{DBObjectotrs}->Prepare(
			SQL   => $SQLOtrsInfoDecompte,
		);
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
			my %Data;
			
			# $Kernel::OM->Get('Kernel::System::Log')->Dumper(%Ticket);
			$Data{TR_ID} = $Row[0];
			$Data{TR_CustID} = $Row[1];
			$Data{TR_Option2} = $Row[2];
			$Data{TR_DateFin} = $Row[3];

			$Data{TR_Caff} = $Row[4];
			
			$Data{TR_Montant} = sprintf("%.2f Euros",$Row[5]);
			$Data{TR_IC} = $Row[6];
			
			push( @UODetailData, \%Data );
		}
	}
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper(@UODetailData);
	return @UODetailData;
}

sub UpdateUO {

	use POSIX qw(strftime); 
	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $ID= $ParamObject->GetParam( Param => 'ID' );
	my $Value= $ParamObject->GetParam( Param => 'Value' );
	my $Type= $ParamObject->GetParam( Param => 'Type' );
	my $UserID = $Param{UserID};
	my $Date= $ParamObject->GetParam( Param => 'Date' );
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $Annee;
	my $mois;
	my $jour;
	if ($Date){
		if( $Date =~ m/\// ) {
			if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
				($mois,$jour,$Annee)  = split /\//, $Date;
			} elsif ($Preferences{UserLanguage} eq 'ja') {
				($Annee,$mois,$jour)  = split /\//, $Date;
			} else {
				($jour,$mois,$Annee)  = split /\//, $Date;
			}
			$Value = $Annee.'-'.$mois.'-'.$jour;
		} elsif( $Date =~ m/\./ ) {
			if ($Preferences{UserLanguage} eq 'zh_CN' || $Preferences{UserLanguage} eq 'zh_TW') {
				($Annee,$mois,$jour) = split /\./, $Date ;
			} else {
				($jour,$mois,$Annee) = split /\./, $Date ;
			}
			$Value = $Annee.'-'.$mois.'-'.$jour;
		} 
	}

	my $Message;
	my $SQLUpdateUO;
	my $NewSolde;
	my $TR_ID;
	my $changetime=strftime "%Y-%m-%d", localtime;
	if ($Type eq 'Owner') {
		$SQLUpdateUO = "UPDATE APA_TR_UO_decompte SET owner=?, change_time=?, change_by=? WHERE id=?";
	} elsif ($Type eq 'Subject') {
		$SQLUpdateUO = "UPDATE APA_TR_UO_decompte SET subject=?, change_time=?, change_by=? WHERE id=?";
	} elsif ($Type eq 'UODateFin') {
		$SQLUpdateUO = "UPDATE APA_TR_UO_decompte SET date=?, change_time=?, change_by=? WHERE id=?";
	} elsif ($Type eq 'TRIC') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_IC=?, change_time=?, change_by=? WHERE TR_ID=?";
	} elsif ($Type eq 'TRDateDebut') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_DateDebut=?, change_time=?, change_by=? WHERE TR_ID=?";
	} elsif ($Type eq 'TRDateFin') {
		my %User = $UserObject->GetUserData(
			UserID => $UserID,
		);
		
		my $SQLLog = "SELECT TR_Log,DATE_FORMAT(TR_DateFin,\"%Y-%m-%d\") from APA_TR WHERE TR_ID=?";

		# get data
		$Self->{DBObjectotrs}->Prepare(
				SQL   => $SQLLog,
				Bind   => [\$ID],
		);

		my $TR_Log;
		my $OldDate;
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
			$TR_Log = $Row[0];
			$OldDate = $Row[1];
		}
	
		$Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Report de la Date d'echeance ".$OldDate." => ".$Value."\r".$TR_Log;
				
		my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";

		$Self->{DBObjectotrs}->Do(
			SQL   => $AddLog,
			Bind => [\$Message,\$ID],
		);
		$SQLUpdateUO = "UPDATE APA_TR SET TR_DateFin=?, change_time=?, change_by=? WHERE TR_ID=?";
		
		
	} elsif ($Type eq 'TRmontant') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_Montant=?, change_time=?, change_by=? WHERE TR_ID=?";
	}  elsif ($Type eq 'TRCustomerMail') {
		$SQLUpdateUO = "UPDATE APA_TR SET UO_CustomerMail=?, change_time=?, change_by=? WHERE TR_ID=?";
	}  elsif ($Type eq 'TRSolde') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_Option2=?, change_time=?, change_by=? WHERE TR_ID=?";
	} elsif ($Type eq 'TRCaff') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_Caff=?, change_time=?, change_by=? WHERE TR_ID=?";
	} elsif ($Type eq 'TRLog') {
		$SQLUpdateUO = "UPDATE APA_TR SET TR_Log=?, change_time=?, change_by=? WHERE TR_ID=?";
	} elsif ($Type eq 'UODelete') {
	
		my $CheckInfoDecompte = "SELECT UO_unit, TR_ID from APA_TR_UO_decompte where id=?";

		$Self->{DBObjectotrs}->Prepare(
				SQL => $CheckInfoDecompte,
				Bind => [\$ID],
				Limit => 1
		);

		my $OldDecompte;
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
				$OldDecompte = $Row[0];
				$TR_ID = $Row[1];
		}
		
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

		$NewSolde = $UOSolde+$OldDecompte;
		
		my $SQLUpdateTR = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";

		$Self->{DBObjectotrs}->Do(
				SQL  => $SQLUpdateTR,
				Bind => [ \$NewSolde,\$TR_ID]
		);

		$SQLUpdateUO = "DELETE FROM APA_TR_UO_decompte WHERE ID=?";
		
		$Self->{DBObjectotrs}->Do(
				SQL  => $SQLUpdateUO,
				Bind => [ \$ID]
		);
	} elsif ($Type eq 'UOUnit') {

		my $CheckInfoDecompte = "SELECT UO_unit, TR_ID from APA_TR_UO_decompte where id=?";

		$Self->{DBObjectotrs}->Prepare(
				SQL => $CheckInfoDecompte,
				Bind => [\$ID],
				Limit => 1
		);

		my $OldDecompte;
		
		while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
				$OldDecompte = $Row[0];
				$TR_ID = $Row[1];
		}
		
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

		$NewSolde = $UOSolde+$OldDecompte-$Value;
		
		my $SQLUpdateTR = "UPDATE APA_TR SET TR_Option2=? WHERE TR_ID=?";

		$Self->{DBObjectotrs}->Do(
				SQL  => $SQLUpdateTR,
				Bind => [ \$NewSolde,\$TR_ID]
		);

		$SQLUpdateUO = "UPDATE APA_TR_UO_decompte SET UO_unit=? WHERE id=?";
	}

	$Self->{DBObjectotrs}->Do(
		SQL  => $SQLUpdateUO,
		Bind => [ \$Value, \$changetime, \$UserID,\$ID]
	);
				
	my $JSON = $LayoutObject->JSONEncode(
		Data => { 
		'UOSolde' => $NewSolde,
		'TR_ID' => $TR_ID,
		'Message' => $Message,
		},
	);

	return $LayoutObject->Attachment(
		ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
		Content     => $JSON,
		Type        => 'inline',
		NoCache     => 1,
	);
}

sub AddDecompte {

	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	
	my $Addrow  = "INSERT INTO APA_TR_UO_decompte (TR_ID) VALUES (?)";
	
	$Self->{DBObjectotrs}->Do(
				SQL   => $Addrow,
				Bind => [\$TR_ID],
		);
		
	my $CheckID = "SELECT LAST_INSERT_ID()";

    $Self->{DBObjectotrs}->Prepare(
		SQL   => $CheckID,
	);
	
	my $InsertID;
    while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
        $InsertID = $Row[0];
    }
	
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
		push @UserData, { RespFullName=>$RespTri, RespID=>$RespIDTri };
		
	}
	
	my $JSONString = $LayoutObject->JSONEncode(
		Data => {
			'InsertID' => $InsertID,
			'Responsable' =>\@UserData,
		},
	);
	   
	return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONString,
			Type        => 'inline',
			NoCache     => 1,
	);
	
}

sub RenewUO {
	use POSIX qw(strftime); 
	my ( $Self, %Param ) = @_;
	
	my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TR_ID= $ParamObject->GetParam( Param => 'TR_ID' );
	my $UserID = $Param{UserID};
	my $changetime=strftime "%Y-%m-%d", localtime;
	my $SQLUpdateUO = "UPDATE APA_TR SET TR_DateDebut = DATE_ADD(TR_DateDebut,INTERVAL 1 YEAR),change_time=?, change_by=? WHERE TR_ID=?";
	
	$Self->{DBObjectotrs}->Do(
		SQL  => $SQLUpdateUO,
		Bind => [\$changetime, \$UserID,\$TR_ID]
	);
	
	$SQLUpdateUO = "UPDATE APA_TR SET TR_DateFin = DATE_ADD(TR_DateFin,INTERVAL 1 YEAR),change_time=?, change_by=? WHERE TR_ID=?";
	
	$Self->{DBObjectotrs}->Do(
		SQL  => $SQLUpdateUO,
		Bind => [\$changetime, \$UserID,\$TR_ID]
	);
	
	my $UOLog = "SELECT TR_Log,DATE_FORMAT(TR_DateDebut,\"%Y-%m-%d\"),DATE_FORMAT(TR_DateFin,\"%Y-%m-%d\") from APA_TR WHERE TR_ID=?";

	# get data
	$Self->{DBObjectotrs}->Prepare(
			SQL   => $UOLog,
			Bind   => [\$TR_ID],
	);
	
	my $TR_Log;
	my $TR_DateD;
	my $TR_DateF;
	while ( my @Row = $Self->{DBObjectotrs}->FetchrowArray() ) {
		$TR_Log = $Row[0];
		$TR_DateD = $Row[1];
		$TR_DateF = $Row[2];
	}
	
	my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );
	
	my $Annee;
	my $mois;
	my $jour;
	my $DateD;
	my $DateF;
	
	($Annee,$mois,$jour)  = split /-/, $TR_DateD;
	if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
		$DateD = $mois.'/'.$jour.'/'.$Annee;
	} elsif ($Preferences{UserLanguage} eq 'ja') {
		$DateD = $Annee.'/'.$mois.'/'.$jour;
	} else {
		$DateD = $jour.'.'.$mois.'.'.$Annee;
	}
	
	($Annee,$mois,$jour)  = split /-/, $TR_DateF;
	if ($Preferences{UserLanguage} eq 'en' || $Preferences{UserLanguage} eq 'sw' || $Preferences{UserLanguage} eq 'uk') {
		$DateF = $mois.'/'.$jour.'/'.$Annee;
	} elsif ($Preferences{UserLanguage} eq 'ja') {
		$DateF = $Annee.'/'.$mois.'/'.$jour;
	} else {
		$DateF = $jour.'.'.$mois.'.'.$Annee;
	}
	
	
	my %User = $UserObject->GetUserData(
		UserID => $UserID,
	);

	my $Message= strftime("%Y-%m-%d", localtime)." ".$User{UserFirstname}. " ".$User{UserLastname}." : Renew avec Report"."\r".$TR_Log;
		
	my $AddLog  = "UPDATE APA_TR SET TR_Log=? WHERE TR_ID=?";
	
	$Self->{DBObjectotrs}->Do(
		SQL   => $AddLog,
		Bind => [\$Message,\$TR_ID],
	);
		
	my $JSON = $LayoutObject->JSONEncode(
		Data => { 
		'Message' => $Message,
		'TR_DateD' => $DateD,
		'TR_DateF' => $DateF,
		'TR_ID' => $TR_ID,
		},
	);

	return $LayoutObject->Attachment(
		ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
		Content     => $JSON,
		Type        => 'inline',
		NoCache     => 1,
	);
}
