# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentAttributeDynamicFieldMap;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::Ticket',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
);

=head1 NAME

Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentAttributeDynamicFieldMap - Event handler

=head1 SYNOPSIS

This handler assigns Ticket DynamicFields based on linked config items.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

    use Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentAttributeDynamicFieldMap;
    my $OTRSCIAssignmentAttributeDynamicFieldMapObject = Kernel::System::ITSMConfigItem::Event::OTRSCIAssignmentAttributeDynamicFieldMap->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item Run()

This method handles the event.

    $OTRSCIAssignmentAttributeDynamicFieldMapObject->Run(
        Event => 'LinkAdd',
        Data  => {
            Comment      => 'new value: 1',
            ConfigItemID => 123,
        },
        UserID => 1,
    );

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data Event UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }
    for my $Needed (qw(Comment ConfigItemID)) {
        if ( !$Param{Data}->{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed in Data!",
            );
            return;
        }
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $DFMapping = $ConfigObject->Get('ITSMConfigItem::TicketDynamicFieldMapping');
    return 1 if ( !defined $DFMapping || !ref $DFMapping eq 'HASH' );

    # safety check - only link add/delete events
    return 1 if $Param{Event} !~ m{ \A Link (?: Add) \z }xms;

    # only for ticket <-> CI link actions
    return 1 if $Param{Data}->{Comment} !~ m{ \A ( \d+ ) %% Ticket \z }xms;

    my $TicketID = $1;

    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
        TicketID      => $TicketID,
        UserID        => $Param{UserID},
        DynamicFields => 1,
    );

    return 1 if ( !%Ticket );

    # get config item object
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    my $ConfigItem = $ConfigItemObject->ConfigItemGet(
        ConfigItemID => $Param{Data}->{ConfigItemID},
    );
    return if !$ConfigItem;

    my $CIVersion = $ConfigItemObject->VersionGet(
        VersionID => $ConfigItem->{LastVersionID},
    );
    return if !$CIVersion;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # Holds the Array of all Ticket Dynamic Field Configurations
    my $DFCfgArray = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,          # optional, defaults to 1
        ObjectType => 'Ticket',
    );

    if ( !defined $DFCfgArray || !ref $DFCfgArray eq 'ARRAY' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "No DynamicFields configured, please add DynamicFields for CI Attributes!",
        );
        return;
    }
    my $DFValueMapping = $ConfigObject->Get('ITSMConfigItem::TicketDynamicFieldValueMapping');

    # Check-hash holding the Dynamic Fields needed for our mapping
    # Structure:
    # $NeededDFs{DynamicFieldName} => 1;
    my %NeededDFs = map { $DFMapping->{$_} => 1 } keys %{$DFMapping};

    # Now find the Dynamic Fields Configuration of just the Dynamic Fields we need for our mapping
    # and put them into a Hash of the structure:
    #
    # ----------- cut here -----------------------
    # %DFConfig = (
    #       'SerialNumber' => {
    #                         'FieldOrder' => '12',
    #                         'ID' => '13',
    #                         'ChangeTime' => '2015-01-21 14:55:53',
    #                         'Name' => 'SerialNumber',
    #                         'Label' => 'SerialNumber',
    #                         'CreateTime' => '2015-01-21 14:55:53',
    #                         'ObjectType' => 'Ticket',
    #                         'Config' => {
    #                                       'RegExList' => [],
    #                                       'Link' => '',
    #                                       'DefaultValue' => ''
    #                                     },
    #                         'InternalField' => '0',
    #                         'FieldType' => 'Text',
    #                         'ValidID' => '1'
    #                       },
    #       'WarrantyExpirationDate' => {
    #                                   'Name' => 'WarrantyExpirationDate',
    #                                   'Label' => 'WarrantyExpirationDate',
    #                                   'CreateTime' => '2015-01-21 14:55:24',
    #                                   'ObjectType' => 'Ticket',
    #                                   'ValidID' => '1',
    #                                   'Config' => {
    #                                                 'Link' => '',
    #                                                 'YearsInFuture' => '5',
    #                                                 'YearsPeriod' => '0',
    #                                                 'DateRestriction' => '',
    #                                                 'DefaultValue' => '0',
    #                                                 'YearsInPast' => '5'
    #                                               },
    #                                   'InternalField' => '0',
    #                                   'FieldType' => 'Date',
    #                                   'ChangeTime' => '2015-01-21 14:55:24',
    #                                   'FieldOrder' => '11',
    #                                   'ID' => '12'
    #                                 },
    # );
    #
    # ----------- cut here -----------------------
    # Key = DynamicField Name
    # Value = DynamicField Config
    #
    # What happens?
    # 1. we grep through the DFcfgarray holding ALL DynamicFieldConfigs
    #    and take a look if the config we're actually dealing with is one we will need for our mapping
    #     $NeededDFs{ $_->{Name} } eq '1'
    #
    #   The result of that grep is an array holding _just_ the configurations that we need for our mapping
    #   To access the config more quickly
    #
    # 2. To access the configurations more quickly
    #    we use map to reformat that Array to a Hash, Key = DynamicField Name, Value = DynamicFieldConfig
    my %DFConfig
        = map { $_->{Name} => $_ } grep { $NeededDFs{ $_->{Name} } && $NeededDFs{ $_->{Name} } eq '1' } @{$DFCfgArray};
    my %CIValues = ();

    for my $CIKey ( sort keys %{$DFMapping} ) {

        # If we have sub-keys the notation in the SysConfig has to be
        # NIC::IPoverDHCP
        # or
        # NIC::IPAddress
        # always using the "Key" of the CI Attribute
        my @CIPath = ();
        if ( $CIKey =~ /::/ ) {
            @CIPath = split /::/, $CIKey;
        }
        else {
            push @CIPath, $CIKey;
        }
        my $TypeAndData = $Self->_GetDefinition(
            CIXMLData => $CIVersion->{XMLData}->[1]->{Version}->[1],
            CIXMLDef  => $CIVersion->{XMLDefinition},
            CIPath    => \@CIPath,
        );

        # Just if we got a value from the CI
        # and the DynamicField of the Ticket we are dealing with
        # is empty
        # we take over the value
        if (
            defined $TypeAndData
            && ref $TypeAndData eq 'HASH'
            && !length $Ticket{ 'DynamicField_' . $DFMapping->{$CIKey} }
            && length $TypeAndData->{Content}
            )
        {
            # For the general_catalog items and others that's values have to be translated
            # to valid DynamicField values
            # we have the DFValueMapping hash
            # that takes ConfigItem Values and maps them to DynamicField values
            if (
                defined $DFValueMapping
                && ref $DFValueMapping eq 'HASH'
                && defined $DFValueMapping->{$CIKey}
                && ref $DFValueMapping->{$CIKey} eq 'HASH'
                && defined $DFValueMapping->{$CIKey}->{ $TypeAndData->{Content} }
                && length $DFValueMapping->{$CIKey}->{ $TypeAndData->{Content} }
                )
            {
                my $Success = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->ValueSet(
                    DynamicFieldConfig => $DFConfig{ $DFMapping->{$CIKey} },
                    ObjectID           => $TicketID,
                    Value              => $DFValueMapping->{$CIKey}->{ $TypeAndData->{Content} },
                    UserID             => $Param{UserID},
                );
            }

            # for the rest we take what we have
            else {
                # Exception for CI attributes of type Date:
                # they are stored as regular YYYY-MM-DD without a time part
                #
                # DynamicFields of Type Date need a Date and Time so add 00:00:00
                # to the date to make it valid for the DF
                if (
                    $TypeAndData->{Type} eq 'Date'
                    && $TypeAndData->{Content} =~ /^\d\d\d\d\-\d\d\-\d\d$/
                    )
                {
                    $TypeAndData->{Content} = $TypeAndData->{Content} . " 00:00:00";
                }
                my $Success = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->ValueSet(
                    DynamicFieldConfig => $DFConfig{ $DFMapping->{$CIKey} },
                    ObjectID           => $TicketID,
                    Value              => $TypeAndData->{Content},
                    UserID             => $Param{UserID},
                );
            }
        }

    }

    return 1;
}

sub _GetDefinition {
    my ( $Self, %Param ) = @_;

    return {} if ( !defined $Param{CIPath}   || ref $Param{CIPath} ne 'ARRAY' );
    return {} if ( !defined $Param{CIXMLDef} || ref $Param{CIXMLDef} ne 'ARRAY' );

    my $CI = shift @{ $Param{CIPath} };

    my @Definition = grep { $_->{Key} eq $CI } @{ $Param{CIXMLDef} };
    my @Data = ();
    if (
        defined $Param{CIXMLData}
        && ref $Param{CIXMLData} eq 'HASH'
        && defined $Param{CIXMLData}->{$CI}
        && ref $Param{CIXMLData}->{$CI} eq 'ARRAY'
        )
    {
        @Data = @{ $Param{CIXMLData}->{$CI} };
    }

    if (
        @{ $Param{CIPath} }
        && @Definition
        && defined $Definition[0]
        && ref $Definition[0] eq 'HASH'
        && defined $Definition[0]->{Sub}
        && ref $Definition[0]->{Sub} eq 'ARRAY'
        && @Data
        && defined $Data[1]
        && ref $Data[1] eq 'HASH'
        )
    {
        return $Self->_GetDefinition(
            CIPath    => $Param{CIPath},
            CIXMLDef  => $Definition[0]->{Sub},
            CIXMLData => $Data[1],
        );
    }
    else {
        # Here we've reached the final element who's value we wanted to get
        #
        # If we deal with Type "GeneralCatalog"
        # and Class starts with "ITSM::ConfigItem"
        # the Content of the data is the ID of the
        # Value stored in the general_catalog table
        #
        # -> get the value for the transfer to a DynamicField
        my $Result = {};
        if (
            @Definition
            && defined $Definition[0]
            && ref $Definition[0] eq 'HASH'
            && defined $Definition[0]->{Input}
            && ref $Definition[0]->{Input} eq 'HASH'
            && defined $Definition[0]->{Input}->{Type}
            && $Definition[0]->{Input}->{Type} eq 'GeneralCatalog'
            && defined $Definition[0]->{Input}->{Class}
            && $Definition[0]->{Input}->{Class} =~ /^ITSM::ConfigItem/
            && @Data
            && defined $Data[1]
            && ref $Data[1] eq 'HASH'
            && defined $Data[1]->{Content}
            && length $Data[1]->{Content}
            && $Data[1]->{Content} =~ /^\d+$/
            )
        {

            my $ItemDataRef = $Kernel::OM->Get('Kernel::System::GeneralCatalog')->ItemGet(
                ItemID => $Data[1]->{Content},
            );
            if ( defined $ItemDataRef ) {
                $Result = {
                    Type    => $ItemDataRef->{Class},
                    Content => $ItemDataRef->{Name},
                };
            }
            else {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'debug',
                    Message =>
                        "No ConfigItem found for GeneralCatalog Class $Definition[0]->{Input}->{Class} with ID $Data[1]->{Content}!",
                );
            }
        }
        else {
            if (
                @Definition
                && defined $Definition[0]
                && ref $Definition[0] eq 'HASH'
                && defined $Definition[0]->{Input}
                && ref $Definition[0]->{Input} eq 'HASH'
                && defined $Definition[0]->{Input}->{Type}
                && @Data
                && defined $Data[1]
                && ref $Data[1] eq 'HASH'
                && defined $Data[1]->{Content}
                && length $Data[1]->{Content}
                )
            {
                $Result = {
                    Type    => $Definition[0]->{Input}->{Type},
                    Content => $Data[1]->{Content},
                    }

            }
            else {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'debug',
                    Message  => "Could not find Type or Content for Attribute $CI!",
                );
            }
        }
        return $Result;
    }
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=head1 VERSION

=cut
