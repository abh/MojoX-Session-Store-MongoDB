use Test::More;

BEGIN {
    eval "use MongoDB";
    if ($@) {
        plan skip_all => "MongoDB is required to run this test";
    }
}

use FindBin qw/$Bin/;
use lib ($Bin . "/../../../lib");
plan tests => 13;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::MongoDB');

my $session = MojoX::Session->new(
    store => MojoX::Session::Store::MongoDB->new(
        {   host       => '127.0.0.1',
            collection => 'sessions',
            database   => 'test',
        }
    )
);

# create
ok(my $sid = $session->create(), 'create session');
ok($sid,              'got session id');
ok($session->flush(), 'flush');

# load
ok($session->load($sid), 'load session id');
is($session->sid, $sid, 'got sid back');

# update
ok($session->data(foo => 'bar'), 'setting data');
ok($session->flush,      'flushing');
ok($session->load($sid), 'loading again');
is($session->data('foo'), 'bar', 'foo is set right');

# delete
ok($session->expire, 'expire');

# the API is weird -- when expired flush just uses return;
$session->flush;
is($session->load($sid), undef, "get undef loading expired session");
