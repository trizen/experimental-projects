#!/usr/bin/perl

# Extract primes from Carmichael numbers that satisfy Pomerance's conditions for being a factor a PSW pseudoprime.

use 5.020;
use strict;
use warnings;

use Storable;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

#my $storable_file = "cache/factors-carmichael.storable";
my $storable_file = "cache/factors-lucas-carmichael.storable";
my $carmichael    = retrieve($storable_file);

my $B = 100_000;    # smooth value

my %seen;

while (my ($n, $value) = each %$carmichael) {

    foreach my $p (split(' ', $value)) {

        length($p) < 100 or next;

        modint($p, 8) == 3     or next;
        kronecker(5, $p) == -1 or next;

        next if exists $seen{$p};
        undef $seen{$p};

        # Conditions for p +/- 1
        my $pp1 = addint($p, 1);
        my $pm1 = subint($p, 1);

        modint($pp1, 4) == 0 or next;
        modint($pp1, 8) != 0 or next;
        modint($pm1, 4) != 0 or next;

        my $pm1d2 = divint($pm1, 2);
        my $pp1d4 = divint($pp1, 4);

        modint($pm1d2, 4) == 1 or next;

        is_smooth($pp1d4, $B) or next;
        is_smooth($pm1d2, $B) or next;

        #is_square_free($pp1d4) or next;
        #is_square_free($pm1d2) or next;

        next if not vecall { modint($_, 4) == 3 } factor($pp1d4);
        next if not vecall { modint($_, 4) == 1 } factor($pm1d2);

        say $p;
    }
}
