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
    my $q = $x/$y;
    ($q*$y == $x) ? $q : ($q+1);
}

my $max_p = 10000;
my %znorder = map { $_ => znorder(2, $_) } @{primes($max_p)};

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    #my $m = "8833404609327838592895595408965";
    #my $m = "1614825036214963273306005";
    #my $m = Math::GMP->new("19258022593463164626195195");
    #my $m = Math::GMP->new("19976310800932286865");      # finds new abundant Fermat psp
    #my $m = Math::GMP->new("2799500171953451613547965");      # finds new abundant Fermat psp
    #my $m = Math::GMP->new("551501533874829967868949105");      # finds new abundant Fermat psp
    #my $m = Math::GMP->new("1389172629407632160878965");      # finds new abundant Fermat psp
    #my $m = Math::GMP->new("3935333227783660512405");      # finds new abundant Fermat psp
    my $m = Math::GMP->new("15312580652854710165");      # finds new abundant Fermat psp
    #my $m = Math::GMP->new("7051637712729097263345");
    #my $m = Math::GMP->new("1256975577207099774483036285");
    #my $m = Math::GMP->new("24383833295");

    my $L = znorder($base, $m);

    $A = $A*$m;
    $B = $B*$m;

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMP->new("$A");
    $B = Math::GMP->new("$B");

    if ($B > Math::GMP->new("2596282479202818734176082185090403265")) {
        $B = Math::GMP->new("2596282479202818734176082185090403265");
    }

    if ($A > $B) {
        return;
    }

    sub ($m, $L, $lo, $k) {

        my $hi = rootint($B/$m, $k);
        $hi = vecmin($max_p, $hi);

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
                    my $n = $m*$p;
                    if (($n - 1) % $znorder{$p} == 0) {
                        $callback->($n);
                    }
                }
            }

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {

            if ($base % $p == 0) {
                next;
            }

            if ($m%$p == 0) {
                next;
            }

            my $z = $znorder{$p};

            is_smooth($z, 13) || next;
            #is_smooth($z, 19) || next;

            gcd($m, $z) == 1 or next;

            __SUB__->($m*$p, lcm($L, $z), $p+1, $k-1);
        }
    }->($m, $L, 3, $k);

    return 1;
}

my $base = 2;
my $from = 2;
my $upto = 2*$from;

while (1) {

    my $ok = 0;
    say "# Range: ($from, $upto)";

    foreach my $k (2..100) {
        fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) { say $n }) or next;
        $ok = 1;
    }

    $ok || last;

    $from = $upto+1;
    $upto = 2*$from;
}
