#!/usr/bin/perl

# a(n) is the largest prime < 10^n obtained with the longest sum of consecutive primes.
# https://oeis.org/A342439

# The longest length of consecutive primes which sums to a prime (A342439(n)) < 10^n.
# https://oeis.org/A342440

# Algorithm from:
#   https://blog.dreamshire.com/project-euler-50-solution/

use 5.010;
use strict;
use warnings;

#use integer;

use ntheory qw(:all);

foreach my $n (1 .. 100) {

    my $limit = powint(10, $n);

    my @prime_sum = (0);
    for (my $p = 2 ; ; $p = next_prime($p)) {
        push @prime_sum, $prime_sum[-1] + $p;
        if ($prime_sum[-1] >= $limit) {
            last;
        }
    }

    my $terms         = 1;
    my $max_prime     = 2;
    my $start_p_index = 1;

    foreach my $i (0 .. $#prime_sum) {
        for (my $j = $#prime_sum ; $j >= $i + $terms ; --$j) {

            my $n = $prime_sum[$j] - $prime_sum[$i];

            if ($j - $i > $terms and $n < $limit and is_prime($n)) {
                ($terms, $max_prime, $start_p_index) = ($j - $i, $n, $i + 1);
                last;
            }
        }
    }

    say "$max_prime is the sum of $terms consecutive primes with first prime = ", nth_prime($start_p_index);
}

__END__
5 is the sum of 2 consecutive primes with first prime = 2
41 is the sum of 6 consecutive primes with first prime = 2
953 is the sum of 21 consecutive primes with first prime = 7
9521 is the sum of 65 consecutive primes with first prime = 3
92951 is the sum of 183 consecutive primes with first prime = 3
997651 is the sum of 543 consecutive primes with first prime = 7
9951191 is the sum of 1587 consecutive primes with first prime = 5
99819619 is the sum of 4685 consecutive primes with first prime = 7
999715711 is the sum of 13935 consecutive primes with first prime = 11
9999419621 is the sum of 41708 consecutive primes with first prime = 2
99987684473 is the sum of 125479 consecutive primes with first prime = 19
999973156643 is the sum of 379317 consecutive primes with first prime = 5
9999946325147 is the sum of 1150971 consecutive primes with first prime = 5
99999863884699 is the sum of 3503790 consecutive primes with first prime = 2
999998764608469 is the sum of 10695879 consecutive primes with first prime = 7
9999994503821977 is the sum of 32729271 consecutive primes with first prime = 5
99999999469565483 is the sum of 100361001 consecutive primes with first prime = 5
