#!/usr/bin/perl

# Least starting prime of exactly n consecutive primes p_i (i = 1..n) such that omega(p_i + 1) = 1 + i.
# https://oeis.org/A373533

# Known terms:
#   5, 23, 499, 13093, 501343, 162598021, 25296334003

use 5.036;
use ntheory qw(:all);

my $n = 6;

my $from = 2;
my $upto = 2 * $from;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = omega_primes($n + 1, $from, $upto);

    foreach my $k (@$arr) {
        if (is_prime($k - 1)) {

            my $q = prev_prime($k - 1);

            if (is_omega_prime($n, $q + 1)) {
                my $ok = 1;
                foreach my $j (3 .. $n) {
                    $q = prev_prime($q);
                    if (is_omega_prime($n - $j + 2, $q + 1)) {
                        ## ok
                    }
                    else {
                        $ok = 0;
                        last;
                    }
                }

                if ($ok and !is_omega_prime($n + 2, next_prime($k) + 1)) {
                    say "a($n) = $q";
                    exit;
                }
            }
        }
    }

    $from = $upto;
    $upto = int(1.3 * $from);
}
