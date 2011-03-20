package Net::Fluidinfo::HasPath;
use Moose::Role;

requires 'parent';

has name => (is => 'ro', isa => 'Str', lazy_build => 1);
has path => (is => 'ro', isa => 'Str', lazy_build => 1);

sub _build_name {
    # TODO: add croaks for dependencies
    my $self = shift;
    my @names = split "/", $self->path;
    $names[-1];
}

sub _build_path {
    # TODO: add croaks for dependencies
    my $self = shift;
    if ($self->parent) {
        $self->parent->path . '/' . $self->name;
    } else {
        $self->name;
    }
}

sub path_of_parent {
   my $self = shift;
   my @names = split "/", $self->path;
   join "/", @names[0 .. $#names-1];
}

sub equal_paths {
    my ($receiver, $p1, $p2) = @_;

    return 1 if !defined $p1 && !defined $p2;
    return 0 if !defined $p1 || !defined $p2;

    if (index($p1, '/') != -1 && index($p1, '/') != -1) {
        my ($username, $rest) = split '/', $p1, 2;
        # ensure the match is performed in scalar context
        scalar($p2 =~ m{\A (?i: \Q$username\E ) / \Q$rest\E \z}x);
    } else {
        $p1 eq $p2;
    }
}

1;