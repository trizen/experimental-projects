#!/usr/bin/perl

# Least k such that phi(k) is an n-th power when k is the product of n distinct primes.
# https://oeis.org/A281069

# Known terms:
#   2, 10, 30, 3458, 29526, 5437705, 91604415, 1190857395, 26535163830, 344957129790

# New upper-bounds:
#   a(14) <= 33110689978317405605970
#   a(15) <= 1262838284613442604484690

use 5.036;
use ntheory qw(:all);
#use Math::AnyNum qw(:overload);
use Math::GMPz;

my $P_smooth = 5;

sub squarefree_almost_primes ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    my $n = $k;

    sub ($m, $lo, $k) {

        my $hi = rootint(divint($B, $m), $k);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            $lo = vecmax($lo, cdivint($A, $m));

            if ($lo > $hi) {
                return;
            }

            my $t;

            forprimes {
                $t = $m * $_;
                if (is_smooth($_-1, $P_smooth) and is_power(euler_phi($t), $n)) {
                    $callback->($t);
                }
            } $lo, $hi;

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {
            is_smooth($p-1, $P_smooth) || next;
            __SUB__->($m * $p, $p + 1, $k - 1);
        }
      }
      ->(Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    my $lo = Math::GMPz->new(2);
    my $hi = 2 * $lo;

    my $min = 'inf';

    while (1) {

        squarefree_almost_primes(
            $lo, $hi, $n,
            sub ($k) {
                if ($k < $min) {
                    #say "a($n) <= $k";
                    $min = $k;
                }
            }
        );

        last if $min < 'inf';

        $lo = $hi + 1;
        $hi = 2 * $lo;
    }

    return $min;
}

for my $n (1 .. 20) {
    say "a($n) <= ", a($n);
}
