#!/usr/bin/perl

# Find the smallest Lucas-Carmichael numbers that is a multiple of a given integer.
# See also: https://oeis.org/A253598

use 5.020;
use ntheory qw(:all);

my @list = (5);

foreach my $p (grep { gcd($_, $list[0]) == 1 } @{primes(36739)}) {

    my @new;

    say "# [$#list] Prime: $p";

    foreach my $n (@list) {
        my $t = $n*$p;
        if ($t < 1e18) {
            if (gcd($t, divisor_sum($t)) == 1) {
                push @new, $t;
                if (vecall { ($t+1) % ($_+1) == 0 } factor($t)) {
                    say $t;
                }
            }
        }
    }

    push @list, @new;
}
