#!/usr/bin/perl

# Smallest base-2 even pseudoprime (A006935) with exactly n prime factors, or 0 if no such number exists.
# https://oeis.org/A270973

# Known terms:
#   161038, 215326, 209665666, 4783964626, 1656670046626, 1202870727916606

# New terms:
#   a(9)  = 52034993731418446
#   a(10) = 1944276680165220226
#   a(11) = 1877970990972707747326
#   a(12) = 1959543009026971258888306
#   a(13) = 102066199849378101848830606

# Lower-bounds:
#   a(12) > 1397223754507606670514567
#   a(13) > 41815837812760091234926591

# Upper-bounds:
#   a(13) <= 102066199849378101848830606

use 5.020;
use warnings;

use ntheory      qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();

    sub ($m, $lambda, $lo, $j) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {

            if ($base % $p == 0) {
                next;
            }

            my $q = $p;
            my $w = Math::GMPz::Rmpz_init();

            Math::GMPz::Rmpz_mul_ui($w, $m, $p);

            while (Math::GMPz::Rmpz_cmp($w, $B) <= 0) {

                my $L = lcm($lambda, znorder($base, $q));

                if ($L < ~0) {
                    Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $w, $L) == 1 or last;
                }
                else {
                    gcd($L, $w) == 1 or last;
                }

                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($w, $A) >= 0) {
                        if ($k == 1 and is_prime($w)) {
                            ## ok
                        }
                        elsif (
                            ($L < ~0)
                            ? do {
                                Math::GMPz::Rmpz_sub_ui($u, $w, 1);
                                Math::GMPz::Rmpz_divisible_ui_p($u, $L);
                            }
                            : (($w - 1) % $L == 0)
                          ) {
                            my $t = Math::GMPz::Rmpz_init_set($w);
                            say "Found upper-bound: $t";
                            $B = $t if ($t < $B);
                            $callback->($t);
                        }
                    }
                }
                else {
                    __SUB__->($w, $L, $p + 1, $j - 1);
                }

                $q *= $p;
                Math::GMPz::Rmpz_mul_ui($w, $w, $p);
            }
        }
      }
      ->(Math::GMPz->new(2), 1, 3, $k - 1);
}

sub a ($n) {

    if ($n < 3) {
        return;
    }

    my $x = Math::GMPz->new(pn_primorial($n));
    #my $x = Math::GMPz->new("41815837812760091234926591");
    my $y = 2 * $x;
    #my $y = Math::GMPz->new("102066199849378101848830606");

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v;
        fermat_pseudoprimes_in_range(
            $x, $y, $n, 2,
            sub ($k) {
                push @v, $k;
            }
        );
        @v = sort { $a <=> $b } @v;
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y + 1;
        $y = 2 * $x;
    }
}

foreach my $n (10) {
    say "a($n) = ", a($n);
}
