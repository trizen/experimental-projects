#!/usr/bin/perl

# Least non-palindromic number k such that k and its digital reversal both have exactly n prime divisors.
# https://oeis.org/A113548

# Known terms:
#   13, 12, 132, 1518, 15015, 204204, 10444434, 241879638, 20340535215, 242194868916

# a(n) >= A239696(n).

# This sequence does not allow ending in 0, else a(8) = 208888680, a(11) = 64635504163230 and a(13) = 477566276048801940. - Michael S. Branicky, Feb 14 2023

# New terms:
#   a(11) = 136969856585562
#   a(12) = 2400532020354468
#   a(13) = 484576809394483806
#   a(14) = 200939345091539746692

# Upper-bounds:
#   a(13) <= 604973037030580218
#   a(14) <= 202183806462387575826

# Lower-bounds:
#   a(14) > 107173980829040893951

# Timings:
#   a(11) is found in 5.7 seconds
#   a(12) is found in 4.8 seconds
#   a(13) is found in 2.5 minutes

# MPU::GMP prime_omega:
#   a(11) in 19.0 seconds
#   a(12) in 14.5 seconds

# Our method:
#   a(11) in 9.7 seconds -- 7.8 seconds -- 6.5 seconds
#   a(12) in 7.2 seconds -- 5.8 seconds -- 5.3 seconds

# While searching for a(14), it took 21 hours and 30 minutes to check the range [107173980829040893951, 214347961658081787902].

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;
use Math::Prime::Util::GMP;

sub mpz_is_omega_prime ($n, $k) {

    state $z = Math::GMPz::Rmpz_init();
    state $t = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_str($z, $n, 10);
    Math::GMPz::Rmpz_root($t, $z, $k);

    my $trial_limit = Math::GMPz::Rmpz_get_ui($t);

    if ($trial_limit > 1e3) {
        $trial_limit = 1e3;
    }

    for (my $p = 2; $p <= $trial_limit; $p = next_prime($p)) {

        if (Math::GMPz::Rmpz_divisible_ui_p($z, $p)) {
            --$k;
            Math::GMPz::Rmpz_set_ui($t, $p);
            Math::GMPz::Rmpz_remove($z, $z, $t);
        }

        ($k > 0) or last;

        if (Math::GMPz::Rmpz_fits_ulong_p($z)) {
            return is_omega_prime($k, Math::GMPz::Rmpz_get_ui($z));
        }
    }

    if (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0) {
        return ($k == 0);
    }

    if ($k == 0) {
        return (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0);
    }

    if ($k == 1) {

        if (Math::GMPz::Rmpz_fits_ulong_p($z)) {
            return is_prime_power(Math::GMPz::Rmpz_get_ui($z));
        }

        return Math::Prime::Util::GMP::is_prime_power(Math::GMPz::Rmpz_get_str($z, 10));
    }

    Math::GMPz::Rmpz_ui_pow_ui($t, next_prime($trial_limit), $k);

    if (Math::GMPz::Rmpz_cmp($z, $t) < 0) {
        return 0;
    }

    Math::GMPz::Rmpz_fits_ulong_p($z)
        ? is_omega_prime($k, Math::GMPz::Rmpz_get_ui($z))
        : (Math::Prime::Util::GMP::prime_omega(Math::GMPz::Rmpz_get_str($z, 10)) == $k);
}

foreach my $n (1..100) {
    my $t = addint(urandomb($n), 1);

    foreach my $k (1..20) {
        if (is_omega_prime($k, $t)) {
            mpz_is_omega_prime($t, $k) || die "error for: ($t, $k)";
        }
        elsif (mpz_is_omega_prime($t, $k)) {
            die "counter-example: ($t, $k)";
        }
    }
}

sub generate($A, $B, $n) {

    $A = vecmax($A, pn_primorial($n));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $j) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        my @lst;
        my $v = Math::GMPz::Rmpz_init();

        foreach my $q (@{primes($lo, $hi)}) {

            if ($q == 5 && Math::GMPz::Rmpz_even_p($m)) {
                # Last digit can't be zero
                next;
            }

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        my $s = Math::GMPz::Rmpz_get_str($v, 10);
                        my $r = reverse($s);
                        if ($r ne $s and (($r > ~0) ? mpz_is_omega_prime($r, $n) : is_omega_prime($n, $r))) {
                            my $w = Math::GMPz::Rmpz_init_set($v);
                            say("Found upper-bound: ", $w);
                            $B = $w if ($w < $B);
                            push @lst, $w;
                        }
                    }
                }
                else {
                    push @lst, __SUB__->($v, $q+1, $j-1);
                }
                Math::GMPz::Rmpz_mul_ui($v, $v, $q);
            }
        }

        return @lst;
    }->(Math::GMPz->new(1), 2, $n);

    return sort { $a <=> $b } @values;
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    #my $x = Math::GMPz->new(pn_primorial($n));
    my $x = Math::GMPz->new("107173980829040893951");
    my $y = 2*$x;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v = generate($x, $y, $n);
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (14) {
    say "a($n) = ", a($n);
}
