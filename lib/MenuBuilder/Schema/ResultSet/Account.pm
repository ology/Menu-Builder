package MenuBuilder::Schema::ResultSet::Account;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub search_by_name {
    my ( $self, $name ) = @_;

    my $result = $self->search({ name => $name })->first;

    return $result;
}

sub create_new {
    my ( $self, $name, $password ) = @_;

    my $result = $self->create(
        {
            name     => $name,
            password => $password,
        }
    );

    return $result;
}

1;
