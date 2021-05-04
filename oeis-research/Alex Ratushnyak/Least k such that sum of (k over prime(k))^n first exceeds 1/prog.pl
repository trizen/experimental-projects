#!/usr/bin/perl

# a(n) is the least k such that Sum_{i=1..k} (i/prime(i))^n > 1.
# https://oeis.org/A343375

# Known terms:
#   2, 3, 6, 129, 107103, 19562634

# New terms:
#

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
