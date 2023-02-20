#!/usr/bin/perl

# Least prime p such that p^2+1 is the product of n distinct primes.
# https://oeis.org/A164511

# Known terms:
#   2, 3, 13, 47, 463, 2917, 30103, 241727, 3202337, 26066087, 455081827, 7349346113, 122872146223

# New terms:
#   a(14) = 2523038248697
#   a(15) = 28435279521433
#   a(16) = 119919330795347

# a(n) >= A180278(n). - ~~~~

# Lower-bounds:
#   a(17) > sqrt(15112812206035615363823250221847)

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub squarefree_omega_palindromes ($A, $B, $k, $callback) {

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

            foreach my $p (@{primes($lo, $hi)}) {
                $p % 4 == 3 and next;
                Math::GMPz::Rmpz_mul_ui($v, $m, $p);
                Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                if (Math::GMPz::Rmpz_perfect_square_p($u) and is_prime(sqrtint($u))) {
                    my $r = Math::GMPz::Rmpz_init_set($v);
                    say("Found upper-bound: ", sqrtint($u));
                    $B = $r if ($r < $B);
                    $callback->(sqrtint($u));
                }
            }

            return;
        }

        my $z = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $hi)}) {
            if ($p%4 == 3) {
                ## p can't be congruent to 3 mod 4.
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
    #my $x = Math::GMPz->new("1889101525754451920477906277730");
    my $y = 2*$x;

    while (1) {
        say("[$n] Sieving range: [$x, $y]");
        my @v;
        squarefree_omega_palindromes($x, $y, $n, sub ($k) {
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

foreach my $n (12) {
    say "a($n) = ", a($n);
}
