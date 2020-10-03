#!/usr/bin/perl

# Try to find a composite number that is both a Lucas pseudoprime and a base-2 Fermat pseudoprime.

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

while (<>) {

    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;

    is_pseudoprime($n, 2) || next;

    if (   is_lucas_pseudoprime($n)
        || is_extra_strong_lucas_pseudoprime($n)
        || is_almost_extra_strong_lucas_pseudoprime($n)) {
        die "Counter-example: $n";
    }
}

say "No counter-example found...";
