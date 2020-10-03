#!/usr/bin/perl

# Filter non-Carmichael numbers.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my %carmichael;

do {
    open my $fh, '<', 'large_carmichael.txt';

    while (<$fh>) {
        next if /^\h*#/;
        /\S/ or next;
        my $n = (split(' ', $_))[-1];
        $n || next;
        $carmichael{$n} = 1;
    }

    close $fh;
};

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];
    $n || next;
    say $n if not exists($carmichael{$n});
}
