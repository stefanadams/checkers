package Checkers::Record;
use Mojo::Base -base, -signatures;
use overload '@{}' => sub { shift->to_array }, bool => sub {1}, '""' => sub { $_[0]->to_string }, fallback => 1;

use Mojo::Util qw(dumper);
use Time::Piece;

my @header = qw/system datetime/;
my @cols = qw/group category check what of result comparison threshold message supress/;

has [@header, @cols];
has fail => sub { shift->status eq 'ALERT' };
has has_result => sub { return length shift->result };
has pass => sub { shift->status eq 'OK' };
has not_info => sub { shift->status ne 'INFO' };
has status => sub ($self) { my $what = lc('_'.$self->what); $self->$what };
has md5_sum => sub ($self) {
  substr(Mojo::Util::md5_sum(join '', map { $self->$_ // '' } qw(system category check what of comparison threshold status)), 0, 8);
};

sub of_check ($self) { join ' ', $self->of, $self->check }

sub is ($self) {
  return 'above' if $self->comparison eq '-ge';
  return 'below' if $self->comparison eq '-le';
}

sub new {
  my $self = shift;
  $self = ref $_[0] eq 'HASH' ? $self->SUPER::new(shift) : $self->SUPER::new;
  @_ = @{$_[0]} if ref $_[0];
  $self->$_(shift//'') foreach @header, @cols;
  return $self;
}

sub to_csv ($self, $delimiter="\t") { join $delimiter, map { $self->$_ // '' } @header, @cols }

sub to_metric ($self, $delimiter="\t") { length $self->result ? join $delimiter, $self->datetime, $self->result : '' }

sub to_array ($self) { [map { $self->$_ // '' } @header, @cols] }

sub to_hash ($self) { return {%$self} }

sub to_string ($self, $delimiter="\t") { join $delimiter, map { $self->$_ // '' } @cols }

# Checks are named as "SHOULD BE" - so alert if exceeded

sub _value ($self) {
  my ($result, $comparison, $threshold) = map { $self->$_ } qw(result comparison threshold);
  if ($comparison eq '-ge' && $result < $threshold) {
    return 'ALERT';
  }
  if ($comparison eq '-le' && $result > $threshold) {
    return 'ALERT';
  }
  return 'OK';
}

sub _count { shift->_value }

sub _change ($self) {

}

sub _info ($self) { return 'INFO' }

1;
