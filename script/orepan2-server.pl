#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use OrePAN2::Server::CLI;
OrePAN2::Server::CLI->new(@ARGV)->run;

__END__

=head1 NAME

orepan2-server.pl - OrePAN2::Server launcher

=head1 SYNOPSIS

    % orepan2-server.pl [options]
        --delivery-dir=s     # a directory tar files of dist to be stored.       (Default: orepan)
        --delivery-paths     # URL path behaves as cpan-mirror                   (Default: /orepan)
        --authenquery-path=s # URL path of the dist uploader                     (Default: /authenquery)
        --compress-index     # 02packages.details.txt is to be compressed or not (Defualt: false)

=head1 DESCRIPTION

OrePAN2::Server launcher.
