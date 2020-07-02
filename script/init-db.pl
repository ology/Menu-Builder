#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Schema;

my ($email, $name, $pass) = @ARGV;

my $config = do './menu_builder.conf';

(my $db_file = $config->{database}) =~ s/^.*?=(.*)$/$1/;

unlink $db_file
    if -e $db_file;
unlink $db_file . '.journal'
    if -e $db_file . '.journal';

my $schema = Schema->connect($config->{database}, '', '');

$schema->deploy({ add_drop_table => 1 });

if ($email && $name && $pass) {
    $schema->resultset('Account')->create({
        email    => $email,
        username => $name,
        password => $pass,
    });
}
