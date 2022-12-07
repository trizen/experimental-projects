#!/usr/bin/perl

# a(n) is the smallest n-gonal pyramidal number divisible by exactly n n-gonal pyramidal numbers.
# https://oeis.org/A358860

# Known terms:
#   56, 140, 4200, 331800, 611520, 8385930

# PARI/GP program:
#   pyramidal(k,r)=(k*(k+1)*((r-2)*k + (5-r)))\6;
#   ispyramidal(n,r)=my(k=sqrtnint(6*n\(r-2), 3)); pyramidal(k,r) == n;
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=pyramidal(k,n)); if(sumdiv(t, d, ispyramidal(d, n)) == n, return(t)));

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub pyramidal ($k, $r) {
    divint(vecprod($k, ($k+1), ($r-2)*$k + (5-$r)), 6);
}

sub is_pyramidal($n, $r) {
    my $k = rootint(divint(mulint($n, 6), $r-2), 3);
    pyramidal($k, $r) == $n;
}

sub a($n) {
    for(my $k = 1; ; ++$k) {
        my $t = pyramidal($k, $n);

        my $count = 0;
        foreach my $d (divisors($t)) {
            if (is_pyramidal($d, $n)) {
                ++$count;
                last if ($count > $n);
            }
        }

        if ($count == $n) {
            return $t;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 56
a(4) = 140
a(5) = 4200
a(6) = 331800
a(7) = 611520
a(8) = 8385930
a(9) = 2334564960
a(10) = 4775553032250
a(11) = 1564399200
