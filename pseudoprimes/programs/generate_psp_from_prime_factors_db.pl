#!/usr/bin/perl

# Generate Fermat pseudoprimes of the form: p*((p-1)*k + 1), for some small constant k.

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
my $CONSTANT_K = 3;
#my $CONSTANT_K = 4;
#my $CONSTANT_K = 20;
#my $CONSTANT_K = 204;
#my $CONSTANT_K = 548;

my $MIN_P = sqrtint(divint(powint(2,64), $CONSTANT_K));

open my $fh, '>>', 'special_fermat_psp.txt';

say ":: Generating with k = $CONSTANT_K... Please wait...";

my %seen_p;

while (my ($key, $value) = each %db) {

    my @f = split(' ', $value);

    next if $f[-1] < $MIN_P;

    foreach my $p (@f) {
        if ($p > $MIN_P) {
            next if $seen_p{$p}++;
            my $t = Math::Prime::Util::mulint($p, addint(mulint($CONSTANT_K, subint($p, 1)), 1));
            if (Math::Prime::Util::GMP::is_pseudoprime($t, 2)) {
                say $fh $t;
            }
        }
    }
}

say ":: Done...";

close $fh;
dbmclose(%db);
