#!/usr/bin/perl

# a(n) = k is the smallest number such that k^3 + 1 has exactly n distinct prime factors.
# https://oeis.org/A180278

# Known terms:
#   0, 1, 3, 5, 17, 59, 101, 563, 2617, 9299, 22109, 132989, 364979, 1970869, 23515229, 109258049, 831731339

# Slow approach.

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

           # $q % 4 == 3 and next;

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_perfect_power_p($u) and Math::Prime::Util::GMP::is_power($u, 3)) {
                            my $t = Math::GMPz::Rmpz_init_set($v);
                            my $w = rootint($u, 3);
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

    my $x = Math::GMPz->new(pn_primorial($n));
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

# Known terms:
#   0, 1, 3, 5, 17, 59, 101, 563, 2617, 9299, 22109, 132989, 364979, 1970869, 23515229, 109258049, 831731339

foreach my $n (7) {
    say "a($n) = ", a($n);
}
