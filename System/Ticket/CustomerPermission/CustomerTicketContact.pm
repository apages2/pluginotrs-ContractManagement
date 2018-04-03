# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::CustomerPermission::CustomerTicketContact;

use utf8;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::DynamicField',
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

    # check needed stuff
    for my $Argument (qw(TicketID UserID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );

            return;
        }
    }

    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        UserID        => 1,
    );

    my $CustomerDynamicFields = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
        FieldType  => 'Customer',    # here is the magic
    );

    # nothing to do here
    return if !IsArrayRefWithData($CustomerDynamicFields);

    CUSTOMERDF:
    for my $CurrentDynamicField ( @{$CustomerDynamicFields} ) {

        if (
            !IsHashRefWithData($CurrentDynamicField)
            || !IsHashRefWithData( $CurrentDynamicField->{Config} )
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Unsupported DynamicField format!',
            );
            next CUSTOMERDF;
        }

        # for better code reading
        my %CurrentDynamicField       = %{$CurrentDynamicField};
        my %CurrentDynamicFieldConfig = %{ $CurrentDynamicField->{Config} };

        # skip if the tab is disabled
        next CUSTOMERDF if !$CurrentDynamicFieldConfig{CustomerInterfaceTab};

        for my $CustomerID ( sort @{ $Ticket{ 'DynamicField_' . $CurrentDynamicField{Name} } } ) {
            if ( $Param{UserID} eq $CustomerID ) {

                return 1;
            }
        }
    }

    return;
}

1;
