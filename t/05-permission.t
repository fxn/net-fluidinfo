use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Test::Exception;

use Net::Fluidinfo;
use Net::Fluidinfo::Namespace;
use Net::Fluidinfo::Tag;
use Net::Fluidinfo::Policy;
use Net::Fluidinfo::TestUtils;

sub is_permission {
    ok shift->isa('Net::Fluidinfo::Permission');
}

sub reset_policies {
    my $fin = shift;
    ok(Net::Fluidinfo::Policy->close_namespaces($fin));
    ok(Net::Fluidinfo::Policy->close_tags($fin));
    ok(Net::Fluidinfo::Policy->close_tag_values($fin));
}

sub check_perm {
    my $perm = shift;
    my $perm2 = Net::Fluidinfo::Permission->get($perm->fin, $perm->category, $perm->path, $perm->action);
    is_permission $perm2;
                
    ok $perm2->category eq $perm->category;
    ok $perm2->action  eq $perm->action;
    ok $perm2->policy eq $perm->policy;
    ok_sets_cmp $perm2->exceptions, $perm->exceptions;
}

my ($username, $password) = net_fluidinfo_dev_credentials;

unless (defined $username && defined $password) {
    plan skip_all => skip_all_message;
    exit 0;
}

skip_suite_unless_run_all;

use_ok('Net::Fluidinfo::Permission');

my ($perm, $path, $ns, $tag);

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite;
$fin->username($username);
$fin->password($password);

# --- Seed data ---------------------------------------------------------------

reset_policies($fin);

$path = "$username/" . random_name;
$ns = Net::Fluidinfo::Namespace->new(
    fin         => $fin,
    description => random_description,
    path        => $path
);
ok $ns->create;

$path = "$username/" . random_name;
$tag = Net::Fluidinfo::Tag->new(
    fin         => $fin,
    description => random_description,
    indexed     => 0,
    path        => $path
);
ok $tag->create;

my %paths = (
    'namespaces' => $ns->path,
    'tags'       => $tag->path,
    'tag-values' => $tag->path
);


# --- GET ---------------------------------------------------------------------

reset_policies($fin);

while (my ($category, $actions) = each %{Net::Fluidinfo::Permission->Actions}) {
    foreach my $action (@$actions) {
        my $perm = Net::Fluidinfo::Permission->get($fin, $category, $paths{$category}, $action);
        is_permission $perm;

        ok $perm->is_closed;
        ok_sets_cmp $perm->exceptions, [$username];
    }
}


# --- PUT except for control --------------------------------------------------

while (my ($category, $actions) = each %{Net::Fluidinfo::Permission->Actions}) {
    foreach my $action (@$actions) {
        next if $action eq 'control';
        foreach my $pname ('open', 'closed') {
            foreach my $exceptions ([], ['foo'], ['foo', 'bar', 'baz', 'woo', 'zoo']) {
                my $perm = Net::Fluidinfo::Permission->get($fin, $category, $paths{$category}, $action);
                is_permission $perm;

                $perm->policy($pname);
                $perm->exceptions($exceptions);
                ok $perm->update;
                check_perm $perm;
            }
        }
    }
}


# --- PUT with control --------------------------------------------------------

reset_policies($fin);

foreach my $category (keys %{Net::Fluidinfo::Permission->Actions}) {
    foreach my $pname ('open', 'closed') {
        foreach my $exceptions ([], ['foo'], ['foo', 'bar', 'baz', 'woo', 'zoo']) {
            my @e = @$exceptions;
            push @e, $username if $pname eq 'closed';
            my $perm = Net::Fluidinfo::Permission->get($fin, $category, $paths{$category}, 'control');
            is_permission $perm;

            $perm->policy($pname);
            $perm->exceptions(\@e);
            ok $perm->update;
            check_perm $perm;
        }
    }

    # Commit suicide, we have to test closing with an empty exception list somehow
    # and we won't be able to delete these $ns or $tag.
    my $perm = Net::Fluidinfo::Permission->get($fin, $category, $paths{$category}, 'control');
    is_permission($perm);
    
    $perm->policy('closed');
    $perm->exceptions([]);
    ok $perm->update;

    # can't read this back, so we could try and catch
    throws_ok { Net::Fluidinfo::Permission->get($fin, $category, $paths{$category}, 'control') } qr/401/;
}

done_testing;
