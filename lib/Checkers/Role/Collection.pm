package Checkers::Role::Collection;
use Mojo::Base -role, -signatures;

use Carp qw(croak);
use Mojo::Util qw(dumper);

our $VERSION = '0.01';
 
requires 'grep';

sub to_csv ($self, $labels=undef, $delimiter=undef) {
  $labels = _parse_labels($labels);
  $self->labels($labels)->map(to_csv => $delimiter // ())->grep(sub{length})->join("\n")
}

sub to_metrics ($self, $labels=undef, $delimiter=undef) {
  $labels = _parse_labels($labels);
  $labels->{group} //= [];
  $labels->{category} //= [];
  $labels->{name} //= [];
  $self->labels($labels)->map(to_metric => $delimiter // ())->grep(sub{length})->join("\n")
}

sub to_string ($self, $labels=undef, $delimiter=undef) {
  $labels = _parse_labels($labels);
  $self->labels($labels)->map(to_string => $delimiter // ())->grep(sub{length})->join("\n")
}

sub labels ($self, $labels=undef) {
  $labels = _parse_labels($labels);
  $self->grep(sub {
    my $record = $_;
    my $group = grep { lc($record->group) =~ lc($_) } @{$labels->{group}} if $labels->{group};
    my $category = grep { lc($record->category) =~ lc($_) } @{$labels->{category}} if $labels->{category};
    my $name = grep { lc($record->name) =~ lc($_) } @{$labels->{name}} if $labels->{name};
    return !grep { defined $_ && !$_ } ($group, $category, $name);
  });
}

sub _parse_labels ($labels='') {
  return $labels if ref $labels eq 'HASH';
  $labels //= '';
  my %labels = ();
  push @{$labels{$1}}, $2 =~ s/\+/ /gr while ($labels =~ s!([^/]+)/([^/]+)!!);
  return \%labels;
}

1;