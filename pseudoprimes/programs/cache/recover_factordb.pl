#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

eval { require GDBM_File };

my $cache_db = "factors.db";

dbmopen(my %db, $cache_db, 0666)
  or die "Can't create/access database <<$cache_db>>: $!";

#my $storable_file = "factors-fermat.storable";
#my $storable_file = "factors-lucas-carmichael.storable";
#my $storable_file = "factors-carmichael.storable";
my $storable_file = "factors-superpsp.storable";

my $table = retrieve($storable_file);

my $count = 0;

while(my ($key, $value) = each %$table) {
    if (not exists $db{$key}) {
        $db{$key} = $value;
    }
}

dbmclose(%db);
