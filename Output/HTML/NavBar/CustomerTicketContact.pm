# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NavBar::CustomerTicketContact;

use strict;
use warnings;

use utf8;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $CustomerDynamicFields = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
        FieldType  => 'Customer',    # here is the magic
    );

    # nothing to do here
    return if !IsArrayRefWithData($CustomerDynamicFields);

    my %TmpResult;
    my $CustomerDynamicFieldPrio = '501';

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    CUSTOMERDF:
    for my $CurrentDynamicField ( @{$CustomerDynamicFields} ) {

        if (
            !IsHashRefWithData($CurrentDynamicField)
            || !IsHashRefWithData( $CurrentDynamicField->{Config} )
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Unsupported DynamicField format!'
            );

            next CUSTOMERDF;
        }

        # for better code reading
        my %CurrentDynamicField       = %{$CurrentDynamicField};
        my %CurrentDynamicFieldConfig = %{ $CurrentDynamicField->{Config} };

        # skip if the tab is disabled
        next CUSTOMERDF if !$CurrentDynamicFieldConfig{CustomerInterfaceTab};

        # perform ticket search
        my @TicketIDs = $TicketObject->TicketSearch(

            # check if there are tickets for this customer field
            # where the current customer is stored
            'DynamicField_' . $CurrentDynamicField{Name} => {
                Equals => $Self->{UserID},
            },

            # result (required)
            Result => 'ARRAY',

            # result limit
            Limit      => 1,
            UserID     => 1,
            Permission => 'ro',
        );

        # no tickets - no link
        next CUSTOMERDF if !@TicketIDs;

        # build the expected structure
        my $TmpPrioKey = sprintf( "%07d", $CustomerDynamicFieldPrio );
        my $TmpNameDescription = $CurrentDynamicFieldConfig{CustomerInterfaceTabName}
            || $CurrentDynamicField{Name} . ' Tickets';
        $TmpResult{$TmpPrioKey} = {
            'Prio'        => $CustomerDynamicFieldPrio,
            'Block'       => '',
            'NavBar'      => 'Ticket',
            'Type'        => 'Submenu',
            'LinkOption'  => '',
            'AccessKey'   => '',
            'Description' => $TmpNameDescription,
            'Name'        => $TmpNameDescription,
            'Link'        => 'Action=CustomerTicketContact&ID=' . $CurrentDynamicField{ID},
            },

            # increase the Prio counter
            $CustomerDynamicFieldPrio++;
    }

    return (
        Sub => {
            Ticket => \%TmpResult,
        },
    );
}

1;
