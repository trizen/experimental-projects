#!/usr/bin/perl

# a(n) is the least k that starts a sequence of exactly n numbers on which i + Omega(i) is constant, where Omega = A001222.
# https://oeis.org/A369228

# Known terms:
#   1, 4, 45, 104, 71874, 392274, 305778473

# New terms:
#   a(8) = 24405534712

use 5.036;
use ntheory qw(:all);

sub find_upper_bound ($n, $N, $max) {

    my $lo = 2;
    my $hi = 2 * $lo;

    while (1) {

        return $max if ($lo > $max);

        foreach my $k (@{almost_primes($n, $lo, $hi)}) {
            if (is_almost_prime($n - 1, $k + 1) and is_almost_prime($n - 2, $k + 2) and vecall { is_almost_prime($n - $_, $k + $_) } 3 .. ($N - 1)) {
                return $k;
            }
        }

        $lo = $hi + 1;
        $hi = int(1.01 * $lo);
    }

    return $max;
}

my $N   = 9;
my $max = ~0;

for (my $n = $N ; $n <= 100 ; ++$n) {
    my $new = find_upper_bound($n, $N, $max);
    if ($new < $max) {
        say "[$n] a($N) <= $new";
        $max = $new;
    }
}
