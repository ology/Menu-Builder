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
        $self->session( auth => $id );
        return $self->redirect_to('/auth');
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
        if $session;

    $self->render( text => 'Denied!' );
    return 0;
};

=head1 AUTHORIZED ROUTES

=head2 GET /auth

Settings page

=cut

get '/auth' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');

    my $meals = $self->schema->resultset('Meal')->search(
        {
            account_id => $account_id,
        },
    );

    my $meal_items = {};
    for my $meal ( $meals->all ) {
        my $items = $self->schema->resultset('MealItem')->search(
            {
                meal_id => $meal->id,
            },
        );

        for my $item ( $items->all ) {
            push @{ $meal_items->{ $meal->id } }, {
                id   => $item->id,
                name => $item->name,
            };
        }
    }

    $self->stash( meals => $meals, meal_items => $meal_items );
} => 'auth';

=head2 POST /new_meal

Create a new meal type.

=cut

post '/new_meal' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');
    my $name       = $self->param('name');
    my $items      = $self->every_param('item');

    if ( $name ) {
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
    }
    else {
        $self->flash( error => 'No meal name given!' );
    }

    $self->redirect_to('/auth');
};

=head2 POST /update_meal

Update a meal.

=cut

post '/update_meal' => sub {
    my ($self) = @_;

    my $meal_id       = $self->param('meal_id');
    my $meal_name     = $self->param('meal_name');
    my $meal_item_ids = $self->every_param('meal_item_id');
    my $meal_items    = $self->every_param('meal_item');

    my $meal = $self->schema->resultset('Meal')->find($meal_id);
    $meal->update({ name => $meal_name });

    for my $n ( 0 .. @$meal_items - 1 ) {
        my $item = $self->schema->resultset('MealItem')->find($meal_item_ids->[$n]);
        $item->update({ name => $meal_items->[$n] });
    }

    $self->redirect_to('/auth');
};

=head2 POST /delete_meal

Delete a meal.

=cut

post '/delete_meal' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');
    my $meal_id    = $self->param('meal_id');

    my $meal = $self->schema->resultset('Meal')->find($meal_id);
    $meal->delete;

    my $items = $self->schema->resultset('MealItem')->search(
        {
            meal_id => $meal->id,
        },
    );

    while ( my $item = $items->next ) {
        $item->delete;
    }

    my $menus = $self->schema->resultset('Menu')->search(
        {
            meal_id => $meal->id,
        },
    );

    while ( my $menu = $menus->next ) {
        $menu->delete;

        $items = $self->schema->resultset('MenuItem')->search(
            {
                menu_id => $menu->id,
            },
        );

        while ( my $item = $items->next ) {
            $item->delete;

            my $details = $self->schema->resultset('ItemDetail')->search(
                {
                    item_id => $item->id,
                },
            );

            while ( my $detail = $details->next ) {
                $detail->delete;
            }
        }
    }

    $self->redirect_to('/auth');
};

=head2 GET/POST /menus

Menus list

=cut

any '/menus' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');
    my $meal_id    = $self->param('meal_id');

    my $meals = $self->schema->resultset('Meal')->search(
        {
            account_id => $account_id,
        },
    );

    my $meal = $self->schema->resultset('Meal')->find($meal_id);
    my $name = $meal ? $meal->name : '';
    my $id   = $meal ? $meal->id : '';

    my $items = $self->schema->resultset('MealItem')->search(
        {
            meal_id => $meal_id,
        },
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

    $self->stash(
        meals      => $meals,
        meal_id    => $id,
        meal_name  => $name,
        items      => $items,
        menus      => $menus,
        menu_items => $menu_items,
        account_id => $account_id,
    );
} => 'menus';

=head2 POST /add_menu

Add a new menu.

=cut

post '/add_menu' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');
    my $meal_id    = $self->param('meal_id');
    my $name       = $self->param('menu_name');
    my $ids        = $self->every_param('meal_item_id');
    my $values     = $self->every_param('item_value');

    if ( $name ) {
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
    }
    else {
        $self->flash( error => 'No menu name given!' );
    }

    $self->redirect_to('/menus');
};

=head2 POST /update_menu

Update a menu.

=cut

post '/update_menu' => sub {
    my ($self) = @_;

    my $menu_id       = $self->param('menu_id');
    my $menu_name     = $self->param('menu_name');
    my $menu_item_ids = $self->every_param('menu_item_id');
    my $menu_items    = $self->every_param('menu_item');

    my $menu = $self->schema->resultset('Menu')->find($menu_id);
    $menu->update({ name => $menu_name });

    for my $n ( 0 .. @$menu_items - 1 ) {
        my $item = $self->schema->resultset('MenuItem')->find($menu_item_ids->[$n]);
        $item->update({ value => $menu_items->[$n] });
    }

    $self->redirect_to('/menus');
};

=head2 POST /delete_menu

Delete a menu.

=cut

post '/delete_menu' => sub {
    my ($self) = @_;

    my $account_id = $self->session('auth');
    my $menu_id    = $self->param('menu_id');

    my $menu = $self->schema->resultset('Menu')->find($menu_id);
    $menu->delete;

    my $items = $self->schema->resultset('MenuItem')->search(
        {
            menu_id => $menu->id,
        },
    );

    while ( my $item = $items->next ) {
        $item->delete;

        my $details = $self->schema->resultset('ItemDetail')->search(
            {
                item_id => $item->id,
            },
        );

        while ( my $detail = $details->next ) {
            $detail->delete;
        }
    }

    $self->redirect_to('/menus');
};

app->start;

=head1 AUTHOR

Gene Boggs <gene.boggs@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
