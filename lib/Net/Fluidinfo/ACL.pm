package Net::Fluidinfo::ACL;
use Moose;
extends 'Net::Fluidinfo::Base';

use MooseX::ClassAttribute;
class_has Actions => (
    is => 'ro',
    isa => 'HashRef[ArrayRef[Str]]',
    default => sub {{
        'namespaces' => [qw(create update delete list control)],
        'tags'       => [qw(update delete control)],
        'tag-values' => [qw(create read delete control)]
    }}
);

has policy     => (is => 'rw', isa => 'Str');
has exceptions => (is => 'rw', isa => 'ArrayRef[Str]');

sub is_open {
    my $self = shift;
    $self->policy eq 'open' 
}

sub is_closed {
    my $self = shift;
    $self->policy eq 'closed' 
}

sub has_exceptions {
    my $self = shift;
    @{$self->exceptions} != 0;
}

no Moose;
no MooseX::ClassAttribute;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Fluidinfo::ACL - A common ancestor for classes that provide an ACL

=head1 SYNOPSIS

 $permission->policy('open');
 my $exceptions = $permission->exceptions;
 
 $policy->is_open;
 $policy->is_closed;
 $policy->has_exceptions;

=head1 DESCRIPTION

C<Net::Fluidinfo::ACL> is a parent class of L<Net::Fluidinfo::Policy> and
L<Net::Fluidinfo::Permission>.

You don't usually need this class, only the interface its children inherit.

=head1 USAGE

=head2 Instance Methods

=over

=item $acl->policy

=item $acl->policy('open'|'closed')

Sets/gets the policy, which must be either 'open' or 'closed'. Note this is not an
instance of L<Net::Fluidinfo::Policy> (the name clash is inherited from the API).

=item $acl->exceptions

=item $acl->exceptions($exceptions)

Gets/sets the exception list of this ACL, which is a possibly empty arrayref of usernames.
In Fluidinfo this is a set, so don't rely on the order of the elements.

=item $acl->is_open

Checks whether the ACL is open.

=item $acl->is_closed

Checks whether the ACL is closed.

=item $acl->has_exceptions

Checks whether the ACL has any exception.

=back


=head1 AUTHOR

Xavier Noria (FXN), E<lt>fxn@cpan.orgE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2011 Xavier Noria

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
