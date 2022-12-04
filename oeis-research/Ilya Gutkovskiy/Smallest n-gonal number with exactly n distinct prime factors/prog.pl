#!/usr/bin/perl

# a(n) is the smallest n-gonal number with exactly n distinct prime factors.
# https://oeis.org/A358862

# Known terms:
#   66, 44100, 11310, 103740, 3333330, 185040240, 15529888374, 626141842326, 21647593547580

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=(k*(n*k - n - 2*k + 4))\2); if(omega(t) == n, return(t)));

sub a($n) {

    for(my $k = 1; ; ++$k) {

        #my $t = divint(mulint($k, ($n*$k - $n - 2*$k + 4)), 2);
        my $t = rshiftint(mulint($k, ($n*$k - $n - 2*$k + 4)), 1);
        #my $t = ($k * ($n*$k - $n - 2*$k + 4))>>1;

        if (prime_omega($t) == $n) {
            return $t;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 66
a(4) = 44100
a(5) = 11310
a(6) = 103740
a(7) = 3333330
a(8) = 185040240
a(9) = 15529888374
a(10) = 626141842326
a(11) = 21647593547580
a(12) = 351877410344460
a(13) = 82634328555218440
