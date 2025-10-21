#!/usr/bin/perl

# Least k such that k + A005117(i) is squarefree with i prime factors, for 1 <= i <= n.
# https://oeis.org/A389393

# Known terms:
#   1, 4, 192, 38280, 97560, 708394680, 7024881780

use 5.036;
use ntheory qw(:all);

my @squarefree = (
                  0,  1,  2,  3,  5,  6,  7,  10, 11, 13, 14, 15, 17, 19, 21, 22, 23, 26, 29, 30, 31, 33, 34, 35, 37, 38, 39, 41, 42, 43, 46, 47,
                  51, 53, 55, 57, 58, 59, 61, 62, 65, 66, 67, 69, 70, 71, 73, 74, 77, 78, 79, 82, 83, 85, 86, 87, 89, 91, 93, 94, 95, 97
                 );

sub squarefree_almost_primes ($A, $B, $k, $callback) {

    my $n    = $k;
    my $sqfr = $squarefree[$n];

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $lo, $k) {

        my $hi = rootint(divint($B, $m), $k);

        if ($lo > $hi) {
            return;
        }

        if ($k == 1) {

            $lo = vecmax($lo, cdivint($A, $m));

            if ($lo > $hi) {
                return;
            }

            forprimes {
                my $t = $m * $_ - $sqfr;
                if (    is_prime($t + 1)
                    and is_almost_prime($n - 1, $t + $squarefree[$n - 1])
                    and is_almost_prime($n - 2, $t + $squarefree[$n - 2])) {
                    $callback->($t);
                }
            }
            $lo, $hi;

            return;
        }

        foreach my $p (@{primes($lo, $hi)}) {
            __SUB__->($m * $p, $p + 1, $k - 1);
        }
      }
      ->(1, (($sqfr % 2 == 0) ? 2 : 3), $k);
}

my $n  = 7;
my $lo = 1;
my $hi = 2 * $lo;

say ":: Searching for a($n)";

while (1) {

    say "Sieving range: [$lo, $hi]";

    my @terms;

    squarefree_almost_primes(
        $lo, $hi, $n,
        sub ($k) {

            my $ok = 1;
            foreach my $i (1 .. $n) {
                if (    is_square_free($k + $squarefree[$i])
                    and is_almost_prime($i, $k + $squarefree[$i])) {
                    ## ok
                }
                else {
                    $ok = 0;
                    last;
                }
            }

            if ($ok) {
                say "Candidate: $k";
                push @terms, $k;
            }
        }
    );

    @terms = sort { $a <=> $b } @terms;

    if (@terms) {
        die "a($n) = $terms[0]\n";
    }

    $lo = $hi + 1;
    $hi = 2 * $lo;
}
