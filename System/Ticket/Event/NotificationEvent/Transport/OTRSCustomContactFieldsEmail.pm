# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::NotificationEvent::Transport::OTRSCustomContactFieldsEmail;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
## nofilter(TidyAll::Plugin::OTRS::Perl::ParamObject)

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use base qw(Kernel::System::Ticket::Event::NotificationEvent::Transport::Base);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::Email',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Queue',
    'Kernel::System::SystemAddress',
    'Kernel::System::Ticket',
    'Kernel::System::User',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::Ticket::Event::NotificationEvent::Transport::OTRSCustomContactFieldsEmail - email transport layer

=head1 SYNOPSIS

Notification event transport layer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a notification transport object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new('');
    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::OTRSCustomContactFieldsEmail');

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

    # cleanup event data
    $Self->{EventData} = undef;

    # get needed objects
    my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
    my $SystemAddressObject = $Kernel::OM->Get('Kernel::System::SystemAddress');
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get recipient data
    my %Recipient = %{ $Param{Recipient} };

    if (
        $Recipient{Type} eq 'Customer'
        && $ConfigObject->Get('CustomerNotifyJustToRealCustomer')
        )
    {
        # return if not customer user ID
        return if !$Recipient{CustomerUserID};

        my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $Recipient{CustomerUserID},
        );

        if ( !$CustomerUser{UserEmail} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'info',
                Message  => "Send no customer notification because of missing "
                    . "customer email (CustomerUserID=$CustomerUser{CustomerUserID})!",
            );
            return;
        }
    }

    # UserEmail is empty if notification is only sent to Cc/Bcc recipients
    if ( $Recipient{UserEmail} ) {
        return if $Recipient{UserEmail} !~ /@/;
        my $IsLocalAddress = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressIsLocalAddress(
            Address => $Recipient{UserEmail},
        );
        return if $IsLocalAddress;
    }

    # create new array to prevent attachment growth (see bug#5114)
    my @Attachments = @{ $Param{Attachments} };

    my %Notification = %{ $Param{Notification} };

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # send notification
    my $From = $ConfigObject->Get('NotificationSenderName') . ' <'
        . $ConfigObject->Get('NotificationSenderEmail') . '>';

    if ( $Param{Notification}->{ContentType} && $Param{Notification}->{ContentType} eq 'text/html' ) {

        # Get configured template with fallback to Default.
        my $EmailTemplate = $Param{Notification}->{Data}->{TransportEmailTemplate}->[0] || 'Default';

        my $Home              = $Kernel::OM->Get('Kernel::Config')->Get('Home');
        my $TemplateDir       = "$Home/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";
        my $CustomTemplateDir = "$Home/Custom/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email";

        if ( !-r "$TemplateDir/$EmailTemplate.tt" && !-r "$CustomTemplateDir/$EmailTemplate.tt" ) {
            $EmailTemplate = 'Default';
        }

        # generate HTML
        $Notification{Body} = $LayoutObject->Output(
            TemplateFile => "NotificationEvent/Email/$EmailTemplate",
            Data         => {
                TicketID => $Param{TicketID},
                Body     => $Notification{Body},
                Subject  => $Notification{Subject},
            },
        );
    }

    # send notification
    if ( $Recipient{Type} eq 'Agent' ) {

        # get needed objects
        my $EmailObject = $Kernel::OM->Get('Kernel::System::Email');

        my $Sent = $EmailObject->Send(
            From       => $From,
            To         => $Recipient{UserEmail},
            Cc         => $Recipient{Cc},
            Bcc        => $Recipient{Bcc},
            Subject    => $Notification{Subject},
            MimeType   => $Notification{ContentType},
            Type       => $Notification{ContentType},
            Charset    => 'utf-8',
            Body       => $Notification{Body},
            Loop       => 1,
            Attachment => $Param{Attachments},
        );

        if ( !$Sent ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "'$Notification{Name}' notification could not be sent to agent '$Recipient{UserEmail} ",
            );

            return;
        }

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'info',
            Message  => "Sent agent '$Notification{Name}' notification to '$Recipient{UserEmail}'.",
        );

        # set event data
        $Self->{EventData} = {
            Event => 'ArticleAgentNotification',
            Data  => {
                TicketID => $Param{TicketID},
            },
            UserID => $Param{UserID},
        };
    }
    else {

        # get queue object
        my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

        my %Address;

        # get article
        my %Article = $TicketObject->ArticleLastCustomerArticle(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
        );

        # set "From" address from Article if exist, otherwise use ticket information, see bug# 9035
        if (%Article) {
            %Address = $QueueObject->GetSystemAddress( QueueID => $Article{QueueID} );
        }
        else {

            # get ticket data
            my %Ticket = $TicketObject->TicketGet(
                TicketID => $Param{TicketID},
            );

            %Address = $QueueObject->GetSystemAddress( QueueID => $Ticket{QueueID} );
        }

        my $ArticleType = 'email-notification-ext';

        if ( IsArrayRefWithData( $Param{Notification}->{Data}->{NotificationArticleTypeID} ) ) {

            # get notification article type
            $ArticleType = $TicketObject->ArticleTypeLookup(
                ArticleTypeID => $Param{Notification}->{Data}->{NotificationArticleTypeID}->[0],
            );
        }

        # compile recipient list per type
        my $CustomContactRecipients;
        RECIPIENTTYPE:
        for my $RecipientType (qw(UserEmail Cc Bcc)) {
            next RECIPIENTTYPE if !$Recipient{$RecipientType};
            if ($CustomContactRecipients) {
                $CustomContactRecipients .= ' / ';
            }
            my $RealType = $RecipientType eq 'UserEmail' ? 'To' : $RecipientType;
            $CustomContactRecipients .= "$Recipient{$RecipientType} ($RealType)"
        }

        my $ArticleID = $TicketObject->ArticleSend(
            ArticleType    => $ArticleType,
            SenderType     => 'system',
            TicketID       => $Param{TicketID},
            HistoryType    => 'SendCustomerNotification',
            HistoryComment => "\%\%" . $CustomContactRecipients,
            From           => "$Address{RealName} <$Address{Email}>",
            To             => $Recipient{UserEmail},
            Cc             => $Recipient{Cc},
            Bcc            => $Recipient{Bcc},
            Subject        => $Notification{Subject},
            Body           => $Notification{Body},
            MimeType       => $Notification{ContentType},
            Type           => $Notification{ContentType},
            Charset        => 'utf-8',
            UserID         => $Param{UserID},
            Loop           => 1,
            Attachment     => $Param{Attachments},
        );

        if ( !$ArticleID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "Customer '$Notification{Name}' notification could not be sent to '$CustomContactRecipients'.",
            );

            return;
        }

        # log event
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'info',
            Message  => "Sent customer '$Notification{Name}' notification to '$CustomContactRecipients'.",
        );

        # set event data
        $Self->{EventData} = {
            Event => 'ArticleCustomerNotification',
            Data  => {
                TicketID  => $Param{TicketID},
                ArticleID => $ArticleID,
            },
            UserID => $Param{UserID},
        };
    }

    return 1;
}

1;
