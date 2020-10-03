#!/usr/bin/perl

# https://en.wikipedia.org/wiki/Wieferich_prime

# See also:
#   https://oeis.org/A001220 -- Wieferich primes: primes p such that p^2 divides 2^(p-1) - 1.
#   https://oeis.org/A039951 -- Smallest prime p such that p^2 divides n^(p-1) - 1.

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

my $base = 2;
my $lim  = 1250000000000000;

#~ my $base = 5;
#~ my $lim = 970000000000000;

#~ my $base = 6;
#~ my $lim = 41190000000000;

#~ my $base = 7;
#~ my $lim = 970000000000000;

#~ my $base = 10;
#~ my $lim = 117200000000000;

#~ my $base = 47;
#~ my $lim = 49000000000000;

#~ my $base = 15;
#~ my $lim = 50000000000000;

#~ my $base = 17;
#~ my $lim = 100000000000000;

#~ my $base = 23;
#~ my $lim  = 31270000000000;

#~ my $base = 30;
#~ my $lim = 98000000000000;

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    next if $factors[-1] < $lim;

    foreach my $p (@factors) {
        if ($p > $lim and Math::Prime::Util::GMP::powmod($base, Math::Prime::Util::GMP::subint($p, 1), Math::Prime::Util::GMP::mulint($p, $p)) eq '1') {
            say "\nFound: $p\n";
        }
    }
}

dbmclose(%db);
