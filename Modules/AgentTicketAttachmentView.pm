# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::OTRS::Perl::SyntaxCheck)

package Kernel::Modules::AgentTicketAttachmentView;

use strict;
use warnings;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get subaction
    $Self->{Subaction} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Subaction' ) || '';

    # define mapping for file types
    my %IconClassFileTypes = (
        'fa-file-image-o' => '^image/',
        'fa-file-pdf-o'   => 'application/pdf',
        'fa-file-word-o' =>
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document|application/vnd.oasis.opendocument.text|application/msword|application/rtf|text/rtf|application/vnd.openxmlformats-officedocument.wordprocessingml.template',
        'fa-file-excel-o' =>
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|application/msexcel|application/vnd.ms-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.template',
        'fa-file-powerpoint-o' =>
            'application/vnd.ms-powerpoint|application/mspowerpoint|application/vnd.openxmlformats-officedocument.presentationml.presentation|application/vnd.openxmlformats-officedocument.presentationml.template|application/vnd.openxmlformats-officedocument.presentationml.slideshow',
        'fa-file-audio-o' => '^audio/',
        'fa-file-video-o' => '^video/',
        'fa-file-archive-o' =>
            'application/x-zip-compressed|application/gzip|application/zip|application/x-rar-compressed|application/x-gtar',
    );
    $Self->{IconClassFileTypes} = \%IconClassFileTypes;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check needed stuff
    if ( !$Self->{TicketID} ) {

        # error page
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    if (
        !$TicketObject->TicketPermission(
            Type     => 'ro',
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID},
        )
        )
    {

        # error screen, don't show ticket
        return $LayoutObject->NoPermission( WithHeader => 'yes' );
    }

    # get ACL restrictions
    $TicketObject->TicketAcl(
        Data          => '-',
        TicketID      => $Self->{TicketID},
        ReturnType    => 'Action',
        ReturnSubType => '-',
        UserID        => $Self->{UserID},
    );
    my %AclAction = $TicketObject->TicketAclActionData();

    # check if ACL resctictions if exist
    if ( IsHashRefWithData( \%AclAction ) ) {

        # show error screen if ACL prohibits this action
        if ( defined $AclAction{ $Self->{Action} } && $AclAction{ $Self->{Action} } eq '0' ) {
            return $LayoutObject->NoPermission( WithHeader => 'yes' );
        }
    }

    my %Ticket = $TicketObject->TicketGet( TicketID => $Self->{TicketID} );
    my $Tn = $TicketObject->TicketNumberLookup( TicketID => $Self->{TicketID} );

    # get articles
    my @ArticleIndex = $TicketObject->ArticleIndex(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

    # check subaction
    if ( $Self->{Subaction} eq "DownloadAttachments" ) {
        my @SelectedAttachments = $Kernel::OM->Get('Kernel::System::Web::Request')->GetArray( Param => 'Checkbox' );
        my %Filenames;
        my $ZipObject = Archive::Zip->new();

        if (@SelectedAttachments) {
            my %ArticleIDs;
            map { $ArticleIDs{$_}++ } @ArticleIndex;

            ATTACHMENT:
            for my $Selection (@SelectedAttachments) {
                next ATTACHMENT if $Selection !~ m {^Checkbox(\d+)_(\d+)$}xms;

                my ( $ArticleID, $FileID ) = ( $1, $2 );

                next ATTACHMENT if ( !$ArticleID || !$FileID );

                # check if the requested article is really part of the ticket
                if ( !$ArticleIDs{$ArticleID} ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'notice',
                        Message  => 'ArticleID '
                            . $ArticleID
                            . ' is not part of Ticket '
                            . $Self->{TicketID}
                            . '! Attachment skipped!'
                    );
                    next ATTACHMENT;
                }

                # get attachment data
                my %Attachment = $TicketObject->ArticleAttachment(
                    ArticleID => $ArticleID,
                    FileID    => $FileID,
                    UserID    => $Self->{UserID},
                );

                # if we have the same filename multiple times, add a counter to the filename
                my $FileNameForZip = $Attachment{Filename};
                if ( $Filenames{ $Attachment{Filename} } ) {
                    $FileNameForZip
                        =~ s{ ((?:\.[^\.]+)?$) }{-$Filenames{$Attachment{Filename}}$1}xms;
                    $Filenames{$FileNameForZip}++;
                }
                $Filenames{ $Attachment{Filename} }++;

                $Kernel::OM->Get('Kernel::System::Encode')->EncodeOutput( \$FileNameForZip );
                $ZipObject->addString( $Attachment{Content}, $FileNameForZip );
            }

            # now create and output zip file
            my $ZipFileHandle;
            my $ZipFilename = 'Attachments-Ticket-' . $Tn . '.zip';
            my $ZipContent  = '';

            # open FileHandle to write into ScalarRef
            open $ZipFileHandle, '>', \$ZipContent;    ## no critic
            if ( $ZipObject->writeToFileHandle($ZipFileHandle) != AZ_OK ) {
                $LayoutObject->FatalError(
                    Message => "Error while trying to write zip archive file!",
                );
            }
            close $ZipFileHandle;

            return $LayoutObject->Attachment(
                Filename    => $ZipFilename,
                ContentType => 'application/zip',
                Content     => $ZipContent,
                NoCache     => 1,
            );
        }
    }

    # show attachment list

    # define if rich text should be used
    my $RichText = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::ZoomRichTextForce')
        || $LayoutObject->{BrowserRichText}
        || 0;

    # strip html and ascii attachments of content
    my $StripPlainBodyAsAttachment = 1;

    # check if rich text is enabled, if not only strip ascii attachments
    if ( !$RichText ) {
        $StripPlainBodyAsAttachment = 2;
    }

    my $Output = $LayoutObject->Header(
        Value => $Tn,
        Type  => 'Small',
    );

    my @Attachments;
    my $ArticleCount = 0;
    ARTICLEID:
    for my $ArticleID (@ArticleIndex) {

        # get article data
        my %Article = $TicketObject->ArticleGet(
            ArticleID => $ArticleID,
            UserID    => $Self->{UserID},
        );

        # read attachments
        my %Index = $TicketObject->ArticleAttachmentIndex(
            ArticleID                  => $ArticleID,
            UserID                     => $Self->{UserID},
            StripPlainBodyAsAttachment => $StripPlainBodyAsAttachment,
            Article                    => \%Article,
        );

        $ArticleCount++;

        next ARTICLEID if !( keys %Index );

        $Article{Count} = $ArticleCount;

        FILEID:
        for my $FileID ( sort keys %Index ) {
            my %Attachment = %{ $Index{$FileID} };

            %Attachment = ( %Article, %Attachment );

            $Attachment{FileID} = $FileID;

            # get article page
            my $RowsPerPage = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::MaxArticlesPerPage') || 1000;

            $Attachment{ArticlePage} = $TicketObject->ArticlePage(
                TicketID    => $Self->{TicketID},
                ArticleID   => $ArticleID,
                RowsPerPage => $RowsPerPage,
            );

            # set CSS icon class name for different file types
            $Attachment{ContentTypeCss} = 'fa-file-o';
            CONTENTTYPE:
            for my $ContentTypeClass ( sort keys %{ $Self->{IconClassFileTypes} } ) {
                my $ContentTypeRegExp = $Self->{IconClassFileTypes}{$ContentTypeClass};

                next CONTENTTYPE if $Attachment{ContentType} !~ m{ $ContentTypeRegExp }xms;

                $Attachment{ContentTypeCss} = $ContentTypeClass;
                last CONTENTTYPE;
            }

            # download type
            my $Type = $Kernel::OM->Get('Kernel::Config')->Get('AttachmentDownloadType') || 'attachment';

            # if attachment will be forced to download, don't open a new download window!
            my $Target = 'target="AttachmentWindow" ';
            if ( $Type =~ /inline/i ) {
                $Target = 'target="attachment" ';
            }
            $Attachment{Target} = $Target;

            # determine communication direction
            if ( $Attachment{ArticleType} =~ /-internal$/smx ) {
                $Attachment{CommunicationDirection} = 'Internal';
            }
            else {
                if ( $Attachment{SenderType} eq 'customer' ) {
                    $Attachment{CommunicationDirection} = 'Incoming';
                }
                else {
                    $Attachment{CommunicationDirection} = 'Outgoing';
                }
            }

            # include class name for inline attachments
            $Attachment{InlineAttachment} = 'Inline' if $Attachment{Disposition} eq 'inline';

            push @Attachments, \%Attachment;
        }
    }

    if ( !@Attachments ) {
        $LayoutObject->Block(
            Name => 'NoAttachments',
        );
    }
    else {
        $LayoutObject->Block(
            Name => 'HasAttachments',
            Data => {
                TicketNumber => $Tn,
                TicketID     => $Self->{TicketID},
                Title        => $Ticket{Title},
            },
        );

        $LayoutObject->Block(
            Name => 'TableHeader',
            Data => {
                TicketNumber => $Tn,
                TicketID     => $Self->{TicketID},
                Title        => $Ticket{Title},
                InlineHide   => $Self->{AttachmentViewInlineHide} ? 'checked="checked" ' : '',
            },
        );

        # loop through the attachments and show them
        for my $Attachment ( sort { $a->{ArticleID} <=> $b->{ArticleID} } @Attachments ) {
            $LayoutObject->Block(
                Name => 'TableRow',
                Data => {
                    %{$Attachment},
                },
            );
        }

        $LayoutObject->Block(
            Name => 'TableFooter',
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentTicketAttachmentView',
        Data         => {
            TicketNumber => $Tn,
            TicketID     => $Self->{TicketID},
            Title        => $Ticket{Title},
        },
    );

    $Output .= $LayoutObject->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
