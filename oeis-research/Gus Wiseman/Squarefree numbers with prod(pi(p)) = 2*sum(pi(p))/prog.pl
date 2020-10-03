#!/usr/bin/perl

# Squarefree numbers whose product of prime indices is twice their sum of prime indices.
# https://oeis.org/A326157

# Known terms:
#   65, 154, 190

use 5.014;
use ntheory qw(:all);

my @lookup;     # prime count lookup table

do {
    my $count = 1;

    forprimes {
        $lookup[$_] = $count;
        ++$count;
    } 1e7;
};

forsquarefree {
    if (!is_prime($_)) {

        my @pi = map { $lookup[$_] // prime_count($_) } factor($_);

        if (vecprod(@pi) == 2 * vecsum(@pi)) {
            say $_;
        }
    }
} 1e7;
