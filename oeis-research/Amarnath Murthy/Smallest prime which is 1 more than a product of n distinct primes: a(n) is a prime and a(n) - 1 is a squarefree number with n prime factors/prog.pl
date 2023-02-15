#!/usr/bin/perl

# Smallest prime which is 1 more than a product of n distinct primes: a(n) is a prime and a(n) - 1 is a squarefree number with n prime factors.
# https://oeis.org/A073918

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::Prime::Util::GMP;

use Math::GMPz;

sub generate ($A, $B, $k, $callback) {

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
                Math::GMPz::Rmpz_add_ui($v, $v, 1);
                my $s = Math::GMPz::Rmpz_get_str($v, 10);
                if (Math::Prime::Util::GMP::is_prime($s)) {
                    my $r = Math::GMPz::Rmpz_init_set($v);
                    #say("Found upper-bound: ", $r);
                    $B = $r if ($r < $B);
                    $callback->($r);
                }
            } $lo, $hi;

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {
            __SUB__->($m*$p, $p+1, $k-1);
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

foreach my $n (1..100) {
    say "$n ", a($n);
}
