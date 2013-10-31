use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use Plack::Util;
use File::Temp;
use File::Zglob;
use HTTP::Request::Common;
use Test::Output;

my $OREPAN2_SERVER_DELIVERY_DIR = File::Temp::tempdir(CLEANUP => 1);
$ENV{OREPAN2_SERVER_DELIVERY_DIR} = $OREPAN2_SERVER_DELIVERY_DIR;

my $app = Plack::Util::load_psgi 'script/orepan2-server.pl';

test_psgi
    app    => $app,
    client => sub {
        my $cb = shift;

        subtest 'git interface' => sub {
            plan skip_all =>  'this test is not Implementation because git stub method unkown. Perhaps see GitDDL test';

            my $res = $cb->(POST "http://localhost/authenquery",
                Content      => +[
                    module => 'git@github.com:Songmu/p5-App-RunCron.git',
                ],
            );

            is $res->code, 200, 'success request ?';
            ok -f $OREPAN2_SERVER_DELIVERY_DIR."/modules/02packages.details.txt.gz", 'is there 02packages.details.txt.gz ?';

            my @files = zglob($OREPAN2_SERVER_DELIVERY_DIR."/authors/**/*.tar.gz");

            ok scalar @files, 'is there MockModule-0.01.tar.gz';
        };

    };

done_testing;

