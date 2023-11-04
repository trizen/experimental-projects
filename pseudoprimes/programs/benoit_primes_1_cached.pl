#!/usr/bin/perl

# Integers k>=3 such that 2^k == 2 (mod k*(k-1)*(k-2)/6).
# https://oeis.org/A337858

# Known terms:
#   3, 5, 37, 101, 44101, 3766141, 8122501, 18671941, 35772661, 36969661, 208168381, 425420101, 725862061, 778003381, 818423101, 1269342901, 9049716901, 27221068981

# Are there any composite integers in the sequence?

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory                qw(vecall);
use Math::Prime::Util::GMP qw(:all);
use experimental           qw(signatures);

sub isok ($k) {
    powmod(2, $k, divint(vecprod($k, subint($k, 1), subint($k, 2)), 6)) eq '2';
}

(
 vecall { isok($_) } (
   5, 37, 101, 44101, 3766141, 8122501, 18671941, 35772661, 36969661, 208168381, 425420101, 725862061, 778003381, 818423101, 1269342901, 9049716901, 27221068981
                     )
)
  || die "error";

my $storable_file = "cache/factors-fermat.storable";
my $fermat        = retrieve($storable_file);

while (my ($k, $v) = each %$fermat) {
    if (isok($k)) {
        say $k;
    }
}

__END__

# Also in the sequence are:

700212813301
720023604301
3930870123181
1304840825428141
