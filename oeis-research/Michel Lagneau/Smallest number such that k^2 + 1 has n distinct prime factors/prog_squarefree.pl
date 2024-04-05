#!/usr/bin/perl

# a(n) = k is the smallest number such that k^2 + 1 has n distinct prime factors.
# https://oeis.org/A180278

# Known terms:
#   0, 1, 3, 13, 47, 447, 2163, 24263, 241727, 2923783, 16485763, 169053487, 4535472963

# New terms:
#   a(13) = 36316463227
#   a(14) = 879728844873
#   a(15) = 4476534430363
#   a(16) = 119919330795347
#   a(17) = 1374445897718223

# Lower-bounds:
#   a(18) > 20222742112347657

# Upper-bounds:
#   a(14) < 904648856077 < 1032304663967

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

sub squarefree_omega_palindromes ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

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
                if (Math::GMPz::Rmpz_perfect_square_p($u)) {
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

    #my $x = Math::GMPz->new(pn_primorial($n));
    #my $x = Math::GMPz->new("408959298542519401035127211363470");
    #my $y = 2*$x;
    my $x = Math::GMPz->new("817918597085038802070254422726941");
    my $y = Math::GMPz->new("11299387660698915814663766217401579");

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

foreach my $n (18) {
    say "a($n) = ", a($n);
}
