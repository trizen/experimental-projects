#!/usr/bin/perl

# Palindromic pseudoprimes (base 2).
# https://oeis.org/A068445

# Known terms:
#   101101, 129921, 1837381, 127665878878566721, 1037998220228997301

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use ntheory qw(is_pseudoprime);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    ($n eq reverse($n))   or next;
    is_pseudoprime($n, 2) or next;

    next if $seen{$n}++;

    if ($n > 1037998220228997301) {
        die "New term: $n";
    }

    say $n;
}
