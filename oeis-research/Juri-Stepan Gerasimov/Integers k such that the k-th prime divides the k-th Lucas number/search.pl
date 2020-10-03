#!/usr/bin/perl

# Integers k such that the k-th prime divides the k-th Lucas number.
# https://oeis.org/A328784

# Known terms:
#   2, 4, 5, 608, 1221, 60264, 205965, 994856, 69709961

use 5.014;
use ntheory qw(:all);

local $| = 1;
my $count = 1;

forprimes {

    if ((lucas_sequence($_, 1, -1, $count))[1] == 0) {
        print($count, ", ");
    }

    ++$count;
} 1e11;

# 69709961, 3140421767
