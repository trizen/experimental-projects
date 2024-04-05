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

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub omega_palindromes($A, $B, $n) {

    $A = vecmax($A, pn_primorial($n));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

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

            $q % 4 == 3 and next;

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_perfect_square_p($u)) {
                            my $t = Math::GMPz::Rmpz_init_set($v);
                            my $w = sqrtint($v-1);
                            say("Found upper-bound: ", $w);
                            $B = $t if ($t < $B);
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

    return sort {  $a <=> $b } @values;
}

sub a($n) {

    if ($n == 0) {
        return 1;
    }

    #my $x = Math::GMPz->new(pn_primorial($n));
    my $x = Math::GMPz->new("408959298542519401035127211363470");
    my $y = 2*$x;

    while (1) {
        say("Sieving range: [$x, $y]");
        my @v = omega_palindromes($x, $y, $n);
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
