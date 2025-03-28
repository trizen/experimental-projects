#!/usr/bin/perl

# a(n) is the smallest n-gonal number with exactly n prime factors (counted with multiplicity).
# https://oeis.org/A358863

# Known terms:
#   28, 16, 176, 4950, 8910, 1408, 346500, 277992, 7542080, 326656, 544320, 120400000, 145213440, 48549888, 4733575168, 536813568, 2149576704, 3057500160, 938539560960, 1358951178240

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=(k*(n*k - n - 2*k + 4))\2); if(bigomega(t) == n, return(t)));

# PARI/GP program for A359014:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=(k*(n*k - n - 2*k + 4))\2); if(bigomega(t) == n, return(k)));

sub a($n) {

    for(my $k = 1; ; ++$k) {

        #my $t = divint(mulint($k, ($n*$k - $n - 2*$k + 4)), 2);
        my $t = rshiftint(mulint($k, ($n*$k - $n - 2*$k + 4)), 1);
        #my $t = ($k * ($n*$k - $n - 2*$k + 4))>>1;

        #if (prime_bigomega($t) == $n) {
        if (is_almost_prime($n, $t)) {
            return $t;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 28
a(4) = 16
a(5) = 176
a(6) = 4950
a(7) = 8910
a(8) = 1408
a(9) = 346500
a(10) = 277992
a(11) = 7542080
a(12) = 326656
a(13) = 544320
a(14) = 120400000
a(15) = 145213440
a(16) = 48549888
a(17) = 4733575168
a(18) = 536813568
a(19) = 2149576704
a(20) = 3057500160
a(21) = 938539560960
a(22) = 1358951178240
a(23) = 36324805836800
a(24) = 99956555776
a(25) = 49212503949312
a(26) = 118747221196800
a(27) = 59461613912064
a(28) = 13749193801728
a(29) = 7526849672380416
a(30) = 98516240758210560
a(31) = 4969489493917696
a(32) = 78673429816934400
a(33) = 4467570822566903808
a(34) = 1013309912383488000
