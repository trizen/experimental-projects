#!/usr/bin/perl

# Least k such that k is the product of n distinct primes and sigma(k) is an n-th power.
# https://oeis.org/A281140

# a(14) <= 94467020965716904490370

use 5.020;
use ntheory qw(:all);
use Math::GMPz;
use experimental qw(signatures);

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

my $k    = 14;
my $from = Math::GMPz->new("240871269907008510");
my $upto = Math::GMPz->new("94467020965716904490370");

squarefree_almost_primes($from, $upto, $k, sub ($n) {
    if (is_power(divisor_sum($n), $k)) {
        say "a($k) <= $n";
    }
});
