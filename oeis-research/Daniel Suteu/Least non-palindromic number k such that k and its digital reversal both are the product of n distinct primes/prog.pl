#!/usr/bin/perl

# Least non-palindromic number k such that k and its digital reversal both are the product of n distinct primes.

# Last digit can't be zero.

# Squarefree version of:
#   https://oeis.org/A113548

# Known terms:
#   13, 15, 165, 1518, 15015, 246246, 10444434, 241879638, 20340535215, 458270430618, 136969856585562, 20446778282756826

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub generate ($A, $B, $k, $callback) {

    my $n = $k;

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    sub ($m, $lo, $k) {

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

            forprimes {
                Math::GMPz::Rmpz_mul_ui($v, $m, $_);
                my $s = Math::GMPz::Rmpz_get_str($v, 10);
                my $r = reverse($s);
                if ($s ne $r and is_omega_prime($n, $r) and is_square_free($r)) {
                    my $t = Math::GMPz::Rmpz_init_set($v);
                    #say("Found upper-bound: ", $r);
                    $B = vecmin($t, $B);
                    $callback->($t);
                }
            } $lo, $hi;

            return;
        }

        my $z = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {
            if ($p == 5 and Math::GMPz::Rmpz_even_p($m)) {
                ## last digit can't be zero
            }
            else {
                Math::GMPz::Rmpz_mul_ui($z, $m, $p);
                __SUB__->($z, $p+1, $k-1);
            }
        }
    }->(Math::GMPz->new(1), 2, $k);
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    my $x = Math::GMPz->new(pn_primorial($n));
    my $y = 2*$x;

    while (1) {
        #say("Sieving range: [$x, $y]");
        my @v;
        generate($x, $y, $n, sub ($k) {
            push @v, $k;
        });
        @v = sort { $a <=> $b } @v;
        if (scalar(@v) > 0) {
            return $v[0];
        }
        $x = $y+1;
        $y = 2*$x;
    }
}

foreach my $n (1..20) {
    say "a($n) = ", a($n);
}
