# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminChatChannel;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ChatChannel',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
    'Kernel::System::Valid',
);

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

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $NavBar = '';

    $NavBar = $LayoutObject->Header();
    $NavBar .= $LayoutObject->NavigationBar(
        Type => 'Admin',
    );

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {

        my $ChatChannelID = $ParamObject->GetParam( Param => 'ID' ) || '';

        # create CustomerGroup objects
        my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

        # get user data
        my %ChatChannel = $ChatChannelObject->ChatChannelGet(
            ChatChannelID => $ChatChannelID
        );

        my $Output = $NavBar;
        $Output .= $Self->_Edit(
            Action => 'Change',
            ID     => $ChatChannelID,
            %ChatChannel,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # add
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {
        my %GetParam;
        $GetParam{UserLogin}  = $ParamObject->GetParam( Param => 'UserLogin' )  || '';
        $GetParam{CustomerID} = $ParamObject->GetParam( Param => 'CustomerID' ) || '';
        my $Output = $NavBar;
        $Output .= $Self->_Edit(
            Action => 'Add',
            %GetParam,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # add or edit action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' || $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $Note = '';
        my ( %GetParam, %Errors );

        $GetParam{Name} = $ParamObject->GetParam( Param => 'Name' ) || '';

        $GetParam{GroupID} = $ParamObject->GetParam( Param => 'GroupID' ) || '';

        $GetParam{ValidID} = $ParamObject->GetParam( Param => 'Valid' ) || '';

        $GetParam{Comment} = $ParamObject->GetParam( Param => 'Comment' ) || '';

        $GetParam{ID} = $ParamObject->GetParam( Param => 'ID' ) || '';

        $GetParam{UserID} = $Self->{UserID};

        # check needed data
        for my $Needed (
            qw(Name GroupID ValidID)
            )
        {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # if no errors occurred
        if ( !%Errors ) {

            # create CustomerGroup objects
            my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

            my $ChatChannelID;

            # by default Success is 1
            my $Success = 1;

            # if new CustomerGroup should be added
            if ( !$GetParam{ID} ) {
                $ChatChannelID = $ChatChannelObject->ChatChannelAdd(%GetParam);
            }
            else {
                $ChatChannelID           = $GetParam{ID};
                $GetParam{ChatChannelID} = $GetParam{ID};
                $Success                 = $ChatChannelObject->ChatChannelUpdate(%GetParam);
            }

            if ( $ChatChannelID && $Success ) {

                $Self->_Overview();

                my $Output        = $NavBar . $Note;
                my $URL           = '';
                my $UserHTMLQuote = $LayoutObject->LinkEncode( $GetParam{Name} );
                my $UserQuote     = $LayoutObject->Ascii2Html( Text => $GetParam{Name} );

                if ( !$GetParam{ID} ) {
                    $Output
                        .= $LayoutObject->Notify(
                        Data => $LayoutObject->{LanguageObject}->Translate(
                            'Chat Channel %s added',
                            $UserQuote,
                            )
                            . "!",
                        );
                }
                else {
                    $Output
                        .= $LayoutObject->Notify(
                        Data => $LayoutObject->{LanguageObject}->Translate(
                            'Chat channel %s edited',
                            $UserQuote,
                            )
                            . "!",
                        );
                }
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AdminChatChannel',
                    Data         => \%Param,
                );

                $Output .= $LayoutObject->Footer();

                return $Output;
            }
            else {
                $Note .= $LayoutObject->Notify( Priority => 'Error' );
            }
        }

        # something has gone wrong
        my $Output = $NavBar . $Note;
        $Output .= $Self->_Edit(
            Action => 'Add',
            Errors => \%Errors,
            %GetParam,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    else {
        $Self->_Overview();
        my $Output = $NavBar;
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminChatChannel',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );

    # create CustomerGroup objects
    my $ChatChannelObject = $Kernel::OM->Get('Kernel::System::ChatChannel');

    my @ChatChannels = $ChatChannelObject->ChatChannelsGet( IncludeDefault => 1 );

    # sort channels by name
    @ChatChannels = sort { uc( $a->{Name} ) cmp uc( $b->{Name} ) }
        @ChatChannels;

    $LayoutObject->Block(
        Name => 'ActionAdd',
        Data => \%Param,
    );

    $LayoutObject->Block(
        Name => 'OverviewHeader',
        Data => {},
    );

    $LayoutObject->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );

    my %Groups = $Kernel::OM->Get('Kernel::System::Group')->GroupList();

    # if there are results to show
    if (@ChatChannels) {

        for my $ChatChannelRef (@ChatChannels) {

            my %ChatChannel = %$ChatChannelRef;
            $ChatChannel{Group} = $Groups{ $ChatChannel{GroupID} };

            my %ValidList = $ValidObject->ValidList();

            my $Validity = $ValidList{ $ChatChannel{ValidID} || '' } || '-';

            $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid    => $Validity,
                    RowClass => $Validity eq 'invalid' ? 'Invalid' : '',
                    %ChatChannel,
                },
            );

            $LayoutObject->Block(
                Name => 'OverviewResultRowLink',
                Data => {
                    Search => $Param{Search},
                    Nav    => $Param{Nav},
                    %ChatChannel,
                },
            );
        }
    }

    # otherwise it displays a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {
                ColSpan => 5,
            },
        );
    }
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block(
        Name => 'ActionOverview',
        Data => \%Param,
    );

    $LayoutObject->Block(
        Name => 'OverviewUpdate',
        Data => \%Param,
    );

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $Param{GroupOption} = $LayoutObject->BuildSelection(
        Data => {
            $DBObject->GetTableData(
                What  => 'id, name',
                Table => 'groups',
                Valid => 1,
            ),
        },
        Translation  => 0,
        PossibleNone => 1,
        Name         => 'GroupID',
        SelectedID   => $Param{GroupID},
        Class        => 'Modernize Validate_Required ' . ( $Param{Errors}->{'GroupIDInvalid'} || '' ),
    );

    $Param{Valid} = $LayoutObject->BuildSelection(
        Data       => { $ValidObject->ValidList(), },
        Name       => "Valid",
        SelectedID => defined( $Param{ValidID} ) ? $Param{ValidID} : 1,
        Class      => "Modernize Validate_Required",
    );

    # shows header
    if ( $Param{Action} eq 'Change' ) {
        $LayoutObject->Block( Name => 'HeaderEdit' );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    if ( $Param{Nav} && $Param{Nav} eq 'None' ) {
        $LayoutObject->Block( Name => 'BorrowedViewJS' );
    }

    return $LayoutObject->Output(
        TemplateFile => 'AdminChatChannel',
        Data         => \%Param,
    );
}

1;
