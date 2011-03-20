use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use Test::More;
use Net::Fluidinfo::TestUtils;

use_ok 'Net::Fluidinfo::Value::Native';

my $v;

ok(Net::Fluidinfo::Value::Native->new->is_native);
ok(!Net::Fluidinfo::Value::Native->new->is_non_native);

ok(Net::Fluidinfo::Value::Native->mime_type eq $Net::Fluidinfo::Value::Native::MIME_TYPE);

ok(Net::Fluidinfo::Value::Native->is_mime_type($Net::Fluidinfo::Value::Native::MIME_TYPE));
ok(!Net::Fluidinfo::Value::Native->is_mime_type('text/html'));
ok(!Net::Fluidinfo::Value::Native->is_mime_type(undef));

ok 'Net::Fluidinfo::Value::Null'         eq Net::Fluidinfo::Value::Native->type_from_json('null');
ok 'Net::Fluidinfo::Value::Boolean'      eq Net::Fluidinfo::Value::Native->type_from_json('true');
ok 'Net::Fluidinfo::Value::Boolean'      eq Net::Fluidinfo::Value::Native->type_from_json('false');
ok 'Net::Fluidinfo::Value::Integer'      eq Net::Fluidinfo::Value::Native->type_from_json('500');
ok 'Net::Fluidinfo::Value::Integer'      eq Net::Fluidinfo::Value::Native->type_from_json('-500');
ok 'Net::Fluidinfo::Value::Float'        eq Net::Fluidinfo::Value::Native->type_from_json('500.0');
ok 'Net::Fluidinfo::Value::Float'        eq Net::Fluidinfo::Value::Native->type_from_json('-500.0');
ok 'Net::Fluidinfo::Value::Float'        eq Net::Fluidinfo::Value::Native->type_from_json('1e2');
ok 'Net::Fluidinfo::Value::Float'        eq Net::Fluidinfo::Value::Native->type_from_json('-1e2');
ok 'Net::Fluidinfo::Value::String'       eq Net::Fluidinfo::Value::Native->type_from_json('""');
ok 'Net::Fluidinfo::Value::String'       eq Net::Fluidinfo::Value::Native->type_from_json('"500"');
ok 'Net::Fluidinfo::Value::Set' eq Net::Fluidinfo::Value::Native->type_from_json('[]');
ok 'Net::Fluidinfo::Value::Set' eq Net::Fluidinfo::Value::Native->type_from_json('[""]');
ok 'Net::Fluidinfo::Value::Set' eq Net::Fluidinfo::Value::Native->type_from_json('["500","foo"]');

ok "Net::Fluidinfo::Value::Null"    eq Net::Fluidinfo::Value::Native->type_from_alias('null');
ok "Net::Fluidinfo::Value::Boolean" eq Net::Fluidinfo::Value::Native->type_from_alias('boolean');
ok "Net::Fluidinfo::Value::Integer" eq Net::Fluidinfo::Value::Native->type_from_alias('integer');
ok "Net::Fluidinfo::Value::Float"   eq Net::Fluidinfo::Value::Native->type_from_alias('float');
ok "Net::Fluidinfo::Value::String"  eq Net::Fluidinfo::Value::Native->type_from_alias('string');
ok "Net::Fluidinfo::Value::Set"     eq Net::Fluidinfo::Value::Native->type_from_alias('set');
ok !Net::Fluidinfo::Value::Native->type_from_alias('unknown alias');

done_testing;
