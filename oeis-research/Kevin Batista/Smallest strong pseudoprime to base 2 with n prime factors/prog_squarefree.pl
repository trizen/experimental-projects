#!/usr/bin/perl

# Smallest strong pseudoprime to base 2 with n prime factors.
# https://oeis.org/A180065

# Known terms:
#   2047, 15841, 800605, 293609485, 10761055201, 5478598723585, 713808066913201, 90614118359482705, 5993318051893040401

# New terms found (24 September 2022):
#   a(11) = 24325630440506854886701
#   a(12) = 27146803388402594456683201
#   a(13) = 4365221464536367089854499301
#   a(14) = 2162223198751674481689868383601
#   a(15) = 548097717006566233800428685318301

# New terms found (01 March 2023):
#   a(16) = 348613808580816298169781820233637261
#   a(17) = 179594694484889004052891417528244514541

# Lower-bounds:
#   a(18) > 4225759284680910908812751551690679779327

# Upper-bounds:
#   a(18) <= 402705517727804564796340190090616337175101

# It took 1 hour and 2 minutes to find a(16).
# It took 5 hours and 39 minutes to find a(17).

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub squarefree_strong_fermat_pseudoprimes_in_range ($A, $B, $k, $base, $callback) {

    $A = vecmax($A, pn_primorial($k));

    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my $generator = sub ($m, $L, $lo, $k, $k_exp, $congr) {

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

                is_prime($p) || next;
                $base % $p == 0 and next;

                my $val = valuation($p - 1, 2);
                if ($val > $k_exp and powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p)) {
                    Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                    Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_ui_p($u, znorder($base, $p))) {
                        my $value = Math::GMPz::Rmpz_init_set($v);
                        say "Found upper-bound: $value";
                        $B = $value if ($value < $B);
                        $callback->($value);
                    }
                }
            }

            return;
        }

        my $t   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {

            $base % $p == 0 and next;

            my $val = valuation($p - 1, 2);
            $val > $k_exp                                                   or next;
            powmod($base, ($p - 1) >> ($val - $k_exp), $p) == ($congr % $p) or next;

            my $z = znorder($base, $p);
            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $z) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $z);
            Math::GMPz::Rmpz_mul_ui($t, $m, $p);

            __SUB__->($t, $lcm, $p + 1, $k - 1, $k_exp, $congr);
        }
    };

    # Cases where 2^(d * 2^v) == -1 (mod p), for some v >= 0.
    foreach my $v (reverse(0 .. logint($B, 2))) {
        $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, $v, -1);
    }

    # Case where 2^d == 1 (mod p), where d is the odd part of p-1.
    $generator->(Math::GMPz->new(1), Math::GMPz->new(1), 2, $k, 0, 1);
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    say "Searching for a($n)";

    #my $x = Math::GMPz->new(pn_primorial($n));
    my $x = Math::GMPz->new("4225759284680910908812751551690679779327");
    my $y = 2*$x;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v;
        squarefree_strong_fermat_pseudoprimes_in_range($x, $y, $n, 2, sub ($k) {
            push @v, $k;
        });
        @v = sort { $a <=> $b } @v;
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y+1;
        $y = 2*$x;

        my $max = Math::GMPz->new("402705517727804564796340190090616337175101");
        $y = $max if ($y > $max);
    }
}

foreach my $n (18) {
    say "a($n) = ", a($n);
}
