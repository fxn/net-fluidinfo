package Net::Fluidinfo::Value::Native;
use Moose;
extends 'Net::Fluidinfo::Value';

use Carp;
use Net::Fluidinfo::JSON;
use MooseX::ClassAttribute;
class_has json => (is => 'ro', default => sub { Net::Fluidinfo::JSON->new });

# In the future more serialisation formats may be supported. When the time
# arrives we'll see how to add them to the design.
our $MIME_TYPE = 'application/vnd.fluiddb.value+json';

sub mime_type {
    $MIME_TYPE;
}

sub is_mime_type {
    my ($class, $mime_type) = @_;
    defined $mime_type && $mime_type eq $MIME_TYPE;
}

sub new_from_json {
    my ($class, $json) = @_;
    $class->type_from_json($json)->new(value => $class->json->decode($json));
}

# Give a JSON string like '5', or '7.32', or 'true', or '"foo"', this method
# returns the name of the class that represents the corresponding Fluidinfo
# native type. For example 'Net::Fluidinfo::Value::Boolean'.
sub type_from_json {
    my ($class, $json) = @_;

    my $type = do {
        if ($class->json->is_null($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Null;
            'Null';
        } elsif ($class->json->is_boolean($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Boolean;
            'Boolean';
        } elsif ($class->json->is_integer($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Integer;
            'Integer';
        } elsif ($class->json->is_float($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Float;
            'Float';
        } elsif ($class->json->is_string($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::String;
            'String';
        } elsif ($class->json->is_array($json)) {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Set;
            'Set';
        } else {
            die "Fluidinfo has sent a native value of unknown type:\n$json\n";
        }
    };
    "Net::Fluidinfo::Value::$type";
}

our %VALID_ALIASES = map { $_ => 1 } qw(null boolean integer float string set);
sub type_from_alias {
    my ($class, $alias) = @_;
    "Net::Fluidinfo::Value::\u$alias" if exists $VALID_ALIASES{$alias};
}

sub type_alias {
    my $self = shift;
    my $class = ref $self || $self;
    my ($type_alias) = $class =~ /::(\w+)$/;
    lc $type_alias;
}

sub to_json {
    # abstract
}

sub payload {
    shift->to_json;
}

sub is_native {
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
