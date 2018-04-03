# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminContactWithData;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # determine relevant dynamic fields
    my $TicketDynamicFieldList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        ObjectType => 'Ticket',
    );
    $Self->{ContactWithDataFields} = {};
    FIELD:
    for my $Field ( @{$TicketDynamicFieldList} ) {
        next FIELD if $Field->{FieldType} ne 'ContactWithData';
        next FIELD if $Field->{ValidID} ne 1;
        $Self->{ContactWithDataFields}->{ $Field->{ID} } = $Field;
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # determine field to show/search
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $Source = $ParamObject->GetParam( Param => 'Source' );
    if ( !$Source ) {
        $Source = (
            sort {
                $Self->{ContactWithDataFields}->{$a}->{Label}
                    cmp $Self->{ContactWithDataFields}->{$b}->{Label}
                } keys %{ $Self->{ContactWithDataFields} }
        )[0];
    }

    # get search terms
    my $Search = $ParamObject->GetParam( Param => 'Search' );
    $Search
        ||= $Kernel::OM->Get('Kernel::Config')->Get('AdminContactWithData::RunInitialWildcardSearch') ? '*' : '';

    # prepare nav bar
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NavBar       = $LayoutObject->Header();
    $NavBar .= $LayoutObject->NavigationBar();

    # override subaction if 'add' button was clicked
    if ( $Self->{Subaction} eq 'Search' && $ParamObject->GetParam( Param => 'Add' ) ) {
        $Self->{Subaction} = 'Add';
    }

    # edit contact mask
    if ( $Self->{Subaction} eq 'Change' ) {

        # get contact data
        my $Contact = $ParamObject->GetParam( Param => 'ID' );
        if ( !$Contact ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No contact is given!',
                Comment => 'Please contact the admin.',
            );
        }
        my $ContactData = $Self->{ContactWithDataFields}->{$Source}->{Config}->{ContactsWithData}->{$Contact};
        if ( !$ContactData ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No data found for given contact in given source!',
                Comment => 'Please contact the admin.',
            );
        }

        # print output
        my $Output = $NavBar;
        $Output .= $Self->_Edit(
            Action => 'Change',
            Source => $Source,
            Search => $Search,
            ID     => $Contact,
            Data   => $ContactData,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # change action
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get contact and field data
        my $Contact = $ParamObject->GetParam( Param => 'ID' );
        if ( !$Contact ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No contact is given!',
                Comment => 'Please contact the admin.',
            );
        }
        my $FieldData = $Self->{ContactWithDataFields}->{$Source};
        if ( !IsHashRefWithData($FieldData) ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No field data found!',
                Comment => 'Please contact the admin.',
            );
        }
        if ( !IsHashRefWithData( $FieldData->{Config}->{ContactsWithData}->{$Contact} ) ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No data found for given contact in given source!',
                Comment => 'Please contact the admin.',
            );
        }

        # get submitted params and overwrite old contact values
        my %NewValues;
        for my $Field ( sort keys %{ $FieldData->{Config}->{PossibleValues} } ) {
            $NewValues{$Field} = $ParamObject->GetParam( Param => $Field ) || '';
        }
        $FieldData->{Config}->{ContactsWithData}->{$Contact} = \%NewValues;

        # check for missing mandatory fields
        my %Errors;
        my $MandatoryFields = $FieldData->{Config}->{MandatoryFieldsComputed};
        FIELD:
        for my $Field ( @{$MandatoryFields} ) {
            next FIELD if $NewValues{$Field};
            $Errors{$Field} = 1;
        }

        my $Output = $NavBar;
        if ( !%Errors ) {

            # update contact (=update complete dynamic field)
            my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldUpdate(
                %{$FieldData},
                UserID => $Self->{UserID},
            );
            if ($UpdateSuccess) {
                $Self->{ContactWithDataFields}->{$Source} = $FieldData;

                # get contact data and show screen again
                $Self->_Overview(
                    Search => $Search,
                    Source => $Source,
                );
                $Output .= $LayoutObject->Notify( Info => 'Contact updated!' );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AdminContactWithData',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }

            # update went wrong
            $Errors{UpdateSuccess} = 1;
            $Output .= $LayoutObject->Notify(
                Info     => 'Error updating contact!',
                Priority => 'Error',
            );
        }

        # something has gone wrong
        $Output .= $Self->_Edit(
            Action => 'Change',
            Source => $Source,
            Search => $Search,
            Errors => \%Errors,
            ID     => $Contact,
            Data   => \%NewValues,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # add contact mask
    elsif ( $Self->{Subaction} eq 'Add' ) {

        # print output
        my $Output = $NavBar;
        $Output .= $Self->_Edit(
            Action => 'Add',
            Source => $Source,
            Search => $Search,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # add action
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get field data
        my $FieldData = $Self->{ContactWithDataFields}->{$Source};
        if ( !IsHashRefWithData($FieldData) ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No field data found!',
                Comment => 'Please contact the admin.',
            );
        }

        # create contact id, increment highest existing id for new contact
        my @ReverseSortedKeys = reverse sort { $a <=> $b } keys %{ $FieldData->{Config}->{ContactsWithData} };

        # get the highest id
        my ($Contact) = @ReverseSortedKeys;

        $Contact ||= 0;
        ++$Contact;

        # get submitted params and set new contact values
        my %NewValues;
        for my $Field ( sort keys %{ $FieldData->{Config}->{PossibleValues} } ) {
            $NewValues{$Field} = $ParamObject->GetParam( Param => $Field ) || '';
        }
        $FieldData->{Config}->{ContactsWithData}->{$Contact} = \%NewValues;

        # check for missing mandatory fields
        my %Errors;
        my $MandatoryFields = $FieldData->{Config}->{MandatoryFieldsComputed};
        FIELD:
        for my $Field ( @{$MandatoryFields} ) {
            next FIELD if $NewValues{$Field};
            $Errors{$Field} = 1;
        }

        my $Output = $NavBar;
        if ( !%Errors ) {

            # create contact (=update complete dynamic field)
            my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldUpdate(
                %{$FieldData},
                UserID => $Self->{UserID},
            );
            if ($UpdateSuccess) {
                $Self->{ContactWithDataFields}->{$Source} = $FieldData;

                # get contact data and show screen again
                $Self->_Overview(
                    Search => $Search,
                    Source => $Source,
                );
                $Output .= $LayoutObject->Notify( Info => 'Contact created!' );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AdminContactWithData',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }

            # update went wrong
            $Errors{CreateSuccess} = 1;
            $Output .= $LayoutObject->Notify(
                Info     => 'Error creating contact!',
                Priority => 'Error',
            );
        }

        # something has gone wrong
        $Output .= $Self->_Edit(
            Action => 'Add',
            Source => $Source,
            Search => $Search,
            Errors => \%Errors,
            ID     => $Contact,
            Data   => \%NewValues,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # overview / search contact list
    else {

        # safety check for source
        if ( !IsHashRefWithData( $Self->{ContactWithDataFields} ) ) {
            return $LayoutObject->ErrorScreen(
                Message =>
                    "No sources found, at least one 'Contact with data' Dynamic Field must be added to the system!",
                Comment => 'Please contact the admin.',
            );
        }
        if ( $Search && !IsHashRefWithData( $Self->{ContactWithDataFields}->{$Source} ) ) {
            return $LayoutObject->ErrorScreen(
                Message => 'No data found for given source!',
                Comment => 'Please contact the admin.',
            );
        }

        $Self->_Overview(
            Search => $Search,
            Source => $Source,
        );

        # print output
        my $Output = $NavBar;
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminContactWithData',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );

    # prepare available sources
    my %Sources;
    for my $DynamicField ( sort keys %{ $Self->{ContactWithDataFields} } ) {
        $Sources{$DynamicField} = $Self->{ContactWithDataFields}->{$DynamicField}->{Label};
    }

    $Param{SourceOption} = $LayoutObject->BuildSelection(
        Data       => { %Sources, },
        Name       => 'Source',
        SelectedID => $Param{Source} || '',
    );

    $LayoutObject->Block(
        Name => 'ActionSearch',
        Data => \%Param,
    );

    $LayoutObject->Block(
        Name => 'OverviewHeader',
        Data => {
            Label => $Self->{ContactWithDataFields}->{ $Param{Source} }->{Label},
        },
    );

    if ( $Param{Search} ) {
        $LayoutObject->Block(
            Name => 'OverviewResult',
            Data => \%Param,
        );

        # make search safe and use '*' as wildcard
        my $Search = $Param{Search};
        $Search =~ s{ \A \s+ }{}xms;
        $Search =~ s{ \s+ \z }{}xms;
        $Search = 'A' . $Search . 'Z';
        my @SearchParts = split '\*', $Search;
        for my $SearchPart (@SearchParts) {
            $SearchPart = quotemeta($SearchPart);
        }
        $Search = join '.*', @SearchParts;
        $Search =~ s{ \A A }{}xms;
        $Search =~ s{ Z \z }{}xms;

        # search contacts
        my $PossibleContacts =
            $Self->{ContactWithDataFields}->{ $Param{Source} }->{Config}->{ContactsWithData};
        my $SearchableFields =
            $Self->{ContactWithDataFields}->{ $Param{Source} }->{Config}
            ->{SearchableFieldsComputed};
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
        my $ContactsFound;
        CONTACT:

        # sort by name
        for my $Contact (
            sort { lc( $PossibleContacts->{$a}->{Name} ) cmp lc( $PossibleContacts->{$b}->{Name} ) }
            keys %{$PossibleContacts}
            )
        {
            my $ContactData = $PossibleContacts->{$Contact};
            my $SearchMatch;
            FIELD:
            for my $Field ( @{$SearchableFields} ) {
                next FIELD if $ContactData->{$Field} !~ m{ $Search }xmsi;
                $SearchMatch = 1;
                last FIELD;
            }
            next CONTACT if !$SearchMatch;

            $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid => $ValidList{ $ContactData->{ValidID} || '' } || '-',
                    Search => $Param{Search},
                    Name   => $ContactData->{Name},
                    Source => $Param{Source},
                    ID     => $Contact,
                },
            );
            $ContactsFound = 1;
        }

        # when there is no data to show, a message is displayed on the table with this colspan
        if ( !$ContactsFound ) {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {
                    ColSpan => 2,
                },
            );
        }
    }

    # if there is nothing to search it shows a message
    else
    {
        $LayoutObject->Block(
            Name => 'NoSearchTerms',
            Data => {},
        );
    }
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
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

    # shows header
    if ( $Param{Action} eq 'Change' ) {
        $LayoutObject->Block(
            Name => 'HeaderEdit',
            Data => {
                Label => $Self->{ContactWithDataFields}->{ $Param{Source} }->{Label},
            },
        );
    }
    else {
        $LayoutObject->Block(
            Name => 'HeaderAdd',
            Data => {
                Label => $Self->{ContactWithDataFields}->{ $Param{Source} }->{Label},
            },
        );
    }

    my $PossibleValues  = $Self->{ContactWithDataFields}->{ $Param{Source} }->{Config}->{PossibleValues};
    my $SortOrder       = $Self->{ContactWithDataFields}->{ $Param{Source} }->{Config}->{SortOrderComputed};
    my $MandatoryFields = $Self->{ContactWithDataFields}->{ $Param{Source} }->{Config}->{MandatoryFieldsComputed};
    my %IsMandatory     = map { $_ => 1 } @{$MandatoryFields};
    for my $Field ( @{$SortOrder} ) {
        $LayoutObject->Block(
            Name => 'Item',
            Data => {},
        );

        my %GetParam;
        my $Block = 'Input';

        if ( $IsMandatory{$Field} ) {

            # add validation
            $GetParam{RequiredClass}          = 'Validate_Required';
            $GetParam{RequiredLabelClass}     = 'Mandatory';
            $GetParam{RequiredLabelCharacter} = '*';

            if ( $Param{Errors}->{$Field} ) {
                $GetParam{InvalidField} = 'ServerError';
            }
        }

        if ( $Field eq 'ValidID' ) {

            # build ValidID string
            $Block = 'Option';
            $GetParam{Option} = $LayoutObject->BuildSelection(
                Data       => { $Kernel::OM->Get('Kernel::System::Valid')->ValidList(), },
                Name       => $Field,
                SelectedID => defined( $Param{Data}->{$Field} ) ? $Param{Data}->{$Field} : 1,
            );
        }
        else {
            $GetParam{Value} = $Param{Data}->{$Field};
        }

        $GetParam{Name}  = $Field;
        $GetParam{Label} = $PossibleValues->{$Field};
        $LayoutObject->Block(
            Name => $Block,
            Data => \%GetParam,
        );
    }

    return $LayoutObject->Output(
        TemplateFile => 'AdminContactWithData',
        Data         => \%Param,
    );
}

1;
