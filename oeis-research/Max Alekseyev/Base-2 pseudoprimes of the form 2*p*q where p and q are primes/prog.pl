#!/usr/bin/perl

# Base-2 pseudoprimes of the form 2*p*q where p and q are primes
# https://oeis.org/A296117

# Known terms:
#   161038, 49699666, 760569694, 4338249646, 357647681422, 547551530002, 3299605275646, 22999986587854, 42820164121582, 55173914702146, 69345154539266, 353190859033982

use 5.036;
use ntheory qw(:all);

use Math::GMPz;

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub even_squarefree_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    if ($k <= 1) {
        return;
    }

    sub ($m, $L, $lo, $k) {

        my $hi = rootint(divint($B, $m), $k);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            $lo = vecmax($lo, divceil($A, $m));
            $lo > $hi && return;

            my $t = invmod($m, $L);
            $t > $hi && return;
            $t += $L while ($t < $lo);

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if (is_prime($p)) {
                    if (($m*$p - 1) % znorder($base, $p) == 0) {
                        $callback->($m*$p);
                    }
                }
            }

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;

            my $z = znorder($base, $p);
            gcd($m, $z) == 1 or next;

            __SUB__->($m * $p, lcm($L, $z), $p + 1, $k - 1);
        }
      }
      ->(2, 1, 3, $k-1);
}

my $k = 3;
my $from = 1;
my $upto = pn_primorial($k);
my $base = 2;

while (1) {

    say "Sieving: [$from, $upto]";

    even_squarefree_fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) { say "New term: $n"; });

    $from = $upto+1;
    $upto = 3*$from;
}
