#!/usr/bin/perl

# a(n) is the smallest n-gonal number divisible by exactly n n-gonal numbers.
# https://oeis.org/A358859

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=(k*(n*k - n - 2*k + 4))\2); if(sumdiv(t, d, ispolygonal(d, n)) == n, return(t)));

sub a($n) {

    my $count;
    for(my $k = 1; ; ++$k) {

        #my $t = divint(mulint($k, ($n*$k - $n - 2*$k + 4)), 2);
        my $t = rshiftint(mulint($k, ($n*$k - $n - 2*$k + 4)), 1);

        $count = 0;
        foreach my $d (divisors($t)) {
            if (is_polygonal($d, $n)) {
                ++$count;
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
a(3) = 6
a(4) = 36
a(5) = 210
a(6) = 4560
a(7) = 6426
a(8) = 326040
a(9) = 4232250
a(10) = 1969110
a(11) = 296676380
a(12) = 4798080
a(13) = 166289760
a(14) = 73765692000
a(15) = 712750500
a(16) = 50561280
a(17) = 33944067893736
a(18) = 2139168754800
a(19) = 4292572951800
a(20) = 1414764341760
a(21) = 72461756727360
a(22) = 180975331456920
a(23) = 1870768457500800
a(24) = 5498331930000
a(25) = 153698278734000
