# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentResourceOverview;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{OverviewScreen} = 'ResourceOverview';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Check if calendar object is registered and if not show fatal screen.
    if ( !$Kernel::OM->Get('Kernel::System::Main')->Require('Kernel::System::Calendar') ) {
        return $LayoutObject->FatalError(
            Message => $LayoutObject->{LanguageObject}->Translate(
                'This feature is part of the %s package. Please install this free add-on before trying to use it again.',
                'OTRSAppointmentCalendar'
            ),
        );
    }

    # Get user's permissions to associated modules which are displayed as links.
    for my $Module (qw(AgentAppointmentCalendarManage AgentAppointmentTeam AgentAppointmentTeamUser)) {
        my $ModuleGroups = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Module')
            ->{$Module}->{Group} // [];

        if ( IsArrayRefWithData($ModuleGroups) ) {
            MODULE_GROUP:
            for my $ModuleGroup ( @{$ModuleGroups} ) {
                if ( $LayoutObject->{"UserIsGroup[$ModuleGroup]"} ) {
                    $Param{ModulePermissions}->{$Module} = 1;
                    last MODULE_GROUP;
                }
            }
        }

        # Always allow links if no groups are specified.
        else {
            $Param{ModulePermissions}->{$Module} = 1;
        }
    }

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get names of all parameters
    my @ParamNames = $ParamObject->GetParamNames();

    # get params
    my %GetParam;
    PARAMNAME:
    for my $Key (@ParamNames) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get all user's valid calendars
    my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
        Valid => 'valid',
    );

    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

    my @Calendars = $CalendarObject->CalendarList(
        UserID  => $Self->{UserID},
        ValidID => $ValidID,
    );

    # check if we found some
    if (@Calendars) {

        my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

        my %TeamList = $TeamObject->AllowedTeamList(
            UserID => $Self->{UserID},
        );

        if ( scalar keys %TeamList > 0 ) {

            # get a local user object
            my $UserObject = $Kernel::OM->Get('Kernel::System::User');

            # get if it's needed to save a new team selection or get
            # a previously selected team
            if ( $GetParam{Team} && $TeamList{ $GetParam{Team} } ) {

                # save the recently selected team
                $UserObject->SetPreferences(
                    Key    => 'LastAppointmentCalendarTeam',
                    Value  => $GetParam{Team},
                    UserID => $Self->{UserID},
                );
            }
            else {

                # get the team selection for the current user
                my %UserPreferences = $UserObject->GetPreferences(
                    UserID => $Self->{UserID},
                );

                if (
                    IsHashRefWithData( \%UserPreferences )
                    && $UserPreferences{LastAppointmentCalendarTeam}
                    && $TeamList{ $UserPreferences{LastAppointmentCalendarTeam} }
                    )
                {
                    $GetParam{Team} = $UserPreferences{LastAppointmentCalendarTeam};
                }
            }

            my @TeamIDs = sort keys %TeamList;
            $Param{Team} = $GetParam{Team} // $TeamIDs[0];

            $Param{TeamStrg} = $LayoutObject->BuildSelection(
                Data         => \%TeamList,
                Name         => 'Team',
                ID           => 'Team',
                Class        => 'Modernize',
                SelectedID   => $Param{Team},
                PossibleNone => 0,
            );

            $LayoutObject->Block(
                Name => 'TeamList',
                Data => {
                    %Param,
                },
            );

            my %TeamUserIDs = $TeamObject->TeamUserList(
                TeamID => $Param{Team},
                UserID => $Self->{UserID},
            );

            if ( scalar keys %TeamUserIDs > 0 ) {

                # get needed objects
                my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
                my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
                my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
                my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

                # new appointment dialog
                if ( $Self->{Subaction} eq 'AppointmentCreate' ) {
                    $Param{AppointmentCreate} = $LayoutObject->JSONEncode(
                        Data => {
                            Start     => $ParamObject->GetParam( Param => 'Start' )     // undef,
                            End       => $ParamObject->GetParam( Param => 'End' )       // undef,
                            PluginKey => $ParamObject->GetParam( Param => 'PluginKey' ) // undef,
                            Search    => $ParamObject->GetParam( Param => 'Search' )    // undef,
                            ObjectID  => $ParamObject->GetParam( Param => 'ObjectID' )  // undef,
                        },
                    );
                }

                # edit appointment dialog
                else {
                    $Param{AppointmentID} = $ParamObject->GetParam( Param => 'AppointmentID' ) // undef;
                }

                $LayoutObject->Block(
                    Name => 'AppointmentCreateButton',
                );

                $LayoutObject->Block(
                    Name => 'CalendarDiv',
                    Data => {
                        %Param,
                        CalendarWidth => 100,
                    },
                );

                $LayoutObject->Block(
                    Name => 'CalendarWidget',
                );

                # get user preferences
                my %Preferences = $UserObject->GetPreferences(
                    UserID => $Self->{UserID},
                );

                # get resource names
                my @TeamUserList;
                for my $UserID ( sort keys %TeamUserIDs ) {
                    my %User = $UserObject->GetUserData(
                        UserID => $UserID,
                    );
                    push @TeamUserList, {
                        UserID       => $User{UserID},
                        Name         => $User{UserFullname},
                        UserLastname => $User{UserLastname},
                    };
                }

                # sort the list by last name
                @TeamUserList = sort { $a->{UserLastname} cmp $b->{UserLastname} } @TeamUserList;
                my @TeamUserIDs = map { $_->{UserID} } @TeamUserList;

                # resource name lookup table
                my %TeamUserList = map { $_->{UserID} => $_->{Name} } @TeamUserList;
                $Param{TeamUserList} = \%TeamUserList;

                # user preference key
                my $ShownResourcesPrefKey = 'User' . $Self->{OverviewScreen} . 'ShownResources-' . $Param{Team};

                # read preference if it exists
                my @ShownResources;
                if ( $Preferences{$ShownResourcesPrefKey} ) {
                    my $ShownResourcesPrefVal = $JSONObject->Decode(
                        Data => $Preferences{$ShownResourcesPrefKey},
                    );

                    # add only valid and unique users
                    for my $UserID ( @{ $ShownResourcesPrefVal || [] } ) {
                        if ( grep { $_ eq $UserID } @TeamUserIDs ) {

                            if ( !grep { $_ eq $UserID } @ShownResources ) {
                                push @ShownResources, $UserID;
                            }
                        }
                    }

                    # activate restore settings button
                    $Param{RestoreDefaultSettings} = 1;
                }

                # set default if empty
                if ( !scalar @ShownResources ) {
                    @ShownResources = @TeamUserIDs;
                }

                # calculate difference
                my @AvailableResources;
                for my $ColumnName (@TeamUserIDs) {
                    if ( !grep { $_ eq $ColumnName } @ShownResources ) {
                        push @AvailableResources, $ColumnName;
                    }
                }

                # allocation list block
                $LayoutObject->Block(
                    Name => 'ShownResourceSettings',
                    Data => {
                        ColumnsEnabled   => $JSONObject->Encode( Data => \@ShownResources ),
                        ColumnsAvailable => $JSONObject->Encode( Data => \@AvailableResources ),
                        %Param,
                    },
                );

                my $CalendarLimit = int $ConfigObject->Get('AppointmentCalendar::CalendarLimitOverview') || 10;
                my $CalendarSelection = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                    Data => $Preferences{ 'User' . $Self->{OverviewScreen} . 'CalendarSelection' } || '[]',
                );

                my $CurrentCalendar = 1;
                for my $Calendar (@Calendars) {

                    # check the calendar if stored in preferences
                    if ( scalar @{$CalendarSelection} ) {
                        if ( grep { $_ == $Calendar->{CalendarID} } @{$CalendarSelection} ) {

                            if ( $CurrentCalendar <= $CalendarLimit ) {
                                $Calendar->{Checked} = 'checked="checked" ';
                            }
                        }
                    }

                    # check calendar by default if limit is not yet reached
                    else {
                        if ( $CurrentCalendar <= $CalendarLimit ) {
                            $Calendar->{Checked} = 'checked="checked" ';
                        }
                    }

                    # get access tokens
                    $Calendar->{AccessToken} = $CalendarObject->GetAccessToken(
                        CalendarID => $Calendar->{CalendarID},
                        UserLogin  => $Self->{UserLogin},
                    );

                    # calendar checkbox in the widget
                    $LayoutObject->Block(
                        Name => 'CalendarSwitch',
                        Data => {
                            %{$Calendar},
                            %Param,
                        },
                    );

                    # calculate best text color
                    $Param{TextColor} = $CalendarObject->GetTextColor(
                        Background => $Calendar->{Color},
                    ) || '#FFFFFF';

                    # calendar source (JSON)
                    $LayoutObject->Block(
                        Name => 'CalendarSource',
                        Data => {
                            %{$Calendar},
                            %Param,
                        },
                    );

                    if ( $CurrentCalendar < scalar @Calendars ) {
                        $LayoutObject->Block(
                            Name => 'CalendarSourceComma',
                        );
                    }

                    $CurrentCalendar++;
                }

                # resource JSON
                $LayoutObject->Block(
                    Name => 'ResourceJSON',
                    Data => {
                        TeamID => $GetParam{Team},
                        %Param,
                    },
                );

                # set initial view
                $Param{DefaultView} = $Preferences{ 'User' . $Self->{OverviewScreen} . 'DefaultView' }
                    || 'timelineWeek';

                # get plugin list
                $Param{PluginList} = $Kernel::OM->Get('Kernel::System::Calendar::Plugin')->PluginList();

                # get registered ticket appointment types
                my %TicketAppointmentTypes = $CalendarObject->TicketAppointmentTypesGet();

                my $CurrentType = 1;
                for my $Type ( sort keys %TicketAppointmentTypes ) {
                    my $NoDrag = 0;

                    # prevent dragging of ticket escalation appointments
                    if (
                        $Type eq 'FirstResponseTime'
                        || $Type eq 'UpdateTime'
                        || $Type eq 'SolutionTime'
                        )
                    {
                        $NoDrag = 1;
                    }

                    # output configured ticket appointment type mark
                    $LayoutObject->Block(
                        Name => 'TicketAppointmentMark',
                        Data => {
                            AppointmentType => $Type,
                            AppointmentMark => lc substr( $TicketAppointmentTypes{$Type}->{Mark}, 0, 1 ),
                        },
                    );
                    if ( $CurrentType < scalar keys %TicketAppointmentTypes ) {
                        $LayoutObject->Block(
                            Name => 'TicketAppointmentMarkComma',
                        );
                    }

                    # output configured ticket appointment type draggability
                    $LayoutObject->Block(
                        Name => 'TicketAppointmentNoDrag',
                        Data => {
                            AppointmentType => $Type,
                            NoDrag          => $NoDrag,
                        },
                    );
                    if ( $CurrentType < scalar keys %TicketAppointmentTypes ) {
                        $LayoutObject->Block(
                            Name => 'TicketAppointmentNoDragComma',
                        );
                    }

                    $CurrentType++;
                }

                # get working hour appointments
                my @WorkingHours = $Self->_GetWorkingHours();

                my $CurrentAppointment = 1;
                for my $Appointment (@WorkingHours) {

                    # sort days of the week
                    my @DoW = sort @{ $Appointment->{DoW} };

                    # output block
                    $LayoutObject->Block(
                        Name => 'WorkingHours',
                        Data => {
                            %{$Appointment},
                            DoW => $LayoutObject->JSONEncode( Data => \@DoW ),
                        },
                    );
                    $LayoutObject->Block(
                        Name => 'WorkingHoursComma',
                    ) if $CurrentAppointment < scalar @WorkingHours;

                    $CurrentAppointment++;
                }
            }

            # show empty team message
            else {
                $LayoutObject->Block(
                    Name => 'EmptyTeam',
                    Data => \%Param,
                );
            }
        }

        # show no team found message
        else {
            $LayoutObject->Block(
                Name => 'NoTeam',
                Data => \%Param,
            );
        }
    }

    # show no calendar found message
    else {
        $LayoutObject->Block(
            Name => 'NoCalendar',
        );
    }

    # get text direction from language object
    my $TextDirection = $LayoutObject->{LanguageObject}->{TextDirection} || '';

    # output page
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentResourceOverview',
        Data         => {
            EditAction        => 'AgentAppointmentEdit',
            EditMaskSubaction => 'EditMask',
            ListAction        => 'AgentAppointmentList',
            DaysSubaction     => 'AppointmentDays',
            FirstDay          => $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 0,
            IsRTLLanguage     => ( $TextDirection eq 'rtl' ) ? 'true' : 'false',
            AppointmentID => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'AppointmentID' )
                // undef,
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GetWorkingHours {
    my ( $Self, %Param ) = @_;

    # get working hours from sysconfig
    my $WorkingHoursConfig = $Kernel::OM->Get('Kernel::Config')->Get('TimeWorkingHours');

    # create working hour appointments for each day
    my @WorkingHours;
    for my $DayName ( sort keys %{$WorkingHoursConfig} ) {

        # day of the week
        my $DoW = 0;    # Sun
        if ( $DayName eq 'Mon' ) {
            $DoW = 1;
        }
        elsif ( $DayName eq 'Tue' ) {
            $DoW = 2;
        }
        elsif ( $DayName eq 'Wed' ) {
            $DoW = 3;
        }
        elsif ( $DayName eq 'Thu' ) {
            $DoW = 4;
        }
        elsif ( $DayName eq 'Fri' ) {
            $DoW = 5;
        }
        elsif ( $DayName eq 'Sat' ) {
            $DoW = 6;
        }

        my $StartTime = 0;
        my $EndTime   = 0;

        START_TIME:
        for ( $StartTime = 0; $StartTime < 24; $StartTime++ ) {

            # is this working hour?
            if ( grep { $_ eq $StartTime } @{ $WorkingHoursConfig->{$DayName} } ) {

                # go to the end of the working hours
                for ( my $EndHour = $StartTime; $EndHour < 24; $EndHour++ ) {
                    if ( !grep { $_ eq $EndHour } @{ $WorkingHoursConfig->{$DayName} } ) {
                        $EndTime = $EndHour;

                        # add appointment
                        if ( $EndTime > $StartTime ) {
                            push @WorkingHours, {
                                StartTime => sprintf( '%02d:00:00', $StartTime ),
                                EndTime   => sprintf( '%02d:00:00', $EndTime ),
                                DoW       => [$DoW],
                            };
                        }

                        # skip some hours
                        $StartTime = $EndHour;

                        next START_TIME;
                    }
                }
            }
        }
    }

    # collapse appointments with same start and end times
    for my $AppointmentA (@WorkingHours) {
        for my $AppointmentB (@WorkingHours) {
            if (
                $AppointmentA->{StartTime} && $AppointmentB->{StartTime}
                && $AppointmentA->{StartTime} eq $AppointmentB->{StartTime}
                && $AppointmentA->{EndTime} eq $AppointmentB->{EndTime}
                && $AppointmentA->{DoW} ne $AppointmentB->{DoW}
                )
            {
                push @{ $AppointmentA->{DoW} }, @{ $AppointmentB->{DoW} };
                $AppointmentB = undef;
            }
        }
    }

    # return only non-empty appointments
    return grep { scalar keys %{$_} } @WorkingHours;
}

1;
