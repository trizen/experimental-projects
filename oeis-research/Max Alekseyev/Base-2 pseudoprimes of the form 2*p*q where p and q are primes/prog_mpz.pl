#!/usr/bin/perl

# Base-2 pseudoprimes of the form 2*p*q where p and q are primes
# https://oeis.org/A296117

# Known terms:
#   161038, 49699666, 760569694, 4338249646, 357647681422, 547551530002, 3299605275646, 22999986587854, 42820164121582, 55173914702146, 69345154539266, 353190859033982

use 5.036;
use ntheory qw(:all);

use Math::GMPz;

sub even_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

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
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                    }
                }
            }

            return;
        }

        my $z = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;

            my $o = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $o) == 1 or next;

            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $o);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p+1, $k-1);
        }
    }->(Math::GMPz->new(2), Math::GMPz->new(1), 3, $k-1);
}

my $k = 3;
my $from = 1;
my $upto = pn_primorial($k);
my $base = 2;

while (1) {

    say "Sieving: [$from, $upto]";

    even_fermat_pseudoprimes_in_range($from, $upto, $k, $base, sub ($n) { say "New term: $n"; });

    $from = $upto+1;
    $upto = 3*$from;
}
