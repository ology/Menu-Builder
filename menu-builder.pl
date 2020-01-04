#!/usr/bin/env perl

=head1 NAME

menu-builder.pl

=head1 DESCRIPTION

Menu builder web app.

=cut

our $VERSION = '0.001000';

use v5.10.0;

use Mojolicious::Lite;

use lib 'lib';

plugin 'Config';

app->secrets( app->config->{secrets} );

plugin 'bcrypt';
plugin 'MenuBuilder::DBAuth';

=head1 PUBLIC ROUTES

=head2 GET /

Show login form.

=cut

get '/' => sub { shift->render } => 'index';

=head2 POST /login

Set session C<auth> if valid.

=cut

post '/login' => sub {
    my ($self) = @_;

    if ( $self->auth( $self->param('username'), $self->param('password') ) ) {
        $self->session( auth => 1 );
        return $self->redirect_to('auth');
    }

    $self->flash( error => 'Invalid login' );
    $self->redirect_to('index');
} => 'login';

=head2 GET /logout

Delete session C<auth>.

=cut

get '/logout' => sub {
    my ($self) = @_;

    delete $self->session->{auth};

    $self->redirect_to('index');
} => 'logout';

under sub {
    my ($self) = @_;

    my $session = $self->session('auth') // '';

    return 1
        if $session eq '1';

    $self->render( text => 'Denied!' );
    return 0;
};

=head1 AUTHORIZED ROUTES

=head2 GET /auth

Authorized page

=cut

get '/auth' => sub {
    my ($self) = @_;
} => 'auth';

app->start;

=head1 AUTHOR

Gene Boggs <gene.boggs@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
