use utf8;
package Schema::Result::MenuItem;
use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('menu_items');

__PACKAGE__->add_columns(
    id           => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    meal_item_id => { data_type => 'integer', is_nullable => 0 },
    value        => { data_type => 'text',    is_nullable => 0 },
    menu_id      => { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(menu => 'Schema::Result::Menu', 'menu_id');

__PACKAGE__->belongs_to(meal_item => 'Schema::Result::MealItem', 'meal_item_id');

1;
