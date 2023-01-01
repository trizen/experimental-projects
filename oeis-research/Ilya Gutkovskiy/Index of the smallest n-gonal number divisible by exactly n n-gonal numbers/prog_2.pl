#!/usr/bin/perl

# a(n) is the index of the smallest n-gonal number divisible by exactly n n-gonal numbers.
# https://oeis.org/A358058

# Known terms:
#   3, 6, 12, 48, 51, 330, 1100, 702, 8120, 980, 5499, 110880, 10472, 2688, 2127411, 517104, 710640, 396480, 2761803, 4254120, 13347975, 707000, 3655827

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=(k*(n*k - n - 2*k + 4))\2); if(sumdiv(t, d, ispolygonal(d, n)) == n, return(k)));

sub a($n) {

    my %table;

    my $count;
    for(my $k = 1; ; ++$k) {

        #my $t = divint(mulint($k, ($n*$k - $n - 2*$k + 4)), 2);
        my $t = rshiftint(mulint($k, ($n*$k - $n - 2*$k + 4)), 1);

        undef $table{$t};

        $count = 0;
        foreach my $d (divisors($t)) {
            if (exists $table{$d}) {
                ++$count;
            }
        }
        if ($count == $n) {
            return $k;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
