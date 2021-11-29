#!/usr/bin/perl

# Given a pseudoprime less than 2^64, check if the number is
# inside Jan Feitsma's database of base-2 Fermat pseudoprimes < 2^64.

# TODO:
#   optimize this with binary search.

# Without binary search, it's faster to just use `bzmore` or `bzgrep`.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use IO::Uncompress::UnZstd;

my $file = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/psps-below-2-to-64.txt.zst";
my $z    = IO::Uncompress::UnZstd->new($file);

my $n = $ARGV[0];

if ($n < 341) {
    die "$n is too small.";
}

if ($n > ~0) {
    die "$n is too large. Must be < 2^64";
}

while (1) {
    chomp(my $t = $z->getline() // last);

    if ($t == $n) {
        say "OK: $n inside the list!";
        exit;
    }
    elsif ($t > $n) {
        last;
    }
}

die "ERROR: $n is not in the list!\n";
