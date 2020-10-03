#!/usr/bin/perl

# a(n) is the least integer k > 2 such that the remainder of -k modulo p is strictly increasing over the first n primes.
# https://oeis.org/A306612

use 5.014;
use ntheory qw(:all);

sub foo {
    my ($n, $from) = @_;

    my $p = nth_prime($n);
    my @primes = reverse @{primes(nth_prime($n-1))};

    OUTER: for(my $k = $from; ; ++$k) {

        my $max = (-$k)%$p;

        foreach my $q(@primes){
            my $t = (-$k) % $q;
            if ($t < $max) {
                $max = $t;
            }
            else {
                next OUTER;
            }
        }

        return $k;
    }
}

my $prev = 3;
foreach my $n(2..100) {
    my $t = foo($n, $prev);
    say "a($n) = $t";
    $prev = $t;
}
