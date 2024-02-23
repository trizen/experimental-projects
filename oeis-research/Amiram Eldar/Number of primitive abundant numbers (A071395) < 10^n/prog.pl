#!/usr/bin/perl

# Number of primitive abundant numbers (A071395) < 10^n.
# https://oeis.org/A306986

# Known terms:
#   0, 3, 14, 98, 441, 1734, 8667, 41653, 213087, 1123424

use 5.036;
use ntheory qw(:all);

sub f ($n, $q, $limit) {

    #if (($n % 6) == 0 || ($n % 28) == 0 || ($n % 496) == 0 || ($n % 8128) == 0) {
    #    return 0;
    #}

    my $count = 0;
    my $p = $q;

    while (1) {

        my $t = $n * $p;
        ($t >= $limit) && last;

        my $ds = divisor_sum($t);

        if ($ds > 2 * $t) {

            my $ok = 1;
            foreach my $pp (factor_exp($t)) {
                my $w = divint($t, $pp->[0]);
                if (divisor_sum($w) >= 2 * $w) {
                    $ok = 0;
                    last;
                }
            }

            $ok and $count += 1;
        }
        elsif ($ds < 2*$t) {
            $count += f($t, $p, $limit);
        }

        $p = next_prime($p);
    }

    return $count;
}

say f(1, 2, powint(10, 4));
say f(1, 2, powint(10, 5));
say f(1, 2, powint(10, 6));

say f(1, 2, powint(10, 11));
