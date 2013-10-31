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

my $mock_tar_name = 'MockModule-0.01.tar.gz';

my $app = Plack::Util::load_psgi 'script/orepan2-server.pl';

test_psgi
    app    => $app,
    client => sub {
        my $cb = shift;

        subtest 'CPAN::Uploader interface' => sub {
            my $res;
            stdout_like {
                $res = $cb->(POST "http://localhost/authenquery",
                    Content_Type => 'form-data',
                    Content      => +[
                        HIDDENNAME                  => 'hirobanex',
                        pause99_add_uri_httpupload  => ["./t/$mock_tar_name"]
                    ],
                );
            } qr/Wrote/,'orepan inject ?';

            is $res->code, 200, 'success request ?';
            ok -f $OREPAN2_SERVER_DELIVERY_DIR."/modules/02packages.details.txt.gz", 'is there 02packages.details.txt.gz ?';

            my @files = zglob($OREPAN2_SERVER_DELIVERY_DIR."/authors/**/$mock_tar_name");

            ok scalar @files, 'is there MockModule-0.01.tar.gz';
        };

    };

done_testing;

