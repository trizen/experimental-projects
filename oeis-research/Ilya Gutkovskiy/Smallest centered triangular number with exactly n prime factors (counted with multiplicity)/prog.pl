#!/usr/bin/perl

# a(n) is the smallest centered triangular number with exactly n prime factors (counted with multiplicity).
# https://oeis.org/A358929

# Known terms:
#   1, 19, 4, 316, 136, 760, 64, 4960, 22144, 103360, 27136, 5492224, 1186816, 41414656, 271212544, 559980544, 1334788096, 12943360, 7032930304, 527049293824, 158186536960, 1096295120896

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = for(k=0, oo, my(t=3*k*(k+1)/2 + 1); if(bigomega(t) == n, return(t))); \\ ~~~~

sub a($n) {
    for(my $k = 0; ;++$k) {
        my $v = divint(mulint(3*$k, ($k + 1)), 2) + 1;
        if (is_almost_prime($n, $v)) {
            return $v;
        }
    }
}

foreach my $n(1..100) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 19
a(2) = 4
a(3) = 316
a(4) = 136
a(5) = 760
a(6) = 64
a(7) = 4960
a(8) = 22144
a(9) = 103360
a(10) = 27136
a(11) = 5492224
a(12) = 1186816
a(13) = 41414656
a(14) = 271212544
a(15) = 559980544
a(16) = 1334788096
a(17) = 12943360
a(18) = 7032930304
a(19) = 527049293824
a(20) = 158186536960
a(21) = 1096295120896
a(22) = 7871801589760
a(23) = 154690378792960
a(24) = 13071965224960
a(25) = 56262393856
a(26) = 964655941943296
a(27) = 412520972025856
a(28) = 20756701338664960
