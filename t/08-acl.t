use strict;
use warnings;

use Test::More;
use Net::Fluidinfo;

use_ok('Net::Fluidinfo::ACL');

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite;
my $acl = Net::Fluidinfo::ACL->new(fin => $fin);

$acl->policy('open');
ok $acl->is_open;

$acl->policy('closed');
ok $acl->is_closed;

$acl->exceptions([]);
ok !$acl->has_exceptions;

$acl->exceptions(['test']);
ok $acl->has_exceptions;

done_testing;
