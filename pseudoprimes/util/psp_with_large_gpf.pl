#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);

eval { require GDBM_File };

my $cache_db = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/programs/cache/factors.db";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

#while (my ($key, $value) = each %cache_db) {
while (<>) {

    /\S/ || next;
    chomp;

    my $n = $_;

    $n > ~0 or next;

    my $value = $cache_db{$n};

    if (not defined $value) {
        warn "# $n does not exist in the DB!\n";
        say $n;
        next;
    }

    my @factors = split(' ', $value);

    if (scalar(@factors) >= 3) {
        if (Math::Prime::Util::GMP::sqrtint($factors[-1]) > $factors[-2]) {

            my $v = Math::Prime::Util::GMP::vecprod(@factors[0..$#factors-1]);

            if (exists $cache_db{$v}) {
                #say "Ignoring: $n -> $v -- ", Math::Prime::Util::GMP::sqrtint($factors[-1]), " > ",  $factors[-2];
                #say $v;
                say $n;
                next;
            }
        }
    }

    #say $n;
}

dbmclose(%cache_db);
