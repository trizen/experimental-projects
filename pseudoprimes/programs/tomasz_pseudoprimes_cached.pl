#!/usr/bin/perl

# Thomas Ordowski asked:
#   Are there composite numbers n such that 2^n - 1 has all prime divisors p == 1 (mod n) ?

# If both 2^p - 1 and 2^q - 1 are prime and n = pq is pseudoprime, then n is such a number.

# However, the known Mersenne primes do not give such pseudoprimes.

# http://list.seqfan.eu/pipermail/seqfan/2018-October/018943.html

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-fermat.storable";
my $numbers       = retrieve($storable_file);

while (my ($n, $value) = each %$numbers) {

    my @f = split(' ', $value);

    if (vecall { Math::Prime::Util::GMP::modint($_, $n) eq '1' } @f) {
        say $n;
    }
}

__END__

# No such number is currently known.
