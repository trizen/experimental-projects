#!/usr/bin/perl

# Find a twin psp(2) other than 4369 and 4371.

# See also:
#   https://www.primepuzzles.net/puzzles/puzz_170.htm

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

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    is_pseudoprime($n, 2) || next;

    if (is_pseudoprime($n + 2, 2) and !is_prime($n + 2)) {
        say($n, " ", $n + 2) if !$seen{$n}++;
    }

    if (is_pseudoprime($n - 2, 2) and !is_prime($n - 2)) {
        say($n - 2, " ", $n) if !$seen{$n - 2}++;
    }
}
