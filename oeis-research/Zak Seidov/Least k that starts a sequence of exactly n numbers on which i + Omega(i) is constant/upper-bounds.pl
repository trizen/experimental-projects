#!/usr/bin/perl

# a(n) is the least k that starts a sequence of exactly n numbers on which i + Omega(i) is constant, where Omega = A001222.
# https://oeis.org/A369228

# Known terms:
#   1, 4, 45, 104, 71874, 392274, 305778473

# Upper-bounds:
#   a(8) <= 24405534712 (confirmed)

use 5.036;
use ntheory qw(:all);

my $p;
my $n = 9;

forprimes {

    $p = $_;

    if (is_almost_prime($n, $p - $n + 1) and is_almost_prime($n-1, $p - $n + 1 + 1) and vecall { is_almost_prime($n-$_, $p - $n + $_ + 1) } 2..($n-2)) {
         die "a($n) <= ", $_ - $n + 1;
    }

} 10, 1e12;
