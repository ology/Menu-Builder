use utf8;
package Schema::Result::Schedule;
use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('schedules');

__PACKAGE__->add_columns(
    id         => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
    account_id => { data_type => 'integer', is_nullable => 0 },
    name       => { data_type => 'text',    is_nullable => 0 },
    monday     => { data_type => 'integer', is_nullable => 1 },
    tuesday    => { data_type => 'integer', is_nullable => 1 },
    wednesday  => { data_type => 'integer', is_nullable => 1 },
    thursday   => { data_type => 'integer', is_nullable => 1 },
    friday     => { data_type => 'integer', is_nullable => 1 },
    saturday   => { data_type => 'integer', is_nullable => 1 },
    sunday     => { data_type => 'integer', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(account => 'Schema::Result::Account', 'account_id');

1;
