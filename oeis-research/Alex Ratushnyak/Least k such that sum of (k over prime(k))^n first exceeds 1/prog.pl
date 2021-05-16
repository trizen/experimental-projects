#!/usr/bin/perl

# a(n) is the least k such that Sum_{i=1..k} (i/prime(i))^n > 1.
# https://oeis.org/A343375

# Known terms:
#   2, 3, 6, 129, 107103, 19562634

# New terms:
#   a(7) = 2433065908

# Term a(7) double-checked with PARI/GP (took 1 hour to verify):
#   k = 2433065907 gives: 0.99999999993821766811733842990753602502
#   k = 2433065908 gives: 1.00000000017401085698940764192873576233

use 5.014;
use warnings;

use ntheory qw(:all);

my $k = 1;
my $n = 7;
my $sum = 0;

forprimes {

    $sum += exp((log($k) - log($_))*$n);

    if ($sum >= 1) {
        die "a($n) = $k (with p = $_)\n";
    }

    ++$k;

} 1e12;
