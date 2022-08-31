#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 28 August 2022
# https://github.com/trizen

# Generate all the squarefree Fermat pseudoprimes to given a base with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
#use Math::GMP qw(:constant);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x,$y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    my $max_p = 30000;
    my $m = 1;
    my $L = znorder($base, $m);

    $A = $A*$m;
    $B = $B*$m;

    $A = vecmax($A, pn_primorial($k));

   # $A = Math::GMP->new("$A");
   # $B = Math::GMP->new("$B");

    $B = vecmin($B, 18436227497407654507);

    if ($A > $B) {
        return;
    }

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

         #   $v = vecmin($v, $max_p);

            say "# Sieving: $m -> ($u, $v)" if ($v - $u > 2e6);

            if ($v-$u > 1e10) {
                die "Range too large!\n";
            }

            forprimes {
                if ($_%80 == 3) {
                    my $t = $m*$_;
                    if (($t-1)%$lambda == 0 and ($t-1)%znorder($base, $_) == 0) {
                        $callback->($t);
                    }
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B,$m), $k);

        for(my $r; $p <= $s; $p = $r) {

            #last if ($p > $max_p);

            $r = next_prime($p);

            $p % 80 == 3 or next;

            if ($base % $p == 0) {
                next;
            }

            if ($m%$p == 0) {
                next;
            }
            my $z = znorder($base, $p);
           # is_smooth($z, 200) || next;

            my $L = lcm($lambda, $z);

            gcd($L, $m) == 1 or next;

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = divint($B,$t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->($m, $L, 3, $k);

    return 1;
}

my $base = 2;
my $from = 2;
my $upto = 2*$from;

while (1) {

    say "# Range: ($from, $upto)";

    foreach my $k (3,5) {
        fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) { say $n }) or next;
    }

    $from = $upto+1;
    $upto = 2*$from;
}
