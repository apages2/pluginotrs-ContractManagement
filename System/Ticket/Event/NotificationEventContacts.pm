# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# $origin: otrs - e90b281d1102687595c84c0089ae6fc5b79cdd08 - Kernel/System/Ticket/Event/NotificationEvent.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

# ---
# OTRSCustomContactFields
# ---
#package Kernel::System::Ticket::Event::NotificationEvent;
package Kernel::System::Ticket::Event::NotificationEventContacts;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
## nofilter(TidyAll::Plugin::OTRS::Perl::ParamObject)
# ---

use strict;
use warnings;

use List::Util qw(first);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::CustomerUser',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Email',
    'Kernel::System::Group',
    'Kernel::System::HTMLUtils',
    'Kernel::System::JSON',
    'Kernel::System::Log',
    'Kernel::System::NotificationEvent',
    'Kernel::System::Queue',
    'Kernel::System::SystemAddress',
    'Kernel::System::TemplateGenerator',
    'Kernel::System::Ticket',
    'Kernel::System::Time',
    'Kernel::System::User',
# ---
# OTRSCustomContactFields
# ---
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Ticket::Event::NotificationEvent::Transport::OTRSCustomContactFieldsEmail',
# ---
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Event Data Config UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( !$Param{Data}->{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID in Data!',
        );
        return;
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # return if no notification is active
    return 1 if $TicketObject->{SendNoNotification};

    # return if no ticket exists (e. g. it got deleted)
    my $TicketExists = $TicketObject->TicketNumberLookup(
        TicketID => $Param{Data}->{TicketID},
        UserID   => $Param{UserID},
    );

    return 1 if !$TicketExists;

    # get notification event object
    my $NotificationEventObject = $Kernel::OM->Get('Kernel::System::NotificationEvent');

    # check if event is affected
    my @IDs = $NotificationEventObject->NotificationEventCheck(
        Event => $Param{Event},
    );

    # return if no notification for event exists
    return 1 if !@IDs;

    # get ticket attribute matches
    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{Data}->{TicketID},
        UserID        => $Param{UserID},
        DynamicFields => 1,
    );

    # get dynamic field objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # get dynamic fields
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    );

    # create a dynamic field config lookup table
    my %DynamicFieldConfigLookup;
    for my $DynamicFieldConfig ( @{$DynamicFieldList} ) {
        $DynamicFieldConfigLookup{ $DynamicFieldConfig->{Name} } = $DynamicFieldConfig;
    }

    NOTIFICATION:
    for my $ID (@IDs) {

        my %Notification = $NotificationEventObject->NotificationGet(
            ID => $ID,
        );

        # verify ticket and article conditions
        my $PassFilter = $Self->_NotificationFilter(
            %Param,
            Ticket                   => \%Ticket,
            Notification             => \%Notification,
            DynamicFieldConfigLookup => \%DynamicFieldConfigLookup,
        );
        next NOTIFICATION if !$PassFilter;

        # add attachments only on ArticleCreate or ArticleSend event
        my @Attachments;
        if (
            ( ( $Param{Event} eq 'ArticleCreate' ) || ( $Param{Event} eq 'ArticleSend' ) )
            && $Param{Data}->{ArticleID}
            )
        {

            # add attachments to notification
            if ( $Notification{Data}->{ArticleAttachmentInclude}->[0] ) {

                # get article, it is needed for the correct behavior of the
                # StripPlainBodyAsAttachment flag into the ArticleAttachmentIndex function
                my %Article = $Kernel::OM->Get('Kernel::System::Ticket')->ArticleGet(
                    ArticleID     => $Param{Data}->{ArticleID},
                    UserID        => $Param{UserID},
                    DynamicFields => 0,
                );

                my %Index = $TicketObject->ArticleAttachmentIndex(
                    ArticleID                  => $Param{Data}->{ArticleID},
                    Article                    => \%Article,
                    UserID                     => $Param{UserID},
                    StripPlainBodyAsAttachment => 3,
                );
                if (%Index) {
                    FILE_ID:
                    for my $FileID ( sort keys %Index ) {
                        my %Attachment = $TicketObject->ArticleAttachment(
                            ArticleID => $Param{Data}->{ArticleID},
                            FileID    => $FileID,
                            UserID    => $Param{UserID},
                        );
                        next FILE_ID if !%Attachment;
                        push @Attachments, \%Attachment;
                    }
                }
            }
        }

        # get recipients
        my @RecipientUsers = $Self->_RecipientsGet(
            %Param,
            Ticket       => \%Ticket,
            Notification => \%Notification,
        );

# ---
# OTRSCustomContactFields
# ---
        my %ContactRecipients;
        my %ContactRecipientsFiltered;
        my $SendJoinedNotification = $Kernel::OM->Get('Kernel::Config')->Get('CustomContactFieldsSendJoinedNotification');

        # to store only contact recipients
        my @ContactRecipientUsers;

        RECIPIENT:
        for my $Recipient (@RecipientUsers) {

            # skip all non-contact recipients (they are handled in the regular module)
            next RECIPIENT if $Recipient->{Type} ne 'Contact';

            # for joint notifications just remember the recipient address and skip to the next recipient
            if ($SendJoinedNotification) {

                if ( $Recipient->{SendType} eq 'To' ) {
                    $ContactRecipients{ $Recipient->{UserEmail} } = 1; # deduplicate
                }

                $ContactRecipientsFiltered{ $Recipient->{SendType} }{ $Recipient->{UserEmail} } = 1; # deduplicate
                next RECIPIENT;
            }

            $Recipient->{Type} = 'Customer';
            push @ContactRecipientUsers, $Recipient;
        }

        # use only contact recipients to send the notifications
        @RecipientUsers = @ContactRecipientUsers;

        # check notification recipients (to, cc, bcc)
        my @UsedContactTypes = grep {$_ =~ /Contact*/ } @{$Notification{Data}->{Recipients}};

        if ( $#UsedContactTypes >= 0 ) {
            $SendJoinedNotification = 1;
        }

        # check if notification should be joint, then send only one to all contacts
        if ( $SendJoinedNotification && ( %ContactRecipients || %ContactRecipientsFiltered )) {

            my $JoinedEmail;
            my $JoinedEmailCc;
            my $JoinedEmailBcc;

            # concatenate all emails separated by a comma
            if ( $ContactRecipientsFiltered{To} ) {
                $JoinedEmail = join ', ', sort keys %{ $ContactRecipientsFiltered{To} };
            }

            if ( $ContactRecipientsFiltered{Cc} ) {
                $JoinedEmailCc = join ', ', sort keys %{ $ContactRecipientsFiltered{Cc} };
            }

            if ( $ContactRecipientsFiltered{Bcc} ) {
                $JoinedEmailBcc = join ', ', sort keys %{ $ContactRecipientsFiltered{Bcc} };
            }

            # set recipient information (this might be replaced as smart tags in the notification)
            my %RecipientDetails;
            for my $Attribute ( qw(
                UserCustomerID UserMobile UserPhone UserLogin UserFirstname UserCountry UserPassword
                UserTitle UserComment UserFax UserCity UserLastname UserZip UserStreet Realname
                UserID UserFullname)
                )
            {
                $RecipientDetails{$Attribute} = 'Joined Contacts';
            }

            # define just one recipient to send the notification
            @RecipientUsers = (
                {
                    Type      => 'Customer',
                    UserEmail => $JoinedEmail,
                    Cc        => $JoinedEmailCc,
                    Bcc       => $JoinedEmailBcc,
                    %RecipientDetails,
                },
            );
        }

# ---
        my @NotificationBundle;

        # get template generator object;
        my $TemplateGeneratorObject = $Kernel::OM->Get('Kernel::System::TemplateGenerator');

        # parse all notification tags for each user
        for my $Recipient (@RecipientUsers) {

            my %ReplacedNotification = $TemplateGeneratorObject->NotificationEvent(
                TicketID              => $Param{Data}->{TicketID},
                Recipient             => $Recipient,
                Notification          => \%Notification,
                CustomerMessageParams => $Param{Data}->{CustomerMessageParams},
                UserID                => $Param{UserID},
            );

            my $UserNotificationTransport = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                Data => $Recipient->{NotificationTransport},
            );

            push @NotificationBundle, {
                Recipient                      => $Recipient,
                Notification                   => \%ReplacedNotification,
                RecipientNotificationTransport => $UserNotificationTransport,
            };
        }

        # get config object
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # get notification transport config
        my %TransportConfig = %{ $ConfigObject->Get('Notification::Transport') || {} };

        # remember already sent agent notifications
        my %AlreadySent;

# ---
# OTRSCustomContactFields
# ---
        # For joint notifications we can only use Email transport
        if ( $SendJoinedNotification ) {
            $Notification{Data}->{Transports} = ['Email'];
        }

# ---
        # loop over transports for each notification
        TRANSPORT:
        for my $Transport ( sort keys %TransportConfig ) {

            # only configured transports for this notification
            if ( !grep { $_ eq $Transport } @{ $Notification{Data}->{Transports} } ) {
                next TRANSPORT;
            }

            next TRANSPORT if !IsHashRefWithData( $TransportConfig{$Transport} );
            next TRANSPORT if !$TransportConfig{$Transport}->{Module};

            # get transport object
            my $TransportObject;
            eval {
                $TransportObject = $Kernel::OM->Get( $TransportConfig{$Transport}->{Module} );
            };

            if ( !$TransportObject ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not create a new $TransportConfig{$Transport}->{Module} object!",
                );

                next TRANSPORT;
            }

            if ( ref $TransportObject ne $TransportConfig{$Transport}->{Module} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "$TransportConfig{$Transport}->{Module} object is invalid",
                );

                next TRANSPORT;
            }

            # check if transport is usable
            next TRANSPORT if !$TransportObject->IsUsable();

            BUNDLE:
            for my $Bundle (@NotificationBundle) {

                my $UserPreference = "Notification-$Notification{ID}-$Transport";

                # check if agent should get the notification
                my $AgentSendNotification = 0;
                if ( defined $Bundle->{RecipientNotificationTransport}->{$UserPreference} ) {
                    $AgentSendNotification = $Bundle->{RecipientNotificationTransport}->{$UserPreference};
                }
                elsif ( grep { $_ eq $Transport } @{ $Notification{Data}->{AgentEnabledByDefault} } ) {
                    $AgentSendNotification = 1;
                }
                elsif (
                    !IsArrayRefWithData( $Notification{Data}->{VisibleForAgent} )
                    || (
                        defined $Notification{Data}->{VisibleForAgent}->[0]
                        && !$Notification{Data}->{VisibleForAgent}->[0]
                    )
                    )
                {
                    $AgentSendNotification = 1;
                }

                # skip sending the notification if the agent has disable it in its preferences
                if (
                    IsArrayRefWithData( $Notification{Data}->{VisibleForAgent} )
                    && $Notification{Data}->{VisibleForAgent}->[0]
                    && $Bundle->{Recipient}->{Type} eq 'Agent'
                    && !$AgentSendNotification
                    )
                {
                    next BUNDLE;
                }

                # Check if notification should not send to the customer.
                if (
                    $Bundle->{Recipient}->{Type} eq 'Customer'
                    && $ConfigObject->Get('CustomerNotifyJustToRealCustomer')
                    )
                {

                    # No UserID means it's not a mapped customer.
                    next BUNDLE if !$Bundle->{Recipient}->{UserID};
                }

                my $Success = $Self->_SendRecipientNotification(
                    TicketID              => $Param{Data}->{TicketID},
                    Notification          => $Bundle->{Notification},
                    CustomerMessageParams => $Param{Data}->{CustomerMessageParams} || {},
                    Recipient             => $Bundle->{Recipient},
                    Event                 => $Param{Event},
                    Attachments           => \@Attachments,
                    Transport             => $Transport,
                    TransportObject       => $TransportObject,
                    UserID                => $Param{UserID},
                );

                # remember to have sent
                if ( $Bundle->{Recipient}->{UserID} ) {
                    $AlreadySent{ $Bundle->{Recipient}->{UserID} } = 1;
                }
            }

# ---
# OTRSCustomContactFields
# ---
            # Additional recipients should already been sent by the
            # Ticket Notifications, then skip them on this event.
            next TRANSPORT;
# ---
            # get special recipients specific for each transport
            my @TransportRecipients = $TransportObject->GetTransportRecipients(
                Notification => \%Notification,
            );

            next TRANSPORT if !@TransportRecipients;

            RECIPIENT:
            for my $Recipient (@TransportRecipients) {

                # replace all notification tags for each special recipient
                my %ReplacedNotification = $TemplateGeneratorObject->NotificationEvent(
                    TicketID              => $Param{Data}->{TicketID},
                    Recipient             => $Recipient,
                    Notification          => \%Notification,
                    CustomerMessageParams => $Param{Data}->{CustomerMessageParams} || {},
                    UserID                => $Param{UserID},
                );

                my $Success = $Self->_SendRecipientNotification(
                    TicketID              => $Param{Data}->{TicketID},
                    Notification          => \%ReplacedNotification,
                    CustomerMessageParams => $Param{Data}->{CustomerMessageParams} || {},
                    Recipient             => $Recipient,
                    Event                 => $Param{Event},
                    Attachments           => \@Attachments,
                    Transport             => $Transport,
                    TransportObject       => $TransportObject,
                    UserID                => $Param{UserID},
                );
            }
        }

        if ( %AlreadySent && $Param{Data}->{ArticleID} && $Param{Data}->{ArticleType} ) {

            # update to field
            my $UpdateToSuccess = $Self->_ArticleToUpdate(
                ArticleID   => $Param{Data}->{ArticleID},
                ArticleType => $Param{Data}->{ArticleType},
                UserIDs     => \%AlreadySent,
                UserID      => $Param{UserID},
            );

            # check for errors
            if ( !$UpdateToSuccess ) {

                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not update To field for Article: $Param{Data}->{ArticleID}.",
                );
            }
        }
    }

    return 1;
}

sub _NotificationFilter {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(Ticket Notification DynamicFieldConfigLookup)) {
        return if !$Param{$Needed};
    }

    # set local values
    my %Notification = %{ $Param{Notification} };

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    KEY:
    for my $Key ( sort keys %{ $Notification{Data} } ) {

        # ignore not ticket related attributes
        next KEY if $Key eq 'Recipients';
        next KEY if $Key eq 'SkipRecipients';
        next KEY if $Key eq 'RecipientAgents';
        next KEY if $Key eq 'RecipientGroups';
        next KEY if $Key eq 'RecipientRoles';
        next KEY if $Key eq 'TransportEmailTemplate';
        next KEY if $Key eq 'Events';
        next KEY if $Key eq 'ArticleTypeID';
        next KEY if $Key eq 'ArticleSenderTypeID';
        next KEY if $Key eq 'ArticleSubjectMatch';
        next KEY if $Key eq 'ArticleBodyMatch';
        next KEY if $Key eq 'ArticleAttachmentInclude';
        next KEY if $Key eq 'NotificationArticleTypeID';
        next KEY if $Key eq 'Transports';
        next KEY if $Key eq 'OncePerDay';
        next KEY if $Key eq 'VisibleForAgent';
        next KEY if $Key eq 'VisibleForAgentTooltip';
        next KEY if $Key eq 'LanguageID';
        next KEY if $Key eq 'SendOnOutOfOffice';
        next KEY if $Key eq 'AgentEnabledByDefault';
        next KEY if $Key eq 'EmailSecuritySettings';
        next KEY if $Key eq 'EmailSigningCrypting';
        next KEY if $Key eq 'EmailMissingCryptingKeys';
        next KEY if $Key eq 'EmailMissingSigningKeys';
        next KEY if $Key eq 'EmailDefaultSigningKeys';
        next KEY if $Key eq 'NotificationType';

        # check recipient fields from transport methods
        if ( $Key =~ m{\A Recipient}xms ) {
            next KEY;
        }

        # check ticket attributes
        next KEY if !$Notification{Data}->{$Key};
        next KEY if !@{ $Notification{Data}->{$Key} };
        next KEY if !$Notification{Data}->{$Key}->[0];
        my $Match = 0;

        VALUE:
        for my $Value ( @{ $Notification{Data}->{$Key} } ) {

            next VALUE if !$Value;

            # check if key is a search dynamic field
            if ( $Key =~ m{\A Search_DynamicField_}xms ) {

                # remove search prefix
                my $DynamicFieldName = $Key;

                $DynamicFieldName =~ s{Search_DynamicField_}{};

                # get the dynamic field config for this field
                my $DynamicFieldConfig = $Param{DynamicFieldConfigLookup}->{$DynamicFieldName};

                next VALUE if !$DynamicFieldConfig;

                my $IsNotificationEventCondition = $DynamicFieldBackendObject->HasBehavior(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Behavior           => 'IsNotificationEventCondition',
                );

                next VALUE if !$IsNotificationEventCondition;

                # Get match value from the dynamic field backend, if applicable (bug#12257).
                my $MatchValue;
                my $SearchFieldParameter = $DynamicFieldBackendObject->SearchFieldParameterBuild(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Profile            => {
                        $Key => $Value,
                    },
                );
                if ( defined $SearchFieldParameter->{Parameter}->{Equals} ) {
                    $MatchValue = $SearchFieldParameter->{Parameter}->{Equals};
                }
                else {
                    $MatchValue = $Value;
                }

                $Match = $DynamicFieldBackendObject->ObjectMatch(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $MatchValue,
                    ObjectAttributes   => $Param{Ticket},
                );

                last VALUE if $Match;
            }
            else {

                if ( $Value eq $Param{Ticket}->{$Key} ) {
                    $Match = 1;
                    last VALUE;
                }
            }
        }

        return if !$Match;
    }

    # match article types only on ArticleCreate or ArticleSend event
    if (
        ( ( $Param{Event} eq 'ArticleCreate' ) || ( $Param{Event} eq 'ArticleSend' ) )
        && $Param{Data}->{ArticleID}
        )
    {

        my %Article = $Kernel::OM->Get('Kernel::System::Ticket')->ArticleGet(
            ArticleID     => $Param{Data}->{ArticleID},
            UserID        => $Param{UserID},
            DynamicFields => 0,
        );

        # check article type
        if ( $Notification{Data}->{ArticleTypeID} ) {

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ArticleTypeID} } ) {

                next VALUE if !$Value;

                if ( $Value == $Article{ArticleTypeID} ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }

        # check article sender type
        if ( $Notification{Data}->{ArticleSenderTypeID} ) {

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ArticleSenderTypeID} } ) {

                next VALUE if !$Value;

                if ( $Value == $Article{SenderTypeID} ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }

        # check subject & body
        KEY:
        for my $Key (qw(Subject Body)) {

            next KEY if !$Notification{Data}->{ 'Article' . $Key . 'Match' };

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ 'Article' . $Key . 'Match' } } ) {

                next VALUE if !$Value;

                if ( $Article{$Key} =~ /\Q$Value\E/i ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }
    }

    return 1;

}

sub _RecipientsGet {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(Ticket Notification)) {
        return if !$Param{$Needed};
    }

    # set local values
    my %Notification = %{ $Param{Notification} };
    my %Ticket       = %{ $Param{Ticket} };

    # get needed objects
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @RecipientUserIDs;
    my @RecipientUsers;

    # add pre-calculated recipient
    if ( IsArrayRefWithData( $Param{Data}->{Recipients} ) ) {
        push @RecipientUserIDs, @{ $Param{Data}->{Recipients} };
    }

    # remember pre-calculated user recipients for later comparisons
    my %PrecalculatedUserIDs = map { $_ => 1 } @RecipientUserIDs;

    # get recipients by Recipients
    if ( $Notification{Data}->{Recipients} ) {

        # get needed objects
        my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

        RECIPIENT:
        for my $Recipient ( @{ $Notification{Data}->{Recipients} } ) {

            if (
                $Recipient
                =~ /^Agent(Owner|Responsible|Watcher|WritePermissions|MyQueues|MyServices|MyQueuesMyServices)$/
                )
            {

                if ( $Recipient eq 'AgentOwner' ) {
                    push @{ $Notification{Data}->{RecipientAgents} }, $Ticket{OwnerID};
                }
                elsif ( $Recipient eq 'AgentResponsible' ) {

                    # add the responsible agent to the notification list
                    if ( $ConfigObject->Get('Ticket::Responsible') && $Ticket{ResponsibleID} ) {

                        push @{ $Notification{Data}->{RecipientAgents} },
                            $Ticket{ResponsibleID};
                    }
                }
                elsif ( $Recipient eq 'AgentWatcher' ) {

                    # is not needed to check Ticket::Watcher,
                    # its checked on TicketWatchGet function
                    push @{ $Notification{Data}->{RecipientAgents} }, $TicketObject->TicketWatchGet(
                        TicketID => $Param{Data}->{TicketID},
                        Result   => 'ARRAY',
                    );
                }
                elsif ( $Recipient eq 'AgentWritePermissions' ) {

                    my $GroupID = $QueueObject->GetQueueGroupID(
                        QueueID => $Ticket{QueueID},
                    );

                    my %UserList = $GroupObject->PermissionGroupUserGet(
                        GroupID => $GroupID,
                        Type    => 'rw',
                        UserID  => $Param{UserID},
                    );

                    my %RoleList = $GroupObject->PermissionGroupRoleGet(
                        GroupID => $GroupID,
                        Type    => 'rw',
                    );
                    for my $RoleID ( sort keys %RoleList ) {
                        my %RoleUserList = $GroupObject->PermissionRoleUserGet(
                            RoleID => $RoleID,
                        );
                        %UserList = ( %RoleUserList, %UserList );
                    }

                    my @UserIDs = sort keys %UserList;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyQueues' ) {

                    # get subscribed users
                    my %MyQueuesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByQueueID(
                        QueueID => $Ticket{QueueID}
                    );

                    my @UserIDs = sort keys %MyQueuesUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyServices' ) {

                    # get subscribed users
                    my %MyServicesUserIDs;
                    if ( $Ticket{ServiceID} ) {
                        %MyServicesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByServiceID(
                            ServiceID => $Ticket{ServiceID},
                        );
                    }

                    my @UserIDs = sort keys %MyServicesUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyQueuesMyServices' ) {

                    # get subscribed users
                    my %MyQueuesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByQueueID(
                        QueueID => $Ticket{QueueID}
                    );

                    # get subscribed users
                    my %MyServicesUserIDs;
                    if ( $Ticket{ServiceID} ) {
                        %MyServicesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByServiceID(
                            ServiceID => $Ticket{ServiceID},
                        );
                    }

                    # combine both subscribed users list (this will also remove duplicates)
                    my %SubscribedUserIDs = ( %MyQueuesUserIDs, %MyServicesUserIDs );

                    for my $UserID ( sort keys %SubscribedUserIDs ) {
                        if ( !$MyQueuesUserIDs{$UserID} || !$MyServicesUserIDs{$UserID} ) {
                            delete $SubscribedUserIDs{$UserID};
                        }
                    }

                    my @UserIDs = sort keys %SubscribedUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
            }

            # Other OTRS packages might add other kind of recipients that are normally handled by
            #   other modules then an elsif condition here is useful.
            elsif ( $Recipient eq 'Customer' ) {

                # get old article for quoting
                my %Article = $TicketObject->ArticleLastCustomerArticle(
                    TicketID      => $Param{Data}->{TicketID},
                    DynamicFields => 0,
                );

                # If the ticket has no articles yet, get the raw ticket data
                if ( !%Article ) {
                    %Article = $TicketObject->TicketGet(
                        TicketID      => $Param{Data}->{TicketID},
                        DynamicFields => 0,
                    );
                }

                my %Recipient;

                # ArticleLastCustomerArticle() returns the latest customer article but if there
                # is no customer article, it returns the latest agent article. In this case
                # notification must not be send to the "From", but to the "To" article field.

                # Check if we actually do have an article
                if ( defined $Article{SenderType} ) {
                    if ( $Article{SenderType} eq 'customer' ) {
                        $Recipient{UserEmail} = $Article{From};
                    }
                    else {
                        $Recipient{UserEmail} = $Article{To};
                    }
                }
                $Recipient{Type} = 'Customer';

                # check if customer notifications should be send
                if (
                    $ConfigObject->Get('CustomerNotifyJustToRealCustomer')
                    && !$Article{CustomerUserID}
                    )
                {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'info',
                        Message  => 'Send no customer notification because no customer is set!',
                    );
                    next RECIPIENT;
                }

                # get language and send recipient
                $Recipient{Language} = $ConfigObject->Get('DefaultLanguage') || 'en';

                if ( $Article{CustomerUserID} ) {

                    my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
                        User => $Article{CustomerUserID},

                    );

                    # join Recipient data with CustomerUser data
                    %Recipient = ( %Recipient, %CustomerUser );

                    # get user language
                    if ( $CustomerUser{UserLanguage} ) {
                        $Recipient{Language} = $CustomerUser{UserLanguage};
                    }
                }

                # get real name
                if ( $Article{CustomerUserID} ) {
                    $Recipient{Realname} = $CustomerUserObject->CustomerName(
                        UserLogin => $Article{CustomerUserID},
                    );
                }
                if ( !$Recipient{Realname} ) {
                    $Recipient{Realname} = $Article{From} || '';
                    $Recipient{Realname} =~ s/<.*>|\(.*\)|\"|;|,//g;
                    $Recipient{Realname} =~ s/( $)|(  $)//g;
                }

                push @RecipientUsers, \%Recipient;
            }
# ---
# OTRSCustomContactFields
# ---
            elsif ( $Recipient =~ /Contact*/ ) {

                # get contact dynamic fields
                my $DynamicFieldsCustomer = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
                    Valid       => 1,
                    ObjectType  => ['Ticket'],
                    FieldType   => 'Customer',
                );

                # init contacts
                my @ContactsTo;
                my @ContactsCc;
                my @ContactsBcc;

                # init dynamic fields
                my $DynamicFieldTo;
                my $DynamicFieldCc;
                my $DynamicFieldBcc;

                next RECIPIENT if !IsArrayRefWithData($DynamicFieldsCustomer);

                # get backend object
                my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

                # check for contacts
                DYNAMICFIELD:
                for my $DynamicFieldConfig ( @{$DynamicFieldsCustomer} ) {
                    next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

                    # Fallback if UseForNotification is not set
                    if ( !$DynamicFieldConfig->{Config}->{UseForNotification} ) {
                        if ( $Recipient =~ /Contact_TO*/ || $Recipient eq 'Contact' ) {
                            my $Value = $DynamicFieldBackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $Param{Data}->{TicketID},
                            );

                            next DYNAMICFIELD if !$Value;

                            push @ContactsTo, @{$Value};
                        }
                    }

                    if ( $DynamicFieldConfig->{Config}->{UseForNotification} && index($DynamicFieldConfig->{Config}->{UseForNotification}, 'To') != -1 ) {
                        if ( $Recipient =~ /Contact_TO*/ || $Recipient eq 'Contact' ) {
                            next DYNAMICFIELD if $Recipient ne 'Contact_TO_' . $DynamicFieldConfig->{Name};
                            my $Value = $DynamicFieldBackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $Param{Data}->{TicketID},
                            );

                            next DYNAMICFIELD if !$Value;

                            push @ContactsTo, @{$Value};
                        }
                    }

                    if ( $DynamicFieldConfig->{Config}->{UseForNotification} && index($DynamicFieldConfig->{Config}->{UseForNotification}, 'Cc') != -1 ) {
                        if ( $Recipient =~ /Contact_CC*/ ) {
                            next DYNAMICFIELD if $Recipient ne 'Contact_CC_' . $DynamicFieldConfig->{Name};
                            my $Value = $DynamicFieldBackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $Param{Data}->{TicketID},
                            );

                            next DYNAMICFIELD if !$Value;

                            push @ContactsCc, @{$Value};
                        }
                    }

                    if ( $DynamicFieldConfig->{Config}->{UseForNotification} && index($DynamicFieldConfig->{Config}->{UseForNotification}, 'Bcc') != -1 ) {
                        if ( $Recipient =~ /Contact_BCC*/ ) {
                            next DYNAMICFIELD if $Recipient ne 'Contact_BCC_' . $DynamicFieldConfig->{Name};
                            my $Value = $DynamicFieldBackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $Param{Data}->{TicketID},
                            );

                            next DYNAMICFIELD if !$Value;

                            push @ContactsBcc, @{$Value};
                        }
                    }

                }
                next RECIPIENT if !@ContactsTo && !@ContactsCc && !@ContactsBcc;

                CUSTOMERLOGINTO:
                for my $CustomerLoginTo (@ContactsTo) {
                    my %RecipientTo = ( Type => 'Contact' );

                    # check for customer email address
                    my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
                        User => $CustomerLoginTo,
                    );
                    if ( !$CustomerUser{UserEmail} ) {
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'info',
                            Message  => "Send no customer notification because of missing "
                                . "customer email (CustomerUserID=$CustomerLoginTo)!",
                        );
                        next CUSTOMERLOGINTO;
                    }

                    # join Recipient data with CustomerUser data
                    %RecipientTo = ( %RecipientTo, %CustomerUser );

                    # get language and send recipient
                    $RecipientTo{Language} = $ConfigObject->Get('DefaultLanguage') || 'en';
                    if ( $CustomerUser{UserLanguage} ) {
                        $RecipientTo{Language} = $CustomerUser{UserLanguage};
                    }

                    # get real name
                    $RecipientTo{Realname} = $CustomerUserObject->CustomerName(
                        UserLogin => $CustomerLoginTo,
                    ) || '';

                    $RecipientTo{UserID} = $CustomerLoginTo;
                    $RecipientTo{SendType} = 'To';
                    push @RecipientUsers, \%RecipientTo;
                }

                CUSTOMERLOGINCC:
                for my $CustomerLoginCc (@ContactsCc) {
                    my %RecipientCc = ( Type => 'Contact' );

                    # check for customer email address
                    my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
                        User => $CustomerLoginCc,
                    );
                    if ( !$CustomerUser{UserEmail} ) {
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'info',
                            Message  => "Send no customer notification because of missing "
                                . "customer email (CustomerUserID=$CustomerLoginCc)!",
                        );
                        next CUSTOMERLOGINCC;
                    }

                    # join Recipient data with CustomerUser data
                    %RecipientCc = ( %RecipientCc, %CustomerUser );

                    # get language and send recipient
                    $RecipientCc{Language} = $ConfigObject->Get('DefaultLanguage') || 'en';
                    if ( $CustomerUser{UserLanguage} ) {
                        $RecipientCc{Language} = $CustomerUser{UserLanguage};
                    }

                    # get real name
                    $RecipientCc{Realname} = $CustomerUserObject->CustomerName(
                        UserLogin => $CustomerLoginCc,
                    ) || '';

                    $RecipientCc{UserID} = $CustomerLoginCc;
                    $RecipientCc{SendType} = 'Cc';
                    push @RecipientUsers, \%RecipientCc;
                }

                CUSTOMERLOGINBCC:
                for my $CustomerLoginBcc (@ContactsBcc) {
                    my %RecipientBcc = ( Type => 'Contact' );

                    # check for customer email address
                    my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
                        User => $CustomerLoginBcc,
                    );
                    if ( !$CustomerUser{UserEmail} ) {
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'info',
                            Message  => "Send no customer notification because of missing "
                                . "customer email (CustomerUserID=$CustomerLoginBcc)!",
                        );
                        next CUSTOMERLOGINBCC;
                    }

                    # join Recipient data with CustomerUser data
                    %RecipientBcc = ( %RecipientBcc, %CustomerUser );

                    # get language and send recipient
                    $RecipientBcc{Language} = $ConfigObject->Get('DefaultLanguage') || 'en';
                    if ( $CustomerUser{UserLanguage} ) {
                        $RecipientBcc{Language} = $CustomerUser{UserLanguage};
                    }

                    # get real name
                    $RecipientBcc{Realname} = $CustomerUserObject->CustomerName(
                        UserLogin => $CustomerLoginBcc,
                    ) || '';

                    $RecipientBcc{UserID} = $CustomerLoginBcc;
                    $RecipientBcc{SendType} = 'Bcc';
                    push @RecipientUsers, \%RecipientBcc;
                }
            }
# ---
        }
    }

    # add recipient agents
    if ( IsArrayRefWithData( $Notification{Data}->{RecipientAgents} ) ) {
        push @RecipientUserIDs, @{ $Notification{Data}->{RecipientAgents} };
    }

    # hash to keep track which agents are already receiving this notification
    my %AgentUsed = map { $_ => 1 } @RecipientUserIDs;

    # get recipients by RecipientGroups
    if ( $Notification{Data}->{RecipientGroups} ) {

        RECIPIENT:
        for my $GroupID ( @{ $Notification{Data}->{RecipientGroups} } ) {

            my %GroupMemberList = $GroupObject->PermissionGroupUserGet(
                GroupID => $GroupID,
                Type    => 'ro',
            );

            GROUPMEMBER:
            for my $UserID ( sort keys %GroupMemberList ) {

                next GROUPMEMBER if $UserID == 1;
                next GROUPMEMBER if $AgentUsed{$UserID};

                $AgentUsed{$UserID} = 1;

                push @RecipientUserIDs, $UserID;
            }
        }
    }

    # get recipients by RecipientRoles
    if ( $Notification{Data}->{RecipientRoles} ) {

        RECIPIENT:
        for my $RoleID ( @{ $Notification{Data}->{RecipientRoles} } ) {

            my %RoleMemberList = $GroupObject->PermissionRoleUserGet(
                RoleID => $RoleID,
            );

            ROLEMEMBER:
            for my $UserID ( sort keys %RoleMemberList ) {

                next ROLEMEMBER if $UserID == 1;
                next ROLEMEMBER if $AgentUsed{$UserID};

                $AgentUsed{$UserID} = 1;

                push @RecipientUserIDs, $UserID;
            }
        }
    }

    # get needed objects
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    my %SkipRecipients;
    if ( IsArrayRefWithData( $Param{Data}->{SkipRecipients} ) ) {
        %SkipRecipients = map { $_ => 1 } @{ $Param{Data}->{SkipRecipients} };
    }

    # agent 1 should not receive notifications
    $SkipRecipients{'1'} = 1;

    # remove recipients should not receive a notification
    @RecipientUserIDs = grep { !$SkipRecipients{$_} } @RecipientUserIDs;

    # get valid users list
    my %ValidUsersList = $UserObject->UserList(
        Type          => 'Short',
        Valid         => 1,
        NoOutOfOffice => 0,
    );

    # remove invalid users
    @RecipientUserIDs = grep { $ValidUsersList{$_} } @RecipientUserIDs;

    # remove duplicated
    my %TempRecipientUserIDs = map { $_ => 1 } @RecipientUserIDs;
    @RecipientUserIDs = sort keys %TempRecipientUserIDs;

    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # get current time-stamp
    my $Time = $TimeObject->SystemTime();

    # get all data for recipients as they should be needed by all notification transports
    RECIPIENT:
    for my $UserID (@RecipientUserIDs) {

        my %User = $UserObject->GetUserData(
            UserID => $UserID,
            Valid  => 1,
        );
        next RECIPIENT if !%User;

        # skip user that triggers the event (it should not be notified) but only if it is not
        #   a pre-calculated recipient
        if (
            !$ConfigObject->Get('AgentSelfNotifyOnAction')
            && $User{UserID} == $Param{UserID}
            && !$PrecalculatedUserIDs{ $Param{UserID} }
            )
        {
            next RECIPIENT;
        }

        # skip users out of the office if configured
        if ( !$Notification{Data}->{SendOnOutOfOffice} && $User{OutOfOffice} ) {
            my $Start = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $User{OutOfOfficeStartYear}, $User{OutOfOfficeStartMonth},
                $User{OutOfOfficeStartDay}
            );
            my $TimeStart = $TimeObject->TimeStamp2SystemTime(
                String => $Start,
            );
            my $End = sprintf(
                "%04d-%02d-%02d 23:59:59",
                $User{OutOfOfficeEndYear}, $User{OutOfOfficeEndMonth},
                $User{OutOfOfficeEndDay}
            );
            my $TimeEnd = $TimeObject->TimeStamp2SystemTime(
                String => $End,
            );

            next RECIPIENT if $TimeStart < $Time && $TimeEnd > $Time;
        }

        # skip users with out ro permissions
        my $Permission = $TicketObject->TicketPermission(
            Type     => 'ro',
            TicketID => $Ticket{TicketID},
            UserID   => $User{UserID}
        );

        next RECIPIENT if !$Permission;

        # skip PostMasterUserID
        my $PostmasterUserID = $ConfigObject->Get('PostmasterUserID') || 1;
        next RECIPIENT if $User{UserID} == $PostmasterUserID;

        $User{Type} = 'Agent';

        push @RecipientUsers, \%User;
    }

    return @RecipientUsers;
}

sub _SendRecipientNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID UserID Notification Recipient Event Transport TransportObject)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
        }
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check if the notification needs to be sent just one time per day
    if ( $Param{Notification}->{Data}->{OncePerDay} && $Param{Recipient}->{UserLogin} ) {

        # get ticket history
        my @HistoryLines = $TicketObject->HistoryGet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
        );

        # get last notification sent ticket history entry for this transport and this user
        my $LastNotificationHistory = first {
            $_->{HistoryType} eq 'SendAgentNotification'
                && $_->{Name} eq
                "\%\%$Param{Notification}->{Name}\%\%$Param{Recipient}->{UserLogin}\%\%$Param{Transport}"
        }
        reverse @HistoryLines;

        if ( $LastNotificationHistory && $LastNotificationHistory->{CreateTime} ) {

            # get time object
            my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

            # get last notification date
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay ) = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->TimeStamp2SystemTime(
                    String => $LastNotificationHistory->{CreateTime},
                    )
            );

            # get current date
            my ( $CurrSec, $CurrMin, $CurrHour, $CurrDay, $CurrMonth, $CurrYear, $CurrWeekDay )
                = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->SystemTime(),
                );

            # do not send the notification if it has been sent already today
            if (
                $CurrYear == $Year
                && $CurrMonth == $Month
                && $CurrDay == $Day
                )
            {
                return;
            }
        }
    }

# ---
# OTRSCustomContactFields
# ---
#    my $TransportObject = $Param{TransportObject};
    my $TransportObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::OTRSCustomContactFieldsEmail');
# ---

    # send notification to each recipient
    my $Success = $TransportObject->SendNotification(
        TicketID              => $Param{TicketID},
        UserID                => $Param{UserID},
        Notification          => $Param{Notification},
        CustomerMessageParams => $Param{CustomerMessageParams},
        Recipient             => $Param{Recipient},
        Event                 => $Param{Event},
        Attachments           => $Param{Attachments},
    );

    return if !$Success;

    if (
        $Param{Recipient}->{Type} eq 'Agent'
        && $Param{Recipient}->{UserLogin}
        )
    {

        # write history
        $TicketObject->HistoryAdd(
            TicketID     => $Param{TicketID},
            HistoryType  => 'SendAgentNotification',
            Name         => "\%\%$Param{Notification}->{Name}\%\%$Param{Recipient}->{UserLogin}\%\%$Param{Transport}",
            CreateUserID => $Param{UserID},
        );
    }

    my %EventData = %{ $TransportObject->GetTransportEventData() };

    return 1 if !%EventData;

    if ( !$EventData{Event} || !$EventData{Data} || !$EventData{UserID} ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not trigger notification post send event",
        );

        return;
    }

    # ticket event
    $TicketObject->EventHandler(
        %EventData,
    );

    return 1;
}

sub _ArticleToUpdate {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(ArticleID ArticleType UserIDs UserID)) {
        return if !$Param{$Needed};
    }

    # not update for User 1
    return 1 if $Param{UserID} eq 1;

    # get needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # not update if its not a note article
    return 1 if $Param{ArticleType} !~ /^note\-/;

    my $NewTo = $Param{To} || '';
    for my $UserID ( sort keys %{ $Param{UserIDs} } ) {
        my %UserData = $UserObject->GetUserData(
            UserID => $UserID,
            Valid  => 1,
        );
        if ($NewTo) {
            $NewTo .= ', ';
        }
        $NewTo .= "$UserData{UserFirstname} $UserData{UserLastname} <$UserData{UserEmail}>";
    }

    # not update if To is the same
    return 1 if !$NewTo;

    return if !$DBObject->Do(
        SQL  => 'UPDATE article SET a_to = ? WHERE id = ?',
        Bind => [ \$NewTo, \$Param{ArticleID} ],
    );

    return 1;
}

1;