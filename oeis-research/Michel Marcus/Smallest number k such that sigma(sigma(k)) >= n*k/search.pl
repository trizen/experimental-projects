#!/usr/bin/perl

# a(n) is the least integer such that sigma(sigma(k)) >= n*k where sigma is A000203, the sum of divisors.
# https://oeis.org/A327630

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

my $n = 1;
for my $k (1 .. 1e10) {
    while (divisor_sum(divisor_sum($k, 1)) >= $k * $n) {
        say "a($n) = $k";
        ++$n;
    }
}
