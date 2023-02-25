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
#   a(12) <= 4766466010613887747468126
#   a(13) <= 102066199849378101848830606 < 264142222928897318700339646 < 1725479220139163740111585726
#   a(14) <= 830980424310040957294391274226 < 866600672627375092851058279666 < 1983132824527094983631028842626 < 2091681251598900871449480765826
#   a(15) <= 108084747660126676387861365978526 < 1842817788240578750872074253088926
#   a(16) <= 37216678196711615864826518577193726 < 37843891059100280944238655216335326
#   a(17) <= 14165393571115472875428298421578481266
#   a(18) <= 29754760201190206689697709808980720234206
#   a(19) <= 83297267513662079869290363590704788631466446
#   a(20) <= 38869290181330286854504265440667019466376871106

use 5.036;
use ntheory qw(:all);

use Math::GMPz;

sub squarefree_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    sub ($m, $L, $lo, $k) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $k);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

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

            Math::GMPz::Rmpz_invert($v, $m, $L);

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
                if (is_prime($p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, znorder($base, $p))) {
                        my $w = Math::GMPz::Rmpz_init_set($v);
                        say "Found upper-bound: $w";
                        $B = $w if ($w < $B);
                        $callback->($w);
                    }
                }
            }

            return;
        }

        my $z = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;
            is_smooth($p-1, 17) || next;

            my $o = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $o) == 1 or next;

            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $o);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p+1, $k-1);
        }
    }->(Math::GMPz->new(2), Math::GMPz->new(1), 3, $k-1);
}

sub a ($n) {

    if ($n < 3) {
        return;
    }

    my $x = Math::GMPz->new(pn_primorial($n));
    #my $x = Math::GMPz->new("698611877253803335257283");
    my $y = 3 * $x;

    #$x = Math::GMPz->new("8659342796477276452489576392442249215");
    #$y = Math::GMPz->new("14165393571115472875428298421578481266");

    while (1) {
        say("[$n] Sieving range: [$x, $y]");
        my @v;
        squarefree_fermat_pseudoprimes_in_range(
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
        $y = 3 * $x;
    }
}

foreach my $n (20) {
    say "a($n) <= ", a($n);
}
