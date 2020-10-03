#!/usr/bin/perl

# Copyright (c) 2013 Daniel "Trizen" Șuteu

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 05 January 2013
# https://github.com/trizen

# Image to TEXT conversion.

use 5.010;
use strict;
use warnings;

use lib qw(.);
use Image2Text qw(get_text update_database);
use Getopt::Std qw(getopts);

my %opt;
getopts('fus', \%opt);

if ($opt{u}) {
    update_database();
}

foreach my $file (@ARGV) {
    next unless -f $file;

    my $extracted_text = get_text(
        $file,
        sub {
            my $row = shift;
            print "ROW: $row\n";
        }
    );

    $extracted_text =~ s{^\.+$}{}gm;
    $extracted_text =~ s{\w\K\s+\.}{.}g;
    $extracted_text =~ s{\w\K\s*,(?=\w\b)}{'}g;
    $extracted_text =~ s{\s\d+\K\s+(?=\.\d)}{}g;
    $extracted_text =~ s{''}{"}g;
    $extracted_text =~ s{,'}{"}g;
    $extracted_text =~ s{\s+[li]$}{!}gm;
    $extracted_text =~ s{\s+([,.])}{$1}g;

    print "\n\n";

    if ($opt{f}) {
        (my $text_file = $file) =~ s{\.\w+\z}{.txt};
        open my $fh, '>', $text_file;
        print {$fh} $extracted_text;
        close $fh;
    }
    else {
        print $extracted_text;
    }

    if ($opt{s}) {
        system 'espeak', $extracted_text;
    }
}
