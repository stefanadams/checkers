package Checkers::Record;
use Mojo::Base -base, -signatures;
use overload '@{}' => sub { shift->to_array }, bool => sub {1}, '""' => sub { $_[0]->to_string }, fallback => 1;

use Mojo::Util qw(dumper);
use Time::Piece;

my @header = qw/system datetime/;
my @cols = qw/group category name what result comparison threshold message supress/;

has [@header, @cols];

sub has_result { return length shift->result }

sub is ($self) {
  return 'above' if $self->comparison eq '-ge';
  return 'below' if $self->comparison eq '-le';
}

sub new {
  my $self = shift->SUPER::new;
  @_ = @{$_[0]} if ref $_[0];
  $self->$_(shift//'') foreach @header, @cols;
  return $self;
}

sub status ($self) { my $what = lc('_'.$self->what); $self->$what }

sub to_csv ($self, $delimiter="\t") { join $delimiter, map { $self->$_ } @header, @cols }

sub to_metric ($self, $delimiter="\t") { join $delimiter, $self->datetime, $self->result }

sub to_array ($self) { [map { $self->$_ } @header, @cols] }

sub to_string ($self, $delimiter="\t") { join $delimiter, map { $self->$_ } @cols }

# Checks are named as "SHOULD BE" - so alert if exceeded

sub _value ($self) {
  my ($result, $comparison, $threshold) = map { $self->$_ } qw(result comparison threshold);
  if ($comparison eq '-ge' && $result <= $threshold) {
    return 'ALERT';
  }
  if ($comparison eq '-le' && $result >= $threshold) {
    return 'ALERT';
  }
  return 'OK';
}

sub _count { shift->_value }

sub _change ($self) {

}

1;
