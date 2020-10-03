#!/usr/bin/perl

# Integers n such that the n-th prime divides the n-th Pell number (A000129(n)).
# https://oeis.org/A270493

# Known terms:
#   3, 10, 45, 1710, 308961, 601929, 732202, 2214702, 7626372, 13976550, 21971144, 27575700, 207268867,

use 5.014;
use ntheory qw(:all);

local $| = 1;
my $count = 1;

forprimes {

    if ((lucas_sequence($_, 2, -1, $count))[0] == 0) {
        print($count, ", ");
    }

    ++$count;
} 1e11;
