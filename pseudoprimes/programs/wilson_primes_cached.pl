#!/usr/bin/perl

# https://en.wikipedia.org/wiki/Wilson_prime

# TODO: optimize!

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

#my $storable_file = "cache/factors-fermat.storable";
#my $storable_file = "cache/factors-lucas-carmichael.storable";
#my $fermat = retrieve($storable_file);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $min = 20000000000000;
my $max = 281474976710656;

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    next if $factors[-1] < $min;

    foreach my $p (@factors) {
        if ($p > $min and $p < $max) {

            my $n = Math::Prime::Util::GMP::subint($p, 1);
            my $m = Math::Prime::Util::GMP::mulint($p, $p);

            say "Checking: $p";

            my $r = Math::Prime::Util::GMP::factorialmod($n, $m);

            if ($r eq Math::Prime::Util::GMP::subint($m, 1)) {
                say "\nFound: $p\n";
            }
        }
    }
}

dbmclose(%db);
