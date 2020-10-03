#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use Math::Prime::Util::GMP;

eval { require GDBM_File };

my $cache_db = "factors.db";
my $storable_file = "factors-fermat.storable";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $table = {};

if (-e $storable_file) {
    say "# Loading data...";
    $table = retrieve($storable_file);
}

say "# Checking database...";

while (my ($key, $value) = each %cache_db) {

    next if exists $table->{$key};

    if (Math::Prime::Util::GMP::is_pseudoprime($key, 2)) {
        $table->{$key} = $value;
    }
}

say "# Storing data...";
store($table, $storable_file);

dbmclose(%cache_db);
