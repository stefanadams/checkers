use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojo::ByteStream qw(b);
use Mojo::File qw(curfile tempdir tempfile);
use Mojo::Util qw(dumper);

my $t = Test::Mojo->new(curfile->dirname->sibling('checkers-server') => {db => curfile->sibling('checkers')});
$t->app->mode('test');
#$t->get_ok('/')->status_is(200);
$t->get_ok('/metrics?group=1&group=2&of=3')->status_is(200);
#$t->get_ok('/metrics' => {'accept' => 'application/json'})->status_is(200);

diag $t->tx->res->body;
done_testing;

__END__
sub _system { $t->app->checkers->system(hostname => $hostname) };
$t->post_ok('/metrics')->status_is(404);
$t->post_ok("/metrics/$hostname" => {Date => Checkers::Date->new} => form => {checkers => {file => "$snapshot_file"}})->status_is(200)->content_is('ok');
$t->post_ok("/metrics/$hostname" => {Date => Checkers::Date->new(time-10)} => form => {checkers => {file => "$snapshot_file"}})->status_is(200)->content_is('ok');
is _system->snapshots->size, 2;
is _system->snapshots->first->records->size, 3;
$t->delete_ok("/metrics/$hostname")->status_is(200);
is _system->snapshots->size, 1;
$t->delete_ok("/metrics/$hostname")->status_is(200);
is _system->snapshots->size, 0;
$t->delete_ok("/metrics/$hostname")->status_is(404);
is _system->snapshots->size, 0;
$t->get_ok("/metrics/$hostname")->status_is(404);
$t->post_ok("/metrics/$hostname" => form => {checkers => {file => curfile->sibling('data/sample1')->to_string}})->status_is(200)->content_is('ok');
$t->get_ok("/metrics/$hostname" => {Accept => 'text/csv'})->status_is(200)
  ->content_like(qr/Public IP/)
  ->content_like(qr/MB RAM Used/)
  ->content_like(qr/GB RAM Free/);
b($t->tx->res->text)
  ->split("\n")->map(sub{scalar split /\t/, $_, -1})
  ->tap(sub{is $_->size, 3, "right number of records"})
  ->each(sub{is $_, 11, 'right number of fields'});
b($t->tx->res->text)
  ->split("\n")->map(sub{scalar split /\t/, $_, -1})
  ->tap(sub{is $_->size, 3, "right number of records"})
  ->each(sub{is $_, 11, 'right number of fields'});
$t->get_ok("/metrics/$hostname" => {Accept => 'application/octet-stream'})->status_is(200)
  ->content_unlike(qr/Public IP/)
  ->content_unlike(qr/MB RAM Used/)
  ->content_unlike(qr/GB RAM Free/)
  ->content_like(qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t\d+/);
b($t->tx->res->text)
  ->split("\n")->map(sub{scalar split /\t/, $_, -1})
  ->tap(sub{is $_->size, 2, "right number of records"})
  ->each(sub{is $_, 2, 'right number of fields'});
$t->get_ok("/metrics/$hostname/category/System" => {Accept => 'text/csv'})->status_is(200)
  ->content_unlike(qr/Public IP/)
  ->content_like(qr/MB RAM Used/)
  ->content_like(qr/GB RAM Free/);

#diag $t->tx->res->body;
done_testing();
