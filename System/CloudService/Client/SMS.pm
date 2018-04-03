# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::CloudService::Client::SMS;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::CloudService::Backend::Configuration',
    'Kernel::System::CloudService::Backend::Run',
    'Kernel::System::Group',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::CloudService::Client::SMS - SMS cloud service client

=head1 SYNOPSIS

Cloud service client are responsible to handles communication with operation on cloud server.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object.

    use Kernel::System::CloudService::Client::SMS;
    my $SMSObject = Kernel::System::CloudService::Client::SMS->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item SendSMS()

perform a SMS sending attempt

    my $Result = $SMSObject->SendSMS(
        To   => '+49172123456789',
        Text => 'Some Message',
    );

    $Result = {
        Success       => 1,                             # 0 or 1
        ErrorMessage  => 'An explanation about error.', # in case of error
        Data          => {
            SendSMS => 1,                              # 0 or 1
        },
    };

=cut

sub SendSMS {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(To Text)) {

        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );

            return;
        }
    }

    # get cloud service configuration object
    my $CloudServiceConfigObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Configuration');

    # get cloud service configuration
    my $CloudServiceData = $CloudServiceConfigObject->CloudServiceGet(
        Name => 'SMS',
    );

    my $AllowedUser = 1;

    # check Role
    if ( $CloudServiceData->{Config}->{AllowedRoles} && $Param{UserID} ) {

        # remove allowed value
        $AllowedUser = 0;

        my %Roles = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserRoleGet(
            UserID => $Param{UserID},
        );

        MYROLES:
        for my $Role ( sort keys %Roles ) {

            # check
            if ( grep { $_ eq $Role } @{ $CloudServiceData->{Config}->{AllowedRoles} } ) {
                $AllowedUser = 1;
                last MYROLES;
            }
        }
    }

    return if !$AllowedUser;

    # define cloud service and operation name
    my $CloudService = 'SMS';
    my $Operation    = 'SendSMS';

    # prepare cloud service request
    my %RequestParams = (
        RequestData => {
            $CloudService => [
                {
                    Operation => $Operation,
                    Data      => {
                        To   => $Param{To},
                        From => $CloudServiceData->{Config}->{SenderString},
                        Text => $Param{Text},
                    },
                },
            ],
        },
    );

    # get cloud service object
    my $CloudServiceObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Run');

    # TODO: Check if is possible to use Scheduler here
    # instead a direct call

    # dispatch the cloud service request
    my $RequestResult = $CloudServiceObject->Request(%RequestParams);

    # as this is the only operation an unsuccessful request means
    # that the operation was also unsuccessful
    return if !IsHashRefWithData($RequestResult);

    my $OperationResult = $CloudServiceObject->OperationResultGet(
        RequestResult => $RequestResult,
        CloudService  => $CloudService,
        Operation     => $Operation,
    );

    # return if there was no result
    return if !IsHashRefWithData($OperationResult);

    # return operation result
    return $OperationResult;
}

=item HealthCheck()

check if is possible to use this cloud service
and retrieve the number of SMS units available

    my $Result = $SMSObject->HealthCheck(
        To   => '+49172123456789',
        From => 'MyCompany',
        Text => 'Some Message',
    );

    $Result = {
        Success       => 1,                             # 0 or 1
        ErrorMessage  => 'An explanation about error.', # in case of error
        Data          => {
            Success      => 1, # 1 or 0, possible values
            AvailableSMS => 10,
            SystemID     => '1234567890',
            CustomerID   => 'TestCustomerID',
        },
    };

=cut

sub HealthCheck {
    my ( $Self, %Param ) = @_;

    # define cloud service and operation name
    my $CloudService = 'SMS';
    my $Operation    = 'SendSMSPermission';

    # prepare cloud service request
    my %RequestParams = (
        RequestData => {
            $CloudService => [
                {
                    Operation => $Operation,
                    Data      => {},
                },
            ],
        },
    );

    # get cloud service object
    my $CloudServiceObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Run');

    # dispatch the cloud service request
    my $RequestResult = $CloudServiceObject->Request(%RequestParams);

    # # TODO: keep this just for testing
    # my $RequestResult = {
    #     Success       => 1,
    #     ErrorMessage  => '',    # optional
    #     $CloudService => [
    #         {
    #             Success      => 1,            # 1 or 0
    #             ErrorMessage => '',           # optional
    #             Operation    => $Operation,
    #             Data         => {
    #                 Success      => 1,
    #                 AvailableSMS => 10,
    #                 SystemID     => '1234567890',
    #                 CustomerID   => 'carlos.garcia@otrs.com',
    #             },
    #         },
    #     ],
    # };

    # as this is the only operation an unsuccessful request means
    # that the operation was also unsuccessful
    return if !IsHashRefWithData($RequestResult);

    my $OperationResult = $CloudServiceObject->OperationResultGet(
        RequestResult => $RequestResult,
        CloudService  => $CloudService,
        Operation     => $Operation,
    );

    # return if there was no result
    return if !IsHashRefWithData($OperationResult);

    # return operation result
    return $OperationResult;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
