package Checkers::Results;
use Mojo::Base 'Mojo::SQLite::Results', -signatures;

use Carp qw(croak);
use Checkers::Record;

sub record { Checkers::Record->new($_[0]->sth->fetchrow_hashref) }

sub records { Checkers::Record->new($_[0]->sth->fetchall_arrayref({})) }

sub version ($self) {
  croak "no can hash" unless $self->can('hash');
  my $hash = $self->hash;
  croak "no can hash version" unless exists $hash->{version};
  return $hash->{version};
}

1;