# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::TicketMenu::AttachmentView;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Group',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    for my $Needed (qw(UserID)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Ticket} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Ticket!'
        );
        return;
    }

    # check if frontend module registered, if not, do not show action
    if ( $Param{Config}->{Action} ) {
        my $Module = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Module')->{ $Param{Config}->{Action} };
        return if !$Module;
    }

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check permission
    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Param{Config}->{Action}");
    if ($Config) {
        if ( $Config->{Permission} ) {
            my $AccessOk = $TicketObject->TicketPermission(
                Type     => $Config->{Permission},
                TicketID => $Param{Ticket}->{TicketID},
                UserID   => $Self->{UserID},
                LogNo    => 1,
            );
            return if !$AccessOk;
        }
        if ( $Config->{RequiredLock} ) {
            if (
                $TicketObject->TicketLockGet( TicketID => $Param{Ticket}->{TicketID} )
                )
            {
                my $AccessOk = $TicketObject->OwnerCheck(
                    TicketID => $Param{Ticket}->{TicketID},
                    OwnerID  => $Self->{UserID},
                );
                return if !$AccessOk;
            }
        }
    }

    # group check
    if ( $Param{Config}->{Group} ) {
        my @Items = split /;/, $Param{Config}->{Group};
        my $AccessOk;
        ITEM:
        for my $Item (@Items) {
            my ( $Permission, $Name ) = split /:/, $Item;
            if ( !$Permission || !$Name ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Invalid config for Key Group: '$Item'! "
                        . "Need something like '\$Permission:\$Group;'",
                );
            }
            my @Groups = $Kernel::OM->Get('Kernel::System::Group')->GroupMemberList(
                UserID => $Self->{UserID},
                Type   => $Permission,
                Result => 'Name',
            );
            next ITEM if !@Groups;

            GROUP:
            for my $Group (@Groups) {
                if ( $Group eq $Name ) {
                    $AccessOk = 1;
                    last GROUP;
                }
            }
        }
        return if !$AccessOk;
    }

    # check acl
    return
        if defined $Param{ACL}->{ $Param{Config}->{Action} }
        && !$Param{ACL}->{ $Param{Config}->{Action} };

    # check if attachments exist for this ticket
    # get articles
    my @ArticleIndex = $TicketObject->ArticleIndex(
        TicketID => $Param{Ticket}->{TicketID},
        UserID   => $Self->{UserID},
    );

    my @Attachments;
    ARTICLEID:
    for my $ArticleID (@ArticleIndex) {

        # read attachments
        my %Index = $TicketObject->ArticleAttachmentIndex(
            ArticleID                  => $ArticleID,
            UserID                     => $Self->{UserID},
            StripPlainBodyAsAttachment => 1,
        );

        next ARTICLEID if !( keys %Index );

        FILEID:
        for my $FileID ( sort keys %Index ) {
            my %Attachment = $TicketObject->ArticleAttachment(
                ArticleID => $ArticleID,
                FileID    => $FileID,
                UserID    => $Self->{UserID},
            );

            # return item
            return { %{ $Param{Config} }, %{ $Param{Ticket} }, %Param };
        }
    }

    # no attachments
    return;

}

1;
