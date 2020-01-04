#!/usr/bin/env perl
use strict;
use warnings;

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $dsn  = 'dbi:SQLite:dbname=menu-builder.db';
my $user = '';
my $pass = '';

make_schema_at(
    'MenuBuilder::Schema',
    { debug => 1, dump_directory => './lib', },
    [ $dsn, $user, $pass, ],
);
