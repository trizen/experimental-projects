#!/usr/bin/perl

# Even composite integers m such that A006190(m)^2 == 1 (mod m)
# https://oeis.org/A337235

use 5.014;
use ntheory qw(:all);

my ($U, $V);
local $| = 1;
for(my $k = 4; ; $k += 2) {
     ($U, $V) = lucas_sequence($k, 3, -1, $k);

     if (mulmod($U, $U, $k) == 1) {
         print $k, ", ";
     }
}
