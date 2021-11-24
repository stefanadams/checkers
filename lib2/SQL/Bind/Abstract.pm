package SQL::Bind::Abstract;
use Mojo::Base -base, -signatures;

use SQL::Bind qw();

sub sql { shift; SQL::Bind::sql(@_) }

1;