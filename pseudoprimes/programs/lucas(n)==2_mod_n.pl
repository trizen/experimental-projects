#!/usr/bin/perl

# Odd integers n such that Lucas V_{1, -1}(n) == 2 (mod n).

# Known terms:
#   1643, 387997, 174819237, 237040185477

# a(4) was found by Giovanni Resta on 02 October 2019.

# Indices of 2 in A213060.
# https://oeis.org/A213060

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    (substr($n, -1) & 1) || next;    # n must be odd

    #~ if ($n > ((~0) >> 1)) {
    #~ $n = Math::GMPz->new("$n");
    #~ }

    my ($u, $v) = lucas_sequence($n, 1, -1, $n);

    if ($v == 2) {
        say $n;
    }
}
