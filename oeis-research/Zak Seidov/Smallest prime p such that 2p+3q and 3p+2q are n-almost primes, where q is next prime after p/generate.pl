#!/usr/bin/perl

# a(n) is the smallest prime p such that 2p+3q and 3p+2q are n-almost primes, where q is next prime after p.
# https://oeis.org/A335737

# Known terms:
#   5, 47, 139, 2521, 77269, 631459, 6758117, 33059357, 7607209367, 173030234371, 152129921851

use 5.036;
use ntheory qw(:all);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    my $n = $k;
    $A = vecmax($A, powint(2, $k));

    sub ($m, $p, $k) {

        if ($k == 1) {

            forprimes {

                my $v = $m*$_;

                my $pp = prev_prime(divint($v - 3, 5));
                my $qq = next_prime($pp);

                if (2*$pp + 3*$qq == $v and is_almost_prime($n, 3*$pp + 2*$qq)) {
                    $callback->($pp);
                }
            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(1, 3, $k);
}

my $n     = 8;
my $lo    = powint(2, $n);
my $hi    = 3 * $lo;
my $limit = 'inf' + 0;

while (1) {

    say "Sieving range: [$lo, $hi]";

    almost_prime_numbers(
        $lo, $hi,
        $n,
        sub ($k) {
            if ($k < $limit) {
                say "a(", $n, ") <= ", $k;
                $limit = $k;
            }
        }
    );

    last if ($hi > $limit);

    $lo = $hi + 1;
    $hi = 2 * $lo;
}
