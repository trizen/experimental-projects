#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# These are numbers n such that sigma(n)-1 divides n*(tau(n)-1).

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

# New term:
#   3662109375 -> 22351741783447265625

use 5.014;
use ntheory qw(:all);

foreach my $y (1 .. 1000) {

    foreach my $x (2 .. 40) {

        foreach my $n (grep { $_ < 2**100 } map { mulint(powint($x, $_), $y) } 1 .. 100) {

            my $u = divisor_sum($n) - 1;

            is_prime($u) || next;

            my $m = mulint($u, $n);

            if (modint(mulint($m, divisor_sum($m, 0) - 1), divisor_sum($m) - 1) == 0) {
                say "\tFound: $n -> $m";
            }
        }
    }
}

__END__
Found: 35 -> 1645
Found: 3662109375 -> 22351741783447265625
Found: 35 -> 1645
Found: 171366 -> 63626653506
Found: 35 -> 1645
Found: 231 -> 88473
Found: 231 -> 88473
Found: 3662109375 -> 22351741783447265625
Found: 3662109375 -> 22351741783447265625
Found: 231 -> 88473
Found: 231 -> 88473
Found: 3662109375 -> 22351741783447265625
Found: 231 -> 88473
Found: 171366 -> 63626653506
...
