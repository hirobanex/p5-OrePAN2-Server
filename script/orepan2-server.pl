#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Plack::Request;
use Plack::Builder;
use Plack::App::Directory;
use OrePAN2::Injector;
use OrePAN2::Indexer;
use File::Spec;
use File::Copy;
use Path::Class;
use File::Temp;

my $delivery_dir     = Path::Class::dir($ENV{OREPAN2_SERVER_DELIVERY_DIR}     || 'orepan');
my $delivery_path    = $ENV{OREPAN2_SERVER_DELIVERY_PATH}    || '/orepan';
my $authenquery_path = $ENV{OREPAN2_SERVER_AUTHENQUERY_PATH} || '/authenquery';

$delivery_dir->mkpath;

my $uploader = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
 
    local $@;
    if ($req->method eq 'POST') {
        eval {
            my ($module, $author);
 
            my $tempdir = File::Temp::tempdir( CLEANUP => 1 );
            if (my $upload = $req->upload('pause99_add_uri_httpupload')) {
                $module = File::Spec->catfile($tempdir, $upload->filename);
                File::Copy::move $upload->tempname, $module;
                $author = $req->param('HIDDENNAME');
            }
            else {
                $module = $req->param('module'); # can be a git repo.
                $author = $req->param('author') || 'DUMMY';
            }
 
            my $injector = OrePAN2::Injector->new(
                directory => $delivery_dir->stringify,
                author    => $author,
            );
            $injector->inject($module);
 
            OrePAN2::Indexer->new(directory => $delivery_dir->stringify)->make_index();
        };
    }
    if (my $err = $@) {
        [500, [], [$err.'']]
    }
    else {
        [200, [], ['OK']]
    }
};

builder {
    mount "$authenquery_path" => builder {$uploader};
    mount "$delivery_path"    => builder {  Plack::App::Directory->new({root=> $delivery_dir->stringify})->to_app };
};

