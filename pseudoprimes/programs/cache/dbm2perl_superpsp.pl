#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::Prime::Util::GMP;

eval { require GDBM_File };

my $cache_db = "factors.db";
my $storable_file = "factors-superpsp.storable";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_super_pseudoprime ($n, $factors) {
    my $gcd = Math::Prime::Util::GMP::gcd(map{ ($_ < ~0) ? ($_-1) : Math::Prime::Util::GMP::subint($_, 1) } split(' ', $factors));
    Math::Prime::Util::GMP::powmod(2, $gcd, $n) eq '1';
}

my $table = {};

if (-e $storable_file) {
    say "# Loading data...";
    $table = retrieve($storable_file);
}

say "# Checking database...";

while (my ($key, $value) = each %cache_db) {

    next if exists $table->{$key};
    Math::Prime::Util::GMP::is_pseudoprime($key, 2) || next;

    if (is_super_pseudoprime($key, $value)) {
        $table->{$key} = $value;
    }
}

say "# Storing data...";
store($table, $storable_file);

dbmclose(%cache_db);
