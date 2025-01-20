#!/usr/bin/perl

# a(n) is the smallest k such that tau(k*2^n - 1) is equal to 2^n where tau = A000005.
# https://oeis.org/A377634

# Known terms:
#   2, 4, 17, 130, 1283, 6889, 40037, 638521, 10126943, 186814849

# New terms:
#   a(11) = 2092495862

# Upper-bounds:
#   a(11) <= 2546733737
#   a(12) <= 8167862431
#   a(13) <= 1052676193433
#   a(14) <= 30964627320559

use 5.036;
use ntheory qw(:all);

my $n   = 10;
my $tau = 1 << $n;

foreach my $k (1 .. 1e12) {
    if (divisors(($k << $n) - 1) == $tau) {
        die "a($n) = $k\n";
    }
}

__END__
a(10) = 186814849
perl prog.pl  478.45s user 0.59s system 72% cpu 11:02.03 total

a(11) = 2092495862 at prog.pl line 22.
perl prog.pl  7452.28s user 8.08s system 77% cpu 2:40:18.38 total
