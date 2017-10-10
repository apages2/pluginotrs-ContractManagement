# --
# Output/HTML/Exaprobe/APA_TicketUO.pm - frontend module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Exaprobe::APA_TicketUO;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Web::Request'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );
	
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

sub Run {
    my ( $Self, %Param ) = @_;

	use POSIX;
    # load required objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	
	my $UserID = $Self->{UserID};
	
	# get the group id which is allowed to Edit the UO
	my $UOGroupID = $GroupObject->GroupLookup(
		Group => $Self->{Group},
	);
	
	my %GroupList = $GroupObject->PermissionUserGroupGet(
        UserID => $UserID,
        Type    => 'ro',  # ro|move_into|priority|create|rw
    );
	
	
	my %RoleList = $GroupObject->PermissionGroupRoleGet(
        GroupID => $UOGroupID,
        Type    => 'ro',  # ro|move_into|priority|create|rw
    );
	
	my $IsAuth;
	for my $RoleID ( sort keys %RoleList ) {
		my %RoleUserList = $GroupObject->PermissionRoleUserGet(
			RoleID => $RoleID,
		);
		
		if ($RoleUserList{$UserID}) {
			$IsAuth =1 ;
		}
		
	}
	
	# get template name
    my $Templatename = $Param{TemplateFile} || '';

    # return if template is empty
    return 1 if !$Templatename;

    # return if not in AgentTicketZoom
    #return 1 if $Templatename ne 'AgentTicketZoom';
	# return 1 if $Templatename ne 'AgentTicketClose';
	
    # get the TicketID
    $Self->{TicketID} = $ParamObject->GetParam( Param => 'TicketID' );

	
    # return if TicketID is empty
    return if !$Self->{TicketID};

	my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Self->{TicketID},
        DynamicFields => 0, 
        Silent        => 0,
	);
	
	
	my $SQLUO = " SELECT sum(time_unit) FROM time_accounting where ticket_id=?";

    # return if result set is empty
    return if !$DBObject->Prepare(
        SQL   => $SQLUO,
        Bind  => [ \$Self->{TicketID} ],
        Limit => 1,
    );
	
	my %Decompt;
    # process result set
    while ( my @Row = $DBObject->FetchrowArray() ) {

        # initialize undefined data sources
        if ( defined $Row[0] ) {
            $Decompt{UOConseil} = ($Row[0]/30);
        }
        else {
            $Decompt{UOConseil} = 0;
        }
    }

    # format and calculate remaining information
    my $UOConseil  = ceil($Decompt{UOConseil});
	
	
	# main sql statement with mandatory data
    my $SQL = " 
		SELECT TR_Option1, TR_Option2, TR_DateFin, TR_Caff
        FROM    APA_TR
        WHERE   (TR_Type='COG_GEST-CHGT' OR TR_Type='COG_CHGT-INFRA' OR TR_Type = 'COG_CHGT-CONC' OR TR_Type = 'COG_CHGT-GO4' OR TR_Type = 'SO_COG-UO-1' OR TR_Type = 'SO_COG-UO-2' OR TR_Type = 'SO_COG-UO-3' OR TR_Type = 'SO_COG-UO-4' OR TR_Type = 'SO_COG-UO-5' OR TR_Type = 'SO_COG-UO-6') AND TR_valid_id=1 AND TR_CustID = ?";

    # return if result set is empty
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Ticket{CustomerID} ],
    );

    # process result set
	my @ContractData;
    while ( my @Row = $DBObject->FetchrowArray() ) {
	my %Data;
        # initialize undefined data sources
        if ( defined $Row[0] ) {
            $Data{ContractQuota} = sprintf '%.1f', $Row[0];
        }
        else {
            $Data{ContractQuota} = sprintf '%.1f', 0;
        }
        if ( defined $Row[1] ) {
            $Data{AvailableQuota} = sprintf '%.1f',$Row[1];
        }
        else {
            $Data{AvailableQuota} = sprintf '%.1f',0;
        }
		$Data{DateFin} = $Row[2];
		$Data{Caff} = $Row[3];
		$Data{Decompt} = $UOConseil;
		
		push( @ContractData, \%Data );
    }

    # return if config does not allow widget display if empty customer quota
    if (
        !@ContractData
        && $ConfigObject->Get('Pool::Preferences::EmptyContractDisplay') eq 'Non'
        )
    {
        return;
    }
	
	for my $Contract (@ContractData) {
		$LayoutObject->Block(
			Name => 'Contract',
			Data => $Contract,
		);
	}
		

    
	# set template and information values
	my $Snippet = $LayoutObject->Output(
		TemplateFile => 'Exaprobe/APA_TicketUO',
		Data         => {
		}
	);

	# get the position for the output, default to bottom
	my $Position = $ConfigObject->Get('Pool::Preferences::Position') || 'bottom';

	if ( $GroupList{$UOGroupID} || $IsAuth ) {
		# add information according to the requested position
		if ( $Position eq 'top' ) {
			${ $Param{Data} } =~ s{(<div \s+ class="SidebarColumn">)}{$1 $Snippet}xsm;
		}
		else {
			${ $Param{Data} } =~ s{(</div> \s+ <div \s+ class="ContentColumn)}{ $Snippet $1 }xms;
		}
	}

    # done, return information
    return ${ $Param{Data} };

}

1;
