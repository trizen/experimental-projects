#!/usr/bin/perl

# Find pseudoprimes to base 2 with small znorder z. Such pseudoprimes divide 2^z - 1.

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

my %table;

while (my ($n, $value) = each %db) {

    my @factors = split(' ', $value);
    my $count   = scalar @factors;

    length($factors[0])  >= 10 or next;
    length($factors[-1]) <= 60 or next;

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    znorder(2, $factors[0])  < 1e6 or next;
    znorder(2, $factors[-1]) < 1e6 or next;

    my $z = lcm(map {znorder(2, $_)} @factors);

    if ($z < 1e6) {
        say "2^$z-1 = $n";
    }
}

dbmclose(%db);
