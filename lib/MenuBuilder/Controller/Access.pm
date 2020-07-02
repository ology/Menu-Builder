package MenuBuilder::Controller::Access;
use Mojo::Base 'Mojolicious::Controller';

use constant ERROR_MSG => 'Invalid fields';

sub index { shift->render }

sub login {
    my ($self) = @_;
    if (my $user = $self->auth($self->param('username'), $self->param('password'))) {
        $self->session(auth => $user->id);
        return $self->redirect_to('menus');
    }
    $self->flash(error => 'Invalid login');
    return $self->redirect_to('login');
}

sub logout {
    my ($self) = @_;
    delete $self->session->{auth};
    return $self->redirect_to('login');
}

sub meals {
    my ($self) = @_;
    my $account = $self->rs('Account')->find($self->session->{auth});
    my $meals = $account->meals->search({}, { order_by => { -asc => \'LOWER(name)' } });
    my $meal_items = {};
    while (my $meal = $meals->next) {
        $meal_items->{ $meal->id } = $meal->items;
    }
    $meals->reset;
    $self->render(
        meals      => $meals,
        meal_items => $meal_items
    );
}

sub new_meal {
    my ($self) = @_;
    my $v = $self->validation;
    $v->required('name', 'not_empty');
    if ($v->has_error) {
        $self->flash(error => ERROR_MSG);
    }
    else {
        my $meal = $self->rs('Meal')->create({
            name       => $v->param('name'),
            account_id => $self->session->{auth},
        });
        my $items = $self->every_param('item');
        for my $item (@$items) {
            $self->rs('MealItem')->create({
                name    => $item,
                meal_id => $meal->id,
            });
        }
    }
    return $self->redirect_to('meals');
}

sub update_meal {
    my ($self) = @_;
    my $v = $self->validation;
    $v->required('meal', 'not_empty');
    $v->required('name', 'not_empty');
    if ($v->has_error) {
        $self->flash(error => ERROR_MSG)
    }
    else {
        my $result = $self->rs('Meal')->find($v->param('meal'));
        $result->update({ name => $v->param('name') });
        my $items = $self->every_param('meal_item_id');
        my $names = $self->every_param('meal_item');
        for my $n (0 .. $#$items) {
            my $id = $items->[$n];
            my $item = $self->rs('MealItem')->find($id);
            $item->update({ name => $names->[$n] });
        }
    }
    return $self->redirect_to('meals');
}

sub delete_meal {
    my ($self) = @_;
    my $v = $self->validation;
    $v->required('meal', 'not_empty');
    if ($v->has_error) {
        $self->flash(error => ERROR_MSG)
    }
    else {
        my $meal = $self->rs('Meal')->find($v->param('meal'));
        my $items = $meal->items;
        while (my $item = $items->next) {
            $item->delete;
        }
        my $menus = $meal->menus;
        while (my $menu = $menus->next) {
            my $menu_items = $menu->items;
            while (my $item = $menu_items->next) {
                $item->delete;
            }
            $menu->delete;
        }
        $meal->delete;
    }
    return $self->redirect_to('meals');
}

sub menus {
    my ($self) = @_;
    my $account = $self->rs('Account')->find($self->session->{auth});
    my $meals = $account->meals->search({}, { order_by => { -asc => \'LOWER(name)' } });
    my $meal_id = $self->param('meal_id');
    my $meal = $meal_id ? $self->rs('Meal')->find($meal_id) : undef;
    my $meal_name = $meal ? $meal->name : '';
    my $items = $meal ? $meal->items : undef;
    my $menus = $self->rs('Menu')->search(
        {
            'meal.account_id' => $self->session->{auth},
        },
        {
            join     => 'meal',
            prefetch => 'meal',
        }
    );
    my $menu_items = {};
    while (my $menu = $menus->next) {
        my $m_items = $menu->items;
        while (my $m_item = $m_items->next) {
            push @{ $menu_items->{ $menu->id } }, $m_item;
        }
    }
    $menus->reset;
    my $schedules = $self->rs('Schedule')->search(
        {
            account_id => $self->session->{auth},
        },
        {
            order_by => 'name',
        }
    );
    $self->render(
        schedules  => $schedules,
        meals      => $meals,
        meal_id    => $meal_id,
        meal_name  => $meal_name,
        items      => $items,
        menus      => $menus,
        menu_items => $menu_items,
        account_id => $account->id,
    );
}

sub add_menu {
    my ($self) = @_;
    my $meal_id = $self->param('meal_id');
    my $name    = $self->param('menu_name');
    my $ids     = $self->every_param('meal_item_id');
    my $values  = $self->every_param('item_value');
    if ($name) {
        my $menu = $self->rs('Menu')->create({
            name    => $name,
            meal_id => $meal_id,
        });
        for my $n (0 .. $#$values) {
            $self->rs('MenuItem')->create({
                meal_item_id => $ids->[$n],
                value        => $values->[$n],
                menu_id      => $menu->id,
            });
        }
    }
    else {
        $self->flash(error => ERROR_MSG);
    }

    $self->redirect_to('/menus');
}

sub delete_menu {
    my ($self) = @_;
    my $menu = $self->rs('Menu')->find($self->param('menu_id'));
    my $items = $menu->items;
    while (my $item = $items->next) {
        $item->delete;
    }
    $menu->delete;
    $self->redirect_to('/menus');
}

sub update_menu {
    my ($self) = @_;
    my $v = $self->validation;
    $v->required('menu_id', 'not_empty');
    $v->required('menu_name', 'not_empty');
    $v->optional('schedule', 'not_empty');
    if ($v->has_error) {
        $self->flash(error => ERROR_MSG)
    }
    else {
        if ($v->param('schedule')) {
            my ($week, $day) = split ' ', $v->param('schedule');
            my $schedule = $self->rs('Schedule')->search(
                {
                    account_id => $self->session->{auth},
                    name       => $week,
                }
            )->first;
            if ($schedule) {
                $schedule->update({ $day => $v->param('menu_id') });
            }
            else {
                $self->rs('Schedule')->create({
                    account_id => $self->session->{auth},
                    name       => $week,
                    $day       => $v->param('menu_id'),
                });
            }
        }
        else {
            my $menu_item_ids = $self->every_param('menu_item_id');
            my $menu_items    = $self->every_param('menu_item');
            my $menu = $self->rs('Menu')->find($v->param('menu_id'));
            $menu->update({ name => $v->param('menu_name') });
            for my $n (0 .. $#$menu_items) {
                my $item = $self->rs('MenuItem')->find($menu_item_ids->[$n]);
                $item->update({ value => $menu_items->[$n] });
            }
        }
    }
    return $self->redirect_to('menus');
}

sub print_schedule {
    my ($self) = @_;
    my $schedules = $self->rs('Schedule')->search(
        {
            account_id => $self->session->{auth},
        },
        {
            order_by => 'name',
        }
    );
    $self->render(
        schedules => $schedules,
    );
}

sub signup { shift->render }

sub new_user {
    my ($self) = @_;
    my $v = $self->validation;
    $v->required('email');
    $v->required('username')->like(qr/^\w+$/);
    $v->required('password')->size(4, 20);
    $v->required('confirm')->equal_to('password');
    if ($v->has_error) {
        $self->flash(error => ERROR_MSG);
        return $self->redirect_to('/signup');
    }
    my $account = $self->rs('Account')->search({ username => $v->param('username') })->first;
    if ($account) {
        $self->flash(error => ERROR_MSG);
        return $self->redirect_to('/signup');
    }
    $self->rs('Account')->create({
        email    => $v->param('email'),
        username => $v->param('username'),
        password => $v->param('password'),
    });
    return $self->redirect_to('/');
}

1;
