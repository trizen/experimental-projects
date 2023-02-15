#!/usr/bin/perl

# Smallest palindrome with exactly n distinct prime factors.
# https://oeis.org/A335645

# Known terms:
#   1, 2, 6, 66, 858, 6006, 222222, 20522502, 244868442, 6172882716, 231645546132, 49795711759794, 2415957997595142, 495677121121776594, 22181673755737618122

# New term found:
#   a(15) = 5521159517777159511255     (took 3h, 40min, 22,564 ms.)

# New term found by Michael S. Branicky:
#   a(16) = 477552751050050157255774

# Lower-bounds:
#   a(17) > 7875626394231654969634815

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

            if ($q == 5 && Math::GMPz::Rmpz_even_p($m)) {
                # Last digit can't be zero
                next;
            }

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {
                        my $s = Math::GMPz::Rmpz_get_str($v, 10);
                        if (reverse($s) eq $s) {
                            my $r = Math::GMPz::Rmpz_init_set($v);
                            #say("Found upper-bound: ", $r);
                            $B = $r if ($r < $B);
                            push @lst, $r;
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
        #say("Sieving range: [$x, $y]");
        my @v = omega_palindromes($x, $y, $n);
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
