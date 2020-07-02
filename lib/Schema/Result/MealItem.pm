use utf8;
package Schema::Result::MealItem;
use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('meal_items');

__PACKAGE__->add_columns(
    id      => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    name    => { data_type => 'text',    is_nullable => 0 },
    meal_id => { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(meal => 'Schema::Result::Meal', 'meal_id');

1;
