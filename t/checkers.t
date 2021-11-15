use Mojo::Base -strict;

use Checkers;
use Mojo::File qw(curfile tempdir);
use Role::Tiny;
use Test::More;

my $checkers = Checkers->new(path => curfile->sibling('checkers'));
isa_ok $checkers, 'Checkers';
isa_ok $checkers->path, 'Mojo::File';
is $checkers->records->size, 0;
ok Role::Tiny::does_role($checkers->path, 'Checkers::Role::File');
is $checkers->load('system1')->size, 12;
is $checkers->load('system2')->size, 12;
is $checkers->load->size, 12;
is $checkers->records->size, 12;
is $checkers->records->labels('/group/group2')->size, 6;
is $checkers->records->labels('/category/system/group/group2')->size, 4;
is $checkers->records->labels('/category/info/group/group1')->size, 1;

my $records = $checkers->load;
is $records->size, 12;
is $checkers->load->to_metrics('/group/group2/category/system/name/Disk')->size, 44;
is $checkers->load->to_metrics('/category/system/name/Disk')->size, 0;
is $checkers->load->to_csv('/group/group2/category/system/name/Disk')->size, 187;
is $checkers->load->to_csv('/category/system/name/Disk')->size, 375;
is $checkers->load->to_csv('/category/system')->size, 701;
is $checkers->load->to_csv->size, 1029;

#diag $checkers->load->tablify;

is $checkers->save($checkers->load->to_string => 'system3')->to_csv->size, 2059;
$checkers->path->remove_tree('system3');
done_testing;