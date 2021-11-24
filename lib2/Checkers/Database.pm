package Checkers::Database;
use Mojo::Base 'Mojo::SQLite::Database', -signatures;

use Carp qw(croak);
use Checkers::Results;
use SQL::Bind qw();

has results_class => 'Checkers::Results';

sub select { croak "select not implemented" }
sub insert { croak "insert not implemented" }
sub update { croak "update not implemented" }
sub delete { croak "delete not implemented" }

sub sql ($self, $sql, %parameters) { $self->query($self->sqlite->abstract->sql($sql, %parameters)) }

sub version ($self) {
  $self->query('select sqlite_version() as version')->version;
}

1;