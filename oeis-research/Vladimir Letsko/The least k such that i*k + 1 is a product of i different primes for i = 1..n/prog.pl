#!/usr/bin/perl

# The least k such that i*k + 1 is a product of i different primes for i = 1..n.
# https://oeis.org/A336027

# Knwon terms:
#   1, 10, 268, 7576, 652726, 913180816

use 5.014;
use ntheory qw(:all);

my $prev = 2;

foreach my $n (1 .. 7) {

    my ($k, $ok);

    forprimes {

        $k  = $_ - 1;
        $ok = 1;

        for (my $i = $n; $i > 1; --$i) {
            if (is_almost_prime($i, $i * $k + 1) && is_square_free($i * $k + 1)) {
            }
            else {
                $ok = 0;
                last;
            }
        }

        if ($ok) {
            say "a($n) = $k";
            $prev = $k;
            lastfor, return;
        }
    } $prev, $prev+1e12;
}
