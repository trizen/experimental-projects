#!/usr/bin/perl

# Composite numbers that divide the concatenation of the reverse of their ascending order prime factors, with repetition, when written in binary.
# https://oeis.org/A372277

# Known terms:
#   87339, 332403, 9813039

use 5.036;
use ntheory qw(:all);

# Next term is greater than:
my $from = 2421000000;

forfactored {

    if ($_ % 1e6 == 0) {
        say "Testing: $_";
    }

    if (@_ > 1 and modint(fromdigits(join('', map { scalar reverse(todigits($_, 2)) } @_), 2), $_) == 0) {
        die "Found new term: $_\n";
    }
} $from, 1e12;

__END__
Testing: 1597000000
Testing: 1598000000
Testing: 1599000000
Testing: 1600000000
^C
perl prog.pl  4460.95s user 9.14s system 98% cpu 1:15:31.56 total

Testing: 2418000000
Testing: 2419000000
Testing: 2420000000
Testing: 2421000000
^C
perl prog.pl  2305.67s user 6.61s system 97% cpu 39:35.61 total
