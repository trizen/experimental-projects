#!/usr/bin/perl

# Generate Carmichael numbers from other numbers, that are almost abundant, using a special multiplier.

use 5.020;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(is_pseudoprime is_carmichael mulint divint vecprod gcd);

my @primes = (3, 5, 17, 23, 29);

#my @primes = (3, 5, 17);
my $multiplier = vecprod(@primes);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    my $g = gcd($n, $multiplier);

    if ($g > 1) {
        next if ($g == $multiplier);
        $n = divint($n, $g);
    }

    $n = mulint($n, $multiplier);

    $n > ~0 or next;

    #is_pseudoprime($n, 2) || next;
    is_carmichael($n) || next;

    say $n;
}
