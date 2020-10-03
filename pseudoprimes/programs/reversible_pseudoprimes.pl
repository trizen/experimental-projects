#!/usr/bin/perl

# Find a pair of distinct reversible psp(2) other than 15709 & 90751.

# See also:
#   https://www.primepuzzles.net/puzzles/puzz_170.htm

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    my $m = reverse($n);

    if ($m < $n) {
        ($n, $m) = ($m, $n);
    }

    if (is_pseudoprime($m, 2) and is_pseudoprime($n, 2) and !is_prime($m) and !is_prime($n) and $n ne $m) {
        say($n, " ", $m) if !$seen{$n}++;
    }
}
