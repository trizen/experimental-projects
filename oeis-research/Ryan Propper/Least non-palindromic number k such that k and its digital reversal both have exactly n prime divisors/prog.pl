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

# Upper-bounds:
#   a(13) <= 604973037030580218

# Lower-bounds:
#   a(14) > 13396747603630111743

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;

sub generate($A, $B, $n) {

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
                        if ($r ne $s and is_omega_prime($n, $r)) {
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
    my $x = Math::GMPz->new("13396747603630111743");
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
