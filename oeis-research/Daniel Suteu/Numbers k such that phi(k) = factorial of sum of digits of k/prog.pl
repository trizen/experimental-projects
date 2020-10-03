#!/usr/bin/perl

# Numbers k such that phi(k) = (sum of digits of k)!.
# https://oeis.org/A???????

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

#use Math::AnyNum qw();
#use Math::GMPz;
#use Math::GMP qw(:constant);

# Finding terms for t = 16, requires over 6 GB of RAM.

my @values;

foreach my $t (1..15) {

    say "Processing: $t";
    my $n = factorial($t);

    foreach my $k (inverse_totient($n)) {
        #say "Testing: $k";
        if (vecsum(split(//, $k)) == $t) {
            push @values, $k;
        }
    }
}

local $| = 1;

foreach my $value (sort { $a <=> $b } @values) {
    print($value, ", ");
}

say '';

__END__
1, 1221, 101600, 112112, 121220, 1310022, 1412010, 1600200, 10071100, 10100350, 10311400, 10612000, 10621000, 11002600, 12130300, 100020080, 102202400, 104111300, 110100530, 113321000, 120020600, 1011041031, 1112011005, 2010003600, 2010232200, 2011012410, 2011110024, 2013030012, 2023030020, 2023210200, 2031011400, 2100710010, 2101140300, 2102050020, 2110110240, 2133012000, 16000132000, 100105041101, 102202041011, 102511020101, 103000314011, 111021340001, 232110023000, 233110101020, 240120002300, 2102001113013, 2200014130011, 3102220000005
