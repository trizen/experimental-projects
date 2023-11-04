#!/usr/bin/perl

# Find primes p such that p-1 and p+1 are both B-smooth, for some small B.

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

sub is_smooth_over_prod ($n, $k) {

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_set($t, $n);
    Math::GMPz::Rmpz_gcd($g, $t, $k);

    while (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_remove($t, $t, $g);
        return 1 if Math::GMPz::Rmpz_cmpabs_ui($t, 1) == 0;
        Math::GMPz::Rmpz_gcd($g, $t, $g);
    }

    return 0;
}

my $B     = 1e5;
my $p_min = 1e10;

my $z = Math::GMPz::Rmpz_init_nobless();
my $k = Math::GMPz::Rmpz_init_nobless();

Math::GMPz::Rmpz_primorial_ui($k, $B);

sub isok ($p) {

    if ($p < ~0) {
        is_smooth($p + 1, int(logint($p, 2)**1.75)) || return;
        is_smooth($p - 1, int(logint($p, 2)**1.75)) || return;
        return 1;
    }

    Math::GMPz::Rmpz_set_str($z, "$p", 10);
    Math::GMPz::Rmpz_add_ui($z, $z, 1);
    is_smooth_over_prod($z, $k) || return;
    Math::GMPz::Rmpz_sub_ui($z, $z, 2);
    is_smooth_over_prod($z, $k) || return;

    return 1;
}

my %seen;

use IO::Handle;
open my $fh, '>:raw', 'smooth_primes_2.txt';
$fh->autoflush(1);

while (my ($n, $value) = each %db) {

    my @factors = split(' ', $value);

    $factors[-1] > $p_min or next;

    foreach my $p (@factors) {
        $p > $p_min or next;

        #say "Checking: $p";
        if (isok($p) and !$seen{$p}++) {
            say $fh $p;
        }
    }
}

dbmclose(%db);
close $fh;
