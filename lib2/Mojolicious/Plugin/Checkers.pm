package Mojolicious::Plugin::Checkers;
use Mojo::Base 'Mojolicious::Plugin';

use Checkers::Model;
use Checkers::Record;
use Mojo::Date;

use constant DATE_ROLE => 'Checkers::Role::Date';

sub register {
  my ($self, $app, $conf) = @_;
  push @{$app->commands->namespaces}, 'Checkers::Command';
  my $model = Checkers::Model->new($conf->{model})->app($app);
  $app->helper('checkers.model' => sub {$model});
  $app->helper('checkers.record.new' => sub ($c, @data) {Checkers::Record->new($c->param('system'), $c->checkers->date, $c->req->request_id, @data)});
  $app->helper('checkers.date' => sub ($c) { state $date = Mojo::Date->new($c->req->headers->date || ())->with_roles(DATE_ROLE) })
  $app->helper('timing.start' => sub ($c, $name=undef) {
    $name ||= $c->current_route;
    $c->timing->begin($name);
  });
  $app->helper('timing.stop' => sub ($c, $name=undef, $desc=undef) {
    $name ||= $c->current_route;
    my $elapsed = $c->timing->elapsed($name);
    return $c->timing->server_timing($name) unless $elapsed;
    $c->timing->server_timing($name, sprintf("%s rps", $c->timing->rps($elapsed)), $elapsed);
  });
  $app->types->type(csv => 'text/csv');
}

1;