# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminCloudServiceSMS;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $CloudServiceID   = $ParamObject->GetParam( Param => 'CloudServiceID' )   || '';
    my $CloudServiceName = $ParamObject->GetParam( Param => 'CloudServiceName' ) || '';

    # check for CloudServiceID
    if ( !$CloudServiceName ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need CloudServiceName!",
        );
    }

    # get cloud service object
    my $CloudServiceObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Configuration');

    # get registered cloud services
    my $CloudServiceList = $CloudServiceObject->CloudServiceList( Valid => 0 );
    my %ReverseCloudServiceList = reverse %{$CloudServiceList};

    # check for an ID
    if ( !$CloudServiceID && !$Self->{Subaction} ) {

        # be in the list means we should edit values
        if ( $ReverseCloudServiceList{$CloudServiceName} ) {
            $Self->{Subaction} = 'Change';

            # get stored cloud service id
            $CloudServiceID = $ReverseCloudServiceList{$CloudServiceName};
        }
        else {
            $Self->{Subaction} = 'Add';
        }
    }

    # get cloud service client object
    my $CloudServiceClientObject = $Kernel::OM->Get('Kernel::System::CloudService::Client::SMS');

    # check sms permissions
    my $PermissionResult = $CloudServiceClientObject->HealthCheck();

    # ------------------------------------------------------------ #
    # sub-action Change: load cloud service and show edit screen
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {

        # check for CloudServiceID
        if ( !$CloudServiceID ) {
            return $LayoutObject->ErrorScreen(
                Message => "Need CloudServiceID!",
            );
        }

        # get cloud service configuration
        my $CloudServiceData = $CloudServiceObject->CloudServiceGet(
            ID => $CloudServiceID,
        );

        # check for valid cloud service configuration
        if ( !IsHashRefWithData($CloudServiceData) ) {
            return $LayoutObject->ErrorScreen(
                Message => "Could not get data for CloudServiceID $CloudServiceID",
            );
        }

        return $Self->_ShowEdit(
            %Param,
            CloudServiceID   => $CloudServiceID,
            CloudServiceName => $CloudServiceName,
            CloudServiceData => $CloudServiceData,
            PermissionResult => $PermissionResult,
            Action           => 'Change',
        );
    }

    # ------------------------------------------------------------ #
    # sub-action ChangeAction: write basic config
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # check for CloudServiceID
        if ( !$CloudServiceID ) {
            return $LayoutObject->ErrorScreen(
                Message => "Need CloudServiceID!",
            );
        }

        # get cloud service configuration
        my $CloudServiceData = $CloudServiceObject->CloudServiceGet(
            ID => $CloudServiceID,
        );

        # check for valid cloud service configuration
        if ( !IsHashRefWithData($CloudServiceData) ) {
            return $LayoutObject->ErrorScreen(
                Message => "Could not get data for CloudServiceID $CloudServiceID",
            );
        }

        # get parameter from web browser
        my $Parameters = $Self->_GetParams();

        # set params hash
        my $GetParam = $Parameters->{Params};

        # set error hash
        my %Error = %{ $Parameters->{Error} };

        if (
            $ReverseCloudServiceList{$CloudServiceName}
            && $ReverseCloudServiceList{$CloudServiceName} ne $CloudServiceID
            )
        {

            # add server error error class
            $Error{CloudServiceNameServerError}        = 'ServerError';
            $Error{CloudServiceNameServerErrorMessage} = 'There is another cloud service with the same name.';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {
            return $Self->_ShowEdit(
                %Error,
                %Param,
                CloudServiceID   => $CloudServiceID,
                CloudServiceName => $CloudServiceName,
                CloudServiceData => $GetParam,
                PermissionResult => $PermissionResult,
                Action           => 'Change',
            );
        }

        # otherwise save configuration and return to overview screen
        my $Success = $CloudServiceObject->CloudServiceUpdate(
            %{$GetParam},
            ID     => $CloudServiceID,
            Name   => $CloudServiceName,
            UserID => $Self->{UserID},
        );

        # show error if cant update
        if ( !$Success ) {
            return $LayoutObject->ErrorScreen(
                Message => "There was an error updating the cloud service",
            );
        }

        # define notification
        my $Notify = $LayoutObject->{LanguageObject}->Translate(
            'Cloud service "%s" updated!',
            $CloudServiceName,
        );

        # go back to cloud service.
        my $RedirectURL = "Action=AdminCloudServices;";
        return $LayoutObject->Redirect(
            OP => $RedirectURL,
        );

    }

    # ------------------------------------------------------------ #
    # sub-action Add: show edit screen (empty)
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Add' ) {

        return $Self->_ShowEdit(
            CloudServiceName => $CloudServiceName,
            PermissionResult => $PermissionResult,
            Action           => 'Add',
        );
    }

    # ------------------------------------------------------------ #
    # sub-action AddAction: create a cloud service
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get parameter from web browser
        my $Parameters = $Self->_GetParams();

        # set params hash
        my $GetParam = $Parameters->{Params};

        # set error hash
        my %Error = %{ $Parameters->{Error} };

        if ( $ReverseCloudServiceList{$CloudServiceName} ) {

            # add server error error class
            $Error{CloudServiceNameServerError}        = 'ServerError';
            $Error{CloudServiceNameServerErrorMessage} = 'There is another cloud service with the same name.';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {
            return $Self->_ShowEdit(
                %Error,
                %Param,
                CloudServiceID   => $CloudServiceID,
                CloudServiceName => $CloudServiceName,
                CloudServiceData => $GetParam,
                PermissionResult => $PermissionResult,
                Action           => 'Add',
            );
        }

        # otherwise save configuration and return to overview screen
        my $ID = $CloudServiceObject->CloudServiceAdd(
            %{$GetParam},
            Name   => $CloudServiceName,
            UserID => $Self->{UserID},
        );

        # show error if cant create
        if ( !$ID ) {
            return $LayoutObject->ErrorScreen(
                Message => "There was an error saving the cloud service configuration.",
            );
        }

        # set CloudServiceID to the new created cloud service
        $CloudServiceID = $ID;

        # define notification
        my $Notify = $LayoutObject->{LanguageObject}->Translate(
            'Cloud Service config "%s" saved!',
            $CloudServiceName,
        );

        # return to edit to continue changing the configuration
        return $Self->_ShowEdit(
            %Param,
            Notify           => $Notify,
            CloudServiceID   => $CloudServiceID,
            CloudServiceName => $CloudServiceName,
            CloudServiceData => $GetParam,
            PermissionResult => $PermissionResult,
            Action           => 'Change',
        );
    }

    return 1;
}

sub _ShowEdit {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # show notifications if any
    if ( $Param{Notify} ) {
        $Output .= $LayoutObject->Notify(
            Info => $Param{Notify},
        );
    }

    # get cloud service data
    my %CloudServiceData = %{ $Param{CloudServiceData} || {} };

    # get group object
    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    # create role select
    $Param{AllowedRolesStrg} = $LayoutObject->BuildSelection(
        Data       => { $GroupObject->RoleList( Valid => 1 ) },
        Size       => 6,
        Name       => 'AllowedRoles',
        Multiple   => 1,
        SelectedID => $CloudServiceData{Config}->{AllowedRoles},
        Class      => 'Modernize',
    );

    # get valid states values
    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

    # create the validity select
    my $ValidtyStrg = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $CloudServiceData{ValidID} || 1,
        PossibleNone => 0,
        Translate    => 1,
        Class        => 'HideTrigger',
        AutoComplete => 'off',
        Class        => 'Modernize',
    );

    # preset the phone fields with the default values
    my %Defaults;
    if ( $Param{Action} eq 'Add' ) {
        $Defaults{Config} = {
            AgentPhoneField    => 'UserMobile',
            CustomerPhoneField => 'UserMobile',
        };
    }

    if ( IsHashRefWithData( $Param{PermissionResult} ) ) {

        if ( !$Param{PermissionResult}->{Success} ) {

            # include not available message
            $LayoutObject->Block(
                Name => 'NoSuccessCheck',
            );
        }
        else {

            my $CloudServiceCheckMessage = 'OK';

            if ( !$Param{PermissionResult}->{Data}->{Authorized} ) {
                $CloudServiceCheckMessage = 'Not authorized.'
            }

            # define notification
            $CloudServiceCheckMessage = $LayoutObject->{LanguageObject}->Translate(
                $CloudServiceCheckMessage,
            );

            $LayoutObject->Block(
                Name => 'SuccessCheck',
                Data => {
                    %{ $Param{PermissionResult}->{Data} },
                    CloudServiceCheckMessage => $CloudServiceCheckMessage,
                },
            );
        }

    }

    $LayoutObject->Block(
        Name => 'Details',
        Data => {
            %Param,
            %CloudServiceData,
            %Defaults,
            ValidtyStrg => $ValidtyStrg,
        },
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminCloudServiceSMS',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GetParams {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    my %Error;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get optional parameters from web browser
    for my $Parameter (
        qw(CloudServiceID CloudServiceName Comment AgentPhoneField CustomerPhoneField SenderString ValidID DataProtectionRegulations)
        )
    {
        $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
    }

    PARAMETER:
    for my $Parameter (qw(AllowedRoles)) {

        my @Data = $ParamObject->GetArray( Param => $Parameter );
        next PARAMETER if !@Data;

        $GetParam{$Parameter} = \@Data;
    }

    # check mandatory params
    for my $Needed (qw(CloudServiceName AgentPhoneField CustomerPhoneField SenderString ValidID)) {
        if ( !$GetParam{$Needed} ) {

            # add server error class
            $Error{ $Needed . 'ServerError' } = 'ServerError';
        }
    }

    # check if data protection regulations have been accepted on adding the SMS cloud service the first time
    if (
        !$GetParam{CloudServiceID}
        && ( !$GetParam{DataProtectionRegulations} || $GetParam{DataProtectionRegulations} ne 'Accept' )
        )
    {
        $Error{'DataProtectionRegulationsServerError'} = 'ServerError';
    }
    delete $GetParam{CloudServiceID};

    # set config values
    ITEM:
    for my $Item (qw(Comment AgentPhoneField CustomerPhoneField SenderString AllowedRoles)) {

        next ITEM if !$GetParam{$Item};

        # set config value
        $GetParam{Config}->{$Item} = $GetParam{$Item};

        # delete param item
        delete $GetParam{$Item};
    }

    return {
        Params => \%GetParam,
        Error  => \%Error,
    };
}

1;
