package MenuBuilder;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  $self->plugin('Helper');

  my $config = $self->plugin('Config');

  $self->secrets($config->{secrets});

  my $r = $self->routes;

  my $auth = $r->under('/' => sub {
    my ($self) = @_;
    my $session = $self->session('auth') // '';
    return 1 if $session;
    return $self->redirect_to('login');
  });

  $r->get('/')->to('access#index')->name('login');
  $r->post('/')->to('access#login');
  $r->get('/logout')->to('access#logout')->name('logout');
  $r->get('/signup')->to('access#signup')->name('signup');
  $r->post('/signup')->to('access#new_user');
  $auth->get('/meals')->to('access#meals');
  $auth->post('/meals')->to('access#new_meal');
  $auth->post('/update_meal')->to('access#update_meal');
  $auth->post('/delete_meal')->to('access#delete_meal');
  $auth->any('/menus')->to('access#menus');
  $auth->post('/add_menu')->to('access#add_menu');
  $auth->post('/delete_menu')->to('access#delete_menu');
  $auth->post('/update_menu')->to('access#update_menu');
  $auth->get('/print_schedule')->to('access#print_schedule');
}

1;
