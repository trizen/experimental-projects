#!/usr/bin/perl

# Smallest k such that bigomega(k) * omega(k) = n.
# https://oeis.org/A328964

# a(p) = 2^p, for p prime.

# First few terms:
#   1, 2, 4, 8, 6, 32, 12, 128, 24, 30, 48, 2048, 60, 8192, 192, 120, 210, 131072, 240, 524288, 420, 480, 3072, 8388608, 840, 2310, 12288, 1920, 1680, 536870912, 3840, 2147483648, 3360, 7680, 196608, 9240, 6720, 137438953472, 786432, 30720, 13440, 2199023255552, 60060, 8796093022208, 26880, 36960, 12582912, 140737488355328, 53760, 510510, 73920, 491520, 107520, 9007199254740992, 240240, 147840, 215040, 1966080

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

sub a($n) {

    if (is_prime($n)) {
        return powint(2, $n);
    }

    my $value = 0;

    forfactored {
        lastfor, do { return ($value = vecprod(@_)) } if ((scalar(uniq(@_)) * scalar(@_)) == $n);
    } 1e10;

    $value;
}

#say a(28);

local $| = 1;
foreach my $n(1..1e6) {
    #say "a($n) = ", a($n);
    print(a($n), ", ");
}
