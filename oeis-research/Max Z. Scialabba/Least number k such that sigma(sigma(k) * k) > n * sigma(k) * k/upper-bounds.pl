#!/usr/bin/perl

# a(n) is the least number k such that sigma(sigma(k) * k) > n * sigma(k) * k.
# https://oeis.org/A368063

# Known terms:
#   1, 2, 3, 10, 160, 12155, 26558675

use 5.036;
use ntheory;
use Math::Prime::Util::GMP qw(:all);

# a(7) <= 170075897311710390
# a(7) <= 25811934519240870
# a(7) <= 4163215245038850
# a(7) <= 2928046583754721
# a(7) <= 2458279478022940
# a(7) <= 1989452141444911
# a(7) <= 767320250907925
# a(7) <= 121155829090725

# a(7) <= 114775357632650
# a(8) <= 272113056574982766111055794421

# sigma(sigma(k) * k) > n * sigma(k) * k.

#my $prod = vecprod(5, 11, 13, 17, 19, 23, 29, 31, 37);
#my $prod = vecprod(5, 11, 13, 17, 19, 23, 29);
#my $prod = 2928046583754721;
#my $prod = vecprod(11, 13, 17, 19, 23, 29, 31, 41, 43, 73);
#my $prod = vecprod(11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67,  );
#my $prod = vecprod(11, 11, 13, 17,  23, 29, 47, 47);

my $n = 7;
my $prod = 223092870 * 73;

foreach my $j (1..1e9) {

    my $k = ntheory::mulint($prod, $j);
    my $sigma = sigma($k);
    my $v = mulint($sigma, $k);

    if (sigma($v) > mulint($n, $v)) {
        die "Found: a($n) <= $k\n";
    }
}
