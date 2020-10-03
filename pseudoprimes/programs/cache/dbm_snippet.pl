#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

eval { require GDBM_File };

my $cache_db = "factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $count = 0;

while (my ($key, $value) = each %db) {
    if (is_pseudoprime($key, 2)) {
        #my @factors = split(' ', $value);
        #say "$key -> [@$value]";
        ++$count;
    }
}

say "There are $count Fermat pseudoprimes to base 2";

dbmclose(%db);
