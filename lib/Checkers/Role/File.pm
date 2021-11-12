package Checkers::Role::File;
use Mojo::Base -role, -signatures;

use Carp qw(croak);
use Checkers::Record;
use Mojo::ByteStream qw(b);
use Mojo::Date;
use Mojo::File qw(path);

our $VERSION = '0.01';
 
requires 'path';

sub remove ($self, $system, $date) { path($self)->child($system, $date)->remove }

sub remove_tree ($self, $system) { path($self)->child($system)->remove_tree }

sub spurt ($self, $chunk, $system, $date=undef) {
  my $path = $self->child($system)->make_path->child(Mojo::Date->new($date // ())->epoch);
  path($path)->spurt($chunk);
  return $path;
}

sub slurp ($self) {
  my $system = $self->dirname->basename;
  my $datetime = Mojo::Date->new($self->basename // ())->with_roles('Checkers::Role::Date');
  b(path($self)->slurp)->split("\n")
    ->with_roles('Checkers::Role::Collection')
    ->map(sub { Checkers::Record->new($system, $datetime, split /\t/) })
}

1;