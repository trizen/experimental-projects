#!/usr/bin/perl

# a(n) is the first prime that starts a string of exactly n consecutive primes that are in A347702.
# https://oeis.org/A356374

# Known terms:
#    131, 41, 11, 178909, 304290583, 8345111009

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

my $n = 7;
my $first;
my $k = 0;

forprimes {

    if ($_ % vecsum(split(//, $_)) == 1) {
        $first //= $_;
        ++$k;
        if ($k >= $n) {
            say "a($n) = ", $first;
            ++$n;
        }
    }
    elsif (defined($first)) {
        undef $first;
        $k = 0;
    }

} 3*1e11, 1e12;
