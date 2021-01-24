#!/usr/bin/perl

# Least positive number k such that sigma(k) = n * sigma(k+1).
# https://oeis.org/A340720

# Known terms:
#   14, 12, 180, 25908120

# a(5) > 53117846646, based on data from A058073.

use 5.014;
use ntheory qw(:all);

my @primes = grep { is_smooth($_+1, 11) } @{primes(1e3)};

my $comb = 5;
say ":: Combinations: 10^", log(binomial(scalar(@primes), $comb))/log(10);

forcomb {
    my $k = vecprod(@primes[@_])-1;

    if (modint(divisor_sum($k), divisor_sum($k+1)) == 0) {
        my $r = divint(divisor_sum($k), divisor_sum($k+1));
        if ($r >= 4) {
            say "$r -> $k";
        }
    }

} scalar(@primes), $comb;

__END__
4 -> 1435055809320
