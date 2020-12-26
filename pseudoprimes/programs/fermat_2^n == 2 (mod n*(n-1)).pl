#!/usr/bin/perl

# Composite values of n such that 2^n == 2 (mod n*(n-1)).
# https://oeis.org/A217468

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;
    next if length($n) > 40;

    is_pseudoprime($n, 2) || next;
    $n = Math::GMPz->new($n);

    if (powmod(2, $n, $n * ($n - 1)) == 2) {
        say $n;
    }
}
