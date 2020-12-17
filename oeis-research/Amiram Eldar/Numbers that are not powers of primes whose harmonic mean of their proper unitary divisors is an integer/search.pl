#!/usr/bin/perl

# Numbers that are not powers of primes (A024619) whose harmonic mean of their proper unitary divisors is an integer.
# https://oeis.org/A335270

# Known terms:
#   228, 1645, 7725, 88473, 20295895122, 22550994580

# Conjecture: all terms have the form n*(usigma(n)-1) where usigma(n)-1 is prime.
# The conjecture was inspired by the similar conjecture of Chai Wah Wu from A247077.

use 5.014;
use strict;

#use integer;

use ntheory qw(:all);

sub usigma {
    vecprod(map { powint($_->[0], $_->[1]) + 1 } factor_exp($_[0]));
}

my $count = 0;

foreach my $k (2 .. 1e9) {

    my $p = usigma($k) - 1;

    is_prime($p) || next;

    my $m = mulint($k, $p);
    next if ($k == $p);
    my $o = prime_omega($k) + 1;

    if (++$count >= 1e5) {
        say "Testing: $k -> $m";
        $count = 0;
    }

    if (modint(mulint($m, ((1 << $o) - 1)), mulint(usigma($k), $p+1) - 1) == 0) {
        say "\tFound: $k -> $m";
        die "New term: $k -> $m\n" if ($m > 22550994580);
    }
}

__END__
Found: 12 -> 228
Found: 35 -> 1645
Found: 75 -> 7725
Found: 231 -> 88473
Found: 108558 -> 20295895122
Found: 120620 -> 22550994580
