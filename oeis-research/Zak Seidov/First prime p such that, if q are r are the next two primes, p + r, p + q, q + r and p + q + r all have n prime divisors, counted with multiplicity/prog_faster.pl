#!/usr/bin/perl

# a(n) is the first prime p such that, if q are r are the next two primes, p + r, p + q, q + r and p + q + r all have n prime divisors, counted with multiplicity.
# https://oeis.org/A368786

# Known terms:
#   1559, 4073, 45863, 1369133, 82888913, 754681217

# New terms:
#   a(9) = 118302786439

use 5.036;
use ntheory qw(:all);

my $n = 10;

my ($p, $q, $r) = (2, 3, 5);

forprimes {

    if (is_almost_prime($n, $p+$r) and is_almost_prime($n, $p+$q) and is_almost_prime($n, $q+$r) and is_almost_prime($n, $p+$q+$r)) {
        die "a($n) = $p\n";
    }

    ($p, $q, $r) = ($q, $r, $_);
} $r+1, 1e13;

__END__
a(9) = 118302786439
perl prog_faster.pl  3277.45s user 8.47s system 95% cpu 57:15.33 total
