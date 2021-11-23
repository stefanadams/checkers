package Checkers::Record;
use Mojo::Base -base, -signatures;
use overload
  '@{}' => sub { shift->to_array },
  '""' => sub { shift->to_string },
  bool => sub {1},
  fallback => 1;

use Checkers::Util qw(mesh);
use Mojo::ByteStream qw(b);
use Mojo::Collection qw(c);
use Mojo::Date;
use Mojo::File qw(path);

use constant COLLECTION_ROLE => 'Checkers::Role::Collection';
use constant DATE_ROLE => 'Checkers::Role::Date';
use constant FILE_ROLE => 'Checkers::Role::File';

our @columns = qw(id system date request_id group_name category check_name what of result comparison threshold status message supress);
has [@columns];

sub check { shift->check_name }

sub columns { [@columns] }

sub fail { shift->status eq 'ALERT' }

sub from_array { shift->new(_mesh(shift)) }

sub from_files ($class, $path) {
  _file($path)->list_tree->map(sub {
    my $date = Mojo::Date->with_roles(DATE_ROLE)->new($_->basename);
    return b(path($_)->slurp)->split("\n")->map(sub {
      $class->new(_mesh([$_->dirname->basename, $date, split /\t/]));
    });
  })->flatten;
}

sub from_hash { shift->new(_mesh(shift)) }

sub from_string ($class, $string, $delimiter="\t") {
  $class->new(_mesh([split $delimiter, $string]));
}

sub group { shift->group_name }

sub has_result { return length shift->result }

sub is ($self) {
  return 'above' if $self->comparison eq '-ge';
  return 'below' if $self->comparison eq '-le';
}

sub new {
  my $self = shift;
  return $self->SUPER::new({_mesh($_[0])}) if ref $_[0] eq 'HASH';
  return c(@{$_[0]})->map(sub{$self->from_hash($_)}) if ref $_[0] eq 'ARRAY';
  return $self->from_string(${$_[0]}, @_) if ref $_[0] eq 'SCALAR';
  return $self->SUPER::new if @_ && not defined $_[0];
  return $self->SUPER::new(@_);
}

sub not_info { shift->status ne 'INFO' }

sub of_check ($self) { join ' ', $self->of, $self->check_name }

sub pass { shift->status eq 'OK' }

#sub select ($self, $columns=undef, $delimiter="\t") {
#  $columns = c(map { $self->$_ // '' } $self->_columns($columns));
#  return $delimiter ? $columns->join($delimiter) : $columns;
#}

#sub to_array ($self, $columns=undef) { $self->select($columns, undef)->to_array }

sub to_files ($self, $collection, $path) {
  _collection($collection)
    ->with_roles('+Transform')
    ->grep(sub{$_->isa('Checkers::Record')})
    ->collect_by(sub { $_->system, $_->epoch })
    ->map(sub {
      my $system = $_->first->system;
      my $epoch = $_->first->epoch;
      _file($path)->child($system)->make_path->child($epoch)->spurt($_->join("\n"));
    });
    #return $self;
}

sub to_hash ($self, $columns=undef) { return {%$self{@$columns}} }

sub to_string ($self, $delimiter="\t") { join $delimiter, map { $self->{$_}||'' } @columns }

sub update ($self) {
  #%$self{@long_list} = map { $_ => _not_null($self->{$_}) } keys %$self{@long_list};
  my $date = Mojo::Date->with_roles(DATE_ROLE)->new($self->date || ());
  my $what = $self->can(lc('_'.$self->what)) || sub { 'UNDEFINED' };
  return $self->date($date)->status($what->());
}

##

sub _change ($self) { }

sub _collection ($obj=undef) {
  $obj = Mojo::Collection->new(ref $obj eq 'ARRAY' ? @$obj : $obj || ()) unless $obj->isa('Mojo::Collection');
  $obj = $obj->with_roles(COLLECTION_ROLE) unless $obj->DOES(COLLECTION_ROLE);
  return $obj;
}

sub _count { shift->_value }

sub _date ($obj=undef) {
  $obj = Mojo::Date->new($obj || ()) unless $obj->isa('Mojo::Date');
  $obj = $obj->with_roles(DATE_ROLE) unless $obj->DOES(DATE_ROLE);
  return $obj;
}

sub _file ($obj=undef) {
  $obj = Mojo::File->new($obj || ()) unless $obj->isa('Mojo::File');
  $obj = $obj->with_roles(FILE_ROLE) unless $obj->DOES(FILE_ROLE);
  return $obj;
}

sub _info ($self) { return 'INFO' }

sub _mesh ($obj) {
  if (ref $obj eq 'ARRAY') {
    @$obj = map { $_//'' } @$obj;
    return mesh @$obj, @columns if $#$obj == $#columns;
  }
  elsif (ref $obj eq 'HASH') {
    %$obj = map { $_ => $obj->{$_}//'' } keys %$obj;
    return %$obj if keys %$obj == $#columns + 1;
  }
  warn "Invalid list length\n";
  return ();
}

sub _not_null { shift || '' }

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
