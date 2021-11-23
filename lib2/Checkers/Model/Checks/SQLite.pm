package Checkers::Model::Checks::Pg;
use Mojo::Base 'Checkers::Model::Checks', -signatures;

use Carp qw(croak);
use Mojo::File qw(curfile);
use Mojo::IOLoop;
use Mojo::SQLite 3.0;

has 'sqlite';

sub a { shift->model->app->mode }

sub new {
  my $self = shift->SUPER::new(@_);
  
  my $init = $self->model->init;
  $self->sqlite(Mojo::SQLite->new($init));

  # my $db = $self->sqlite->db;
  # croak 'PostgreSQL 9.5 or later is required' if $db->dbh->{pg_server_version} < 90500;

  # Migrate to latest version if necessary
  my $migrations = $self->resources->child('migrations', 'sqlite.sql');
  warn $migrations;
  $self->sqlite->auto_migrate(1)->migrations->name('checkers')->from_file($migrations) if -e $migrations;

  return $self;
}

#sub z {}

1;