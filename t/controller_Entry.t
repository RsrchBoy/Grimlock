use strict;
use warnings;
use Test::More;
use HTTP::Request::Common qw(DELETE PUT);
use Test::WWW::Mechanize::PSGI;
use FindBin qw( $Bin );
use lib "$Bin/../t/lib";
use Data::Dumper;
use Test::DBIx::Class qw(:resultsets);

BEGIN {
  $ENV{DBIC_TRACE} = 1;
  $ENV{CATALYST_CONFIG} = "t/grimlock_web_test.conf"
}
# must be AFTER this begin statement so that these env vars take root properly
use Grimlock::Web;

# create role records
fixtures_ok 'user'
  => 'installed the basic fixtures from configuration files';

my $mech = Test::WWW::Mechanize::PSGI->new(
  app =>  Grimlock::Web->psgi_app(@_),
  cookie_jar => {}
);

# try to create draft without auth
$mech->post('/entry',
  Content_Type => 'application/x-www-form-urlencoded',
  Content => {
    title => 'test',
    body => 'derp'
  }
);

ok !$mech->success, "doesn't work for unauthed users";

# create a post authed now
$mech->post('/user/login',
  Content_Type => 'application/x-www-form-urlencoded',
  Content => {
    name => 'herp',
    password => 'derp'
  }
);

BAIL_OUT "can't log in" unless $mech->success;

ok $mech->success, "logged in ok";

$mech->post('/entry',
 Content_Type => 'application/x-www-form-urlencoded',
  Content => {
    title => 'test title with spaces! <script>alert("and javascript!")</script>',
    body => 'derp',
    published => 1
  }
);

ok $mech->success, "POST worked";
$mech->get_ok('/test-title-with-spaces');
ok $mech->content_lacks('<script>alert("and javascript!")</script>'), "no scripts here";
ok $mech->content_contains("derp"), "content is correct";

$mech->post('/test-title-with-spaces/reply',
 Content_Type => 'application/x-www-form-urlencoded',
  Content => {
    title => 'reply test',
    body => 'derpen',
    published => 1
  }
);

$mech->post('/test-title-with-spaces/reply',
 Content_Type => 'application/x-www-form-urlencoded',
  Content => {
    title => 'reply test another test',
    body => 'derpen',
    published => 1
  }
);

ok $mech->success, "reply post works ok";

# stolen from https://metacpan.org/source/BOBTFISH/Catalyst-Action-REST-0.99/t/lib/Test/Rest.pm
#my $req = HTTP::Request->new( PUT => '/test-title-with-spaces' );
#$req->content_type( 'text/plain' );
#$req->content_length(do { use bytes; length( 'title=huehuehuehue' ) });
#$req->add_content('title=huehuehuehue');
$mech->put ('/test-title-with-spaces?title=huehuehue' );
ok $mech->success, "changing title works ok";
$mech->request( DELETE '/huehuehue' );
ok $mech->success, "entry deletion works";

done_testing();
