#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Schema;

my ($email, $name, $pass) = @ARGV;

my $config = do './menu_builder.conf';

my $schema = Schema->connect($config->{database}, '', '');

my $account = $schema->resultset('Account')->search({ username => $name })->first;

if ($account) {
    $account->update({ password => $pass });
}
else {
    $schema->resultset('Account')->create({ email => $email, username => $name, password => $pass });
}
