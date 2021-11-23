package Checkers::Util;
use Mojo::Base -strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mesh);

sub mesh (\@\@;\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@)
{
  my $max = -1;
  $max < $#$_ && ($max = $#$_) foreach @_;
  ## no critic (BuiltinFunctions::ProhibitComplexMappings)
  return map {
    my $ix = $_;
    ## no critic (BuiltinFunctions::RequireBlockMap)
    map $_->[$ix], @_;
  } 0 .. $max;
}

1;
