# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentDynamicFieldDatabaseDetails;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get params
    for my $Item (qw(DynamicFieldName ID)) {
        $Param{$Item} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Item );
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    if ( !$Param{DynamicFieldName} && !$Param{ID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No DynamicFieldName or ID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # get the pure DynamicField name without prefix
    my $DynamicFieldName = substr( $Param{DynamicFieldName}, 13 );

    # get the dynamic field value for the current ticket
    my $DynamicFieldConfig = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        Name => $DynamicFieldName,
    );

    # get the dynamic field database object
    $Kernel::OM->ObjectParamAdd(
        'Kernel::System::DynamicFieldDatabase' => {
            DynamicFieldConfig => $DynamicFieldConfig,
        },
    );
    my $DynamicFieldDatabaseObject = $Kernel::OM->Get('Kernel::System::DynamicFieldDatabase');

    # perform the search based on the given dynamic field config
    my @Result = $DynamicFieldDatabaseObject->DatabaseSearchDetails(
        Config     => $DynamicFieldConfig->{Config},
        Identifier => $Param{ID},
    );

    # show the search overview page
    $LayoutObject->Block(
        Name => 'DetailsOverview',
        Data => {
            DynamicFieldName => $DynamicFieldName,
        },
    );

    # iterate over the needed column and assign
    # them to the details overview
    COLUMN:
    for my $Column ( @{ $Result[0] } ) {

        next COLUMN if !$Column->{Label};

        $LayoutObject->Block(
            Name => 'DetailsRow',
            Data => {
                ColumnHead => $Column->{Label},
                ColumnData => $Column->{Data} || '',
            },
        );
    }

    # start with page ...
    my $Output = $LayoutObject->Header( Type => 'Small' );
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentDynamicFieldDatabaseDetails',
        Data         => {
            %Param,
            DynamicFieldName => $DynamicFieldName,
            }
    );
    $Output .= $LayoutObject->Footer( Type => 'Small' );

    return $Output;
}

sub _JSONReturn {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => [ $Param{Success} ],
    );

    # send response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || $LayoutObject->JSONEncode(
            Data => [],
        ),
        Type    => 'inline',
        NoCache => 1,
    );
}

1;
