#!/usr/bin/perl

# Palindromic Bruckman-Lucas pseudoprimes.
# https://oeis.org/A005845

# Known terms:
#   15251, 1625261, 14457475441

use 5.036;
use ntheory                qw(:all);
use Math::Prime::Util::GMP qw();

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    ($n eq reverse($n))                                                                              or next;
    (($n > ~0) ? Math::Prime::Util::GMP::lucasvmod(1, -1, $n, $n) : lucasvmod(1, -1, $n, $n)) eq '1' or next;

    next if $seen{$n}++;

    say $n;
}
