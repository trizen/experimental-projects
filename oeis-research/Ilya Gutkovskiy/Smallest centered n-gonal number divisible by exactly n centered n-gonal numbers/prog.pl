#!/usr/bin/perl

# a(n) is the smallest centered n-gonal number divisible by exactly n centered n-gonal numbers.
# https://oeis.org/A358861

# Known terms:
#   64, 925, 2976, 93457, 866272, 11025, 3036880

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=((n*k*(k+1))/2+1)); if(sumdiv(t, d, issquare(8*(d-1)/n + 1) && (sqrtint((8*(d-1))/n + 1)-1)%2 == 0) == n, return(t))); \\ ~~~~

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub a($n) {

    my $count;
    for(my $k = 1; ;++$k) {

        my $t = divint(mulint($n*$k, ($k+1)), 2) + 1;
        $count = 0;

        foreach my $d (divisors($t)) {
            if ((8*($d-1)) % $n == 0 and is_square(divint(8*($d-1), $n) + 1) and (sqrtint(divint(8*($d-1), $n) + 1)-1)%2 == 0) {
            #if (lshiftint($d-1, 3) % $n == 0 and is_square(divint(lshiftint($d-1, 3), $n) + 1)) {
                ++$count;
            }
        }
        if ($count == $n) {
            return $t;
        }
    }
}

foreach my $n (16) {
    say "a($n) = ", a($n);
}

__END__
a(10) = 18412718645101
a(11) = 9283470627432
a(12) = 201580440699781
a(13) = 92839099743040
a(14) = 5236660451226975
a(15) = 66779973961058176
a(16) = ?
a(17) = 1415913990579036

# Lower bounds:
a(16) > 4422094135361
