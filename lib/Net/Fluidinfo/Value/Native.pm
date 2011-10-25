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

sub new_from_fin_type_and_json {
    my ($class, $fin_type, $json) = @_;
    my $native_class = $class->class_for_fin_type($fin_type);
    $native_class->new(value => $class->json->decode($json));
}

sub class_for_fin_type {
    my ($class, $fin_type) = @_;

    my $type = do {
        if ($fin_type eq 'null') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Null;
            'Null';
        } elsif ($fin_type eq 'boolean') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Boolean;
            'Boolean';
        } elsif ($fin_type eq 'int') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Integer;
            'Integer';
        } elsif ($fin_type eq 'float') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Float;
            'Float';
        } elsif ($fin_type eq 'string') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::String;
            'String';
        } elsif ($fin_type eq 'list-of-strings') {
            # instead of ordinary use(), to play nice with inheritance
            require Net::Fluidinfo::Value::Set;
            'Set';
        } else {
            die "Fluidinfo has sent an unknown native type header: $fin_type\n";
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
