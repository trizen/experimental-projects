#!/usr/bin/perl

# Sum of the first r nonsquares equals the sum of the first s squares.
# https://oeis.org/A355371

# Intersection of A000330 and A086849.

# Known terms:
#    5, 91, 506, 650, 11440

#  If it exists, a(6) > 5.4*10^12.

# New lower-bound (if a(6) exists):
#   a(6) > 3348959773123132416

use 5.014;
use strict;
use warnings;

use ntheory qw(divint vecprod);

for my $n (2588000000 .. 1e10) {

    my $w = sqrt($n);
    my $k = int(1/2 + ($n + $w)*($n/2 + $w/6 + 1/3) - $w*(int(1/2 + $w) - $w)**2);
    my $t = (((sqrt(11664*$k**2 - 3) + 108*$k)**(1/3) / 3**(2/3) + 1/(3*sqrt(11664*$k**2 - 3) + 324*$k)**(1/3) - 1)/2);

    my $u = sprintf('%.0f', $t);
    my $z = divint(vecprod($u,($u+1),(2*$u+1)), 6);

    if ($n % 1e6 == 0) {
        say "Checking: $n with k = $k";
    }

    if ($z == $k) {
        say "Found: $k with t = $t";
        die "New term: $k" if ($k > 11440);
    }
}
