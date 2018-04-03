# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OTRSCustomContactFieldsAdminNotificationEvent;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Web::Request',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::Ticket',
    'Kernel::System::NotificationEvent',
    'Kernel::System::DynamicField::Backend',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $TemplateName = $Param{TemplateFile} || '';
    return 1 if !$TemplateName;

    # get valid modules
    my $ValidTemplates = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Output::FilterElementPost')
        ->{'OTRSCustomContactFieldsAdminNotificationEvent'}->{Templates};

    # apply only if template is valid in config
    return 1 if !$ValidTemplates->{$TemplateName};

    # get a local param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    return 1 if !$ParamObject->GetParam( Param => 'Subaction' );

    # get needed objects
    my $NotificationEventObject   = $Kernel::OM->Get('Kernel::System::NotificationEvent');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get notification id
    my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';

    # get subaction
    my $Subaction = $ParamObject->GetParam( Param => 'Subaction' );

    # dynamic field section
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    );

    my $OptionAdd = '';

    LIST:
    for my $DynamicList ( @{$DynamicFieldList} ) {
        next LIST if $DynamicList->{FieldType} ne 'Customer';

        # Fallback if UseForNotification is not set
        if ( !$DynamicList->{Config}->{UseForNotification} && !defined( $DynamicList->{Config}->{UseForNotification} ) )
        {
            $OptionAdd
                .= '<option value="Contact_TO_'
                . $DynamicList->{Name} . '">'
                . $DynamicList->{Name}
                . ' (To)</option>';
        }
        if (
            $DynamicList->{Config}->{UseForNotification}
            && index( $DynamicList->{Config}->{UseForNotification}, 'To' ) != -1
            )
        {
            $OptionAdd
                .= '<option value="Contact_TO_'
                . $DynamicList->{Name} . '">'
                . $DynamicList->{Name}
                . ' (To)</option>';
        }
        if (
            $DynamicList->{Config}->{UseForNotification}
            && index( $DynamicList->{Config}->{UseForNotification}, 'Cc' ) != -1
            )
        {
            $OptionAdd
                .= '<option value="Contact_CC_'
                . $DynamicList->{Name} . '">'
                . $DynamicList->{Name}
                . ' (Cc)</option>';
        }
        if (
            $DynamicList->{Config}->{UseForNotification}
            && index( $DynamicList->{Config}->{UseForNotification}, 'Bcc' ) != -1
            )
        {
            $OptionAdd
                .= '<option value="Contact_BCC_'
                . $DynamicList->{Name} . '">'
                . $DynamicList->{Name}
                . ' (Bcc)</option>';
        }
    }

    if ( $Subaction eq 'Add' ) {

        ${ $Param{Data} }
            =~ s{(<label .+? for="Recipients"> .+? <option .+? value="Customer"> .+? </option>)}{$1 $OptionAdd}xmsg;

    }
    elsif ( $Subaction eq 'Change' ) {

        ${ $Param{Data} }
            =~ s{(<label .+? for="Recipients"> .+? <option .+? value="Customer"> .+? </option>)}{$1 $OptionAdd}xmsg;

        my %Data = $NotificationEventObject->NotificationGet(
            ID => $ID,
        );

        RECIPIENTS:
        for my $Recipients ( @{ $Data{Data}->{Recipients} } ) {

            if ( $Recipients eq 'Customer' ) {
                ${ $Param{Data} }
                    =~ s{(<label .+? for="Recipients"> .+? <option .+? value="Customer" .+?> .+? </option>)}{$1 $OptionAdd}xmsg;
            }

            if ( $Recipients eq 'Contact' ) {
                ${ $Param{Data} }
                    =~ s{(<label .+? for="Recipients"> .+? <option .+? value="$Recipients .+?")}{$1 selected="selected"}xmsg;
            }
            elsif ( $Recipients =~ /Contact_TO_*/ ) {
                ${ $Param{Data} }
                    =~ s{(<label .+? for="Recipients"> .+? <option .+? value="$Recipients")}{$1 selected="selected"}xmsg;
            }
            elsif ( $Recipients =~ /Contact_CC_*/ ) {
                ${ $Param{Data} }
                    =~ s{(<label .+? for="Recipients"> .+? <option .+? value="$Recipients")}{$1 selected="selected"}xmsg;
            }
            elsif ( $Recipients =~ /Contact_BCC_*/ ) {
                ${ $Param{Data} }
                    =~ s{(<label .+? for="Recipients"> .+? <option .+? value="$Recipients")}{$1 selected="selected"}xmsg;
            }
        }

    }

    return 1;
}

1;
