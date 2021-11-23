package SQL::Bind::Abstract;
use Mojo::Base -base, -signatures;

#use SQL::Bind qw(sql);

sub sql { SQL::Bind::sql(@_) }

1;