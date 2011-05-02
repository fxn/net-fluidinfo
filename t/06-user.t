use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Test::Exception;

use Net::Fluidinfo;
use Net::Fluidinfo::TestUtils;

use_ok('Net::Fluidinfo::User');

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite;
foreach my $username ('test', 'fxn') {
    my $user = Net::Fluidinfo::User->get($fin, $username);
    ok $user->username eq $username;
    ok $user->name eq $username;
}

# fetch unexistant user
throws_ok { Net::Fluidinfo::User->get($fin, random_name) } qr/404/;

done_testing;
