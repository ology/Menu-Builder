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

    if ( my $id = $self->auth( $self->param('username'), $self->param('password') ) ) {
        $self->session( auth => 1 );
        return $self->redirect_to( '/auth?account_id=' . $id );
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

Settings page

=cut

get '/auth' => sub {
    my ($self) = @_;

    my $account_id = $self->param('account_id');

    my $meals = $self->schema->resultset('Meal')->search(
        {
            account_id => $account_id,
        },
        {
            order_by => { -asc => 'name' },
        }
    );

    my $meal_items = {};
    for my $meal ( $meals->all ) {
        my $items = $self->schema->resultset('MealItem')->search(
            {
                meal_id => $meal->id,
            },
            {
                order_by => { -asc => 'name' },
            }
        );

        for my $item ( $items->all ) {
            push @{ $meal_items->{ $meal->id } }, $item->name;
        }
    }

    $self->stash( account_id => $account_id, meals => $meals, meal_items => $meal_items );
} => 'auth';

=head2 POST /new_meal

Create a new menu type.

=cut

post '/new_meal' => sub {
    my ($self) = @_;

    my $account_id = $self->param('account_id');
    my $name       = $self->param('name');
    my $items      = $self->every_param('item');

    my $meal = $self->schema->resultset('Meal')->create(
        {
            name       => $name,
            account_id => $account_id,
        },
    );

    for my $item ( @$items ) {
        $self->schema->resultset('MealItem')->create(
            {
                name    => $item,
                meal_id => $meal->id,
            },
        );
    }

    $self->redirect_to( '/auth?account_id=' . $account_id );
};

=head2 GET /menus

Menus list

=cut

get '/menus' => sub {
    my ($self) = @_;
} => 'menus';

app->start;

=head1 AUTHOR

Gene Boggs <gene.boggs@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
