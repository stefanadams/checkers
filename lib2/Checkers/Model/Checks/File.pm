package Checkers::Model::Checks::File;
use Mojo::Base 'Checkers::Model::Checks', -signatures;

use Carp qw(croak);
use Checkers::Record;
use Mojo::ByteStream qw(b);
use Mojo::Collection qw(c);
use Mojo::File qw(curfile);
use Mojo::Home;
use Mojo::IOLoop;
use Mojo::Pg 4.0;

use constant FILE_ROLE => 'Checkers::Role::File';

sub add ($self, $record) {
  my $file = $self->path($record->system, $record->date->epoch)->spurt($record);
  warn sprintf "metrics len: %s\tsystem: %s\tdate: %s\n", length($record), $record->system, $record->date;
  warn sprintf "file %s size %d\n", $file, $file->stat->size;
  return $self;
}

sub find ($self, $system=undef, $limit=1) {
  my $path = $self->path;
  my $files = $system ? c($path->child($system)) : $path->list({dir => 1});
  return $files->map(sub {
    $_->with_roles(FILE_ROLE)->list->sort->tail($limit)->map(sub { $_->slurp2 });
  })->flatten;
}

sub path ($self, $system=undef, $datetime=undef) {
  my $path = Mojo::Home->new->child($self->model->init);
  return $path unless $system;
  $path = $path->child($system);
  $path->make_path unless -d $path;
  return $datetime ? $path->child($datetime->epoch) : $path;
}

sub remove ($self, $system, $limit) {
  my $path = $self->path($system);
  my $files = $path->list->sort;
  my $number = $files->size;
  $limit = $number if $limit < 0 || $limit > $number;
  #$files->[$_-1]->remove for (1..$limit);
  $files->head($limit)->each('remove');
  $path->remove_tree unless $path->list->size;
  return $self;
}

1;