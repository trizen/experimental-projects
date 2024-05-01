#!/usr/bin/perl

# Composite numbers that divide the concatenation of the reverse of their ascending order prime factors, with repetition.
# https://oeis.org/A372046

# Known terms:
#   998, 1636, 9998, 15584, 49447, 99998, 1639964, 2794612, 9999998, 15842836, 1639360636, 1968390098

use 5.036;
use ntheory qw(:all);

# Next term is greater than:
my $from = 10648000000;

forfactored {

    if ($_ % 1e6 == 0) {
        say "Testing: $_";
    }

    if (@_ > 1 and modint(join('', map { scalar reverse($_) } @_), $_) == 0) {
        die "Found new term: $_\n";
    }
} $from, 1e12;

__END__
Testing: 9504000000
Testing: 9505000000
Testing: 9506000000
^C
perl prog.pl  12241.38s user 26.69s system 96% cpu 3:31:17.95 total

Testing: 10646000000
Testing: 10647000000
Testing: 10648000000
^C
perl prog.pl  1947.68s user 2.91s system 95% cpu 34:08.11 total
