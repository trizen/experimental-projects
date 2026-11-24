#!/usr/bin/perl

# Number of primary Carmichael numbers (A324316) less than 10^n.
# https://oeis.org/A324317

# Known terms:
#   0, 0, 0, 2, 4, 9, 19, 51, 107, 219, 417, 757, 1470, 2666, 5040, 9280, 17210, 32039, 59762, 111811, 210627, 397968

# New terms:
#   a(23) = 754150
#   a(24) =

use 5.036;
use strict;
use warnings;
use Math::Prime::Util::GMP qw();
use Math::Prime::Util qw(factor is_square_free todigits vecsum);

sub is_ok ($n) {
    for my $p (Math::Prime::Util::GMP::factor($n)) {
        return 0 unless (vecsum(Math::Prime::Util::GMP::todigits($n, $p)) == $p);
    }
    return 1;
}

my $len = 23;
my $skip = $len;
my $count = 754150;

while (defined(my $line = <>)) {
    chomp $line;
    next if length($line) <= $skip;

    if (length($line) != $len) {
        say "a($len) = $count";
        ++$len;
    }

    if (is_ok($line)) {
        ++$count;
    }
}

say "Final count: $count";

__END__
from sympy import factorint
from sympy.ntheory import digits
def ok(n):
    pf = factorint(n)
    if n < 2 or max(pf.values()) > 1: return False
    return all(sum(digits(n, p)[1:]) == p for p in pf)
print([k for k in range(10**6) if ok(k)]) # Michael S. Branicky, Jul 03 2022
