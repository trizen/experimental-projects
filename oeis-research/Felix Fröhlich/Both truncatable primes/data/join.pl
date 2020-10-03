#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

my @files = sort glob("*.txt");

#say for @files;

my $k = 3;
open my $out_fh, '>', 'output.txt';

foreach my $file(@files) {

    /\b\d+\.txt\z/ or next;

    open my $fh, "<", $file;
    while (<$fh>) {
        chomp($_);
        say $out_fh "$k $_";
        ++$k;
    }
    close $fh;
}

close $out_fh;
say "Total records: ", $k-1;
