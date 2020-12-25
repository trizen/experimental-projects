#!/usr/bin/perl

# https://en.wikipedia.org/wiki/Wall%E2%80%93Sun%E2%80%93Sun_prime

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

my $k = 1;
my $lim = 970000000000000;

#~ my $k = 2;
#~ my $lim = 10000000000;

#~ my $k = 3;
#~ my $lim = 25000000000;

#~ my $k = 7;
#~ my $lim = 1000000000;

#~ my $k = 6;
#~ my $lim = 25233137;

my %seen;

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    next if $factors[-1] < $lim;

    foreach my $p (@factors) {
        if ($p > $lim) {

            my ($U, $V) = Math::Prime::Util::GMP::lucas_sequence(Math::Prime::Util::GMP::mulint($p, $p), $k, -1, $p);

            if ($V == $k) {
                next if $seen{$p}++;
                say "\nFound: $p\n";
            }
        }
    }
}

dbmclose(%db);
