package Checkers::Model::Base;
use Mojo::Base -base, -signatures;

use Carp qw(croak);
use Mojo::Date;
use Mojo::File qw(curfile);

has 'model';
has name => sub { die sprintf "%s name not defined\n", ref shift };

sub new { shift->SUPER::new(model => shift, @_) }

sub resources ($self) {
  my $class = ref $self;
  $class =~ s/^Checkers::Model:://;
  curfile->sibling($self->name, 'resources');
}

1;