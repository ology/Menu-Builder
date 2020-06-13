#!/usr/bin/env perl

use lib 'lib';
use MenuBuilder::Schema;

use Mojolicious::Lite;

my ( $name, $pass ) = @ARGV;

my $config = plugin 'Config'=> { file => '../menu-builder.conf' };
plugin 'bcrypt';

my $password = app->bcrypt($pass);

my $schema = MenuBuilder::Schema->connect( $config->{database} );

$schema->resultset('Account')->create({ name => $name, password => $password });
