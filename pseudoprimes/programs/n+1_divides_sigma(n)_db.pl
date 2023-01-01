#!/usr/bin/perl

# Try to find a squarefree number n such that n+1 | sigma(n).

# See also:
#   https://math.stackexchange.com/questions/4576393/if-n-is-square-free-and-n1-mid-sigman-is-n-a-prime

# No counter-example found...

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use POSIX qw(ULONG_MAX);

use Math::GMPz;
use List::Util qw(uniq);
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub my_sigma ($factors) { # assumes n is squarefree

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_set_ui($t, 1);

    foreach my $p (@$factors) {
        if ($p < ULONG_MAX) {
            Math::GMPz::Rmpz_mul_ui($t, $t, $p + 1);
        }
        else {
            Math::GMPz::Rmpz_set_str($u, $p, 10);
            Math::GMPz::Rmpz_add_ui($u, $u, 1);
            Math::GMPz::Rmpz_mul($t, $t, $u);
        }
    }

    return $t;
}

my $z = Math::GMPz::Rmpz_init();

my @results;

while (my ($key, $value) = each %db) {

    Math::Prime::Util::GMP::modint($key, 4) == 3 or next;

    my @factors = split(' ', $value);

    scalar(@factors) >= 4 or next;

    #$factors[-1] < ~0 or next;

    my $sigma = my_sigma(\@factors);

    Math::GMPz::Rmpz_set_str($z, $key, 10);
    Math::GMPz::Rmpz_add_ui($z, $z, 1);

    if (Math::GMPz::Rmpz_divisible_p($sigma, $z)) {
        say "Almost counter-example: $z";
        if (join(' ', @factors) eq join(' ', uniq(@factors))) {
            die "Found counter-example: $z";
        }
    }
}

say "No counter-example found...";
