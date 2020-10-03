#!/usr/bin/perl

# Try to find a Fibonacci pseudoprime `n` such that `legendre(n,5) = -1` and `n` is also a Fermat pseudoprime to base 2.
# The reward for such pseudoprime is $620.

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::Prime::Util::GMP qw(lucas_sequence is_pseudoprime divrem addint);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    next if $n < ~0;

    my $r = divrem($n, 5);
    ($r == 2) or ($r == 3) or next;

    is_pseudoprime($n, 2) or next;

    say "Testing: $n";

    if ((lucas_sequence($n, 1, -1, addint($n, 1)))[0] == 0) {
        die "\nCounter-example: $n\n";
    }
}

say "No counter-example was found...";
