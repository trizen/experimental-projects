#!/usr/bin/perl

# XOR two or more files together into one file.

use 5.014;
use strict;
use warnings;

my $data = '';

foreach my $file (@ARGV) {

    my $content = do {
        open my $fh, '<:raw', $file
          or die "Can't open <<$file>>: $!";
        local $/;
        <$fh>;
    };

    $data ^= $content;
}

binmode(STDOUT, ':raw');
print $data;
