#!/usr/bin/perl

# a(n) is the smallest k such that tau(k*2^n - 1) is equal to 2^n where tau = A000005.
# https://oeis.org/A377634

# Known terms:
#   2, 4, 17, 130, 1283, 6889, 40037, 638521, 10126943, 186814849

# Upper-bounds:
#   a(11) <= 2546733737
#   a(12) <= 8167862431
#   a(13) <= 1052676193433
#   a(14) <= 30964627320559

# Lower-bound:
#   a(n)*2^n - 1 >= A360438(n). - ~~~~

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub omega_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k) {

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {

            my $r = next_prime($q);

            for (my $v = mulint($m, $q); $v <= $B ; $v = mulint($v, $q)) {
                if ($k == 1) {
                    $callback->($v) if ($v >= $A);
                }
                else {
                    if (mulint($v, $r) <= $B) {
                         __SUB__->($v, $r, $k - 1);
                    }
                }
            }
        }
    }->(1, 3, $k);
}

my $N = 10;
my $lo = 1;
my $hi = 2*$lo;
my @table;

while (1) {

    say "[$N] Sieving: [$lo, $hi]";

    omega_prime_numbers($lo, $hi, $N, sub ($k) {
        my $v = valuation($k+1, 2);
        if ($v >= 10 and (!$table[$v] or $k < $table[$v]) and divisors($k) == (1<<$v)) {
            say "a($v) <= ", (($k+1)>>$v);
            $table[$v] = $k;
        }
    });

    $lo = $hi+1;
    $hi = 2*$lo;
}
