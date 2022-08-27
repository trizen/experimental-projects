#!/usr/bin/perl

# a(n) is the smallest k with n prime factors such that p^k == p (mod k) for every prime p dividing k.
# https://oeis.org/A294179

# Known terms:
#   2, 65, 561, 41041, 825265, 321197185

# New terms found:
#   a(7) = 5394826801
#   a(8) = 232250619601

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use Math::Sidef qw(squarefree_almost_prime_count);

sub almost_prime_count_range ($n, $from, $upto) {
    almost_prime_count($n, $upto) - almost_prime_count($n, $from-1);
}

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub squarefree_almost_primes ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            forprimes {
                $callback->(mulint($m, $_));
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        while ($p <= $s) {

            my $r = next_prime($p);
            my $t = mulint($m, $p);
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }

            $p = $r;
        }
    }->(1, 2, $k);
}

sub upper_bound($n, $from = 2, $upto = 2*$from) {

    say "\n:: Searching an upper-bound for a($n)\n";

    while (1) {

        my $count = squarefree_almost_prime_count($n, $from, $upto);

        if ($count > 0) {

            say "Sieving range: [$from, $upto]";
            say "This range contains: $count elements\n";

            squarefree_almost_primes($from, $upto, $n, sub ($v) {
                if (vecall {powmod($_, $v, $v) == $_} factor($v)) {
                    say "a($n) <= $v\n";
                }
            })
        }

        $from = $upto+1;
        $upto *= 2;
    }
}

upper_bound(8);
