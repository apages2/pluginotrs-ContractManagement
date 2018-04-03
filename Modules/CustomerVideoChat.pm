# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerVideoChat;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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

    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
        return $Self->ErrorResponse(
            Message => Translatable('Chat is not active.'),
        );
    }

    if ( $Self->{Subaction} eq 'SignalSend' ) {
        return $Self->SignalSend();
    }
    elsif ( $Self->{Subaction} eq 'SignalReceive' ) {
        return $Self->SignalReceive();
    }

    return $Self->VideoChatScreen();
}

sub VideoChatScreen {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');

    my %GetParam;
    for my $Param (qw(ChatID)) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );

        if ( !$GetParam{$Param} ) {
            return $Self->ErrorResponse(
                Message => Translatable('Need') . ' ' . $Param . '.',
            );
        }
    }

    # Get optional parameters.
    $GetParam{InviteAccept} = $ParamObject->GetParam( Param => 'InviteAccept' ) // '';
    $GetParam{NoVideo}      = $ParamObject->GetParam( Param => 'NoVideo' )      // '';

    # check if user is chat participant
    my %ChatParticipant = $ChatObject->ChatParticipantCheck(
        ChatID      => $GetParam{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'Customer',
    );

    if ( !%ChatParticipant ) {
        return $Self->ErrorResponse(
            Message => "No permission.",
        );
    }

    # get TURN servers configuration
    my $TURNServers = $Kernel::OM->Get('Kernel::System::VideoChat')->OTRSBusinessTURNServerGet();

    my $Count = 1;
    for my $TURNServer ( @{ $TURNServers || [] } ) {
        $LayoutObject->Block(
            Name => 'TURNServer',
            Data => {
                JSONConfig => $LayoutObject->JSONEncode( Data => $TURNServer ),
            },
        );
        $LayoutObject->Block(
            Name => 'TURNServerComma',
        ) if $Count++ < scalar @{$TURNServers};
    }

    # get chat participants
    my @Participants = $ChatObject->ChatParticipantList(
        ChatID => $GetParam{ChatID},
    );

    my $TargetUser;

    PARTICIPANT:
    for my $Participant (@Participants) {

        # skip non-agents, inactive participants and observers
        next PARTICIPANT if $Participant->{ChatterType} ne 'User';
        next PARTICIPANT if $Participant->{ChatterActive} != 1;
        next PARTICIPANT if $Participant->{PermissionLevel} eq 'Observer';

        $TargetUser = $Participant;

        last PARTICIPANT;
    }

    my $DefaultAgentName = $ConfigObject->Get('ChatEngine::DefaultAgentName') || '';

    # add numbers to DefaultAgentNames if needed
    # only do this if DefaultAgentName is available
    # otherwise we're using real agent names
    if (
        $ConfigObject->Get('ChatEngine::DefaultAgentNameNumbers')
        && $DefaultAgentName
        )
    {
        # get ChatterNumber
        my $ChatterNumber = $ChatObject->ChatParticipantNumberGet(
            ChatID      => $GetParam{ChatID},
            ChatterName => $TargetUser->{ChatterName},
        );

        $TargetUser->{ChatterName} = $DefaultAgentName . $ChatterNumber;
    }

    if ($TargetUser) {
        return $LayoutObject->Output(
            TemplateFile => 'CustomerVideoChat',
            Data         => {
                %GetParam,
                RequesterID   => $Self->{UserID},
                RequesterType => 'Customer',
                TargetID      => $TargetUser->{ChatterID},
                TargetType    => 'User',
                TargetName    => $TargetUser->{ChatterName},
            },
        );
    }
    else {
        return;
    }
}

sub SignalSend {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $VideoChatObject = $Kernel::OM->Get('Kernel::System::VideoChat');

    my %GetParam;
    for my $Param (qw(ChatID RequesterID RequesterType TargetID TargetType SignalKey SignalValue)) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );

        if ( !$GetParam{$Param} ) {
            return $LayoutObject->FatalError(
                Message => Translatable('Need') . ' ' . $Param . '.',
            );
        }
    }

    my %Data;
    $Data{Success} = $VideoChatObject->SendSignal(
        %GetParam,
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Data ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub SignalReceive {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $VideoChatObject = $Kernel::OM->Get('Kernel::System::VideoChat');

    my %GetParam;
    for my $Param (qw(ChatID TargetID TargetType)) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );

        if ( !$GetParam{$Param} ) {
            return $LayoutObject->FatalError(
                Message => Translatable('Need') . ' ' . $Param . '.',
            );
        }
    }

    my %Data = (
        Success => 1,
        Signals => $VideoChatObject->ReceiveSignals(
            %GetParam,
        ),
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => \%Data ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub ErrorResponse {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # In case of an AJAX request we don't want an error HTML page.
    #   We'll just redirect to the chat completed page
    if ( $Kernel::OM->Get('Kernel::System::Web::Request')->IsAJAXRequest() ) {
        my %Response = (
            Redirect => '?Action=CustomerChat;Subaction=ChatCompleted',
        );
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $LayoutObject->JSONEncode( Data => \%Response ),
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    return $LayoutObject->CustomerFatalError(
        Message => $Param{Message},
    );
}

1;
