#!/usr/bin/perl

# a(n) is the smallest centered n-gonal number with exactly n prime factors (counted with multiplicity).
# https://oeis.org/A358926

# Known terms:
#   316, 1625, 456, 3964051, 21568, 6561, 346528

# PARI/GP program:
#    a(n) = if(n<3, return()); for(k=1, oo, my(t=((n*k*(k+1))/2+1)); if(bigomega(t) == n, return(t))); \\ ~~~~

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub a($n) {
    for(my $k = 1; ;++$k) {
        my $v = divint(mulint($n*$k, ($k + 1)), 2) + 1;
        if (is_almost_prime($n, $v)) {
            return $v;
        }
    }
}

foreach my $n(3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 316
a(4) = 1625
a(5) = 456
a(6) = 3964051
a(7) = 21568
a(8) = 6561
a(9) = 346528
a(10) = 3588955448828761
a(11) = 1684992
a(12) = 210804461608463437
a(13) = 36865024
a(14) = 835904150390625
a(15) = 2052407296
