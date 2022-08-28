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
use Math::GMP qw(:constant);

sub divceil ($x,$y) {   # ceil(x/y)
    my $q = divint($x, $y);
    (mulint($q, $y) == $x) ? $q : ($q+1);
}

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    #my $m = "8833404609327838592895595408965";
    #my $m = "1614825036214963273306005";
    my $m = "775553931136780560856033387845";      # finds new abundant Fermat psp
    #my $m = "1256975577207099774483036285";
    #my $m = "847680446732501153015644492914585";
    my $L = znorder($base, $m);

    $A = mulint($A, $m);
    $B = mulint($B, $m);

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lambda, $p, $k, $u = undef, $v = undef) {

        if ($k == 1) {

            say "# Sieving: $m -> ($u, $v)" if ($v - $u > 2e6);

            forprimes {
                my $t = mulint($m, $_);
                if (modint($t-1, $lambda) == 0 and modint($t-1, znorder($base, $_)) == 0) {
                    $callback->($t);
                }
            } $u, $v;

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        for(my $r; $p <= $s; $p = $r) {

            $r = next_prime($p);

            if (modint($m, $p) == 0) {
                next;
            }

            my $t = mulint($m, $p);
            my $z = znorder($base, $p) // next;
            my $L = lcm($lambda, $z);

            ($p >= 3 and gcd($L, $t) == 1) or next;

            my $u = divceil($A, $t);
            my $v = divint($B, $t);

            if ($u <= $v) {
                __SUB__->($t, $L, $r, $k - 1, (($k==2 && $r>$u) ? $r : $u), $v);
            }
        }
    }->($m, $L, 3, $k);
}

my $base = 2;
my $from = 2;
my $upto = 2*$from;

while (1) {

    say "# Range: ($from, $upto)";

    foreach my $k (2..100) {
        pn_primorial($k) < $upto or last;
        fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) { say $n });
    }

    $from = $upto+1;
    $upto = 2*$from;
}
