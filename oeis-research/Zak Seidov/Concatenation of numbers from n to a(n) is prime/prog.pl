#!/usr/bin/perl

# Smallest a(n) > n such that concatenation of numbers from n to a(n) is a prime.
# https://oeis.org/A084559

use 5.014;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(is_prob_prime factor trial_factor);

sub a {
    my ($n) = @_;

    my $t = $n;
    for(my $k = $n+1; ;++$k) {
        $t .= $k;

        #say "Testing: $k";
        #say "Factoring: $t";

        my @f = trial_factor($t, 1e6);

        if (@f > 1) {

        }
        else {
            say "[$k] Candidate: $t";
            sleep 1;
        }
        #say join' ', trial_factor($t);
        #say '';

        #sleep 1;

        if (is_prob_prime($t)) {
            return $k;
        }
    }
}

say a(10);

#foreach my $n(2..100) {
#    say "a($n) = ", a($n);
#}
