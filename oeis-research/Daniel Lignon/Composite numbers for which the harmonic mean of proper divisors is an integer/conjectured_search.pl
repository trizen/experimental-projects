#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

use 5.014;
use ntheory qw(:all);
use Math::AnyNum qw(sum);

use integer;

my @mpq;
my $count = 0;

foreach my $n (2e7 .. 1e8) {

    my $u = divisor_sum($n) - 1;

    is_prime($u) || next;

    my $t = $n * $u;
    my @d = divisors($t);

    if (++$count >= 1e4) {
        say "Testing: $n -> $t";
        $count = 0;
    }

    pop @d;

    foreach my $i (0 .. $#d) {
        Math::GMPq::Rmpq_set_ui(($mpq[$i] //= Math::GMPq::Rmpq_init()), 1, $d[$i]);
    }

    my $h = sum(@mpq[0 .. $#d]);

    if (Math::GMPq::Rmpq_integer_p(scalar(@d) / $$h)) {
        die "Found: $n -> $t\n";
    }
}
