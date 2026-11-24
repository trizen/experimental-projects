#!/usr/bin/perl

# Number of primary Carmichael numbers (A324316) less than 10^n.
# https://oeis.org/A324317

# Known terms:
#   0, 0, 0, 2, 4, 9, 19, 51, 107, 219, 417, 757, 1470, 2666, 5040, 9280, 17210, 32039, 59762, 111811, 210627, 397968

# New terms:
#   a(23) = 754150
#   a(24) = 1329780

use 5.036;
use strict;
use warnings;
use Math::GMPz;
use Math::Prime::Util::GMP qw(gcd todigits factor vecprod);
use Math::Prime::Util qw(vecsum vecall primes);

sub is_ok ($n) {
    for my $p (factor($n)) {
        return 0 unless (vecsum(todigits($n, $p)) == $p);
    }
    return 1;
}

my $len = 23;
#my $len = 11;
my $skip = $len;
#my $count = 417;
my $count = 754150;

my $primorial = vecprod(@{primes(3, 300)});

while (defined(my $line = <>)) {
    chomp $line;
    next if length($line) <= $skip;

    if (length($line) != $len) {
        say "a($len) = $count";
        ++$len;
    }

    my $gcd = gcd($line, $primorial);

    if ($gcd ne '1') {
        next if not vecall { vecsum(todigits($line, $_)) == $_ } Math::Prime::Util::factor($gcd);
    }

    if (is_ok($line)) {
        ++$count;
    }
}

say "Final count: $count";

__END__
a(1) = 0
a(2) = 0
a(3) = 0
a(4) = 2
a(5) = 4
a(6) = 9
a(7) = 19
a(8) = 51
a(9) = 107
a(10) = 219
a(11) = 417
a(12) = 757
a(13) = 1470
a(14) = 2666
a(15) = 5040
a(16) = 9280
a(17) = 17210
a(18) = 32039
a(19) = 59762
a(20) = 111811
a(21) = 210627
a(22) = 397968
a(23) = 754150
a(24) = 1329780
