#!/usr/bin/perl

# Composite numbers that divide the reverse of the concatenation of their ascending order prime factors, with repetition.
# https://oeis.org/A371696

# Known terms:
#   26, 38, 46, 378, 26579, 84941, 178838, 30791466, 39373022, 56405502, 227501395, 904085931

# New terms:
#   1657827142

use 5.036;
use ntheory qw(:all);

# Next term is greater than:
my $from = 11062000000;

forfactored {

    if ($_ % 1e6 == 0) {
        say "Testing: $_";
    }

    if (@_ > 1 and modint(scalar reverse(join('', @_)), $_) == 0) {
        die "Found new term: $_\n";
    }
} $from, 1e12;

__END__
Testing: 1656000000
Testing: 1657000000
Found new term: 1657827142
perl prog.pl  585.29s user 0.29s system 99% cpu 9:49.90 total
