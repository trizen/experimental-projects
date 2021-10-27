#!/usr/bin/perl

# Generate pseudoprimes using the prime factors of other pseudoprimes.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

warn ":: Sieving primes...\n";

my $B = 10_000_000;    # smooth value

my %seen;

while (my ($key, $value) = each %db) {
    foreach my $p (split(' ', $value)) {

        length($p) < 150 or next;

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

dbmclose(%db);
