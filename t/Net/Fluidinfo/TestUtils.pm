package Net::Fluidinfo::TestUtils;
use base Exporter;
our @EXPORT = qw(
    random_about
    random_description
    random_name
    net_fluidinfo_dev_credentials
    skip_all_message
    skip_suite_unless_run_all
    ok_sets_cmp
    ok_dies
);

use Time::HiRes 'time';
use Test::More;

sub random_about {
    random_token("about");
}

sub random_description {
    random_token("description");
}

sub random_name {
    random_token("name", '-');
}

sub random_token {
    my ($token, $separator) = @_;
    $separator ||= ' ';
    join $separator, "Net::Fluidinfo", $token, time, rand;
}

# These are used to run the suites of policies and permissions. The dev user
# should be dedicated, not net-fluidinfo, so that these tests can't interfere
# with suites running elsewhere.
sub net_fluidinfo_dev_credentials {
    @ENV{'NET_FLUIDINFO_DEV_USERNAME', 'NET_FLUIDINFO_DEV_PASSWORD'};
}

sub skip_all_message {
    'this suite is brittle in a shared sandbox, only runs in the dev machine'
}

sub ok_sets_cmp {
    my ($a, $b) = @_;
    is_deeply [sort @$a], [sort @$b];
}

sub ok_dies(&) {
    eval { shift->() };
    ok $@;
}

sub skip_suite_unless_run_all {
    unless ($ENV{NET_FLUIDINFO_RUN_FULL_SUITE}) {
       plan skip_all => "set NET_FLUIDINFO_RUN_FULL_SUITE to run these";
       exit 0;
    }
}

1;