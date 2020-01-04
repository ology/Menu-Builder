package MenuBuilder::DBAuth;

use Mojo::Base 'Mojolicious::Plugin';

use MenuBuilder::Schema;

sub register {
    my ( $self, $app ) = @_;

    $app->helper( schema => sub {
        my ($c) = @_;

        return state $schema = MenuBuilder::Schema->connect( $c->config('database') );
    } );

    $app->helper( auth => sub {
        my ( $c, $user, $pass ) = @_;

        my $result = $c->schema->resultset('Account')->search_by_name($user);

        return 1
            if $result && $c->bcrypt_validate( $pass, $result->password );
    } );

}

1;
