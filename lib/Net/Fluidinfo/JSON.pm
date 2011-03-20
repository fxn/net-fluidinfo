package Net::Fluidinfo::JSON;
use Moose;

use JSON::XS;

has json => (
    is      => 'ro',
    isa     => 'JSON::XS',
    default => sub { JSON::XS->new->utf8->allow_nonref },
    handles => [qw(encode decode)]
);

#
# --- Predicates --------------------------------------------------------------
#

sub is_null {
    my $str = $_[1];
    $str eq 'null'
}

sub is_boolean {
    my $str = $_[1];
    $str eq 'true' || $str eq 'false';
}

# Assumes the argument is a well-formed JSON literal.
sub is_string {
    my $str = $_[1];
    $str =~ /\A"/;
}

# Assumes the argument is a well-formed JSON literal.
sub is_number {
    my $str = $_[1];
    $str =~ /\A-?\d/;
}

# Assumes the argument is a well-formed JSON literal.
sub is_integer {
    my $str = $_[1];
    $str =~ /\A-?\d+\z/;
}

# Assumes the argument is a well-formed JSON literal.
sub is_float {
    my ($receiver, $str) = @_;
    $receiver->is_number($str) && !$receiver->is_integer($str);
}

# Assumes the argument is a valid JSON literal.
sub is_array {
    my $str = $_[1];
    $str =~ /\A\[/;
}

1;
