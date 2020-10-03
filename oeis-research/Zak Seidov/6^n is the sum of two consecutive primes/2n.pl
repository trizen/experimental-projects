#!/usr/bin/perl

# Numbers n with property that 6^n is the sum of two consecutive primes.
# https://oeis.org/A165744

use 5.014;
#use ntheory qw(:all);
use Math::Prime::Util::GMP qw(prev_prime next_prime is_prob_prime);
use Math::AnyNum qw(ipow);

# from 3000

foreach my $n(1..4000) {

    #say "Testing: $n";

    my $pow = ipow(2, $n);
    my $ipow = $pow>>1;

    my $x = Math::AnyNum->new(next_prime($ipow));
    #my $y = next_prime($ipow);

    #if ($x + $y == $pow) {
    if (is_prob_prime($pow - $x) and $x + prev_prime($ipow) == $pow) {
        say "Found: $n";
        die "New term: $n" if ($n > 1678);
    }
}
