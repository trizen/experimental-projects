#!/usr/bin/perl

# Composite numbers k such that A003958(k) divides k-1.
# https://oeis.org/A340093
# where A003958(n) is completely multiplicative with A003958(p) = p-1.

# Known terms:
#   4, 8, 9, 16, 32, 64, 81, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 180225, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648

# Are there any other non-powers of 2 apart from 9, 81, 180225 (= 3^4 * 5^2 * 89) present?

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
        return 1 if Math::GMPz::Rmpz_cmp_ui($t, 1) == 0;
        Math::GMPz::Rmpz_gcd($g, $t, $g);
    }

    return 0;
}

my $t = Math::GMPz::Rmpz_init();

my $primorial = Math::GMPz::Rmpz_init();
Math::GMPz::Rmpz_primorial_ui($primorial, 1e5);

while (my ($key, $value) = each %db) {

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    #~ Math::GMPz::Rmpz_add_ui($t, $t, 1);
    Math::GMPz::Rmpz_sub_ui($t, $t, 1);

    next if (Math::GMPz::Rmpz_popcount($t) == 1);
    is_smooth_over_prod($t, $primorial) || next;

    my $n = Math::GMPz::Rmpz_get_str($t, 10);
    my @factors = Math::Prime::Util::GMP::factor($n);

    my $v = Math::Prime::Util::GMP::vecprod(map { subint($_, 1) } @factors);

    if (Math::Prime::Util::GMP::modint($n, $v) == 1) {
        say $n;
    }
}

dbmclose(%db);

__END__

# Number k such that A003958(k) divides k, where k-1 is a Lucas pseudoprime:

435272313093488640000
3421183043174400000000
