# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Notification::ChatAvailabilityCheck;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::User',
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get UserID param
    $Self->{UserID} = $Param{UserID} || die "Got no UserID!";

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # Check if Chat is active
    if ( $ConfigObject->Get('ChatEngine::Active') ) {
        my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');
        if (
            $Self->{UserID} != -1
            && $ChatReceivingAgentsGroup
            && $LayoutObject->{"UserIsGroup[$ChatReceivingAgentsGroup]"}
            && $ConfigObject->Get('Ticket::Agent::UnavailableForExternalChatsOnLogin')
            )
        {
            # Check user preferences
            my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
                UserID => $Self->{UserID},
            );

            if (
                defined $Preferences{ChatAvailabilityNotification}
                &&
                $Preferences{ChatAvailabilityNotification}
                )
            {
                # Display message, but this time only (reset ChatAvailabilityNotification)
                $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                    Key    => 'ChatAvailabilityNotification',
                    Value  => '0',
                    UserID => $Self->{UserID},
                );

                return $LayoutObject->Notify(
                    Priority => 'Notice',
                    Link     => $LayoutObject->{Baselink} . 'Action=AgentChat;Subaction=SetAvailability;Availability=2',
                    LinkClass => 'AvailabilityNotification',
                    Data =>
                        $LayoutObject->{LanguageObject}
                        ->Translate("You are unavailable for external chats. Would you like to go online?"),
                );
            }
        }
    }

    return '';
}

1;
