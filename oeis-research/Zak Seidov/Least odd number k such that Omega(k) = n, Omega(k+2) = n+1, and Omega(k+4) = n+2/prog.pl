#!/usr/bin/perl

# a(n) is the least odd number k such that Omega(k) = n, Omega(k+2) = n+1, and Omega(k+4) = n+2, where Omega(k) is the number of prime factors of k (A001222).
# https://oeis.org/A335496

# Known terms:
#   23, 871, 5423, 229955, 13771373, 558588875, 21549990623, 1325878234371

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

my $n    = 9;
my $from = 1325878234371;
my $to   = $from * 200;

foralmostprimes {

    if ($_ % 2) {
        if (is_almost_prime($n + 1, $_ - 2) and is_almost_prime($n, $_ - 4)) {
            die "Found: a($n) = ", $_ - 4;
        }
    }

} $n + 2, $from, $to;
