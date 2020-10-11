#!/usr/bin/perl

# k-1 for integers k>=4 such that 2^k == 4 (mod k*(k-1)*(k-2)*(k-3)/24).
# https://oeis.org/A337859

# Known terms:
#   3, 5, 37, 44101, 157081, 2031121, 7282801, 8122501, 18671941, 78550201, 208168381, 770810041, 2658625201, 2710529641, 5241663001, 14643783001, 18719308441, 56181482281, 73303609681, 74623302001, 110102454001, 140659081201

# Are there any composite integers in the sequence?

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(vecall);
use Math::Prime::Util::GMP qw(:all);
use experimental qw(signatures);

sub isok($k) {
    powmod(2, $k, divint(vecprod($k, subint($k, 1), subint($k, 2), subint($k, 3)), 24)) eq '4';
}

(vecall { isok($_+1) } (5, 37, 44101, 157081, 2031121, 7282801, 8122501, 18671941, 78550201, 208168381, 770810041, 2658625201, 2710529641, 5241663001, 14643783001, 18719308441)) || die "error";

my $storable_file = "cache/factors-fermat.storable";
my $fermat = retrieve($storable_file);

while (my ($k, $v) = each %$fermat) {
    if (isok(addint($k, 1))) {
        say $k;
    }
}

__END__

# Also in the sequence are:

74623302001
720023604301
1416018681001
69738446158921
1304840825428141
11704996230181254001
