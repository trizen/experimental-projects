#!/usr/bin/perl

# Least k such that prime(k) + prime(k+1) contains n prime divisors (with multiplicity), otherwise 0.
# https://oeis.org/A251600

# Smallest prime p such that the sum of it and the following prime have n prime factors including multiplicity, or 0 if no such prime exists.
# https://oeis.org/A105418

# Found: 184328920, 68035462, 92566977, 457932094

# Found for A105418:
#  a(31) = 10066329587

use 5.014;
use ntheory qw(is_prime factor forprimes nth_prime next_prime prime_count);

my $p = 2;
my $n = 32;

forprimes {

    if (factor($_+$p) >= $n) {
        say "Found: ", prime_count($p), " with ", scalar(factor($_+$p)), " factors";
    }

    $p = $_;

} next_prime($p), 1e13;

#~ my $k = 10;
#~ my $p = nth_prime($k);
#~ my $n = 3;

#~ forprimes {

    #~ if (factor($_+$p) == $n) {
        #~ say "Found: ", prime_count($p), " with p=$p";
        #~ ++$n;
    #~ }

    #~ $p = $_;

#~ } next_prime($p), 1e13;
