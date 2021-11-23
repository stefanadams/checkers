package Checkers::Model::Checks::Pg;
use Mojo::Base 'Checkers::Model::Checks', -signatures;

use Carp qw(croak);
use Mojo::File qw(curfile);
use Mojo::IOLoop;
use Mojo::Pg 4.0;

has 'pg';

sub a { shift->model->app->mode }

sub new {
  my $self = shift->SUPER::new(@_);
  
  my $init = $self->model->init;
  $self->pg(Mojo::Pg->new($init));

  my $db = Mojo::Pg->new($init)->db;
  croak 'PostgreSQL 9.5 or later is required' if $db->dbh->{pg_server_version} < 90500;
  $db->disconnect;

  # Migrate to latest version if necessary
  my $migrations = $self->resources->child('migrations', 'pg.sql');
  warn $migrations;
  $self->pg->auto_migrate(1)->migrations->name('checkers')->from_file($migrations) if -e $migrations;

  return $self;
}

#sub z {}

1;