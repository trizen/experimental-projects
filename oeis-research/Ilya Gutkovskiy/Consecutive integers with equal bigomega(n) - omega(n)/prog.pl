#!/usr/bin/perl

# a(n) is the smallest number k such that factorizations of n consecutive integers starting at k have the same excess of number of primes counted with multiplicity over number of primes counted without multiplicity (A046660).
# https://oeis.org/draft/A323253

#~ a(1) = 4
#~ a(2) = 6
#~ a(3) = 21
#~ a(4) = 844
#~ a(5) = 74849
#~ a(6) = 671346
#~ a(7) = 8870025

# See also:
#   https://oeis.org/A072072

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub excess ($n) {
    scalar(factor($n)) - scalar(factor_exp($n));
}

sub score ($n) {
    my $t = excess($n);
    foreach my $k(1..100) {
        if (excess($k + $n) != $t) {
            return $k;
        }
    }
}

my $n = 1;

#my $upto = 30199064929748;
#my $upto = 80566783622;
#my $upto = 300000000000000 + 4*1e6;
my $from = 30199064929748 + 2*1e7;

forcomposites {

    while (score($_) >= $n) {
        say "a($n) = ", $_;
        ++$n;
    }

} $from, $from+1e7;

__END__
a(7) = 30199059114825
