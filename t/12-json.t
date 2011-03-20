use strict;
use warnings;

use Test::More;
use Net::Fluidinfo::JSON;

my $json = Net::Fluidinfo::JSON->new;

# These predicates are *not* JSON validators. Assuming a string contains well-formed
# JSON with a value of some Fluidinfo type, these methods only discrimate. Thus, we do not
# test their behaviour for ill-formed stuff, nor JSON objects or generic arrays.

# null
my $str = "null";
ok  $json->is_null($str);
ok !$json->is_boolean($str);
ok !$json->is_string($str);
ok !$json->is_number($str);
ok !$json->is_integer($str);
ok !$json->is_float($str);
ok !$json->is_array($str);

# boolean
foreach $str ('false', 'true') {
    ok !$json->is_null($str);
    ok  $json->is_boolean($str);
    ok !$json->is_string($str);
    ok !$json->is_number($str);
    ok !$json->is_integer($str);
    ok !$json->is_float($str);
    ok !$json->is_array($str);
}

# string
foreach $str ('"null"', '"false"', '"true"', '"1"', '"0.3"', '"0e0"', '""', qq("foo \n bar \n baz")) {
    ok !$json->is_null($str);
    ok !$json->is_boolean($str);
    ok  $json->is_string($str);
    ok !$json->is_number($str);
    ok !$json->is_integer($str);
    ok !$json->is_float($str);
    ok !$json->is_array($str);    
}

# integer
foreach $str ('0', '-0', '1', '-1', '60', '-3600', '365', '-12') {
    ok !$json->is_null($str);
    ok !$json->is_boolean($str);
    ok !$json->is_string($str);
    ok  $json->is_number($str);
    ok  $json->is_integer($str);
    ok !$json->is_float($str);
    ok !$json->is_array($str);
}

# float
foreach $str ('0.0', '-0.0', '1.3', '-1.0', '60.1', '-3600.2', '365.8', '-12.9') {
    ok !$json->is_null($str);
    ok !$json->is_boolean($str);
    ok !$json->is_string($str);
    ok  $json->is_number($str);
    ok !$json->is_integer($str);
    ok  $json->is_float($str);
    ok !$json->is_array($str);
}

# set of strings
foreach $str ('[]', '["1"]', '["foo", "bar"]') {
    ok !$json->is_null($str);
    ok !$json->is_boolean($str);
    ok !$json->is_string($str);
    ok !$json->is_number($str);
    ok !$json->is_integer($str);
    ok !$json->is_float($str);
    ok  $json->is_array($str);
}

done_testing;