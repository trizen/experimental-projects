#!/usr/bin/perl

# Semiprimes p*q with p <= q such that Sum_{primes r <= p} (q mod r) = q.
# https://oeis.org/A350735

# Known terms:
#   143, 169, 209, 1943, 8413, 11773, 288727, 292421, 544987, 1519381, 1798397, 3245527, 3506509, 4528499, 7043693, 9682711, 10476493, 11670493, 12603709, 16051433, 21499519, 21916327

# New terms found:
#   143, 169, 209, 1943, 8413, 11773, 288727, 292421, 544987, 1519381, 1798397, 3245527, 3506509, 4528499, 7043693, 9682711, 10476493, 11670493, 12603709, 16051433, 21499519, 21916327, 64595353, 68086903, 75022813, 81430093, 90537803, 134473993, 136693819, 146316323

# Extra terms:
#   159971521, 165217813, 175366019, 183773221,

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub isok ($p, $q) {
    my $sum = 0;
    for(my $r = 2; $r <= $p; $r = next_prime($r)) {
        $sum += $q % $r;
        return 0 if ($sum > $q);
    }
    return ($sum == $q);
}

local $| = 1;

forsemiprimes {
    my ($p, $q) = factor($_);

    if (isok($p, $q)) {
        print $_, ", ";
    }
} 1e10;
