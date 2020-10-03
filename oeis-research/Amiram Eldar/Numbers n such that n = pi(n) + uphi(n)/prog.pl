#!/usr/bin/perl

# Numbers n such that n = pi(n) + uphi(n), where pi = A000720, uphi = A047994.
# https://oeis.org/A298761

# See also:
#   https://oeis.org/A100411
#   https://oeis.org/A037170

# 70112131, 70113559, 325575773, 514258883, 742327529, 1069238453

use 5.014;
use ntheory qw(factor_exp vecprod forprimes next_prime prime_count prev_prime);

my $from = prev_prime(70112131-1000);
#my $from = 2;

my $pi = prime_count($from);
my $prev_p = $from;

forprimes {

    foreach my $i(1..$_-$prev_p-1) {

        #prime_count($prev_p+$i) == $pi or die "error for: ", $prev_p+$i;

        if (vecprod(map{$_->[0]**$_->[1] - 1 } factor_exp($prev_p+$i)) + $pi == $prev_p+$i) {
            say "Found: ", $prev_p+$i;
        }
    }

    $prev_p = $_;
    ++$pi;

} next_prime($from), 1e13;
