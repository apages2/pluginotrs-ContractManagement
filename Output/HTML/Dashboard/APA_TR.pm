# --
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dashboard::APA_TR;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed parameters
    for my $Needed (qw(Config Name UserID)) {
        die "Got no $Needed!" if ( !$Self->{$Needed} );
    }
	
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	$Self->{Group} = $ConfigObject->Get('ContractManagement::Config')->{Group};
	

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

    return;
}


sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} }
    );
}


sub Run {
    my ( $Self, %Param ) = @_;

    return if !$Param{CustomerID};

    my $TRObject = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_TR');

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	
	my $UserID = $Self->{UserID};
	
	
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

    if ( $IsAdminGroup || $IsAdmin) {
        $LayoutObject->Block(
            Name => 'ContentLargeTRAddAdmin',
            Data => {
                CustomerID => $Self->{CustomerID},
            },
        );
    } 
	
    # get MCO data sources
    my @MCOSource = $TRObject->GetTR(
				CustomerID => $Param{CustomerID},
				ServiceType => 'MCO_%',
	);
	
	 # show "none" if there are no MCO
    if ( !@MCOSource ) {
        $LayoutObject->Block(
            Name => 'ContentLargeMCOListNone',
            Data => {},
        );
    } else {
		 if (  $IsAdminGroup || $IsAdmin) {
			for my $MCOKey (@MCOSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeMCOListRowAdmin',
					Data => $MCOKey,
				);
			}
		} else {
			for my $MCOKey (@MCOSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeMCOListRowAgent',
					Data => $MCOKey,
				);
			}
		}
	}
	
	# get UO data sources
    my @UOSource = $TRObject->GetTR(
				CustomerID => $Param{CustomerID},
				ServiceType => 'SO_COG-UO-%',
	);
	
	 # show "none" if there are no UO
    if ( !@UOSource ) {
        $LayoutObject->Block(
            Name => 'ContentLargeUOListNone',
            Data => {},
        );
    } else {
		if ( $IsAdminGroup || $IsAdmin ) {
			for my $UOKey (@UOSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeUOListRowAdmin',
					Data => $UOKey,
				);
			}
		} else {
			for my $UOKey (@UOSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeUOListRowAgent',
					Data => $UOKey,
				);
			}
		}
	}
	
	# get RTC data sources
    my @RTCSource = $TRObject->GetTR(
				CustomerID => $Param{CustomerID},
				ServiceType => 'SO_RTC-%',
	);
	
	 # show "none" if there are no RTC
    if ( !@RTCSource ) {
        $LayoutObject->Block(
            Name => 'ContentLargeRTCListNone',
            Data => {},
        );
    } else {
		if ( $IsAdminGroup || $IsAdmin ) {
			for my $RTCKey (@RTCSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeRTCListRowAdmin',
					Data => $RTCKey,
				);
			}
		} else {
			for my $RTCKey (@RTCSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeRTCListRowAgent',
					Data => $RTCKey,
				);
			}
		}
	}
		
	# get SUP  data sources
    my @SUPSource = $TRObject->GetTR(
				CustomerID => $Param{CustomerID},
				ServiceType => 'SO_SUP-H%',
	);
	
	 # show "none" if there are no SUP
    if ( !@SUPSource ) {
        $LayoutObject->Block(
            Name => 'ContentLargeSUPListNone',
            Data => {},
        );
    } else {
		if ( $IsAdminGroup || $IsAdmin ) {
			for my $SUPKey (@SUPSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeSUPListRowAdmin',
					Data => $SUPKey,
				);
			}
		} else {
			for my $SUPKey (@SUPSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeSUPListRowAgent',
					Data => $SUPKey,
				);
			}	
		}
	}
	
	
	# get BACKUP data sources
    my @BACKSource = $TRObject->GetTR(
				CustomerID => $Param{CustomerID},
				ServiceType => 'SO_BACKUP-DEVICES',
	);
	
	 # show "none" if there are no BACKUP
    if ( !@BACKSource ) {
        $LayoutObject->Block(
            Name => 'ContentLargeBACKListNone',
            Data => {},
        );
    } else {
		if ( $IsAdminGroup || $IsAdmin ) {
			for my $BACKKey (@BACKSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeBACKListRowAdmin',
					Data => $BACKKey,
				);
			}
		} else {
			for my $BACKKey (@BACKSource) {
				$LayoutObject->Block(
					Name => 'ContentLargeBACKListRowAgent',
					Data => $BACKKey,
				);
			}	
		}
	}
	
    my $Content = $LayoutObject->Output(
        TemplateFile => 'Exaprobe/APA_AgentDashboardTR',
        Data         => {
        },
    );

    return $Content;
}

1;
