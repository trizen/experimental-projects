#!/usr/bin/perl

# a(n) is the smallest centered n-gonal number with exactly n distinct prime factors.
# https://oeis.org/A358894

# Known terms:
#   460, 99905, 463326, 808208947, 23089262218

# Finding a(11) took ~24 minutes.

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = if(n<3, return()); for(k=1, oo, my(t=((n*k*(k+1))/2+1)); if(omega(t) == n, return(t)));

sub a($n) {

    for(my $k = 1; ; ++$k) {

        #my $t = (($n*$k*($k+1))>>1)+1;
        my $t = rshiftint(mulint($n*$k, $k+1), 1)+1;

        #if (prime_omega($t) == $n) {
        if (is_omega_prime($n, $t)) {
            return $t;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 460
a(4) = 99905
a(5) = 463326
a(6) = 808208947
a(7) = 23089262218
a(8) = 12442607161209225
a(9) = 53780356630
a(10) = 700326051644920151
a(11) = 46634399568693102
a(12) = 45573558879962759570353
