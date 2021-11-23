package Checkers::Role::Date;
use Mojo::Base -role, -signatures;
use overload '""' => sub { shift->to_datetime }, fallback => 1;

use Carp qw(croak);
use Mojo::Util qw(dumper);
use Time::Piece;

our $VERSION = '0.01';
 
requires 'epoch';

sub to_datetime { localtime(Time::Piece->strptime(shift->to_string)->epoch)->strftime('%F %T') }

1;