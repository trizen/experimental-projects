#!/usr/bin/perl

use 5.014;
use Math::Prime::Util::GMP qw(factor);

my %factors;

while(<>) {
    if (/^(\d+)\s+(\d+)/) {
        my ($n, $k) = ($1, $2);
        warn "Factoring: $k\n";
        @factors{factor($k)} = ();
    }
}

say for sort { $a <=> $b } keys %factors;
