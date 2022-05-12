#!/usr/bin/perl

# Numbers k such that the k-th triangular number mod the sum (with multiplicity) of prime factors of k, and the k-th triangular number mod the sum of divisors of k, are the same prime
# https://oeis.org/A353002

# Known terms:
#   93, 2653, 30433, 1922113, 15421122, 28776673, 240409057, 611393953

# New terms found:
#   2713190397, 5413336381

# No other terms < 6074000999.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

local $| = 1;

my $from = 611393953-10;
my $triangle = mulint($from, $from+1)>>1;

forfactored {

    $triangle = addint($triangle, $_);

    my $p = modint($triangle, vecsum(@_));

    if (is_prime($p) and (modint($triangle, divisor_sum($_)) == $p)) {
        print $_, ", ";
    }

} $from+1, 1e10;
