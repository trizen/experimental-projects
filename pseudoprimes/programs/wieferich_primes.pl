#!/usr/bin/perl

# Wieferich primes: primes p such that p^2 divides 2^(p-1) - 1.
# https://oeis.org/A001220

# Known terms:
#   1093, 3511

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if (is_square($n) and is_pseudoprime($n, 2)) {
        next if $seen{$n}++;
        say sqrtint($n);
    }
}
