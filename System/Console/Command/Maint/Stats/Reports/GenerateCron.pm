# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Stats::Reports::GenerateCron;

use strict;
use warnings;
use utf8;

use base qw(
    Kernel::System::Console::BaseCommand
    Kernel::System::Console::Command::Maint::Stats::Reports::Generate
);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::PDF::StatisticsReports',
    'Kernel::System::CronEvent',
    'Kernel::System::Email',
    'Kernel::System::Main',
    'Kernel::System::PID',
    'Kernel::System::StatsReport',
    'Kernel::System::Time',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Automatically generate statistics reports and email them to the specified recipients.');

    $Self->AddOption(
        Name        => 'force-pid',
        Description => "Start even if another process is still registered in the database.",
        Required    => 0,
        HasValue    => 0,
    );

    return;
}

sub PreRun {
    my ($Self) = @_;

    my $PIDCreated = $Kernel::OM->Get('Kernel::System::PID')->PIDCreate(
        Name  => $Self->Name(),
        Force => $Self->GetOption('force-pid'),
        TTL   => 60 * 60 * 24 * 3,
    );
    if ( !$PIDCreated ) {
        my $Error = "Unable to register the process in the database. Is another instance still running?\n";
        $Error .= "You can use --force-pid to override this check.\n";
        die $Error;
    }

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Generating reports...</yellow>\n");

    my $StatsReportObject = $Kernel::OM->Get('Kernel::System::StatsReport');
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my %StatsReportsList  = %{ $StatsReportObject->StatsReportList() // {} };
    my $Errors;

    my $From = $ConfigObject->Get('NotificationSenderName') . ' <'
        . $ConfigObject->Get('NotificationSenderEmail') . '>';

    STATSREPORTID:
    for my $StatsReportID ( sort keys %StatsReportsList ) {
        my %StatsReport = %{
            $StatsReportObject->StatsReportGet(
                ID => $StatsReportID,
                ) // {},
        };

        if ( !%StatsReport ) {
            $Self->PrintError('Could not find report.');
            $Errors++;
            next STATSREPORTID;
        }
        my $CronDefinition = $StatsReport{Config}->{CronDefinition};
        next STATSREPORTID if !$CronDefinition;

        my $CronPreviousEvent = $Kernel::OM->Get('Kernel::System::CronEvent')->PreviousEventGet(
            Schedule => $CronDefinition,
        );
        my $CronLastRun = $StatsReport{Config}->{CronLastRun} || 0;
        next STATSREPORTID if $CronPreviousEvent <= $CronLastRun;

        my $StatTitle = $StatsReport{Config}->{Title} || 'OTRS Business Solution™ Report';

        $Self->Print("  <yellow>$StatTitle...</yellow>\n");
        my $GenerationTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();

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

        my $PDFString = eval {
            $Self->_GeneratePDF(
                StatsReport => \%StatsReport,
            );
        };
        if ($@) {
            $Self->PrintError($@);
            $Errors++;
            next STATSREPORTID;
        }

        my %Attachment = (
            Filename    => "$StatTitle.pdf",
            ContentType => "application/pdf",
            Content     => $PDFString,
            Encoding    => "base64",
            Disposition => "attachment",
        );

        my $EmailSent = $Kernel::OM->Get('Kernel::System::Email')->Send(
            From       => $From,
            To         => $StatsReport{Config}->{EmailRecipients},
            Subject    => $StatsReport{Config}->{EmailSubject},
            Body       => $StatsReport{Config}->{EmailBody},
            Charset    => 'utf-8',
            Attachment => [ {%Attachment}, ],
        );
        if ( !$EmailSent ) {
            $Self->PrintError("Could not send to $StatsReport{Config}->{EmailRecipients}.\n");
            $Errors++;    # Continue anyway and mark report as executed.
        }
        else {
            $Self->Print("    Sent email to <yellow>$StatsReport{Config}->{EmailRecipients}</yellow>.\n");
        }

        # Fetch report again to avoid collisions with changes in the meantime.
        %StatsReport = %{
            $StatsReportObject->StatsReportGet(
                ID => $StatsReportID,
                ) // {},
        };

        # Remember generation time.
        $StatsReport{Config}->{CronLastRun} = $GenerationTime;
        $StatsReportObject->StatsReportUpdate(
            %StatsReport,
            UserID => 1,
        );
    }

    if ($Errors) {
        $Self->Print("<yellow>Done.</yellow>\n");
        return $Self->ExitCodeError();
    }

    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

sub PostRun {
    my ($Self) = @_;

    return $Kernel::OM->Get('Kernel::System::PID')->PIDDelete( Name => $Self->Name() );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
