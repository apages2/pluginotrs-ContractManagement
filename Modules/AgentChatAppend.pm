# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentChatAppend;

use strict;
use warnings;

use Mail::Address;

use Kernel::System::CheckItem;
use Kernel::System::CustomerUser;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Chat',
    'Kernel::System::CheckItem',
    'Kernel::System::CustomerUser',
    'Kernel::System::JSON',
    'Kernel::System::Ticket',
    'Kernel::System::User',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;
    my %Error;
    my %GetParam;

    $Param{FromChatID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FromChatID' );
    $Param{CustomerUser} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'CustomerUser' ) || '';

    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    if ( !$Param{FromChatID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No FromChatID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check for chat permissions
    if ( $GetParam{FromChatID} ) {
        if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
            return $LayoutObject->FatalError(
                Message => "ChatEngine is not active.",
            );
        }

        # Ok, take the chat
        my %ChatParticipant = $Kernel::OM->Get('Kernel::System::Chat')->ChatParticipantCheck(
            ChatID        => $Param{FromChatID},
            ChatterType   => 'User',
            ChatterID     => $Self->{UserID},
            ChatterActive => 1,
        );

        if ( !%ChatParticipant ) {
            return $LayoutObject->FatalError(
                Message => "No permission.",
            );
        }
    }

    # Get permissions for given chat
    my $PermissionLevel = $ChatObject->ChatPermissionLevelGet(
        ChatID => $Param{FromChatID},
        UserID => $Self->{UserID},
    );

    # Check if this user is just an observer
    if ( $PermissionLevel ne 'Participant' && $PermissionLevel ne 'Owner' ) {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    # Get Chat
    my %Chat = $ChatObject->ChatGet(
        ChatID => $Param{FromChatID},
    );

    if ( !%Chat ) {
        return $LayoutObject->FatalError(
            Message => "Chat is not active.",
        );
    }

    # Get Customer data (if exists)
    my %CustomerUser;

    if ( $Chat{RequesterType} eq 'Customer' ) {

        # C2A
        # Get customer
        %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $Chat{RequesterID},
        );
    }
    elsif ( $Chat{TargetType} eq 'Customer' ) {

        # A2C
        # We need to search for customer in participants
        my @Participants = $ChatObject->ChatParticipantList(
            ChatID => $Param{FromChatID},
        );

        PARTICIPANTS:
        for my $Participant (@Participants) {
            if ( $Participant->{ChatterType} eq 'Customer' ) {

                # Get customer
                %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
                    User => $Participant->{ChatterID},
                );

                last PARTICIPANTS;
            }
        }
    }

    # append action
    if ( $Self->{Subaction} eq 'Append' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get all parameters
        for my $Parameter (qw( SearchTicketNumber )) {
            $GetParam{$Parameter}
                = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Parameter ) || '';
        }

        # removing blank spaces from the ticket number
        $Kernel::OM->Get('Kernel::System::CheckItem')->StringClean(
            StringRef => \$GetParam{'SearchTicketNumber'},
            TrimLeft  => 1,
            TrimRight => 1,
        );

        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        # check some stuff
        my $MainTicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $GetParam{'SearchTicketNumber'},
        );

        # check for errors
        if ( !$MainTicketID ) {
            $Error{'SearchTicketNumberInvalid'} = 'ServerError';
        }

        if (%Error) {
            my $Output = $LayoutObject->Header(
                Type      => 'Small',
                BodyClass => 'Popup',
            );

            # Permissions have been checked before
            if ( $Param{FromChatID} ) {
                my @ChatMessages = $Kernel::OM->Get('Kernel::System::Chat')->ChatMessageList(
                    ChatID => $Param{FromChatID},
                );

                for my $Message (@ChatMessages) {
                    $Message->{MessageText} = $LayoutObject->Ascii2Html(
                        Text        => $Message->{MessageText},
                        LinkFeature => 1,
                    );
                }

                $LayoutObject->Block(
                    Name => 'ChatArticlePreview',
                    Data => {
                        ChatMessages => \@ChatMessages,
                    },
                );
            }

            $Output .= $LayoutObject->Output(
                TemplateFile => 'AgentChatAppend',
                Data         => { %Param, %GetParam, %Error },
            );
            $Output .= $LayoutObject->Footer(
                Type => 'Small',
            );
            return $Output;
        }

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # check permissions
        my $Access = $TicketObject->TicketPermission(
            Type     => 'Owner',
            TicketID => $MainTicketID,
            UserID   => $Self->{UserID},
        );

        # error screen, don't show ticket
        if ( !$Access ) {
            return $LayoutObject->NoPermission( WithHeader => 'yes' );
        }

        # do actual appending stuff
        my $ChatObject = $Kernel::OM->Get('Kernel::System::Chat');
        my %Chat       = $ChatObject->ChatGet(
            ChatID => $Param{FromChatID},
        );
        my @ChatMessageList = $ChatObject->ChatMessageList(
            ChatID => $Param{FromChatID},
        );
        my $ChatArticleID;

        if (@ChatMessageList) {
            for my $Message (@ChatMessageList) {
                $Message->{MessageText} = $LayoutObject->Ascii2Html(
                    Text        => $Message->{MessageText},
                    LinkFeature => 1,
                );
            }

            my $JSONBody = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
                Data => \@ChatMessageList,
            );

            my $ChatArticleType = 'chat-internal';
            my $ChatHistoryType = 'AddNote';
            my $ChatSenderType  = 'agent';
            if (
                $Chat{RequesterType} eq 'Customer'
                || $Chat{TargetType} eq 'Customer'
                )
            {

                $ChatArticleType = 'chat-external';
                $ChatHistoryType = 'EmailCustomer';
                $ChatSenderType  = 'customer';
            }

            $ChatArticleID = $TicketObject->ArticleCreate(
                TicketID       => $MainTicketID,
                ArticleType    => $ChatArticleType,
                SenderType     => $ChatSenderType,
                Subject        => $Kernel::OM->Get('Kernel::Language')->Translate('Chat'),
                Body           => $JSONBody,
                From           => "$Self->{UserFirstname} $Self->{UserLastname} <$Self->{UserEmail}>",
                MimeType       => 'application/json',
                Charset        => $LayoutObject->{UserCharset},
                UserID         => $Self->{UserID},
                HistoryType    => $ChatHistoryType,
                HistoryComment => $Self->{Config}->{HistoryComment} || '%%',
            );
        }

        # if new ticket is created
        if ($ChatArticleID) {

            # check is customer actively present
            # it means customer has accepted this chat and not left it!
            my $CustomerPresent = $ChatObject->CustomerPresent(
                ChatID => $Param{FromChatID},
                Active => 1,
            );

            my $Success;

            # if there is no customer present in the chat
            # just remove the chat
            if ( !$CustomerPresent ) {
                $Success = $ChatObject->ChatDelete(
                    ChatID => $Param{FromChatID},
                );
            }

            # otherwise set chat status to closed and inform other agents
            else {
                $Success = $ChatObject->ChatUpdate(
                    ChatID     => $Param{FromChatID},
                    Status     => 'closed',
                    Deprecated => 1,
                );

                my $LeaveMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                    "%s has left the chat.",
                    $Self->_SenderName(),
                );

                $Success = $ChatObject->ChatMessageAdd(
                    ChatID          => $Param{FromChatID},
                    ChatterID       => $Self->{UserID},
                    ChatterType     => 'User',
                    MessageText     => $LeaveMessage,
                    SystemGenerated => 1,
                );

                # time after chat will be removed
                my $ChatTTL = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::ChatTTL');

                my $ChatClosedMessage = $Kernel::OM->Get('Kernel::Language')->Translate(
                    "This chat has been closed and will be removed in %s hours.",
                    $ChatTTL,
                );

                $Success = $ChatObject->ChatMessageAdd(
                    ChatID          => $Param{FromChatID},
                    ChatterID       => $Self->{UserID},
                    ChatterType     => 'User',
                    MessageText     => $ChatClosedMessage,
                    SystemGenerated => 1,
                );

                # remove all AGENT participants from chat
                my @ParticipantsList = $ChatObject->ChatParticipantList(
                    ChatID => $Param{FromChatID},
                );
                CHATPARTICIPANT:
                for my $ChatParticipant (@ParticipantsList) {

                    # skip it this participant is not agent
                    next CHATPARTICIPANT if $ChatParticipant->{ChatterType} ne 'User';

                    # remove this participants from the chat
                    $Success = $ChatObject->ChatParticipantRemove(
                        ChatID      => $Param{FromChatID},
                        ChatterID   => $ChatParticipant->{ChatterID},
                        ChatterType => 'User',
                    );
                }

            }

            # close the popup
            return $LayoutObject->PopupClose(
                URL =>
                    "Action=AgentChat;ChatAppended=1;AppendChatID=$Param{FromChatID};AppendTicketID=$MainTicketID;AppendArticleID=$ChatArticleID",
            );
        }
        else {

            return $LayoutObject->FatalError(
                Message =>
                    "There was an error appending the article. Please check the log file for more information.",
            );
        }
    }

    # append action
    elsif ( $Self->{Subaction} eq 'AJAXTicketSearch' ) {

        # AJAXTicketSearch
        my $Search = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Search' );

        my ( @Tickets, @TicketIDs );

        @TicketIDs = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSearch(
            Result       => 'ARRAY',
            Limit        => 20,
            TicketNumber => "%$Search%",
            UserID       => 1,
        );

        for my $TicketID (@TicketIDs) {
            my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
                TicketID => $TicketID,
                UserID   => 1,
            );

            push @Tickets, {
                TicketNumber => $Ticket{TicketNumber},
                TicketTitle  => $Ticket{Title},
            };
        }

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \@Tickets ),
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    else {

        # append box
        my $Output = $LayoutObject->Header(
            Type      => 'Small',
            BodyClass => 'Popup',
        );

        # if there is a ticket id in chat, find corresponding ticket number
        my $TicketNumber;
        if ( $Chat{TicketID} ) {
            my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
                TicketID => $Chat{TicketID},
                UserID   => 1,                 # always search as root
                Silent   => 1,                 # do log error if the ticket does not exist
            );

            if (%Ticket) {
                $TicketNumber = $Ticket{TicketNumber};
            }
        }

        # Permissions have been checked before
        if ( $Param{FromChatID} ) {
            my @ChatMessages = $Kernel::OM->Get('Kernel::System::Chat')->ChatMessageList(
                ChatID => $Param{FromChatID},
            );

            for my $Message (@ChatMessages) {
                $Message->{MessageText} = $LayoutObject->Ascii2Html(
                    Text        => $Message->{MessageText},
                    LinkFeature => 1,
                );
            }

            $LayoutObject->Block(
                Name => 'ChatArticlePreview',
                Data => {
                    ChatMessages => \@ChatMessages,
                },
            );
        }

        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentChatAppend',
            Data         => {
                %Param,
                CustomerUser       => $CustomerUser{UserLogin},
                SearchTicketNumber => $TicketNumber,
                }
        );
        $Output .= $LayoutObject->Footer(
            Type => 'Small',
        );
        return $Output;
    }
}

sub _SenderName {
    my ( $Self, %Param ) = @_;

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my %UserData   = $UserObject->GetUserData(
        UserID => $Self->{UserID},
    );

    my $RequesterName = $UserData{UserFullname};
    $RequesterName ||= $Self->{UserID};

    return $RequesterName;
}

1;
