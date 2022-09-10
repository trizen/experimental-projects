#!/usr/bin/perl

# Smallest overpseudoprime to base 2 (A141232) with n distinct prime factors.
# https://oeis.org/A353409

# Known terms:
#   2047, 13421773, 14073748835533

# Upper-bounds:
#   a(5) <= 1376414970248942474729
#   a(6) <= 48663264978548104646392577273
#   a(7) <= 294413417279041274238472403168164964689
#   a(8) <= 98117433931341406381352476618801951316878459720486433149
#   a(9) <= 1252977736815195675988249271013258909221812482895905512953752551821

# New terms confirmed (03 September 2022):
#   a(5) = 1376414970248942474729
#   a(6) = 48663264978548104646392577273
#   a(7) = 294413417279041274238472403168164964689

use 5.020;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::GMP qw(:constant);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    ($q*$y == $x) ? $q : ($q+1);
}

sub squarefree_fermat_overpseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            if (prime_count($u, $v) < divint($v-$u, $lambda)) {
                forprimes {
                    if (($m*$_ - 1)%$lambda == 0 and powmod($base, $lambda, $_) == 1 and znorder($base, $_) == $lambda) {
                        $callback->($m*$_);
                    }
                } $u, $v;
                return;
            }

            my $w = $lambda * divceil($u-1, $lambda);

            for(; $w <= $v; $w += $lambda) {
                if (is_prime($w+1) and powmod($base, $lambda, $w+1) == 1) {
                    my $p = $w+1;
                    if (($m*$p - 1)%$lambda == 0 and znorder($base, $p) == $lambda) {
                        $callback->($m*$p);
                    }
                }
            }

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for(my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);
            $base % $p == 0 and next;

            my $L = znorder($base, $p);
            $L == $lambda or $lambda == 1 or next;

            gcd($L, $m) == 1 or next;

            my $t = $m*$p;
            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->(1, 1, 2, $k);
}

sub a($n) {
    my $x = pn_primorial($n);
    my $y = 2*$x;

    $x = Math::GMP->new("$x");
    $y = Math::GMP->new("$y");

    for (;;) {
        my @arr;
        squarefree_fermat_overpseudoprimes_in_range($x, $y, $n, 2, sub($v) { push @arr, $v });
        if (@arr) {
            @arr = sort {$a <=> $b} @arr;
            return $arr[0];
        }

        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (2..100) {
    say "a($n) = ", a($n);
}
