#!/usr/bin/perl

# a(0) = 0; thereafter a(n) = a(n-1) + phi(n) if phi(n) > a(n-1), otherwise a(n) = a(n-1) - phi(n), where phi is the Euler phi-function A000010.
# https://oeis.org/A327443

# Known terms:
#   0, 2, 4, 13, 145, 416, 621, 1856, 4730, 5163, 8113, 18260, 142396, 1650399, 6569927, 19975865, 23773865, 371728346, 517406582, 642281555

use 5.014;
use ntheory qw(:all);

local $| = 1;

my $term = 0;
my $n    = 0;

#my $n = 642281555;             # uncomment this to search for more terms
my $phi = euler_phi($n + 1);

while (1) {

    if ($term == 0) {
        print($n, ", ");
    }

    if ($phi > $term) {
        $term += $phi;
    }
    else {
        $term -= $phi;
    }

    ++$n;
    $phi = euler_phi($n + 1);
}
