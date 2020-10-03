#!/usr/bin/perl

# a(n) is the least integer k such that the remainder of k modulo p is strictly increasing over the first n primes.
# https://oeis.org/A306582

use 5.014;
use ntheory qw(:all);

# 0, 2, 4, 34, 52, 194, 502, 1138, 4042, 5794, 5794, 62488, 798298, 5314448, 41592688

sub foo {
    my ($n, $from) = @_;

    my $p = nth_prime($n);
    my @primes = reverse @{primes(nth_prime($n-1))};

    OUTER: for(my $k = $from; ; ++$k) {

        my $max = $k%$p;
        #my $ok = 1;

        foreach my $q(@primes){
            if ($k % $q < $max) {
                $max = $k%$q;
            }
            else {
                next OUTER;
            }
        }

        return $k;
    }
}

my $prev = 5037219688;
foreach my $n(18..100) {
    my $t = foo($n, $prev);
    say "a($n) = $t";
    $prev = $t;
}
