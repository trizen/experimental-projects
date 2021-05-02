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

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    my $v = Math::Prime::Util::GMP::vecprod(map { Math::Prime::Util::GMP::subint($_, 1) } @factors);

    if (Math::Prime::Util::GMP::modint(Math::Prime::Util::GMP::subint($key, 1), $v) == 0) {
        say $key;
    }
}

dbmclose(%db);

__END__

# No other non-power terms > 2^64 are known.
