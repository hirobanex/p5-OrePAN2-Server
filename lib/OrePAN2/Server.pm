package OrePAN2::Server;
use 5.008001;
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
    my $directory      = $args{directory} || 'orepan';
    my $compress_index = 1;
    $compress_index = $args{compress_index} if exists $args{compress_index};

    return sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        return [404, [], ['NOT FOUND']] if $req->path_info !~ m!\A/?\z!ms;

        if ($req->method eq 'POST') {
            eval {
                my ($module, $author);

                my $tempdir = File::Temp::tempdir( CLEANUP => 1 );
                if (my $upload = $req->upload('pause99_add_uri_httpupload')) {
                    # request from CPAN::Uploader
                    $module = File::Spec->catfile($tempdir, $upload->filename);
                    File::Copy::move $upload->tempname, $module;
                    $author = $req->param('HIDDENNAME');
                }
                else {
                    $module = $req->param('module'); # can be a git repo.
                    $author = $req->param('author') || 'DUMMY';
                }
                return [404, [], ['NOT FOUND']] if !$module && !$author;
                $author = uc $author;

                my $injector = OrePAN2::Injector->new(
                    directory => $directory,
                    author    => $author,
                );
                $injector->inject($module);

                OrePAN2::Indexer->new(directory => $directory)->make_index(
                    no_compress => !$compress_index,
                );
            };

            if (my $err = $@) {
                warn $err . '';
                return [500, [], [$err.'']];
            }
        }

        return [200, [], ['OK']];
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

OrePAN2::Server - BackAPN Server

=head1 SYNOPSIS

    % orepan2-server.pl

=head1 DESCRIPTION

OrePAN2::Server is BackPAN Server, or L<OrePAN2> uploader.

Like uploading to cpan, you can upload to your orepan2 by http post request.

If you set your BackPAN url in options(L<cpanm> --mirror, L<carton> PERL_CARTON_MIRROR env), you can easily install and manage your modules in your project.

=head1 SEE ALSO

L<orepan2-server.pl>, L<OrePAN2>, L<Minilla>

=head1 LICENSE

Copyright (C) Hiroyuki Akabane.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hiroyuki Akabane E<lt>hirobanex@gmail.comE<gt>

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

