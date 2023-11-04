#!/usr/bin/perl

# Numbers k where phi(k) divides k - 3.
# https://oeis.org/A350777

# Known terms:
#   1, 2, 3, 9, 195, 5187

# No term larger than 5187 is known...

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

use POSIX qw(ULONG_MAX);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub my_euler_phi ($factors) {    # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_mul_ui($t, $t, $p - 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, $p, 10);
            Math::GMPz::Rmpz_sub_ui($u, $u, 1);
            Math::GMPz::Rmpz_mul($t, $t, $u);
        }
    }

    return $t;
}

my $t = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %db) {

    #next if length($key) > 100;

    my @factors = split(' ', $value);

    next if $factors[-1] >= ULONG_MAX;

    my $phi = my_euler_phi(\@factors);

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    Math::GMPz::Rmpz_sub_ui($t, $t, 3);

    if (Math::GMPz::Rmpz_divisible_p($t, $phi)) {
        say $key;
    }
}

dbmclose(%db);
