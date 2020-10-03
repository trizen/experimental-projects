#!/usr/bin/perl

# Indices m such that A008348(m) = 0.
# https://oeis.org/A309225

# A008348 is defined as:
#   a(0)=0, a(n) = a(n-1) + prime(n) if a(n-1) < prime(n) else a(n-1) - prime(n).

# There seems to be jumps of magnitude ~2.8 when the sequence gets very close to zero.

# Open problem: are there infinitely many zeros in this sequence?

# The only known zeros occur at the following indices:
#   0, 3, 369019, 22877145

# The next zero, if it exists, it occurs at an index > 37607912018.
# In other words, A309225(5) > pi(10^12).

# See also:
#   https://oeis.org/A008348

use 5.014;
use ntheory qw(:all);

my $n     = 0;
my $count = 0;

forprimes {

    ($n < $_) ? ($n += $_) : ($n -= $_);

    if ($n == 0) {
        my $count = prime_count($_);
        say "a($count) = $n";
    }

} 1e12;

__END__
a(133098) = 91
a(133100) = 33
a(133102) = 15
a(133104) = 9
a(133106) = 1

a(369001) = 100
a(369003) = 88
a(369005) = 82
a(369007) = 76
a(369009) = 68
a(369011) = 56
a(369013) = 34
a(369015) = 16
a(369017) = 12
a(369019) = 0

a(1028394) = 93
a(1028396) = 75
a(1028398) = 69
a(1028400) = 45
a(1028402) = 39
a(1028404) = 27

a(2880273) = 100
a(2880275) = 78
a(2880277) = 58
a(2880279) = 56
a(2880281) = 48
a(2880283) = 38
a(2880285) = 14
a(2880287) = 6

a(8100936) = 97
a(8100938) = 91
a(8100940) = 79
a(8100942) = 67
a(8100944) = 55
a(8100946) = 45
a(8100948) = 17

a(22877139) = 68
a(22877141) = 28
a(22877143) = 14
a(22877145) = 0

a(64823556) = 95
a(64823558) = 81
a(64823560) = 39
a(64823562) = 25
a(64823564) = 17
a(64823566) = 9
a(64823568) = 7

a(184274927) = 78
a(184274929) = 36
a(184274931) = 6

a(525282738) = 53
a(525282740) = 47
