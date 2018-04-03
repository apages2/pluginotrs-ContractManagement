# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentChatAvailability;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{Config} = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    if ( !$Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::Active') ) {
        return $LayoutObject->FatalError(
            Message => "Chat is not active.",
        );
    }

    my $ChatReceivingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
    my $ChatStartingAgentsGroup
        = $Kernel::OM->Get('Kernel::Config')->Get('ChatEngine::PermissionGroup::ChatStartingAgents');

    if (
        $Self->{UserID} != 1
        && (
            !$ChatReceivingAgentsGroup
            || !$ChatStartingAgentsGroup
            || (
                !$LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
                && !$LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
            )
        )
        )
    {
        return $LayoutObject->FatalError(
            Message => "No permission.",
        );
    }

    my %Preferences = $UserObject->GetPreferences(
        UserID => $Self->{UserID},
    );

    # Get current availability
    my $ChatAvailability = $Preferences{ChatAvailability} || '0';

    if ( $Self->{Subaction} eq 'Toogle' ) {

        # Increment
        $ChatAvailability++;

        # Reset if needed
        $ChatAvailability = 0 if $ChatAvailability == 3;

        # Store in preferences
        my $Success = $UserObject->SetPreferences(
            Key    => 'ChatAvailability',
            Value  => $ChatAvailability,
            UserID => $Self->{UserID},
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $LayoutObject->JSONEncode( Data => $ChatAvailability ),
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
