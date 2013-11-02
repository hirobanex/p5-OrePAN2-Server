package OrePAN2::Server;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use File::Copy ();
use File::Spec;
use File::Temp ();
use Plack::Request;
use OrePAN2::Injector;
use OrePAN2::Indexer;

sub uploader {
    my ($class, %args) = @_;
    my $directory   = $args{directory};
    my $no_compress = $args{no_compress};

    return sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        return [404, [], ['NOT FOUND']] if $req->path_info !~ m!\A/?\z!ms;

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
                return [404, [], ['NOT FOUND']] if !$module && !$author;

                my $injector = OrePAN2::Injector->new(
                    directory => $directory,
                    author    => $author,
                );
                $injector->inject($module);

                OrePAN2::Indexer->new(directory => $directory)->make_index(
                    no_compress => $no_compress,
                );
            };

            if (my $err = $@) {
                return [500, [], [$err.'']]
            }
        }

        return [200, [], ['OK']]
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

OrePAN2::Server - It's new $module

=head1 SYNOPSIS

    use OrePAN2::Server;

=head1 DESCRIPTION

OrePAN2::Server is ...

=head1 LICENSE

Copyright (C) Hiroyuki Akabane.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hiroyuki Akabane E<lt>hirobanex@gmail.comE<gt>

=cut

