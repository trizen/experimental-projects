#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# These are numbers n such that sigma(n)-1 divides n*(tau(n)-1).

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

use 5.014;
use strict;

#use integer;

use ntheory qw(:all);

my $count = 0;

foreach my $k (2 .. 1e9) {

    my $p = divisor_sum($k) - 1;

    is_prime($p) || next;

    next if ($k == $p);
    my $m = mulint($k, $p);

    if (++$count >= 1e5) {
        say "Testing: $k -> $m";
        $count = 0;
    }

    if (modint(mulint($m, divisor_sum($m, 0) - 1), divisor_sum($m) - 1) == 0) {
        say "\tFound: $k -> $m";
    }
}
