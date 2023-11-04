#!/usr/bin/perl

# Find almost-extra-strong Lucas pseudoprimes that are not extra-strong Lucas pseudoprimes.

# The first few terms, are:
#   10469, 154697, 233659, 472453, 629693, 852389, 1091093, 1560437, 1620673, 1813601, 1969109, 2415739, 2595329, 2756837, 3721549, 4269341, 5192309, 7045433, 7226669, 7265561, 9081929, 9826289, 10176893, 11436829, 11855969

use 5.020;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(
  is_pseudoprime
  is_lucas_pseudoprime
  is_extra_strong_lucas_pseudoprime
  is_almost_extra_strong_lucas_pseudoprime
);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n < 1e14);

    #next if length($n) > 40;

    is_pseudoprime($n, 2) && next;

    if (is_almost_extra_strong_lucas_pseudoprime($n)
        and not is_extra_strong_lucas_pseudoprime($n)) {
        say $n;
    }
}

__END__

# Some larger terms:

101379108770549
546532586280913937
1643850930720414293
