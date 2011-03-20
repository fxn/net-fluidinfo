package Net::Fluidinfo::Policy;
use Moose;
extends 'Net::Fluidinfo::ACL';

has username => (is => 'ro', isa => 'Str');
has category => (is => 'ro', isa => 'Str');
has action   => (is => 'ro', isa => 'Str');

sub get {
    my ($class, $fin, $user_or_username, $category, $action) = @_;
    
    my $username = $class->get_username_from_user_or_username($user_or_username);
    $fin->get(
        path       => $class->abs_path('policies', $username, $category, $action),
        headers    => $fin->accept_header_for_json,
        on_success => sub {
            my $response = shift;
            my $h = $class->json->decode($response->content);
            $class->new(
                fin      => $fin,
                username => $username,
                category => $category,
                action   => $action,
                %$h
            );
        }
    );
}

sub update {
    my $self = shift;

    my $payload = $self->json->encode({policy => $self->policy, exceptions => $self->exceptions});
    $self->fin->put(
        path    => $self->abs_path('policies', $self->username, $self->category, $self->action),
        headers => $self->fin->headers_for_json,
        payload => $payload
    );
}

# Generates convenience methods to completely open or close resources.
#
#     open_namespaces
#     close_namespaces
#     open_tags
#     close_tags
#     open_tag_values
#     close_tag_values
#
while (my ($category, $actions) = each %{__PACKAGE__->Actions}) {
    no strict 'refs';
    foreach my $prefix ('open', 'close') {
        my $method_name = "${prefix}_${category}";
        $method_name =~ tr/-/_/; # tag-values -> tag_values
        *$method_name = sub {
            my ($class, $fin, $user_or_username) = @_;

            my $username = $class->get_username_from_user_or_username($user_or_username);
            $username = $fin->username if not defined $username;
            foreach my $action (@$actions) {
                my $policy = $class->get($fin, $username, $category, $action);
                $policy->policy($prefix eq 'open' ? 'open' : 'closed');
                $policy->exceptions($prefix eq 'open' ? [] : [$username]);
                my $status = $policy->update;
                return $status unless $status;
            }
            1;            
        };
    }
}

# Generates getters for all pairs category/action:
#
#     get_create_policy_for_namespaces
#     ...
#     get_update_policy_for_tags
#     ...
#     get_read_policy_for_tag_values
#     ...
#
while (my ($category, $actions) = each %{__PACKAGE__->Actions}) {
    no strict 'refs';
    foreach my $action (@$actions) {
        my $method_name = "get_${action}_policy_for_${category}";
        $method_name =~ tr/-/_/; # tag-values -> tag_values
        *$method_name = sub {
            my ($class, $fin, $user_or_username) = @_;
            my $username = $class->get_username_from_user_or_username($user_or_username);
            $class->get($fin, $username, $category, $action);
        };
    }
}

sub get_username_from_user_or_username {
    my ($receiver, $user_or_username) = @_;
    ref $user_or_username ? $user_or_username->username : $user_or_username;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Fluidinfo::Policy - Fluidinfo policies

=head1 SYNOPSIS

 use Net::Fluidinfo::Policy;

 # get
 $policy = Net::Fluidinfo::Policy->get($fin, $user_or_username, $category, $action);
 $policy->policy;
 $policy->exceptions;

 # update
 $policy->policy('closed');
 $policy->exceptions($exceptions);
 $policy->update;

=head1 DESCRIPTION

C<Net::Fluidinfo::Policy> models Fluidinfo policies.

=head1 USAGE

=head2 Inheritance

C<Net::Fluidinfo::Policy> is a subclass of L<Net::Fluidinfo::ACL>.

=head2 Class methods

=over

=item Net::Fluidinfo::Policy->get($fin, $user_or_username, $category, $action)

Retrieves the policy on action C<$action>, for the category C<$category> of
user C<$user_or_username>.

C<Net::Fluidinfo> provides a convenience shortcut for this method.

=item Net::Fluidinfo::Policy->get_I<action>_policy_for_I<category>($fin, $user_or_username)

These are convenience methods, there's one for each defined pair action/category:

     get_create_policy_for_namespaces
     ...
     get_update_policy_for_tags
     ...
     get_read_policy_for_tag_values
     ...

=back

=head2 Instance Methods

=over

=item $tag->update

Updates the policy in Fluidinfo.

=item $tag->username

Returns the username of the user the policy concerns to.

=item $tag->category

Returns the category the policy is about.

=item $tag->action

Returns the action the policy is about.

=back

=head1 FLUIDINFO DOCUMENTATION

=over

=item Fluidinfo high-level description

L<http://doc.fluidinfo.com/fluidDB/permissions.html#policies-and-their-exceptions>

=item Fluidinfo API specification

L<http://api.fluidinfo.com/fluidDB/api/*/policies/*>

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

