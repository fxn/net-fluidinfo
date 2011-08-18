use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Net::Fluidinfo;
use Net::Fluidinfo::TestUtils;

use Data::UUID;

use_ok('Net::Fluidinfo::Object');

my $fin = Net::Fluidinfo->_new_for_net_fluidinfo_test_suite( quiet => 1 );

my $uuid = Data::UUID->new->create_str;

diag "Creating test objects with UUID $uuid";

my $object  = $fin->get_or_create_object( about => $uuid );
diag "Object created with id " . $object->id;
is ($object->about, $uuid, 'Object autovivification');
my $object2 = $fin->get_or_create_object( about => $uuid );
is( $object->id, $object2->id, "Object ids same");
# we retrieve with get_object_by_about later, after tagging

my $ns_parent = "net-fluidinfo/namespaces/$uuid";
my $ns_path   = "$ns_parent/namespace";
my $ns_description = "Endpoint namespace test";
my $ns = $fin->get_or_create_namespace( 
    path        => $ns_path,
    description => $ns_description
);
is ($ns->path,        $ns_path,        "NS paths ok (on create)");
is ($ns->description, $ns_description, "NS descriptions ok (on create)");

my $ns2 = $fin->get_or_create_namespace(
    path        => $ns_path,
    description => $ns_description
);
is ($ns2->path,        $ns_path,        "NS paths ok (on retrieve)");
is ($ns2->description, $ns_description, "NS descriptions ok (on retrieve)");

my $ns3 = $fin->get_namespace( $ns_parent, description => 1 );
is ($ns3->description, $ns_parent,      "NS descriptions ok (via get_namespace)");

my $tag_name        = "bar";
my $tag_parent      = "net-fluidinfo/tags/$uuid/foo";
my $tag_path        = "$tag_parent/$tag_name";
my $tag_description = "Testing tag";
my $tag = $fin->get_or_create_tag(
    tag         => $tag_path,
    description => $tag_description,
);
is ($tag->name,        $tag_name,        "Tag names ok (on create)");
is ($tag->path,        $tag_path,        "Tag paths ok (on create)");
is ($tag->description, $tag_description, "Tag descriptions ok (on create)");

my $tag2 = $fin->get_or_create_tag(
    tag         => $tag_path,
    description => $tag_description,
);
is ($tag2->name,        $tag_name,        "Tag names ok (on retrieve)");
is ($tag2->path,        $tag_path,        "Tag paths ok (on retrieve)");
is ($tag2->description, $tag_description, "Tag descriptions ok (on retrieve)");

my $tag3 = $fin->get_tag( $tag_path, description => 1 );
is ($tag3->description, $tag_description, "Tag descriptions ok (via get_tag)");

my $new_tag   = "$tag_parent/someothertag";
my $new_value = "Hello!";
$object->tag_autovivify( $new_tag => string => $new_value );
my $object3 = $fin->get_object_by_about( $uuid );
is( $object->id, $object3->id, "Object ids same (using get_object_by_about)");
is( $object3->value($new_tag), $new_value, "tag_autovivify'd value is correct" );

isa_ok( $fin->last_error_response, 'HTTP::Response' );

done_testing;
