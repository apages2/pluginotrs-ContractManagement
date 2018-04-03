# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::NotificationEvent::Transport::SMS;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
## nofilter(TidyAll::Plugin::OTRS::Perl::ParamObject)

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use base qw(Kernel::System::Ticket::Event::NotificationEvent::Transport::Base);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::CloudService::Client::SMS',
    'Kernel::System::CloudService::Backend::Configuration',
    'Kernel::System::OTRSBusiness',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::Ticket::Event::NotificationEvent::Transport::SMS - SMS transport layer

=head1 SYNOPSIS

Notification event transport layer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a notification transport object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('');
    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::SMS');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub SendNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID UserID Notification Recipient)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Needed!',
            );
            return;
        }
    }

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # cleanup event data
    $Self->{EventData} = undef;

    # get recipient data
    my %Recipient = %{ $Param{Recipient} };

    # get notification data
    my %Notification = %{ $Param{Notification} };

    # get cloud service configuration object
    my $CloudServiceConfigObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Configuration');

    # get cloud service configuration
    my $CloudServiceData = $CloudServiceConfigObject->CloudServiceGet(
        Name => 'SMS',
    );

    # get agent phone field
    my $AgentPhoneField = $CloudServiceData->{Config}->{AgentPhoneField} || 'UserMobile';

    # get customer phone field
    my $CustomerPhoneField = $CloudServiceData->{Config}->{CustomerPhoneField} || 'UserMobile';

    # get PhoneNumber from recipient's data
    my $PhoneNumber = '';

    # get UserID from recipient
    my $RecipientUserID = '';

    if ( $Recipient{Type} eq 'Agent' ) {

        # check if phone field name is not empty
        return if !$AgentPhoneField;

        # check if phone field exists
        return if !$Recipient{$AgentPhoneField};

        # get phone number
        $PhoneNumber = $Recipient{$AgentPhoneField};

        # check if UserID field exists
        return if !$Recipient{UserID};

        # get recipient UserID number
        $RecipientUserID = $Recipient{UserID};

    }
    elsif ( $Recipient{Type} eq 'Customer' ) {

        # check if phone field name is not empty
        return if !$CustomerPhoneField;

        # check if phone field exists
        return if !$Recipient{$CustomerPhoneField};

        # get phone number
        $PhoneNumber = $Recipient{$CustomerPhoneField};
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # Use ticket number construct as a default reference.
    my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
    my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');
    my $TicketNumber      = $TicketObject->TicketNumberLookup(
        TicketID => $Param{TicketID},
        UserID   => $Param{UserID},
    );
    my $Reference = "[$TicketHook$TicketHookDivider$TicketNumber]";

    # Replace the reference with URLs for agent and customer recipients.
    if ( $Recipient{Type} eq 'Agent' ) {
        $Reference = $ConfigObject->Get('HttpType')
            . '://' . $ConfigObject->Get('FQDN')
            . '/' . $ConfigObject->Get('ScriptAlias')
            . 'index.pl?Action=AgentTicketZoom;TicketID=' . $Param{TicketID};
    }
    elsif ( $Recipient{Type} eq 'Customer' ) {
        $Reference = $ConfigObject->Get('HttpType')
            . '://' . $ConfigObject->Get('FQDN')
            . '/' . $ConfigObject->Get('ScriptAlias')
            . 'customer.pl?Action=CustomerTicketZoom;TicketNumber=' . $TicketNumber;
    }

    my $NewSubject = $TicketObject->TicketSubjectClean(
        TicketNumber => $TicketNumber,
        Subject      => $Notification{Subject},
    );

    # give content for SMS notification
    my $NotificationMessage = $NewSubject . ' ' . $Reference;

    # get needed objects
    my $SMSObject = $Kernel::OM->Get('Kernel::System::CloudService::Client::SMS');

    # send the sms
    my $Result = $SMSObject->SendSMS(
        To     => $PhoneNumber,
        Text   => $NotificationMessage,
        UserID => $RecipientUserID,
    );

    # error handling
    if ( !$Result->{Success} ) {

        my $ErrorMessage = $Result->{ErrorMessage} || '';

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "'$Notification{Name}' notification could not be sent to $PhoneNumber! $ErrorMessage",
        );

        return;
    }

    # log event
    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'info',
        Message  => "Sent '$Notification{Name}' notification to $PhoneNumber.",
    );

    # set event data based on recipient type
    $Self->{EventData} = {
        Event => 'Article' . $Recipient{Type} . 'Notification',
        Data  => {
            TicketID => $Param{TicketID},
        },
        UserID => $Param{UserID},
    };

    return 1;
}

sub GetTransportRecipients {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Notification)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed",
            );
        }
    }

    # get cloud service configuration object
    my $CloudServiceConfigObject = $Kernel::OM->Get('Kernel::System::CloudService::Backend::Configuration');

    # get cloud service configuration
    my $CloudServiceData = $CloudServiceConfigObject->CloudServiceGet(
        Name => 'SMS',
    );

    # get customer phone field
    my $PhoneField = $CloudServiceData->{Config}->{CustomerPhoneField} || 'UserMobile';

    my @Recipients;

    # get recipients by RecipientSMS
    if ( $Param{Notification}->{Data}->{RecipientSMS} ) {
        if ( $Param{Notification}->{Data}->{RecipientSMS}->[0] ) {

            my @PhoneNumbers = split ',', $Param{Notification}->{Data}->{RecipientSMS}->[0];

            PHONENUMBER:
            for my $PhoneNumber (@PhoneNumbers) {

                next PHONENUMBER if !$PhoneNumber;

                my %Recipient;
                $Recipient{Realname}    = '';
                $Recipient{Type}        = 'Customer';
                $Recipient{$PhoneField} = $PhoneNumber;

                push @Recipients, \%Recipient;
            }
        }
    }

    return @Recipients;
}

sub TransportSettingsDisplayGet {
    my ( $Self, %Param ) = @_;

    KEY:
    for my $Key (qw(RecipientSMS)) {
        next KEY if !$Param{Data}->{$Key};
        next KEY if !defined $Param{Data}->{$Key}->[0];
        $Param{$Key} = $Param{Data}->{$Key}->[0];
    }

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # generate HTML
    my $Output = $LayoutObject->Output(
        TemplateFile => 'AdminNotificationEventTransportSMSSettings',
        Data         => \%Param,
    );

    return $Output;
}

sub TransportParamSettingsGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(GetParam)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed",
            );
        }
    }

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    PARAMETER:
    for my $Parameter (qw(RecipientSMS)) {
        my @Data = $ParamObject->GetArray( Param => $Parameter );
        next PARAMETER if !@Data;
        $Param{GetParam}->{Data}->{$Parameter} = \@Data;
    }

    # Note: Example how to set errors and use them
    # on the normal AdminNotificationEvent screen
    # # set error
    # $Param{GetParam}->{$Parameter.'ServerError'} = 'ServerError';

    return 1;
}

sub IsUsable {
    my ( $Self, %Param ) = @_;

    my $OTRSBusinessObject = $Kernel::OM->Get('Kernel::System::OTRSBusiness');

    # OTRSBusiness not yet installed?
    return 0 if !$OTRSBusinessObject->OTRSBusinessIsInstalled();

    # check entitlement status
    # register status is performed on OTRSBusinessEntitlementStatus
    my $EntitlementStatus = 'forbidden';
    $EntitlementStatus = $OTRSBusinessObject->OTRSBusinessEntitlementStatus(
        CallCloudService => 0,
    );
    return 0 if $EntitlementStatus eq 'forbidden';

    # allow to use this method if everything was OK
    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
