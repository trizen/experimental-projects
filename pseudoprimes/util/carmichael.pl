#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/programs/cache/factors.db";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub my_is_carmichael_fast ($n, $factors) {
    my $nm1 = Math::Prime::Util::GMP::subint($n, 1);
    return if not vecall {
        Math::Prime::Util::GMP::modint($nm1, ($_ < ~0) ? ($_-1) : Math::Prime::Util::GMP::subint($_, 1)) eq '0'
    } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
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

    if (my_is_carmichael_fast($n, [split(' ', $value)])) {
        say $n;
    }
}

dbmclose(%cache_db);
