# --
# Kernel/System/Ticket/Event/APA_TicketCloseUpdateResume.pm - core module
# Copyright (C) (2017) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::APA_TicketCloseUpdateResume;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

# list your object dependencies (e.g. Kernel::System::DB) here
our @ObjectDependencies = (
     'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
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

    # listen to all kinds of events
    if ( !$Param{Data}->{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TicketID in Data!",
        );
        return;
    }
	
	$Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Param{UserID},
        );
		
		$Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Param{Data}->{Value},
        );
	
	if ( $Param{Event} eq 'TicketDynamicFieldUpdate_Resume' ) {
	
		# get ticket object
		my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
		
		my %UserData = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                UserID => $Param{UserID},
            );
           my $From = $UserData{UserFirstname} . ' ' . $UserData{UserLastname};

		
		
		my $ArticleID = $TicketObject->ArticleCreate(
			TicketID             => $Param{Data}->{TicketID},         
			ArticleType      => 'note-internal',
			SenderType           => 'agent',                          # (required) agent|system|customer
			
			UserID               => $Param{UserID},                              # (required)

			From           => $From,       # not required but useful
			To             => '',               # not required but useful
			Subject        => 'Résumé de clôture',
			Body           => $Param{Data}->{Value},                     # not required but useful
			ContentType    => 'text/plain; charset=ISO-8859-15',      # or optional Charset & MimeType
			HistoryType    => 'AddNote',                          # EmailCustomer|Move|AddNote|PriorityUpdate|WebRequestCustomer|...
			HistoryComment => 'Résumé Update',
		   
			NoAgentNotify    => 0,                                      # if you don't want to send agent notifications
			AutoResponseType => 'auto reject'                            # auto reject|auto follow up|auto reply/new ticket|auto remove
		);
	}
}