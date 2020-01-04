#!/usr/bin/env perl

=head1 NAME

auth-helper

=head1 DESCRIPTION

This is a L<Mojolicious::Lite> app that enables login/out and new
account creation with L<Mojolicious::Plugin::Bcrypt> through
L<DBIx::Class>.

=cut

our $VERSION = '0.001000';

use v5.10.0;

use Mojolicious::Lite;

use lib 'lib';

plugin 'Config';

app->secrets( app->config->{secrets} );

plugin 'bcrypt';
plugin 'AuthHelper::DBAuth';

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

Show all accounts and new user form.

=cut

get '/auth' => sub {
    my ($self) = @_;

    my $accounts = $self->accounts;

    $self->render( accounts => $accounts );
} => 'auth';

=head2 POST /add

Add new user.

=cut

post '/add' => sub {
    my ($self) = @_;

    my $result = $self->add( $self->param('username'), $self->param('password') );

    if ( $result ) {
        $self->flash( message => 'User added' );
    }
    else {
        $self->flash( error => 'Cannot add user!' );
    }

    $self->redirect_to('auth');
};

app->start;

=head1 AUTHOR

Gene Boggs <gene.boggs@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__DATA__

@@_credentials.html.ep
    %= label_for username => 'Username:'
    %= text_field 'username'
    %= label_for password => 'Password:'
    %= password_field 'password'

@@_flash.html.ep
% if ( flash('error') ) {
    %= tag h2 => (style => 'color:red') => flash('error')
% }
% if ( flash('message') ) {
    %= tag h2 => (style => 'color:green') => flash('message')
% }

@@index.html.ep
%= tag h1 => 'Login'
%= include '_flash'
%= form_for login => (method => 'post') => begin
    %= include '_credentials'
    %= submit_button 'Login'
%= end

@@auth.html.ep
%= tag h1 => 'Authorized'
%= include '_flash'
New user:
%= form_for add => (method => 'post') => begin
    %= include '_credentials'
    %= submit_button 'Add'
%= end
% if ( $accounts ) {
    % while ( my $account = $accounts->next ) {
    <%= $account->id %>: <%= $account->name %> - <%= $account->created %>
    %= tag 'br'
    % }
% }
%= tag 'p'
%= link_to Logout => 'logout'
