package Checkers::Model;
use Mojo::Base -base, -signatures;

use Carp qw(croak);
use Mojo::Date;
use Mojo::Loader qw(load_class);
use Mojo::Util qw(camelize dumper);

use constant DATE_ROLE => 'Checkers::Role::Date';

has app => sub { $_[0]{app_ref} = Mojo::Server->new->build_app('Mojo::HelloWorld') }, weak => 1;
has [qw(driver init)];

sub AUTOLOAD {
  my $self = shift;
  our $AUTOLOAD; # keep 'use strict' happy
  my $program = $AUTOLOAD =~ s/.*:://r;
  my $class = join '::', __PACKAGE__, camelize($program), $self->driver;
  return $self->{$class} if $self->{$class};
  warn "Loading $class\n";
  my $e = load_class $class;
  croak ref $e ? $e : qq{Backend "$class" missing} if $e;

  return $self->{$class} = $class->new($self, @_);
}

sub new {
  my $self = shift->SUPER::new;
  $self->driver($_[0]->[0])->init($_[0]->[1]);
  $self->driver or die "Driver not specified\n";
  $self->init or die sprintf "Driver %s not initialized\n", $self->driver;
  return $self;
}

sub remove ($self, $system, $limit) {
  $self->checks->remove($system, $limit);
}

sub save ($self, $metrics, $system, $datestr=undef) {
  my $date = Mojo::Date->with_roles(DATE_ROLE)->new($datestr || ());
  $self->checks->save($metrics, $system, $date);
  return $self;
}

1;