#!/usr/bin/env perl
use strict;
use warnings;

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $dsn  = 'dbi:SQLite:dbname=menu-builder.db';
my $user = undef;
my $pass = undef;

make_schema_at(
    'MenuBuilder::Schema', {
        debug             => 1,
        dump_directory    => './lib',
        schema_components => [qw(Schema::Config)],
    },
    [ $dsn, $user, $pass, ],
);
