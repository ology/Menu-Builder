use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use lib $ENV{HOME} . '/sandbox/Test-SQLite/lib';
use Test::SQLite;

use Schema;

my $t = Test::Mojo->new('MenuBuilder');

$t->ua->max_redirects(1);

my $sqlite = Test::SQLite->new;
$t->app->config->{database} = $sqlite->dsn;
my $schema = Schema->connect($sqlite->dsn);
isa_ok $schema, 'Schema';
$schema->deploy;

$t->get_ok('/')
  ->status_is(200)
  ->content_like(qr/Login/);

$t->get_ok('/signup')
  ->status_is(200)
  ->content_like(qr/Signup/)
  ->element_exists('form input[name="email"]')
  ->element_exists('form input[name="username"]')
  ->element_exists('form input[name="password"]')
  ->element_exists('form input[name="confirm"]');

$t->post_ok('/signup' => form => {})
  ->status_is(200)
  ->content_like(qr/Invalid fields/);

$t->post_ok('/signup' => form => { email => 'test@example.com', username => 'test', password => 'test', confirm => 'test' })
  ->status_is(200)
  ->content_isnt('Invalid fields')
  ->content_like(qr/Login/);

$t->post_ok('/' => form => {})
  ->status_is(200)
  ->content_like(qr/Invalid login/);

$t->post_ok('/' => form => { username => 'test', password => 'test' })
  ->status_is(200)
  ->content_isnt('Invalid login')
  ->content_like(qr/Logout/);

$t->get_ok('/meals')
  ->status_is(200)
  ->content_like(qr/new meal/);

$t->post_ok('/meals' => form => {})
  ->status_is(200)
  ->content_like(qr/Invalid fields/);

$t->post_ok('/meals' => form => { name => 'Test Meal', item => 'Test Item' })
  ->status_is(200)
  ->content_like(qr/Test Meal/);

$t->post_ok('/update_meal' => form => { meal => 1, name => 'Test Meal!', meal_item_id => 1, meal_item => 'Test Item' })
  ->status_is(200)
  ->content_like(qr/Test Meal!/);

$t->get_ok('/menus')
  ->status_is(200)
  ->content_like(qr/Setup/);

$t->post_ok('/menus' => form => { meal_id => 1 })
  ->status_is(200)
  ->content_like(qr/New Test Meal! menu/);

$t->post_ok('/add_menu' => form => { meal_id => 1, menu_name => 'Foo', meal_item_id => 1, item_value => 'Bar' })
  ->status_is(200)
  ->content_like(qr/Test Meal!:/)
  ->content_like(qr/Foo/)
  ->content_like(qr/Bar/);

$t->post_ok('/update_menu' => form => { menu_id => 1, menu_name => 'Foo?', menu_item_id => 1, menu_item => 'Bar...' })
  ->status_is(200)
  ->content_like(qr/Test Meal!:/)
  ->content_like(qr/Foo\?/)
  ->content_like(qr/Bar\.\.\./);

$t->post_ok('/delete_meal' => form => { meal => 1 })
  ->status_is(200)
  ->content_isnt('Test Meal!');

$t->get_ok('/menus')
  ->status_is(200)
  ->content_isnt('Test Meal!:')
  ->content_isnt('Foo');

done_testing();
