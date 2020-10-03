#!/usr/bin/perl

# Number of powerful numbers between 2^(n-1)+1 and 2^n.
# https://oeis.org/A062761

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);

# 0, 1, 1, 2, 3, 3, 7, 8, 12, 17, 25, 36, 50, 74, 105, 152, 213, 306, 437, 620, 882, 1256, 1781, 2531, 3588, 5091, 7221, 10225, 14504

sub is_powerful ($n) {

    foreach my $p (2, 3, 5, 7, 11) {
        if ($n % $p == 0) {
            if ($n % ($p * $p) != 0) {
                return 0;
            }
        }
    }

    vecall { $_->[1] > 1 } reverse factor_exp($n);
}

local $| = 1;

foreach my $n (1 .. 22) {

    my $count = 0;

    foreach my $k (powint(2, $n - 1) + 1 .. powint(2, $n)) {
        if (is_powerful($k)) {
            ++$count;
        }
    }

    print($count, ", ");
}

say '';
