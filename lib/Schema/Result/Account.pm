use utf8;
package Schema::Result::Account;
use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('accounts');

__PACKAGE__->load_components(qw/EncodedColumn/);

__PACKAGE__->add_columns(
    id       => { data_type => 'int',  is_nullable => 0, is_serializable => 1, is_auto_increment => 1 },
    email    => { data_type => 'text', is_nullable => 0, is_serializable => 1 },
    username => { data_type => 'text', is_nullable => 0, is_serializable => 1 },
    password => { data_type => 'text', is_nullable => 0, is_serializable => 1,
        encode_column       => 1,
        encode_class        => 'Crypt::Eksblowfish::Bcrypt',
        encode_args         => { key_nul => 0, cost => 6 },
        encode_check_method => 'check_password',
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint('username_unique', ['username']);

__PACKAGE__->has_many(meals => 'Schema::Result::Meal', 'account_id');

__PACKAGE__->has_many(schedules => 'Schema::Result::Schedule', 'account_id');

1;
