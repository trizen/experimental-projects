#!/usr/bin/perl

# Find the smallest Lucas-Carmichael numbers that is a multiple of a given integer.
# See also: https://oeis.org/A253598

use 5.020;
use ntheory qw(:all);

my @list = (471);

foreach my $p(grep {gcd($_, $list[0]) == 1} @{primes(36739)}) {

    my @new = @list;

    say "[$#new] Prime: $p";
    foreach my $n(@list) {
        my $t = $n*$p;
        if ($t <= 4131709859199) {
            if (gcd($p+1, $t) == 1) {
                my @factors = factor($t);
                if (vecall { gcd($t, $_+1) == 1 } @factors) {
                    push @new, $t;
                    if (vecall { ($t+1) % ($_+1) == 0 } @factors) {
                        say $t;
                    }
                }
            }
        }
    }

    @list = @new;
}
