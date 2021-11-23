package Checkers::Role::File;
use Mojo::Base -role, -signatures;

use Carp qw(croak);
use Checkers::Record;
use Mojo::ByteStream qw(b);
use Mojo::Date;
use Mojo::File qw(path);

use constant COLLECTION_ROLE => 'Checkers::Role::Collection';
use constant DATE_ROLE => 'Checkers::Role::Date';

our $VERSION = '0.01';
 
requires 'path';

# sub remove ($self, $system, $tail) {
#   path($self)->child($system)->list->sort->tail($tail)->map('remove')->remove;
# }

# sub remove_tree ($self, $system) { path($self)->child($system)->remove_tree }

# sub spurt ($self, $chunk, $system, $date=undef) {
#   my $path = $self->child($system)->make_path->child(Mojo::Date->new($date // ())->epoch);
#   path($path)->spurt($chunk);
#   return $path;
# }

# sub slurp ($self) {
#   my $system = $self->dirname->basename;
#   my $datetime = Mojo::Date->new($self->basename // ())->with_roles(DATE_ROLE);
#   b(path($self)->slurp)->split("\n")
#     ->with_roles(COLLECTION_ROLE)
#     ->map(sub { Checkers::Record->new($system, $datetime, split /\t/) })
# }

# sub slurp2 ($self) {
#   my $date = Mojo::Date->with_roles(DATE_ROLE)->new($self->basename);
#   b(path($self)->slurp)->split("\n")->map(sub {
#     Checkers::Record->new($self->dirname->basename, $date, split /\t/);
#   });
# }

1;