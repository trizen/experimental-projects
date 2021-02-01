#!/usr/bin/perl

# a(n) is the least index k such that the n-th odd squarefree number A056911(n) divides A110566(k).
# https://oeis.org/A338120

# Search for a(35).

# Lower bound:
#   a(35) > 10^7

use 5.014;
use Math::AnyNum qw(lcm inv);

my $v = 85;     # == A056911(35)

my $L = 1;      # LCM
my $H = 0;      # Harmonic

foreach my $k (1..1e8) {

    say "Testing: $k";

    $L = lcm($L, $k);
    $H += inv($k);

    if (($L / $H->denominator) % $v == 0) {
        die "\nFound: $k\n";
    }
}
