# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::PDF::StatisticsReports;

use strict;
use warnings;

#use File::Stat;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::Output::HTML::Statistics::View',
    'Kernel::System::FileTemp',
    'Kernel::System::Main',
    'Kernel::System::PDF',
    'Kernel::System::Stats',
    'Kernel::System::StatsReport',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub GeneratePDF {
    my ( $Self, %Param ) = @_;

    my %StatsReport = %{ $Param{StatsReport} };

    my $UserLanguage = $Param{UserLanguage};

    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StatsReportObject = $Kernel::OM->Get('Kernel::System::StatsReport');

    # Always create a new instance here. This might be called from a script to produce
    #   several reports in one process, and that fails with one instance.
    $Kernel::OM->ObjectsDiscard( Objects => ['Kernel::System::PDF'] );
    my $PDFObject = $Kernel::OM->Get('Kernel::System::PDF');

    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $PhantomJSBinary = $Kernel::OM->Get('Kernel::Config')->Get('PhantomJS::Bin');

    my $Page = $LayoutObject->{LanguageObject}->Translate('Page');
    my $Time = $LayoutObject->{Time};

    # get maximum number of pages
    my $MaxPages = $ConfigObject->Get('PDF::MaxPages');
    if ( !$MaxPages || $MaxPages < 1 || $MaxPages > 1000 ) {
        $MaxPages = 100;
    }

    my $Title = $StatsReport{Config}->{Title};

    # page params
    my %PageParam;
    $PageParam{PageOrientation} = 'landscape';
    $PageParam{MarginTop}       = 30;
    $PageParam{MarginRight}     = 40;
    $PageParam{MarginBottom}    = 40;
    $PageParam{MarginLeft}      = 40;

    #$PageParam{HeaderRight}     = $ConfigObject->Get('Stats::StatsHook') . $Stat->{StatNumber};
    #$PageParam{HeadlineLeft}    = $Title;

    # create new pdf document
    my $PageCounter = 1;

    $PDFObject->DocumentNew(
        Title  => $ConfigObject->Get('Product') . ': ' . $Title,
        Encode => 'utf8',
    );

    # Cover page
    $PDFObject->PageNew(
        %PageParam,
    );
    $PageCounter++;

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => 'middle',
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => +44,
    );

    my $FallbackHeadline = $LayoutObject->{LanguageObject}->Translate( "%s Report", 'OTRS Business Solution™' );
    $PDFObject->Text(
        Text => $StatsReport{Config}->{Headline} || $FallbackHeadline,
        FontSize => 20,
        Align    => 'center',
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => -20,
    );

    $PDFObject->Text(
        Text     => $Title,
        FontSize => 15,
        Align    => 'center',
        Color    => '#555555',
    );

    $PDFObject->PositionSet(
        Move => 'relativ',
        Y    => -20,
    );

    $PDFObject->Text(
        Text     => $Time,
        FontSize => 9,
        Align    => 'center',
        Color    => '#555555',
    );

    # Insert an empty page for the TOC, to be filled later
    $PDFObject->PageNew(
        %PageParam,
        FooterRight => $Page . ' ' . $PageCounter++,
    );

    my $TOCPage = $PDFObject->{Page};    # sorry :D

    $PDFObject->PageNew(
        %PageParam,
        FooterRight => $Page . ' ' . $PageCounter++,
    );

    my $OutputParagraph = sub {
        my %Param = @_;

        my $Text = $Param{Text};

        while ($Text) {
            my %Result = $PDFObject->Text(
                %Param,
                Text => $Text,
            );
            $Text = $Result{LeftOver};

            if ($Text) {
                if ( $PageCounter >= $MaxPages ) {
                    return;
                }
                $PDFObject->PageNew(
                    %PageParam,
                    FooterRight => $Page . ' ' . $PageCounter++,
                );
            }
        }

        return 1;
    };

    my $ChapterCounter = 1;
    my @Chapters;

    # output preamble
    if ( $StatsReport{Config}->{Preamble} && $PageCounter <= $MaxPages ) {
        my $FallbackCaption = $LayoutObject->{LanguageObject}->Translate("Preamble");
        my $Caption = $ChapterCounter++ . ' ' . ( $StatsReport{Config}->{PreambleCaption} || $FallbackCaption );
        push(
            @Chapters,
            {
                Caption => $Caption,
                Page    => $PageCounter - 1
            }
        );
        $PDFObject->Text(
            Text     => $Caption,
            FontSize => 13,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -13,
        );

        $OutputParagraph->(
            Text     => $StatsReport{Config}->{Preamble},
            FontSize => 9,
        );

        $PDFObject->PageNew(
            %PageParam,
            FooterRight => $Page . ' ' . $PageCounter++,
        );
    }

    my $StatCounter = 0;

    my $TranslateTimeZone = $LayoutObject->{LanguageObject}->Translate('Time Zone');

    STAT_CONFIG:
    for my $StatConfig ( @{ $StatsReport{Config}->{StatsConfiguration} // [] } ) {
        next STAT_CONFIG if !ref $StatConfig;

        my $StatID = $StatConfig->{StatGetParams}->{StatID};
        next STAT_CONFIG if !$StatID;

        my $Stat = $Kernel::OM->Get('Kernel::System::Stats')->StatsGet(
            StatID => $StatID,
        );

        my %GetParam = eval {
            $Kernel::OM->Get('Kernel::Output::HTML::Statistics::View')->StatsParamsGet(
                Stat         => $Stat,
                UserGetParam => $StatConfig->{StatGetParams},
            );
        };

        if ($@) {
            next STAT_CONFIG;
        }

        # Check available formats from stat
        my @Formats = @{ $Stat->{Format} // [] };
        @Formats = grep { $_ =~ m{^D3|Print} } @Formats;

        # Use the format selected by the user or the first available format.
        my $Format = $StatConfig->{StatGetParams}->{Format} || $Formats[0];

        # Skip stat if format is wrong.
        if ( $Format !~ m{^D3|Print} ) {
            next STAT_CONFIG;
        }

        if ( $StatCounter++ > 0 ) {
            $PDFObject->PageNew(
                %PageParam,
                FooterRight => $Page . ' ' . $PageCounter++,
            );
        }

        my @StatArray = @{
            $Kernel::OM->Get('Kernel::System::Stats')->StatsRun(
                StatID       => $StatID,
                GetParam     => \%GetParam,
                UserID       => $Param{UserID},
                UserLanguage => $UserLanguage,
            );
        };

        # exchange axis if selected
        if ( $GetParam{ExchangeAxis} ) {
            my @NewStatArray;
            my $Title = $StatArray[0][0];

            shift(@StatArray);
            for my $Key1 ( 0 .. $#StatArray ) {
                for my $Key2 ( 0 .. $#{ $StatArray[0] } ) {
                    $NewStatArray[$Key2][$Key1] = $StatArray[$Key1][$Key2];
                }
            }
            $NewStatArray[0][0] = '';
            unshift( @NewStatArray, [$Title] );
            @StatArray = @NewStatArray;
        }

        my $TitleArrayRef = shift @StatArray;
        my $HeadArrayRef  = shift @StatArray;

        my %StatReportSettings = %{ $StatConfig->{StatReportSettings} // {} };

        my $Caption = $ChapterCounter++ . ' ' . ( $StatReportSettings{Title} || $Stat->{Title} );

        # If a time zone was selected
        if ( $StatConfig->{StatGetParams}->{TimeZone} ) {
            $Caption .= " ($TranslateTimeZone $StatConfig->{StatGetParams}->{TimeZone})";
        }

        push(
            @Chapters,
            {
                Caption => $Caption,
                Page    => $PageCounter - 1
            }
        );
        $PDFObject->Text(
            Text     => $Caption,
            FontSize => 13,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -13,
        );

        if ( $StatReportSettings{Preface} ) {
            $OutputParagraph->(
                Text     => $StatReportSettings{Preface},
                FontSize => 9,
            );
            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => -6,
            );
        }

        # Direct table output in PDF
        if ( $Format eq 'Print' || !$PhantomJSBinary ) {

            # if array = empty
            if ( !@StatArray ) {
                push @StatArray, [ ' ', 0 ];
            }

            # Translate the column and row description
            $Kernel::OM->Get('Kernel::Output::HTML::Statistics::View')->_ColumnAndRowTranslation(
                StatArrayRef => \@StatArray,
                HeadArrayRef => $HeadArrayRef,
                StatRef      => $Stat,
                ExchangeAxis => $GetParam{ExchangeAxis},
            );

            # create the header
            my $CellData;
            my $CounterRow  = 0;
            my $CounterHead = 0;
            for my $Content ( @{$HeadArrayRef} ) {
                $CellData->[$CounterRow]->[$CounterHead]->{Content} = $Content;
                $CellData->[$CounterRow]->[$CounterHead]->{Font}    = 'ProportionalBold';
                $CounterHead++;
            }
            if ( $CounterHead > 0 ) {
                $CounterRow++;
            }

            # create the content array
            for my $Row (@StatArray) {
                my $CounterColumn = 0;
                for my $Content ( @{$Row} ) {
                    $CellData->[$CounterRow]->[$CounterColumn]->{Content} = $Content;
                    $CounterColumn++;
                }
                $CounterRow++;
            }

            # output 'No matches found', if no content was given
            if ( !$CellData->[0]->[0] ) {
                $CellData->[0]->[0]->{Content} = $LayoutObject->{LanguageObject}->Translate('No matches found.');
            }

            # table params
            my %TableParam;
            $TableParam{CellData}            = $CellData;
            $TableParam{Type}                = 'Cut';
            $TableParam{FontSize}            = 6;
            $TableParam{Border}              = 0;
            $TableParam{BackgroundColorEven} = '#DDDDDD';
            $TableParam{Padding}             = 4;

            PAGE:
            while ( $PageCounter <= $MaxPages ) {

                # output table (or a fragment of it)
                %TableParam = $PDFObject->Table( %TableParam, );

                # stop output or output next page
                last PAGE if $TableParam{State};

                $PDFObject->PageNew(
                    %PageParam,
                    FooterRight => $Page . ' ' . $PageCounter++,
                );
            }

            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => -6,
            );

        }

        # D3 charts; load in PhantomJS and generate PNG to embed in PDF.
        else {
            my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home');

            # This is needed because we run this function also from a console commands where
            #   there is no Action initially.
            local $LayoutObject->{Action} = 'AgentStatisticsReports';

            # Generate local file URLs for PhantomJS (ok, this is a hack).
            local $ConfigObject->{'Frontend::WebPath'}        = "file://$Home/var/httpd/htdocs/";
            local $ConfigObject->{'Frontend::JavaScriptPath'} = "file://$Home/var/httpd/htdocs/js/";
            my $Output = $LayoutObject->Header( Type => 'Small' );
            $Output .= $LayoutObject->Output(
                Data => {
                    %{$Stat},
                    RawData => [
                        [$Title],
                        $HeadArrayRef,
                        @StatArray,
                    ],
                    Format => $Format,
                },
                TemplateFile => 'StatisticsReports/Graph2PNG',
            );
            $Output .= $LayoutObject->Footer(
                Type => 'Small',
            );

            # Remove HTTP headers
            $Output =~ s{\A.*?(<!DOCTYPE)}{$1}smx;

            my ( $TempHTMLFH, $TempHTMLFilename ) = $Kernel::OM->Get('Kernel::System::FileTemp')->TempFile(
                Suffix => '.html',
            );
            close($TempHTMLFH);
            my ( $TempPNGFH, $TempPNGFilename ) = $Kernel::OM->Get('Kernel::System::FileTemp')->TempFile(
                Suffix => '.png',
            );
            close($TempPNGFH);

            $Kernel::OM->Get('Kernel::System::Main')->FileWrite(
                Location => $TempHTMLFilename,
                Mode     => 'utf8',
                Content  => \$Output,
            );

            my $CommandOutput
                = `$PhantomJSBinary $Home/var/thirdparty/phantomjs/rasterize_delayed.js $TempHTMLFilename $TempPNGFilename 1200px 2>&1`
                // '';
            if ($!) {
                $CommandOutput .= "$!";
            }
            chomp $CommandOutput;

            my $Stat = File::stat::stat($TempPNGFilename);
            if ( $Stat->size() ) {
                $PDFObject->Image(
                    File   => $TempPNGFilename,
                    Width  => 1200 * ( 300 / 72 ),
                    Height => 900 * ( 300 / 72 ),
                );
            }
            else {
                my $Messages = $LayoutObject->{LanguageObject}->Translate(
                    'Error: this graph could not be generated: %s.',
                    $CommandOutput
                );
                $PDFObject->Text(
                    Text     => $Messages,
                    FontSize => 9,
                    Color    => '#FF000',
                );

                $PDFObject->PositionSet(
                    Move => 'relativ',
                    Y    => -6,
                );
            }
        }

        if ( $StatReportSettings{Postface} ) {
            $OutputParagraph->(
                Text     => $StatReportSettings{Postface},
                FontSize => 9,
            );
            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => -6,
            );
        }
    }

    # output epilogue
    if ( $StatsReport{Config}->{Epilogue} && $PageCounter < $MaxPages ) {
        $PDFObject->PageNew(
            %PageParam,
            FooterRight => $Page . ' ' . $PageCounter++,
        );

        my $FallbackCaption = $LayoutObject->{LanguageObject}->Translate("Epilogue");
        my $Caption = $ChapterCounter++ . ' ' . ( $StatsReport{Config}->{EpilogueCaption} || $FallbackCaption );
        push(
            @Chapters,
            {
                Caption => $Caption,
                Page    => $PageCounter - 1
            }
        );
        $PDFObject->Text(
            Text     => $Caption,
            FontSize => 13,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -13,
        );

        $OutputParagraph->(
            Text     => $StatsReport{Config}->{Epilogue},
            FontSize => 9,
        );
    }

    # Generate TOC
    {
        local $PDFObject->{Page} = $TOCPage;

        $PDFObject->PositionSet(
            X => 'left',
            Y => 'top',
        );

        $PDFObject->Text(
            Text     => $LayoutObject->{LanguageObject}->Translate('Table of Contents'),
            FontSize => 13,
        );

        $PDFObject->PositionSet(
            Move => 'relativ',
            Y    => -13,
        );

        for my $Chapter (@Chapters) {
            $PDFObject->Text(
                Text     => $Chapter->{Caption},
                FontSize => 9,
            );

            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => +9,
            );

            $PDFObject->Text(
                Text     => $Chapter->{Page},
                FontSize => 9,
                Align    => 'right',
            );

            $PDFObject->PositionSet(
                Move => 'relativ',
                Y    => -6,
            );
        }
    }

    # return the pdf document
    return $PDFObject->DocumentOutput();
}

1;
