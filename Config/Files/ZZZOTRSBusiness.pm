# OTRS config file
# VERSION:1.1
package Kernel::Config::Files::ZZZOTRSBusiness;
use strict;
use warnings;
no warnings 'redefine';
use utf8;

sub Load {
    my ($File, $Self) = @_;

    my @Permissions = @{ $Self->{'System::Permission'} // [] };

    for my $Permission (qw(chat_owner chat_participant chat_observer)) {
        if (!grep { $_ eq $Permission } @Permissions) {
            unshift @{ $Self->{'System::Permission'} // [] }, $Permission;
        }
    }
}

1;
