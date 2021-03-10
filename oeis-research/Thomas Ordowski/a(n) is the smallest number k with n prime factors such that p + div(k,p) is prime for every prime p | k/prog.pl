#!/usr/bin/perl

# a(n) is the smallest number k with n prime factors such that p + k/p is prime for every prime p | k.
# https://oeis.org/A294925

# Known terms:
#    2, 6, 30, 210, 15810, 292110, 16893030, 984016110, 17088913842, 2446241358990, 1098013758964122

# Upper-bounds:
#   a(11) <= 1716039298403430

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub squarefree_almost_primes ($A, $B, $k) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                if (modint($m, $_)) {

                    my $n = mulint($m, $_);

                    if (vecall { is_prime(addint($_, divint($n, $_))) } factor($n)) {
                        say $n;
                    }
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        while ($p <= $s) {

            if (modint($m, $p) == 0) {
                $p = next_prime($p);
                next;
            }

            my $t = mulint($m, $p);
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            # Optional optimization for tight ranges
            if ($u > $v) {
                $p = next_prime($p);
                next;
            }

            $u = $p if ($k==2 && $p>$u);

            __SUB__->($t, $p, $k - 1, $u, $v);
            $p = next_prime($p);
        }
    }->(1, 2, $k);

    return;
}

#~ my $k = 10;
#~ my $from = 1;
#~ my $upto = 2446241358990*2;

my $k    = 12;
my $from = 1;
my $upto = 912530181633450280;

squarefree_almost_primes($from, $upto, $k);
