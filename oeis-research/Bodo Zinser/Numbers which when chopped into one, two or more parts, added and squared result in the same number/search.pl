#!/usr/bin/perl

# Numbers which when chopped into one, two or more parts, added and squared result in the same number
# https://oeis.org/A104113

# Generate terms of the sequence.

# See also:
#   https://projecteuler.net/problem=719

use 5.020;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);

sub isok ($i, $j, $d, $e, $n, $sum = 0) {

    if ($sum + join('', @{$d}[$i .. $e]) < $n) {
        return 0;
    }

    my $new_sum = $sum + join('', @{$d}[$i .. $j]);

    if ($new_sum > $n) {
        return 0;
    }

    if ($new_sum == $n and $j >= $e) {
        return 1;
    }

    if ($j + 1 <= $e) {
        isok($j + 1, $j + 1, $d, $e, $n, $new_sum) && return 1;
        isok($i,     $j + 1, $d, $e, $n, $sum)     && return 1;
    }

    return 0;
}

foreach my $n (2 .. 1e7) {
    my @d = todigits($n * $n);
    if (isok(0, 0, \@d, $#d, $n)) {
        say $n * $n;
    }
}
