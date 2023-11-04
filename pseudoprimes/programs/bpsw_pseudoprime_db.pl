#!/usr/bin/perl

# Try to find a BPSW pseudoprime.

use 5.036;
use Math::Prime::Util::GMP;

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

while (my ($n) = each %db) {

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    if (Math::Prime::Util::GMP::is_lucas_pseudoprime($n)) {
        die "BPSW counter-example: $n";
    }
    elsif (Math::Prime::Util::GMP::is_almost_extra_strong_lucas_pseudoprime($n)) {
        die "BPSW counter-example: $n";
    }
}
