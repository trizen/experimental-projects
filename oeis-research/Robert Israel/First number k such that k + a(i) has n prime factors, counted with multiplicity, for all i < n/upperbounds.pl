#!/usr/bin/perl

use 5.036;
use ntheory qw(:all);

my @terms = (0, 2, 4, 66, 1012, 14630, 929390, 63798350, 19371451550);

my $prefix = 40150;

my $n = 9;

foralmostprimes {

    my $t = $prefix * $_;

    if (    is_almost_prime($n, $t + $terms[-1])
        and is_almost_prime($n, $t + $terms[-2])
        and is_almost_prime($n, $t + $terms[-3])
        and vecall { is_almost_prime($n, $t + $_) } @terms) {
        die "Found: a($n) <= $t";
    }

} $n - prime_bigomega($prefix), 1e9;
