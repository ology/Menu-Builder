use utf8;
package Schema::Result::Meal;
use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('meals');

__PACKAGE__->add_columns(
    id         => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    name       => { data_type => 'text',    is_nullable => 0 },
    account_id => { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(account => 'Schema::Result::Account', 'account_id');

__PACKAGE__->has_many(items => 'Schema::Result::MealItem', 'meal_id');

__PACKAGE__->has_many(menus => 'Schema::Result::Menu', 'meal_id');

1;
