#!/usr/bin/perl

# Try to find Fermat pseudoprimes P such that (P-1)/2 is prime.

# No such pseudoprimes should exist.

use 5.020;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(is_pseudoprime is_prob_prime subint divint);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    is_pseudoprime($n, 2) || next;

    if (is_prob_prime(divint(subint($n, 1), 2))) {
        say $n;
    }
}
