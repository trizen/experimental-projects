#!/usr/bin/perl

# Generate Fermat pseudoprimes of the form: n*((n-1)*k + 1), for some small constant k where n is also a Fermat pseudoprime.

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

#my $CONSTANT_K = 2;
my $CONSTANT_K = 4;
#my $CONSTANT_K = 20;
#my $CONSTANT_K = 204;
#my $CONSTANT_K = 548;

open my $fh, '>>', 'special_fermat_psp.txt';

say ":: Generating with k = $CONSTANT_K... Please wait...";

my %seen_p;

while (my ($n, $value) = each %db) {
    my $t = Math::Prime::Util::mulint($n, addint(mulint($CONSTANT_K, subint($n, 1)), 1));
    if (Math::Prime::Util::GMP::is_pseudoprime($t, 2)) {
        say $fh $t;
    }
}

say ":: Done...";

close $fh;
dbmclose(%db);
