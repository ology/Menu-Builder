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

Create a new meal type.

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

=head2 POST /delete_meal

Delete a meal.

=cut

post '/delete_meal' => sub {
    my ($self) = @_;

    my $account_id = $self->param('account_id');
    my $meal_id    = $self->param('meal_id');

    my $meal = $self->schema->resultset('Meal')->find({ id => $meal_id });
    $meal->delete;

    my $items = $self->schema->resultset('MealItem')->search(
        {
            meal_id => $meal->id,
        },
    );

    while ( my $item = $items->next ) {
        $item->delete;
    }

    $self->redirect_to( '/auth?account_id=' . $account_id );
};

=head2 GET /menus

Menus list

=cut

any '/menus' => sub {
    my ($self) = @_;

    my $account_id = $self->param('account_id');
    my $meal_id    = $self->param('meal_id');

    my $meals = $self->schema->resultset('Meal')->search(
        {
            account_id => $account_id,
        },
        {
            order_by => { -asc => 'name' },
        }
    );

    my $meal = $self->schema->resultset('Meal')->find({ id => $meal_id });
    my $name = $meal ? $meal->name : '';
    my $id   = $meal ? $meal->id : '';

    my $items = $self->schema->resultset('MealItem')->search(
        {
            meal_id => $meal_id,
        },
        {
            order_by => { -asc => 'name' },
        }
    );

    my $menus = $self->schema->resultset('Menu')->search(
        {
            'meal.account_id' => $account_id,
        },
        {
            join     => 'meal',
            prefetch => 'meal',
        }
    );

    my $menu_items = {};
    for my $menu ( $menus->all ) {
        my $m_items = $self->schema->resultset('MenuItem')->search(
            {
                menu_id => $menu->id,
            },
            {
                join     => 'meal_item',
                prefetch => 'meal_item',
            }
        );

        for my $m_item ( $m_items->all ) {
            push @{ $menu_items->{ $menu->id } }, $m_item;
        }
    }


    $self->stash( account_id => $account_id, meals => $meals, meal_id => $id, meal_name => $name, items => $items, menus => $menus, menu_items => $menu_items );
} => 'menus';

post '/add_menu' => sub {
    my ($self) = @_;

    my $account_id = $self->param('account_id');
    my $meal_id    = $self->param('meal_id');
    my $name       = $self->param('menu_name');
    my $ids        = $self->every_param('meal_item_id');
    my $values     = $self->every_param('item_value');

    my $menu = $self->schema->resultset('Menu')->create(
        {
            name    => $name,
            meal_id => $meal_id,
        },
    );

    for my $n ( 0 .. @$values - 1 ) {
        $self->schema->resultset('MenuItem')->create(
            {
                meal_item_id => $ids->[$n],
                value        => $values->[$n],
                menu_id      => $menu->id,
            },
        );
    }

    $self->redirect_to( '/menus?account_id=' . $account_id );
};

app->start;

=head1 AUTHOR

Gene Boggs <gene.boggs@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
