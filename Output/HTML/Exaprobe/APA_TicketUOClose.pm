# --
# Output/HTML/Exaprobe/APA_TicketUOClose.pm - frontend module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Exaprobe::APA_TicketUOClose;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

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
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
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
	
    # get the TicketID
    $Self->{TicketID} = $ParamObject->GetParam( Param => 'TicketID' );

	# return if TicketID is empty
	if ( !$Self->{TicketID} ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No TicketID is given!'),
            Comment => Translatable('Please contact the administrator.'),
        );
    }
	
	my %Ticket = $TicketObject->TicketGet(
		TicketID      => $Self->{TicketID},
		DynamicFields => 0,
		Silent        => 0,
	);
	
	# get data
    my %Data = ();
	
	
	my $SQLUO = " SELECT sum(time_unit) FROM time_accounting where ticket_id=?";

    # return if result set is empty
    return if !$DBObject->Prepare(
        SQL   => $SQLUO,
        Bind  => [ \$Self->{TicketID} ],
        Limit => 1,
    );
	
    # process result set
    while ( my @Row = $DBObject->FetchrowArray() ) {

        # initialize undefined data sources
        if ( defined $Row[0] ) {
            $Data{UOConseil} = ($Row[0]/30);
        }
        else {
            $Data{UOConseil} = 0;
        }
    }

    # format and calculate remaining information
    my $UOConseil  = ceil($Data{UOConseil});
	
	my $SQL = " SELECT TR_ID, UO_unit FROM APA_TR_UO_decompte where ticket_id=?";

    # return if result set is empty
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Self->{TicketID} ],
        Limit => 1,
    );
	
	
	my @TRExist;
    # process result set
    while ( my @Row = $DBObject->FetchrowArray() ) {
		my %TRSelect;
        # initialize undefined data sources
        if ( defined $Row[0] ) {
            $TRSelect{ID} = $Row[0];
			$TRSelect{UO} = $Row[1];
			push( @TRExist, \%TRSelect );
        }
		else {
			$TRSelect{UOConseil} = $UOConseil;
			push( @TRExist, \%TRSelect );
		}
        
    }
	
	# $Kernel::OM->Get('Kernel::System::Log')->Log(
				# Priority => 'error',
				# Message  => $Ticket{CustomerID}
			# );
	
	my $SQLTR = "SELECT TR_ID, TR_Caff, TR_Description FROM APA_TR where (TR_Type='COG_GEST-CHGT' OR TR_Type='COG_CHGT-INFRA' OR TR_Type = 'COG_CHGT-CONC' OR TR_Type = 'COG_CHGT-GO4' OR TR_Type = 'SO_COG-UO-1' OR TR_Type = 'SO_COG-UO-2' OR TR_Type = 'SO_COG-UO-3' OR TR_Type = 'SO_COG-UO-4' OR TR_Type = 'SO_COG-UO-5' OR TR_Type = 'SO_COG-UO-6') AND TR_valid_id=1 AND TR_CustID=?";

    # return if result set is empty
    return if !$DBObject->Prepare(
        SQL   => $SQLTR,
        Bind  => [ \$Ticket{CustomerID} ],
    );

	my @TRData;
	
    # process result set
    while ( my @Row = $DBObject->FetchrowArray() ) {

        my %Data;
		
		$Data{TR_ID} = $Row[0];
        $Data{TR_Caff} = $Row[1];
		$Data{TR_Description} = $Row[2];
		push( @TRData, \%Data );
		
    }
	
	my @DataCalculUO;
	my %CalculUO;
	
	$CalculUO{UOConseil}= $UOConseil;
	push (@DataCalculUO, \%CalculUO );
	
	
	if (@TRData) {
	
		$LayoutObject->Block(
						Name => 'PoolExist',
					);
					
		for my $CalculUOCons (@DataCalculUO) {
			$LayoutObject->Block(
				Name => 'UOConseil',
				Data => $CalculUOCons,
			);
		}
					
					
			
		my $NbContract = scalar(@TRData);
		
		my $NbElem = scalar(@TRExist);
		
		# $Kernel::OM->Get('Kernel::System::Log')->Log(
				# Priority => 'error',
				# Message  => $NbElem
			# );
			
		if (!$NbElem) {
			$LayoutObject->Block(
				Name => 'TRCreateDecompte',
				Data => 
			);
		}
		if ($NbContract>1) {
		
			$LayoutObject->Block(
				Name => 'TRListSelect',
				Data => @TRExist,
			);
			for my $TR (@TRData) {
				$LayoutObject->Block(
					Name => 'TRList',
					Data => $TR,
				);
			}
		} else {
			for my $TR (@TRData) {
				$LayoutObject->Block(
					Name => 'TRListAlone',
					Data => $TR,
				);
			}
		}
		
		$LayoutObject->Block(
			Name => 'DecompteUO',
			Data => @TRExist,
		);
		
		
	}
	
	# set template and information values
	my $Snippet = $LayoutObject->Output(
		TemplateFile => 'Exaprobe/APA_TicketUOClose',
		Data         => {
		}
	);

	# $Kernel::OM->Get('Kernel::System::Log')->Log(
				# Priority => 'error',
				# Message  => $IsAuth
			# );
			
	# add information according to the requested position
	if ( $GroupList{$UOGroupID} || $IsAuth ) {
		# ${ $Param{Data} } =~ s{(<div \s+ class="WidgetSimple \s+ (Expanded|Collapsed)" \s+ id="WidgetArticle">)}{ $Snippet $1 }xms;
		${ $Param{Data} } =~ s{(</div> \s+ <div \s+ class="Footer)}{ $Snippet $1 }xms;
	}
	


    # done, return information
    return ${ $Param{Data} };

}

1;
