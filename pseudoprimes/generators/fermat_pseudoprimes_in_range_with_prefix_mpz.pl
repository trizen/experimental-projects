#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 28 August 2022
# https://github.com/trizen

# Generate all the squarefree Fermat pseudoprimes to given a base with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

my $max_p = 1000000;
my %znorder = map { $_ => znorder(2, $_) } @{primes($max_p)};

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    #my $m = "8833404609327838592895595408965";
    #my $m = "1614825036214963273306005";
    #my $m = Math::GMPz->new("19258022593463164626195195");
    #my $m = Math::GMPz->new("19976310800932286865");      # finds new abundant Fermat psp
    my $m = Math::GMPz->new("2799500171953451613547965");      # finds new abundant Fermat psp
    #my $m = Math::GMPz->new("551501533874829967868949105");      # finds new abundant Fermat psp
    #my $m = Math::GMPz->new("1389172629407632160878965");      # finds new abundant Fermat psp
    #my $m = Math::GMPz->new("3935333227783660512405");      # finds new abundant Fermat psp
    #my $m = Math::GMPz->new("15312580652854710165");      # finds new abundant Fermat psp
    #my $m = Math::GMPz->new("7051637712729097263345");
    #my $m = Math::GMPz->new("1256975577207099774483036285");
    #my $m = Math::GMPz->new("24383833295");

    my $L = znorder($base, $m);

    $L = Math::GMPz->new("$L");

    $A = $A*$m;
    $B = $B*$m;

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    if ($B > Math::GMPz->new("898943937249247967890084629421065")) {
        $B = Math::GMPz->new("898943937249247967890084629421065");
    }

    if ($A > $B) {
        return;
    }

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    sub ($m, $L, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);
        $hi = vecmin($max_p, $hi);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            Math::GMPz::Rmpz_cdiv_q($u, $A, $m);

            if (Math::GMPz::Rmpz_fits_ulong_p($u)) {
                $lo = vecmax($lo, Math::GMPz::Rmpz_get_ui($u));
            }
            elsif (Math::GMPz::Rmpz_cmp_ui($u, $lo) > 0) {
                if (Math::GMPz::Rmpz_cmp_ui($u, $hi) > 0) {
                    return;
                }
                $lo = Math::GMPz::Rmpz_get_ui($u);
            }

            if ($lo > $hi) {
                return;
            }

            Math::GMPz::Rmpz_invert($v, $m, $L) || return;

            if (Math::GMPz::Rmpz_cmp_ui($v, $hi) > 0) {
                return;
            }

            if (Math::GMPz::Rmpz_fits_ulong_p($L)) {
                $L = Math::GMPz::Rmpz_get_ui($L);
            }

            my $t = Math::GMPz::Rmpz_get_ui($v);
            $t > $hi && return;
            $t += $L while ($t < $lo);

            for (my $p = $t ; $p <= $hi ; $p += $L) {
                if (is_prime($p) and $base % $p != 0 and !Math::GMPz::Rmpz_divisible_ui_p($m, $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    my $z = ($znorder{$p} // znorder($base, $p));
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, $z)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                    }
                }
            }

            return;
        }

        my $t   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            Math::GMPz::Rmpz_divisible_ui_p($m, $p) and next;
            $base % $p == 0 and next;

            my $z = ($znorder{$p} // znorder($base, $p));
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);
            Math::GMPz::Rmpz_mul_ui($t, $m, $p);

            __SUB__->($t, $lcm, $p + 1, $k - 1);
        }
      }
      ->($m, $L, 3, $k);

      return 1;
}

my $base = 2;
my $from = Math::GMPz->new("2");
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
