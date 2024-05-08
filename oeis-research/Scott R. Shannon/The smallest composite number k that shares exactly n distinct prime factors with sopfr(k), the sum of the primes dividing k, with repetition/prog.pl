#!/usr/bin/perl

# The smallest composite number k that shares exactly n distinct prime factors with sopfr(k), the sum of the primes dividing k, with repetition.
# https://oeis.org/A372524

# Known terms:
#   6, 4, 30, 1530, 40530, 37838430, 900569670

# New terms:
#   a(7) = 781767956970

# Lower-bounds:
#   a(8) > 70368744177663

# Conjecture: A001221(a(n)) = n+1, for n >= 2. - ~~~~

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub omega_prime_numbers ($A, $B, $n, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    my $min_value = pn_primorial($n);

    sub ($m, $sopfr, $p, $k) {

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {

            my $r = $q+1;
            my $t = $sopfr+$q;

            for (my $v = $m * $q; $v <= $B ; do { $v *= $q; $t += $q }) {
                if ($k == 1) {
                    if ($v >= $A and gcd($t, $v) >= $min_value and is_omega_prime($n, gcd($t, $v))) {
                        $callback->($v);
                        $B = $v if ($v < $B);
                    }
                }
                else {
                    if ($v*$r <= $B) {
                         __SUB__->($v, $t, $r, $k - 1);
                    }
                }
            }
        }
    }->(1, 0, 2, $k);
}

my $n = 8;
my $lo = 1;
my $hi = 2*$lo;

while (1) {

    say "Sieving: [$lo, $hi]";

    my @terms;
    omega_prime_numbers($lo, $hi, $n, $n+1, sub ($k) {
            say "Upper-bound: $k";
            push @terms, $k;
    });

    @terms = sort {$a <=> $b} @terms;

    if (@terms){
        die "\nFound: a($n) = $terms[0]\n";
    }

    $lo = $hi+1;
    $hi = 2*$lo;
}
