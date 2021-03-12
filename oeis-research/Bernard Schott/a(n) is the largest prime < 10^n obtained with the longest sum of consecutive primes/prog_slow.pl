#!/usr/bin/perl

# a(n) is the largest prime < 10^n obtained with the longest sum of consecutive primes.
# https://oeis.org/A342439

# The longest length of consecutive primes which sums to a prime (A342439(n)) < 10^n.
# https://oeis.org/A342440

use 5.010;
use strict;
use integer;
use warnings;

use List::UtilsBy qw(max_by);
use ntheory qw(:all);

foreach my $n (1 .. 100) {

    my $limit = powint(10, $n);

    my $sum = 0;
    my @primes;

    for (my $p = 2 ; ; $p = next_prime($p)) {
        $sum += $p;
        if ($sum / 2 > $limit) {
            last;
        }
        push @primes, $p;
    }

    my @arr;
    my $l = scalar(@primes) - 1;

    for (my $i = 0 ; $i <= $l ; ++$i) {
        my $sum = $primes[$i];
        for (my $j = $i + 1 ; ($j <= $l - $i) && (($sum += $primes[$j]) < $limit) ; ++$j) {
            is_prime($sum) && push @arr, [$j - $i + 1, $sum];
        }
    }

    my $p = max_by { $_->[0] } @arr;
    say "$p->[1] is the sum of $p->[0] consecutive primes";
}

__END__
5 is the sum of 2 consecutive primes
41 is the sum of 6 consecutive primes
953 is the sum of 21 consecutive primes
9521 is the sum of 65 consecutive primes
92951 is the sum of 183 consecutive primes
997651 is the sum of 543 consecutive primes
9951191 is the sum of 1587 consecutive primes
99819619 is the sum of 4685 consecutive primes
999715711 is the sum of 13935 consecutive primes
