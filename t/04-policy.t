use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Net::Fluidinfo;
use Net::Fluidinfo::TestUtils;

my ($username, $password) = net_fluidinfo_dev_credentials;

unless (defined $username && defined $password) {
    plan skip_all => skip_all_message;
    exit 0;
}

sub is_policy {
    ok shift->isa('Net::Fluidinfo::Policy');
}

skip_suite_unless_run_all;

use_ok('Net::Fluidinfo::Policy');

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite;
$fin->username($username);
$fin->password($password);

my ($policy, $policy2);
foreach my $u ($username, Net::Fluidinfo::User->get($fin, $username), 'test', Net::Fluidinfo::User->get($fin, 'test')) {
    $policy = Net::Fluidinfo::Policy->get($fin, $u, 'namespaces', 'create');
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'namespaces';
    ok $policy->action   eq 'create';
    
    $policy = Net::Fluidinfo::Policy->get($fin, $u, 'tags', 'update');
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'tags';
    ok $policy->action   eq 'update';

    $policy = Net::Fluidinfo::Policy->get($fin, $u, 'tag-values', 'read');
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'tag-values';
    ok $policy->action   eq 'read';

    $policy = Net::Fluidinfo::Policy->get_create_policy_for_namespaces($fin, $u);
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'namespaces';
    ok $policy->action   eq 'create';
    is_policy(Net::Fluidinfo::Policy->get_update_policy_for_namespaces($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_delete_policy_for_namespaces($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_list_policy_for_namespaces($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_control_policy_for_namespaces($fin, $u));
    
    $policy = Net::Fluidinfo::Policy->get_update_policy_for_tags($fin, $u);
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'tags';
    ok $policy->action   eq 'update';
    is_policy(Net::Fluidinfo::Policy->get_delete_policy_for_tags($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_control_policy_for_tags($fin, $u));
    
    $policy = Net::Fluidinfo::Policy->get_create_policy_for_tag_values($fin, $u);
    is_policy $policy;
    ok $policy->username eq Net::Fluidinfo::Policy->get_username_from_user_or_username($u);
    ok $policy->category eq 'tag-values';
    ok $policy->action   eq 'create';
    is_policy(Net::Fluidinfo::Policy->get_read_policy_for_tag_values($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_delete_policy_for_tag_values($fin, $u));
    is_policy(Net::Fluidinfo::Policy->get_control_policy_for_tag_values($fin, $u));
}

my $except_self = [$fin->username];
while (my ($category, $actions) = each %{Net::Fluidinfo::Policy->Actions}) {
    foreach my $prefix ('open', 'close') {
        my $method_name = "${prefix}_${category}";
        $method_name =~ tr/-/_/;
        ok(Net::Fluidinfo::Policy->$method_name($fin));
        foreach my $action (@$actions) {
            my $policy = Net::Fluidinfo::Policy->get($fin, $fin->username, $category, $action);
            is_policy $policy;
            if ($prefix eq 'open') {
                ok $policy->is_open;
                ok !$policy->has_exceptions;
            } else {
                ok $policy->is_closed;
                ok_sets_cmp $policy->exceptions, $except_self;
            }
        }
    }
}

while (my ($category, $actions) = each %{Net::Fluidinfo::Policy->Actions}) {
    foreach my $action (@$actions) {
        foreach my $pname ('open', 'closed') {
            foreach my $exceptions ([], ['foo'], ['foo', 'bar', 'baz', 'woo', 'zoo']) {
                $policy = Net::Fluidinfo::Policy->get($fin, $fin->username, $category, $action);
                is_policy($policy);
            
                $policy->policy($pname);
                $policy->exceptions($exceptions);
                ok $policy->update;

                $policy2 = Net::Fluidinfo::Policy->get($fin, $fin->username, $category, $action);
                is_policy($policy2);
                
                ok $policy->username eq $policy2->username;
                ok $policy->category eq $policy2->category;
                ok $policy->action  eq $policy2->action;
                ok $policy->policy eq $policy2->policy;
                ok_sets_cmp $policy->exceptions, $policy2->exceptions;
            }
        }
    }
}

done_testing;
