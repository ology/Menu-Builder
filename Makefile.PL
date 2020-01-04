use inc::Module::Install;

name        'menu-builder';
all_from    'menu-builder';
license     'perl';

requires    'Mojolicious';
requires    'Mojolicious::Plugin::Bcrypt';
requires    'DBIx::Class';
requires    'DBIx::Class::Schema::Config';

auto_install(
    do_once => 1,    # skip previously failed modules
);

WriteAll;
