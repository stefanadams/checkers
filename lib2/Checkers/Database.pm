package Checkers::Database;
use Mojo::Base 'Mojo::SQLite::Database', -signatures;

use Carp qw(croak);
use Checkers::Results;
use SQL::Bind;

has results_class => 'Checkers::Results';

sub select { croak "select not implemented" }
sub insert { croak "insert not implemented" }
sub update { croak "update not implemented" }
sub delete { croak "delete not implemented" }

sub select_where ($self, $sql, @parameters) { $self->query(SQL::Bind::sql("select * from checkers where $sql", @parameters)) }

sub version ($self) {
  $self->query('select sqlite_version() as version')->version;
}

1;