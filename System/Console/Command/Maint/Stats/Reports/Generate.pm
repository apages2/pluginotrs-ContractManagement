# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Stats::Reports::Generate;

use strict;
use warnings;
use utf8;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Statistics::View',
    'Kernel::Output::PDF::StatisticsReports',
    'Kernel::System::Main',
    'Kernel::System::Stats',
    'Kernel::System::StatsReport',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Manually generate statistics reports.');
    $Self->AddOption(
        Name        => 'report-name',
        Description => "Specify a report name.",
        Required    => 1,
        HasValue    => 1,
        ValueRegex  => qr/.*/smx,
    );

    $Self->AddOption(
        Name        => 'target-path',
        Description => "Specify file path for generated PDF report.",
        Required    => 1,
        HasValue    => 1,
        ValueRegex  => qr/.*/smx,
    );

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Generating report...</yellow>\n");

    my $StatsReportObject = $Kernel::OM->Get('Kernel::System::StatsReport');

    my %StatsReport = %{
        $StatsReportObject->StatsReportGet(
            Name => $Self->GetOption('report-name')
            ) // {},
    };
    if ( !%StatsReport ) {
        $Self->PrintError('Could not find report.');
        return $Self->ExitCodeError();
    }

    my $PDFString = eval {
        $Self->_GeneratePDF(
            StatsReport => \%StatsReport,
            UserID      => 1,
        );
    };
    if ($@) {
        $Self->PrintError($@);
        return $Self->ExitCodeError();
    }

    my $FileWritten = $Kernel::OM->Get('Kernel::System::Main')->FileWrite(
        Location => $Self->GetOption('target-path'),
        Mode     => 'binary',
        Content  => \$PDFString,
    );

    if ( !$FileWritten ) {
        $Self->PrintError( 'Could not write to file' . $Self->GetOption('target-path') . "." );
        return $Self->ExitCodeError();
    }

    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

sub _GeneratePDF {
    my ( $Self, %Param ) = @_;

    my %StatsReport = %{ $Param{StatsReport} };

    my $Errors;

    my $UserLanguage = $StatsReport{Config}->{LanguageID}
        || $Kernel::OM->Get('Kernel::Config')->Get('DefaultLanguage')
        || 'en';

    $Kernel::OM->ObjectsDiscard( Objects => ['Kernel::Language'] );
    $Kernel::OM->ObjectParamAdd(
        'Kernel::Language' => {
            UserLanguage => $UserLanguage,
        },
        'Kernel::Output::HTML::Layout' => {
            UserLanguage => $UserLanguage,
        },
    );

    STAT_CONFIG:
    for my $StatConfig ( @{ $StatsReport{Config}->{StatsConfiguration} // [] } ) {
        next STAT_CONFIG if !ref $StatConfig;

        my $StatsObject     = $Kernel::OM->Get('Kernel::System::Stats');
        my $StatsViewObject = $Kernel::OM->Get('Kernel::Output::HTML::Statistics::View');

        my $StatID = $StatConfig->{StatGetParams}->{StatID};
        next STAT_CONFIG if !$StatID;

        my $Stat = $StatsObject->StatsGet(
            StatID => $StatID,
            UserID => 1,
        );
        next STAT_CONFIG if !ref $Stat;

        my $StatsConfigurationValid = $StatsViewObject->StatsConfigurationValidate(
            Stat   => $Stat,
            Errors => {},
            UserID => 1,
        );
        if ( !$StatsConfigurationValid ) {
            $Errors++;
            next STAT_CONFIG;
        }

        my %GetParam = eval {
            $StatsViewObject->StatsParamsGet(
                Stat         => $Stat,
                UserGetParam => $StatConfig->{StatGetParams},
                UserID       => 1,
            );
        };

        if ($@) {
            $Errors++;
        }
    }

    if ($Errors) {
        die 'This report contains statistics with configuration errors.';
    }

    my $PDFGeneratorObject = $Kernel::OM->Get('Kernel::Output::PDF::StatisticsReports');

    return $PDFGeneratorObject->GeneratePDF(
        StatsReport  => \%StatsReport,
        UserLangauge => $UserLanguage,
        UserID       => 1,
    );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
