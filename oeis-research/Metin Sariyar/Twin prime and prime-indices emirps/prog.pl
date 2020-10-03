#!/usr/bin/perl

# Numbers k such that k, k+2, pi(k) and pi(k)+2 are all emirps, where pi(k) is the prime indice of k.
# https://oeis.org/A327751

# Terms bellow 10^10:
#   128969, 399389, 1929287, 17390069, 165438191, 184426337, 319600241, 326546399, 345329909, 356861891, 701051009, 727604831, 729442757, 753804677, 1412456741, 1444697909, 1570780529, 1842734357, 3033509021, 3117086699, 3151894619, 3162105929, 3292460357, 3567017009, 3598720451, 3627759227, 3959518877, 3959959301, 3964211261, 7112272889, 7293206819, 7332267959, 7338181757, 7469872847, 7511872727, 7513508201, 7556803409, 7557937529, 7600676231, 7832385791, 7956845627, 7966828817

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

local $| = 1;

sub is_emirp ($n) {
    is_prime($n) and is_prime(scalar reverse($n)) and $n ne reverse($n);
}

my $count = 0;

forprimes {

    ++$count;

    if (is_emirp($count) and is_emirp($count + 2) and is_emirp($_ + 2) and is_emirp($_)) {
        print($_, ", ");
    }

} 1e10;


__END__

if (is_prime($count) and is_prime($count+2) and is_prime(scalar reverse($count)) and is_prime(scalar reverse($count+2)) and $count ne reverse($count) and ($count+2) ne reverse($count+2)) {
    if (is_prime($_+2) and is_prime(scalar reverse($_)) and is_prime(scalar reverse($_+2)) and $_ ne reverse($_) and ($_+2) ne reverse($_+2)) {
        print($_, ", ");
    }
}
