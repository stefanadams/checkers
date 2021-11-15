package Checkers;
use Mojo::Base -base, -signatures;

use Checkers::Record;
use Mojo::Collection;
use Mojo::File;

has records => sub { Mojo::Collection->new->with_roles('Checkers::Role::Collection', '+Transform') };

sub load ($self, $system=[]) {
  @{$self->records} = ();
  my %system = (map { $_ => 1 } @$system);
  $self->path->list({dir => 1})->grep(sub {
    $system{$_->basename} || !keys %system;
  })->sort->each(sub {
    $_->list->sort
      ->tap(sub {
        $_ = $_->new($_->last) unless $system;
      })
      ->each(sub {
        push @{$self->records}, @{$_->slurp};
      })
  });
  $self->records;
}

sub path ($self, $path=undef) {
  return Mojo::File->new($self->{path} //= $path)->with_roles('Checkers::Role::File') unless $#_;
  $self->{path} = $path;
  return Mojo::File->new($path)->with_roles('Checkers::Role::File');
}

sub save ($self, $chunk, $system, $date=undef) {
  my $records = $self->path->spurt($chunk => $system => $date)->slurp;
  push @{$self->records}, @$records;
  $self->records;
}

1;