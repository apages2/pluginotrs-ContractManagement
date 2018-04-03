# OTRS config file (automatically generated)
# VERSION:1.1
package Kernel::Config::Files::ZZZACL;
use strict;
use warnings;
no warnings 'redefine';
use utf8;
sub Load {
    my ($File, $Self) = @_;

# Created: 2017-02-23 11:19:27 (tcastelle.msc)
# Changed: 2017-02-23 11:23:35 (tcastelle.msc)
$Self->{TicketAcl}->{'Filtre queue pour Astreinte Econocom'} = {
  'Possible' => {
    'Ticket' => {
      'Queue' => [
        'Astreinte'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'UserCustomerID' => [
        'ASTREINTE ECONOCOM'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2018-01-11 18:12:25 (apages.msc)
# Changed: 2018-01-11 19:40:21 (apages.msc)
$Self->{TicketAcl}->{'Supprimer champ constructeur dans file PDP et Spam'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Action' => {}
  },
  'Properties' => {
    'Frontend' => {
      'Action' => [
        'AgentTicketClose'
      ]
    },
    'Queue' => {
      'Name' => [
        'Spam et Marketing'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

}
1;
