#!/usr/bin/perl

# Palindromic Bruckman-Lucas pseudoprimes.
# https://oeis.org/A005845

# Known terms:
#   15251, 1625261, 14457475441

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    ($n eq reverse($n)) or next;
    (lucas_sequence($n, 1, -1, $n))[1] == 1 or next;

    next if $seen{$n}++;

    say $n;
}
