#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 August 2022
# https://github.com/trizen

# Generate all the Lucas-Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub lucas_carmichael_numbers_in_range ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            printf("# $m -> ($u, $v) -> 10^%.3f\n", log($v-$u)/log(10))  if ($v - $u > 2e6);

            if ($v-$u > 1e10) {
                die "Range too large!\n";
            }

            foreach my $p (@{primes($u, $v)}) {
                my $t = mulint($m, $p);
                if (modint($t+1, $lambda) == 0 and modint($t+1, $p+1) == 0) {
                    $callback->($t);
                }
            }

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for (my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);
            my $t = mulint($m, $p);
            my $L = lcm($lambda, $p+1);

            ($p >= 3 and gcd($L, $t) == 1) or next;

            # gcd($t, divisor_sum($t)) == 1 or die "$t: not Lucas-cyclic";

            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(1, 1, 3, $k);
}

my $min_k = 10;                 # mininum number of prime factors
my $max_k = 1e4;                # maxinum number of prime factors

#my $from  = 1;                  # generate terms >= this
#my $upto  = 196467189590024639; # generate terms <= this

# Generate terms in this range
my $from  = 3614740529402519;
my $upto  = 20576473996736735;

foreach my $k ($min_k .. $max_k) {

    last if pn_primorial($k) > $upto;

    say "# Generating with k = $k";

    lucas_carmichael_numbers_in_range($from, $upto, $k, sub ($n) { say $n });
}
