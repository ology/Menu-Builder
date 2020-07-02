#!/usr/bin/env perl
use strict;
use warnings;

__END__
use DBI;

use lib 'lib';
use Schema;

my $dbh = DBI->connect('DBI:SQLite:dbname=../Menu-Builder/menu-builder.db', '', '') or die $DBI::errstr;

my $config = do './menu-builder.conf';

my $schema = Schema->connect($config->{database}, '', '');

my $sql = 'SELECT * FROM meal where account_id=2';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute() or die $dbh->errstr;
my $data = $sth->fetchall_hashref('id');
$sth->finish;
for my $datum (keys %$data) {
    my $meal = $schema->resultset('Meal')->create({
        account_id => $data->{$datum}{account_id},
        name       => $data->{$datum}{name},
    });

    $sql = 'SELECT * FROM meal_item where meal_id=?';
    $sth = $dbh->prepare($sql) or die $dbh->errstr;
    $sth->execute($data->{$datum}{meal_id}) or die $dbh->errstr;
    my $item_data = $sth->fetchall_hashref('id');
    $sth->finish;
    for my $d (keys %$item_data) {
        my $item = $schema->resultset('MealItem')->create({
            name    => $item_data->{$d}{name},
            meal_id => $meal->id,
        });
    }

    $sql = 'SELECT * FROM menu where meal_id=?';
    $sth = $dbh->prepare($sql) or die $dbh->errstr;
    $sth->execute($data->{$datum}{meal_id}) or die $dbh->errstr;
    my $menu_data = $sth->fetchall_hashref('id');
    $sth->finish;
    for my $m (keys %$menu_data) {
        my $menu = $schema->resultset('Menu')->create({
            name    => $menu_data->{$m}{name},
            meal_id => $meal->id,
        });

        $sql = 'SELECT * FROM menu_item where menu_id=?';
        $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($menu_data->{$m}{menu_id}) or die $dbh->errstr;
        my $menu_item_data = $sth->fetchall_hashref('id');
        $sth->finish;
        for my $i (keys %$menu_item_data) {
            my $menu = $schema->resultset('MenuItem')->create({
                meal_item_id => $menu_item_data->{$i}{meal_item_id},
                name         => $menu_item_data->{$i}{name},
                value        => $menu_item_data->{$i}{value},
                menu_id      => $menu->id,
            });
        }
    }

}
