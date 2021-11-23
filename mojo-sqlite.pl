$ENV{DBI_TRACE}='SQL';
use Checkers::Database;
use Mojo::Base -strict;
use Mojo::SQLite;
use SQL::Bind::Abstract;
 
# Select the library version
my $sql = Mojo::SQLite->new('sqlite:memory.db')->abstract('SQL::Bind::Abstract')->database_class('Checkers::Database');
my $db = $sql->db;
say $db->version;
$db->sqlite->migrations->name('my_names_app')->from_string(<<EOF)->migrate;
-- 1 up
CREATE TABLE checkers (id SERIAL PRIMARY KEY, system text, date integer, request_id text, group_name text, category text, check_name text, what text, of text, result integer, comparison text, threshold integer, status text, message text, suppress bool);
INSERT INTO checkers VALUES (null, 'system', strftime('%s','now'), 'ahjdd', 'group', 'category', 'value', 'disk', '/', 1, '-le', 3, 'OK', 'bah', 0);
INSERT INTO checkers VALUES (null, 'system', strftime('%s','now'), 'ahjdd', 'group', 'category', 'value', 'disk', '/', 1, '-le', 3, 'OK', 'bah', 0);
-- 1 down
DROP TABLE checkers;
EOF
#say Mojo::Util::dumper($db->query('select * from checkers where system="system"')->hash);
$db->select_where('system=:system group by system', system => 'system')->records->each(sub{say});
$db->select('checks');