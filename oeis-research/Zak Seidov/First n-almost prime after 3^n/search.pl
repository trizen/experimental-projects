#!/usr/bin/perl

# a(n) is the least positive number k such that 3^n + k is n-almost prime (first n-almost prime after 3^n).
# https://oeis.org/A337219

# Known terms:
#   2, 1, 1, 3, 9, 7, 21, 63, 157, 471, 5, 15, 45, 135, 405, 1215, 3645, 10935, 32805, 98415, 295245, 885735, 2657205, 4409119, 2741597, 8224791, 16285765, 15302863, 45908589, 137725767, 77632981, 232898943, 161825917, 485477751, 1456433253, 3027122479, 1565174669, 4695524007, 14086572021

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

sub a {
    my ($n) = @_;

    my $p = powint(3, $n);

    foreach my $k (1 .. 1e10) {
        if (is_almost_prime($n, addint($p, $k))) {
            return $k;
        }
    }

    return undef;
}

sub a_faster {
    my ($n, $prev) = @_;

    my $p     = powint(3, $n);
    my $found = undef;

    foralmostprimes {

        $found = subint($_, $p);
        lastfor, return $found;

    } $n, addint($p, 1), addint($p, mulint(3, $prev));

    return $found;
}

local $| = 1;
my $prev = 2;

foreach my $n (1 .. 100) {
    my $v = a_faster($n, $prev) // last;
    print($v, ", ");
    $prev = $v;
}
