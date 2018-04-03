# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentVideoChat;

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
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( !$ConfigObject->Get('ChatEngine::Active') ) {
        return $LayoutObject->FatalError(
            Message => Translatable('Chat is not active.'),
        );
    }

    my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    my $ChatStartingAgentsGroup  = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatStartingAgents');
    my $VideoChatAgentsGroup     = $ConfigObject->Get('ChatEngine::PermissionGroup::VideoChatAgents');

    if (
        $Self->{UserID} != 1
        && (
            !$ChatReceivingAgentsGroup
            || !$ChatStartingAgentsGroup
            || !$VideoChatAgentsGroup
            || (
                !$LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
                && !$LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
                && !$LayoutObject->{"UserIsGroup[$VideoChatAgentsGroup]"}
            )
        )
        )
    {
        return $LayoutObject->FatalError(
            Message => 'No permission.',
            Info    => 'Please contact.'
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
    for my $Param (qw(ChatID TargetID TargetType)) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );

        if ( !$GetParam{$Param} ) {
            return $LayoutObject->FatalError(
                Message => Translatable('Need') . ' ' . $Param . '.',
            );
        }
    }

    # Get optional parameters.
    $GetParam{RequestSent}  = $ParamObject->GetParam( Param => 'RequestSent' )  // '';
    $GetParam{InviteAccept} = $ParamObject->GetParam( Param => 'InviteAccept' ) // '';
    $GetParam{NoVideo}      = $ParamObject->GetParam( Param => 'NoVideo' )      // '';

    # check if user is chat participant
    my $Access = $ChatObject->ChatParticipantCheck(
        ChatID      => $GetParam{ChatID},
        ChatterID   => $Self->{UserID},
        ChatterType => 'User',
    );

    if ( !$Access ) {
        return $LayoutObject->FatalError(
            Message => Translatable('You are not participant in this chat!'),
        );
    }

    # TURN servers configuration
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

    # Get target name from participant list.
    my @Participants = $ChatObject->ChatParticipantList(
        ChatID => $GetParam{ChatID},
    );

    my $TargetName;

    PARTICIPANT:
    for my $Participant (@Participants) {
        if (
            $Participant->{ChatterID} eq $GetParam{TargetID}
            && $Participant->{ChatterType} eq $GetParam{TargetType}
            )
        {
            $TargetName = $Participant->{ChatterName};
            last PARTICIPANT;
        }
    }

    my $Output = $LayoutObject->Header(
        Value => $GetParam{NoVideo}
        ? $LayoutObject->{LanguageObject}->Translate('Audio call')
        : $LayoutObject->{LanguageObject}->Translate('Video call'),
        Type => 'Small',
    );
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentVideoChat',
        Data         => {
            %GetParam,
            RequesterID   => $Self->{UserID},
            RequesterType => 'User',
            TargetName    => $TargetName,
        },
    );
    $Output .= $LayoutObject->Footer(
        Type => 'Small',
    );

    return $Output;
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

1;
