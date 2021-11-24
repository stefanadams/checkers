package Checkers::Record;
use Mojo::Base -base, -signatures;
use overload
  '@{}' => sub { shift->to_array },
  '""' => sub { shift->to_string },
  bool => sub {1},
  fallback => 1;

use Checkers::Util qw(mesh);
use Mojo::Collection qw(c);
use Mojo::Date;
use Scalar::Util qw(blessed);

our @columns = qw(id epoch result comparison threshold message suppress labels);
has [@columns];

sub alert { shift->status eq 'ALERT' }

sub check { shift->check_name }

sub columns { [@columns] }

sub date { Mojo::Date->with_roles('Checkers::Role::Date')->new(shift->epoch || ()) }

sub fail { shift->alert }

sub from_array ($class, $array) { $class->new(_mesh($array)) }

sub from_collection ($class, $collection) { $collection->map(sub{$class->new($_)}) }

sub from_hash ($class, $hash) { $class->new(_mesh($hash)) }

sub from_string ($class, $string, $delimiter="\t") {
  $class->new(_mesh([split $delimiter, $string, $#{$class->columns}]));
}

sub group { shift->group_name }

sub has_result { return length shift->result }

sub info { shift->status eq 'INFO' }

sub is ($self) {
  return 'above' if $self->comparison eq '-ge';
  return 'below' if $self->comparison eq '-le';
}

sub new {
  my $class = shift;
  return $class->from_collection($_[0]) if blessed($_[0]) && $_[0]->isa('Mojo::Collection');
  return $class->from_array($_[0]) if ref $_[0] eq 'ARRAY';
  return $class->from_hash($_[0]) if ref $_[0] eq 'HASH';
  return $class->from_string(${$_[0]}, $_[1]) if ref $_[0] eq 'SCALAR';
  return $class->SUPER::new(@_);
}

sub not_info { shift->status ne 'INFO' }

sub of_check ($self) { join ' ', $self->of, $self->check_name }

sub pass { shift->status eq 'OK' }

sub pass { shift->ok }

sub status ($self) {
  my $what = $self->can(lc('_'.$self->what)) || sub { 'UNDEFINED' };
  $what->();
}

sub to_array ($self, $columns=undef) { return [map { $self->{$_} } @{$columns || $self->columns}] }

sub to_hash ($self, $columns=undef) { return {%$self{@{$columns || $self->columns}}} }

sub to_string ($self, $columns=undef, $delimiter="\t") { join $delimiter, @{$self->to_array($columns)}} }

##

sub _change ($self) { }

sub _count { shift->_value }

sub _info ($self) { return 'INFO' }

sub _mesh ($obj) {
  if (ref $obj eq 'ARRAY') {
    @$obj = map { $obj->[$_]//'' } 0..$#columns;
    return mesh @$obj, @columns if $#$obj == $#columns;
  }
  elsif (ref $obj eq 'HASH') {
    %$obj = map { $_ => $obj->{$_}//'' } @columns;
    return %$obj;
  }
  warn "Invalid list length\n";
  return ();
}

# Checks are named as "SHOULD BE" - so alert if exceeded
sub _value ($self) {
  my ($result, $comparison, $threshold) = @$self{qw(result comparison threshold)};
  if ($comparison eq '-ge' && $result < $threshold) {
    return 'ALERT';
  }
  if ($comparison eq '-le' && $result > $threshold) {
    return 'ALERT';
  }
  return 'OK';
}

1;
