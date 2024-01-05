#!/usr/bin/perl

# a(n) is the first prime p such that, if q are r are the next two primes, p + r, p + q, q + r and p + q + r all have n prime divisors, counted with multiplicity.
# https://oeis.org/A368786

# Known terms:
#   1559, 4073, 45863, 1369133, 82888913, 754681217

use 5.036;
use ntheory qw(:all);

my $n = 9;

my $from = 1;
my $upto = 2;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n, $from, $upto);

    foreach my $k (@$arr) {

        my $p = prev_prime(($k >> 1) + 1);
        my $r = next_prime($p);

        if ($p + $r == $k) {
            my $q = next_prime($r);
            if (is_almost_prime($n, $p + $q) and is_almost_prime($n, $q + $r) and is_almost_prime($n, $p + $q + $r)) {
                die "a($n) = $p\n";
            }
        }
    }

    $from = $upto + 1;
    $upto = int(1.5 * $from);
}
