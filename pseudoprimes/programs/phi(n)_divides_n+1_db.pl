#!/usr/bin/perl

# Numbers n such that phi(n) divides n+1, where phi is Euler's totient function (A000010).
# https://oeis.org/A203966

# Known terms:
#   1, 2, 3, 15, 255, 65535, 83623935, 4294967295, 6992962672132095

# No term > 2^64 is known.

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use POSIX qw(ULONG_MAX);

use Math::GMPz;
use List::Util qw(uniq);
use ntheory    qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

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

my $z = Math::GMPz::Rmpz_init();

my @results;

while (my ($key, $value) = each %db) {

    Math::Prime::Util::GMP::modint($key, 3 * 5 * 17) == 0 or next;    # conjecture

    my @factors = split(' ', $value);

    scalar(@factors) >= 7 or next;

    #$factors[-1] < ~0 or next;

    my $phi = my_euler_phi(\@factors);

    Math::GMPz::Rmpz_set_str($z, $key, 10);
    Math::GMPz::Rmpz_add_ui($z, $z, 1);

    if (Math::GMPz::Rmpz_divisible_p($z, $phi)) {
        say "Almost counter-example: $key";
        if (join(' ', @factors) eq join(' ', uniq(@factors))) {
            die "Found counter-example: $key";
        }
    }
}

say "No counter-example found...";
