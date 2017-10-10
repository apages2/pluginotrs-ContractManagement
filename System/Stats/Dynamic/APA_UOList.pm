# --
# Kernel/System/Stats/Dynamic/APA_UOList.pm - all advice functions
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Dynamic::APA_UOList;

use strict;
use warnings;

use List::Util qw( first );

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Lock',
    'Kernel::System::Log',
    'Kernel::System::Priority',
    'Kernel::System::Queue',
    'Kernel::System::Service',
    'Kernel::System::SLA',
    'Kernel::System::State',
    'Kernel::System::Stats',
    'Kernel::System::Ticket',
    'Kernel::System::Time',
    'Kernel::System::Type',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

	$Self->{Group} = $ConfigObject->Get('ContractManagement::Config')->{Group};

    
    return $Self;
}

sub GetObjectName {
    my ( $Self, %Param ) = @_;

    return 'UODecompte';
}

sub GetObjectAttributes {
    my ( $Self, %Param ) = @_;
	
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
	
	my %Limit = (
        5         => 5,
        10        => 10,
        20        => 20,
        50        => 50,
        100       => 100,
        unlimited => Translatable('unlimited'),
    );
	
	my %UOAttributes = %{ $Self->_UOAttributes() };
	my %OrderBy = map { $_ => $UOAttributes{$_} } grep { $_ ne 'Number' } keys %UOAttributes;
	my %SortSequence = (
        Up   => Translatable('ascending'),
        Down => Translatable('descending'),
    );
	
    my @ObjectAttributes = (
        {
            Name             => Translatable('Attributes to be printed'),
            UseAsXvalue      => 1,
            UseAsValueSeries => 0,
            UseAsRestriction => 0,
            Element          => 'UOAttributes',
            Block            => 'MultiSelectField',
            Translation      => 1,
            Values           => \%UOAttributes,
            Sort             => 'IndividualKey',
            SortIndividual   => $Self->_SortedAttributes(),

        },
		{
            Name             => Translatable('Create Time'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'CreateTime',
            TimePeriodFormat => 'DateInputFormat',             # 'DateInputFormatLong',
            Block            => 'Time',
            Values           => {
                TimeStart => 'UOCreateTimeNewerDate',
                TimeStop  => 'UOCreateTimeOlderDate',
            },
        },
        {
            Name             => Translatable('Order by'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 1,
            UseAsRestriction => 0,
            Element          => 'OrderBy',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%OrderBy,
            Sort             => 'IndividualKey',
            SortIndividual   => $Self->_SortedAttributes(),
        },
        {
            Name             => Translatable('Sort sequence'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 1,
            UseAsRestriction => 0,
            Element          => 'SortSequence',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%SortSequence,
        },
        {
            Name             => Translatable('Limit'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'Limit',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%Limit,
            Sort             => 'IndividualKey',
            SortIndividual   => [ '5', '10', '20', '50', '100', 'unlimited', ],
        },
		
        
    );
	
	
        # Get Pool UO by Customer
        # (This way also can be the solution for the CustomerUserID)
        $DBObject->Prepare(
            SQL => "SELECT TR_ID, TR_CustID, TR_Caff FROM APA_TR where TR_Type LIKE 'SO_COG-UO-1%'",
        );

        # fetch the result
        my %UOID;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            if ( $Row[0] ) {
                $UOID{ $Row[0] } = $Row[1]." - ".$Row[2];
            }
        }

        my %ObjectAttribute = (
            Name             => Translatable('Contract Number'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'TR_ID',
            Block            => 'MultiSelectField',
            Values           => \%UOID,
        );

        push @ObjectAttributes, \%ObjectAttribute;
    
	
	return @ObjectAttributes;
}

sub GetStatTablePreview {
    my ( $Self, %Param ) = @_;

    return $Self->GetStatTable(
        %Param,
        Preview => 1,
    );
}

sub GetStatTable {
    my ( $Self, %Param ) = @_;
    my %UOAttributes    = map { $_ => 1 } @{ $Param{XValue}{SelectedValues} };
    my $SortedAttributesRef = $Self->_SortedAttributes();
    my $Preview             = $Param{Preview};

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
	my $UOObject = $Kernel::OM->Get('Kernel::System::Exaprobe::APA_UO');
	
	
	# set default values if no sort or order attribute is given
    my $OrderRef = first { $_->{Element} eq 'OrderBy' } @{ $Param{ValueSeries} };
    my $OrderBy = $OrderRef ? $OrderRef->{SelectedValues}[0] : 'date';
    my $SortRef = first { $_->{Element} eq 'SortSequence' } @{ $Param{ValueSeries} };
    my $Sort = $SortRef ? $SortRef->{SelectedValues}[0] : 'Down';
    my $Limit = $Param{Restrictions}{Limit};

	 
	 
	# get the involved tickets
    my @UOList;

    if ($Preview) {
        @UOList = $UOObject->GetUOList(
            UserID     => 1,
			Limit  => 10, 
			%{ $Param{Restrictions} },
        );
    }
    else {
        @UOList = $UOObject->GetUOList(
            UserID     => 1,
			%{ $Param{Restrictions} },
        );
    }
	
	
	
	
	# $Kernel::OM->Get('Kernel::System::Log')->Dumper($SortedAttributesRef);
	 # generate the UO list
    my @StatArray;
    for my $UO (@UOList) {
		my @ResultRow;
		ATTRIBUTE:
        for my $Attribute ( @{$SortedAttributesRef} ) {
            next ATTRIBUTE if !$UOAttributes{$Attribute};
			
			# $Kernel::OM->Get('Kernel::System::Log')->Log(
				# Priority => 'error',
				# Message  => ${$UO}{ticket_id},
			# );
			
            push @ResultRow, ${$UO}{$Attribute};
        }
        push @StatArray, \@ResultRow;
	}
	
	@StatArray = $Self->_IndividualResultOrder(
            StatArray          => \@StatArray,
            OrderBy            => $OrderBy,
            Sort               => $Sort,
            SelectedAttributes => \%UOAttributes,
            Limit              => $Limit,
        );
	
	return @StatArray;
}

sub GetHeaderLine {
    my ( $Self, %Param ) = @_;
    my %SelectedAttributes = map { $_ => 1 } @{ $Param{XValue}{SelectedValues} };

    my $UOAttributes    = $Self->_UOAttributes();
    my $SortedAttributesRef = $Self->_SortedAttributes();
    my @HeaderLine;

    # get language object
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

    ATTRIBUTE:
    for my $Attribute ( @{$SortedAttributesRef} ) {
        next ATTRIBUTE if !$SelectedAttributes{$Attribute};
        push @HeaderLine, $LanguageObject->Translate( $UOAttributes->{$Attribute} );
    }
    return \@HeaderLine;
}

sub _UOAttributes { 
	my $Self = shift;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my %UOAttributes = (
		TR_ID => 'Contract Number',
		ticket_number => $ConfigObject->Get('Ticket::Hook'),
        UO_unit   => 'Number of UO deduct',
        date => 'Date',
        owner => 'Owner',
        Subject => 'Subject',
    );
return \%UOAttributes;
}

sub _SortedAttributes {
    my $Self = shift;

    my @SortedAttributes = qw(
		TR_ID
		ticket_number
        UO_unit
        date
        owner
		Subject
    );

    

    return \@SortedAttributes;
}

sub _IndividualResultOrder {
    my ( $Self, %Param ) = @_;
    my @Unsorted = @{ $Param{StatArray} };
    my @Sorted;

    # find out the positon of the values which should be
    # used for the order
    my $Counter          = 0;
    my $SortedAttributes = $Self->_SortedAttributes();

    ATTRIBUTE:
    for my $Attribute ( @{$SortedAttributes} ) {
        next ATTRIBUTE if !$Param{SelectedAttributes}{$Attribute};
        last ATTRIBUTE if $Attribute eq $Param{OrderBy};
        $Counter++;
    }

    # order after a individual attribute
    if ( $Param{OrderBy} eq 'TR_ID' ) {
        @Sorted = sort { $a->[$Counter] <=> $b->[$Counter] } @Unsorted;
    }
	elsif ( $Param{OrderBy} eq 'ticket_number' ) {
        @Sorted = sort { $a->[$Counter] <=> $b->[$Counter] } @Unsorted;
    }
    elsif ( $Param{OrderBy} eq 'UO_unit' ) {
        @Sorted = sort { $a->[$Counter] cmp $b->[$Counter] } @Unsorted;
    }
    elsif ( $Param{OrderBy} eq 'date' ) {
        @Sorted = sort { $a->[$Counter] <=> $b->[$Counter] } @Unsorted;
    }
    elsif ( $Param{OrderBy} eq 'owner' ) {
        @Sorted = sort { $a->[$Counter] <=> $b->[$Counter] } @Unsorted;
    }
    else {
        @Sorted = sort { $a->[$Counter] cmp $b->[$Counter] } @Unsorted;
    }

    # make a reverse sort if needed
    if ( $Param{Sort} eq 'Down' ) {
        @Sorted = reverse @Sorted;
    }

    # take care about the limit
    if ( $Param{Limit} && $Param{Limit} ne 'unlimited' ) {
        my $Count = 0;
        @Sorted = grep { ++$Count <= $Param{Limit} } @Sorted;
    }

    return @Sorted;
}




1;

