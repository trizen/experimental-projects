#!/usr/bin/perl

# Strong pseudoprimes n to base 2 such that n-2 and n+2 are primes.
# https://oeis.org/A230485

# Known terms:
#   3465253618401, 44202753561285411, 1640293473202755801, 10623546148468360251

use 5.020;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(is_strong_pseudoprime addint subint is_prob_prime);

my %seen;

while (<>) {

    /\S/ or next;
    next if /^#/;

    my $n = (split(' ', $_))[-1];

    $n || next;

    is_strong_pseudoprime($n, 2) || next;

    if (is_prob_prime(subint($n, 2)) and is_prob_prime(addint($n, 2))) {
        say $n if !$seen{$n}++;

        if ($n > ~0) {
            die "Found new term: $n";
        }
    }
}
