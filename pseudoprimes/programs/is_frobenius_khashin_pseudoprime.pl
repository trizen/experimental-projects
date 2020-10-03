#!/usr/bin/perl

# Try to find a Frobenius-Khashin pseudoprime.

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::Prime::Util::GMP qw(is_frobenius_khashin_pseudoprime);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;

    if (is_frobenius_khashin_pseudoprime($n)) {
        die "\nCounter-example: $n\n";
    }
}

say "No counter-example found...";
