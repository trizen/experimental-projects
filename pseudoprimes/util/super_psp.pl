#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/programs/cache/factors.db";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_super_pseudoprime ($n, $factors) {
    my $gcd = Math::Prime::Util::GMP::gcd(map{ ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } split(' ', $factors));
    Math::Prime::Util::GMP::powmod(2, $gcd, $n) eq '1';
}

#while (my ($key, $value) = each %cache_db) {
while (<>) {

    /\S/ || next;
    chomp;

    my $n = $_;

    $n > ~0 or next;

    my $value = $cache_db{$n};

    if (not defined $value) {
        warn "# $n does not exist in the DB!\n";
        next;
    }

    if (is_super_pseudoprime($n, $value)) {
        say $n;
    }
}

dbmclose(%cache_db);
