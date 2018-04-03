# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerChatDownload;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

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

    # Needed objects
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output;

    # Get needed params
    $Param{ChatID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ChatID' );
    $Param{Format} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Format' );

    # check needed stuff
    for my $Needed (qw(ChatID Format)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return $LayoutObject->ErrorScreen( Message => 'Need $Needed!' );
        }
    }

    # check permissions
    my $Access = $ChatObject->ChatParticipantCheck(
        ChatID      => $Param{ChatID},
        ChatterID   => $Self->{UserID},    # Typically this would be a UserID
        ChatterType => 'Customer',         # Typically this would be 'User' or 'Customer'
    );

    return $LayoutObject->NoPermission( WithHeader => 'yes' ) if !$Access;

    if ( $Param{Format} eq 'PDF' ) {
        return $Self->_GenerateChatPDF(%Param);
    }
}

sub _GenerateChatPDF {
    my ( $Self, %Param ) = @_;

    # Needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ChatObject   = $Kernel::OM->Get('Kernel::System::Chat');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $PDFObject    = $Kernel::OM->Get('Kernel::System::PDF');
    my $TimeObject   = $Kernel::OM->Get('Kernel::System::Time');

    # Get Chat messages
    my @ChatMessages = $ChatObject->ChatMessageList(
        ChatID          => $Param{ChatID},    # get all messages
        MaskAgentName   => 1,
        ExcludeInternal => 1,                 # optional (default 0) - if set, system will return only external messages
    );

    # generate pdf output
    if ($PDFObject) {
        my $PrintedBy = $LayoutObject->{LanguageObject}->Translate('printed by');
        my $Time      = $LayoutObject->{Time};
        my %Page;

        # get maximum number of pages
        $Page{MaxPages} = $ConfigObject->Get('PDF::MaxPages');
        if ( !$Page{MaxPages} || $Page{MaxPages} < 1 || $Page{MaxPages} > 1000 ) {
            $Page{MaxPages} = 100;
        }
        my $HeaderRight  = $Kernel::OM->Get('Kernel::Language')->Translate("Chat") . " #$Param{ChatID}";
        my $HeadlineLeft = $HeaderRight;
        my $Title        = $HeaderRight;

        $Page{MarginTop}    = 30;
        $Page{MarginRight}  = 40;
        $Page{MarginBottom} = 40;
        $Page{MarginLeft}   = 40;
        $Page{HeaderRight}  = $HeaderRight;
        $Page{FooterLeft}   = '';
        $Page{PageText}     = $LayoutObject->{LanguageObject}->Translate('Page');
        $Page{PageCount}    = 1;

        # create new pdf document
        $PDFObject->DocumentNew(
            Title  => $ConfigObject->Get('Product') . ': ' . $Title,
            Encode => $LayoutObject->{UserCharset},
        );

        # create first pdf page
        $PDFObject->PageNew(
            %Page,
            FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
        );
        $Page{PageCount}++;

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # output title
        $PDFObject->Text(
            Text     => $Kernel::OM->Get('Kernel::Language')->Translate("Chat protocol"),
            FontSize => 13,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # output "printed by"
        $PDFObject->Text(
            Text => $PrintedBy . ' '
                . $Self->{UserFirstname} . ' '
                . $Self->{UserLastname} . ' ('
                . $Self->{UserEmail} . ')'
                . ', ' . $Time,
            FontSize => 9,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -14,
        );

        for my $Message (@ChatMessages) {

            # Position
            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => -7,
                X    => 'left',
            );

            my %ReturnTime = $PDFObject->Text(
                Text   => $Message->{CreateTime},
                Height => 7,
                Type => 'ReturnLeftOver',    # (optional) default ReturnLeftOver (ReturnLeftOver|ReturnLeftOverHard|Cut)
                Font     => 'ProportionalBoldItalic',
                FontSize => 7,
                Color    => '#AAAAAA',
            );

            if ( $ReturnTime{LeftOver} ) {

                # There is no enough space on this page

                # Add new page
                $PDFObject->PageNew(
                    %Page,
                    FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                );
                $Page{PageCount}++;

                # Position
                $PDFObject->PositionSet(
                    Move => 'relativ',
                    X    => 'left',
                    Y    => -7,
                );

                $PDFObject->Text(
                    Text   => $Message->{CreateTime},
                    Height => 7,
                    Type =>
                        'ReturnLeftOver',    # (optional) default ReturnLeftOver (ReturnLeftOver|ReturnLeftOverHard|Cut)
                    Font     => 'ProportionalBoldItalic',
                    FontSize => 7,
                    Color    => '#AAAAAA',
                );
            }

            # Position
            $PDFObject->PositionSet(
                Move => 'relativ',
                X    => 90,
                Y    => 7,
            );

            my %ResultName;
            if ( $Message->{SystemGenerated} ne 1 ) {
                %ResultName = $PDFObject->Text(
                    Text     => $Message->{ChatterName},
                    Height   => 7,
                    Type     => 'Cut',
                    Font     => 'ProportionalBold',
                    FontSize => 7,
                    Color    => $Message->{ChatterType} eq 'User' ? '#000000' : '#FF7722',
                );
            }
            else {
                %ResultName = $PDFObject->Text(
                    Text     => $Kernel::OM->Get('Kernel::Language')->Translate("System"),
                    Color    => '#AAAAAA',
                    Height   => 7,
                    Type     => 'Cut',
                    Font     => 'ProportionalBold',
                    FontSize => 7,
                );
            }

            # Position
            $PDFObject->PositionSet(
                Move => 'relativ',
                X    => $ResultName{RequiredWidth} + 10,
                Y    => 7,
            );

            # output message
            my %Return = $PDFObject->Text(
                Text   => $Message->{MessageText},
                Height => 7,
                Type => 'ReturnLeftOver',    # (optional) default ReturnLeftOver (ReturnLeftOver|ReturnLeftOverHard|Cut)
                Font     => $Message->{SystemGenerated} ? 'ProportionalBoldItalic' : 'Proportional',
                FontSize => 7,
                Color => $Message->{SystemGenerated} ? '#AAAAAA' : '#000000',
            );

            my $LeftOver = '';

            # Check if message is too long
            while ( $Return{LeftOver} ) {    #&&  scalar @{$Return{PossibleRows}} > 0) {
                $PDFObject->PositionSet(
                    Move => 'absolut',
                    X    => 130,
                );
                $PDFObject->PositionSet(
                    Move => 'relativ',
                    Y    => -7,
                );
                %Return = $PDFObject->Text(
                    Text   => $Return{LeftOver},
                    Height => 7,
                    Type =>
                        'ReturnLeftOver',    # (optional) default ReturnLeftOver (ReturnLeftOver|ReturnLeftOverHard|Cut)
                    Font => $Message->{SystemGenerated} ? 'ProportionalBoldItalic' : 'Proportional',
                    FontSize => 7,
                    Color    => $Message->{SystemGenerated} ? '#AAAAAA' : '#000000',
                );

                if ( $LeftOver ne $Return{LeftOver} ) {
                    $LeftOver = $Return{LeftOver};
                }
                elsif ( $Return{LeftOver} ) {

                    # LeftOver is same like in previous iteration, there is not enough space

                    # Add new pages
                    $PDFObject->PageNew(
                        %Page,
                        FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                    );
                    $Page{PageCount}++;

                    # Position
                    $PDFObject->PositionSet(
                        Move => 'relativ',
                        X    => 170,
                    );
                }
            }
        }

        # return the pdf document
        my $Filename = 'Chat_' . $Param{ChatID};
        my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
            SystemTime => $TimeObject->SystemTime(),
        );
        $M = sprintf( "%02d", $M );
        $D = sprintf( "%02d", $D );
        $h = sprintf( "%02d", $h );
        $m = sprintf( "%02d", $m );
        my $PDFString = $PDFObject->DocumentOutput();
        return $LayoutObject->Attachment(
            Filename    => $Filename . "_" . "$Y-$M-$D" . "_" . "$h-$m.pdf",
            ContentType => "application/pdf",
            Content     => $PDFString,
            Type        => 'inline',
        );
    }
    else {
        return $LayoutObject->ErrorScreen( Message => 'Can\'t create PDFObject!' );
    }
}

1;
