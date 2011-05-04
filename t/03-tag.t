use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Test::Exception;

use Net::Fluidinfo;
use Net::Fluidinfo::TestUtils;

use_ok('Net::Fluidinfo::Tag');

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite;

my ($tag, $tag2, $description, $name, $path);

$description = random_description;
$name = random_name;
$path = $fin->username . "/$name";

# create a tag
$tag = Net::Fluidinfo::Tag->new(
    fin         => $fin,
    description => $description,
    indexed     => 1,
    path        => $path
);
ok $tag->create;
ok $tag->has_object_id;
ok $tag->object->id eq $tag->object_id;
ok $tag->name eq $name;
ok $tag->path_of_parent eq $fin->username;
ok $tag->namespace->name eq $fin->username;
ok $tag->path eq $path;

# Try to create it again
throws_ok { $tag->create } qr/412/;

# fetch it
$tag2 = Net::Fluidinfo::Tag->get($fin, $tag->path, description => 1);
ok $tag2->description eq $tag->description;
ok $tag2->indexed;
ok $tag2->object_id eq $tag->object_id;
ok $tag2->name eq $tag->name;
ok $tag2->path_of_parent eq $tag->path_of_parent;
ok $tag2->namespace->name eq $tag->namespace->name;
ok $tag2->path eq $tag->path;

# update description
$description = random_description;
$tag->description($description);
ok $tag->update;

$tag2 = Net::Fluidinfo::Tag->get($fin, $tag->path, description => 1);
ok $tag2->description eq $tag->description;

# delete it
ok $tag->delete;

# create in an unexistant path
$tag = Net::Fluidinfo::Tag->new(
    fin         => $fin,
    description => $description,
    indexed     => 1,
    path        => "$path/" . random_name,
);
throws_ok { $tag->create } qr/404/;
throws_ok { $tag->update } qr/404/;
throws_ok { $tag->delete } qr/404/;

# fetch unexistant tag
throws_ok { Net::Fluidinfo::Tag->get($fin, $path) } qr/404/;

# fetch tag from unexistant namespace
throws_ok { Net::Fluidinfo::Tag->get($fin, "$path/" . random_name) } qr/404/;


done_testing;
