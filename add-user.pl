#!/usr/bin/env perl

use lib 'lib';
use MenuBuilder::Schema;

use Mojolicious::Lite;

my ( $name, $pass ) = @ARGV;

plugin 'bcrypt';

my $password = app->bcrypt($pass);

my $schema = MenuBuilder::Schema->connect('menu-builder.db');

$schema->resultset('Account')->create({ name => $name, password => $password });
