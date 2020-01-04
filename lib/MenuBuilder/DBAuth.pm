package MenuBuilder::DBAuth;

use Mojo::Base 'Mojolicious::Plugin';

use MenuBuilder::Schema;

sub register {
    my ( $self, $app ) = @_;

    $app->helper( schema => sub {
        my ($c) = @_;

        return state $schema = AuthHelper::Schema->connect( $c->config('database') );
    } );

    $app->helper( auth => sub {
        my ( $c, $user, $pass ) = @_;

        my $result = $c->schema->resultset('Account')->search_by_name($user);

        return 1
            if $result && $c->bcrypt_validate( $pass, $result->password );
    } );

    $app->helper( add => sub {
        my ( $c, $user, $pass ) = @_;

        return 0
            unless $user && $pass;

        my $result = $c->schema->resultset('Account')->create_new(
            $user,
            $c->bcrypt($pass),
        );

        return $result;
    } );

    $app->helper( accounts => sub {
        my ($c) = @_;

        my $result = $c->schema->resultset('Account');

        return $result;
    } );

}

1;
