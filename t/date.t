use Mojo::Base -strict;

use Test::More;

use Mojo::Date;
use Mojo::File qw(tempdir);

my $date = Mojo::Date->new;
isa_ok $date, 'Mojo::Date';
$date = $date->with_roles('Checkers::Role::Date');
isa_ok $date, 'Mojo::Date';
like $date, qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$/;
like $date->new($date->epoch), qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$/;

done_testing;