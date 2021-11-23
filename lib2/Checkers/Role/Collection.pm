package Checkers::Role::Collection;
use Mojo::Base -role, -signatures;

use Carp qw(croak);
use Checkers::Summary;
use Mojo::Util qw(dumper md5_sum url_unescape);
use Mojolicious::Routes::Pattern;

our $VERSION = '0.01';
 
requires 'grep';

sub dump ($self, $dump=1) { $self->tap(sub { warn dumper $_ }) if $dump; $self }
sub dump_size ($self, $dump=1) { $self->tap(sub { warn $_->size }) if $dump; $self }

sub filter ($self, $filter={}, $comparison='re') {
  $self->grep(sub {
    my $record = $_;
    my @checks = ();
    my @attr = qw(system datetime group category check of status);
    foreach my $attr (@attr) {
      push @checks, scalar grep {
        defined $_ &&
        $comparison eq 'eq' ? lc($record->$attr) eq lc($_) : lc($record->$attr) =~ lc($_)
      } @{$filter->{$attr}} if exists $filter->{$attr} && scalar @{$filter->{$attr}};
    }
    return scalar(grep { $_ } @checks) == scalar(@checks);
  })->sort;
}

sub fail ($self, $last_fail) {
  my $ids = $self->summarize->flatten->dump(0)->reduce(sub { $a->{$b->md5_sum} = $b if $b->fail; $a }, {});
  my %ids = (map { $_ => 1 } sort keys %$ids);
  my %last_ids = (map { $_ => 1 } sort @{$last_fail->{fail}->{all_ids}});
  delete $last_ids{$_} and delete $ids{$_} foreach keys %ids;
  return {
    alert => {
      new_id => join(',', sort keys %ids),
      current_id => join(',', sort keys %$ids),
      total => scalar(keys %ids),
    },
    fail => {
      new => [map { {system => $ids->{$_}->system, datetime => $ids->{$_}->datetime->epoch, records => $ids->{$_}} } keys %ids],
      new_ids => [keys %ids],
      all => [map { {system => $ids->{$_}->system, datetime => $ids->{$_}->datetime->epoch, records => $ids->{$_}} } keys %$ids],
      all_ids => [map { $ids->{$_}->md5_sum } keys %$ids],
      total => $self->summarize->flatten->reduce(sub { $a + $b->fail }, 0),
    },
    total => $self->summarize->flatten->reduce(sub { $a + $b->not_info }, 0),
  };
}

sub query ($self, $filter=undef) {
  $self
    ->summarize($filter)
    ->map(sub { $_->with_roles('+Transform')->collect_by(sub { $_->check }) })
}

sub summarize ($self, $filter=undef) {
  $filter = _parse_filter($filter);
  $self
    ->filter($filter)
    ->collect_by(sub { $_->system })
    ->map(sub {
      $_
        ->with_roles('+Transform')
        ->collect_by(sub { $_->datetime->epoch } )
        ->sort(sub { $b->first->datetime->epoch <=> $a->first->datetime->epoch })
        #->tap(sub{$_->flatten->map(sub{warn sprintf "%s / %s\n", $_->system, $_->datetime->epoch}) })
        ->first
    })
    ->flatten
    ->with_roles('+Transform')
    ->collect_by(sub { $_->category })
    ->with_roles('Checkers::Role::Collection', '+Transform')
}

sub to_hash ($self, $filter=undef) {
  $filter = _parse_filter($filter);
  $self->dump(0)->filter($filter)->dump(0)->hashify(sub { @$_{qw(group category check of)} }, sub { return {%$_} });
}

sub to_csv ($self, $filter=undef, $delimiter=undef) {
  $filter = _parse_filter($filter);
  $self->filter($filter)->map(to_csv => $delimiter // ())->grep(sub{length})->join("\n")
}

sub to_metrics ($self, $system, $group, $category, $check, $of, $delimiter=undef) {
  my $filter = {system => [$system], group => [$group], category => [$category], check => [$check], of => [$of]};
  $self->dump_size(0)->filter($filter, 'eq')->dump_size(0)->map(to_metric => $delimiter // ())->grep(sub{length})->join("\n")
}

sub to_records ($self, $filter=undef, $keys=[qw(group category check of)]) {
  $filter = _parse_filter($filter);
  $self->filter($filter)->hashify(sub { @$_{@$keys} }, sub { $_ });
}

sub to_string ($self, $filter=undef, $delimiter=undef) {
  $filter = _parse_filter($filter);
  $self->filter($filter)->map(to_string => $delimiter // ())->grep(sub{length})->join("\n")
}

sub _parse_filter ($filter='') {
  return $filter if ref $filter eq 'HASH';
  $filter //= '';
  my %filter = ();
  push @{$filter{url_unescape($1)}}, url_unescape($2) =~ s/\+/ /gr while ($filter =~ s!([^/]+)/([^/]*|$)/?!!);
  return \%filter;
}

1;