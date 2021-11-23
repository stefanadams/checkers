package Checkers::Model::Checks;
use Mojo::Base -base, 'Checkers::Model::Base';

use Carp qw(croak);
use Mojo::File qw(curfile);

has name => sub { curfile->basename('.pm') };

sub a { croak 'Method "a" not implemented by subclass' }

sub z { croak 'Method "z" not implemented by subclass' }

1;