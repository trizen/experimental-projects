#!/usr/bin/perl

# a(n) is the index of the smallest tetrahedral number with exactly n prime factors (counted with multiplicity), or -1 if no such number exists.
# https://oeis.org/A359090

use 5.036;
use ntheory qw(:all);

sub a($n) {

    my $x = 1;    # 2
    my $y = 1;    # 3
    my $z = 2;    # 4

    my $found = undef;

    forfactored {
        $z = scalar(@_);

        if ($x + $y + $z - 2 == $n) {
            $found = $_ - 2;
            lastfor;
        }

        ($x, $y) = ($y, $z);

    } 5, 1e13;

    return $found;
}

foreach my $n (1 .. 100) {
    say "$n ", a($n);
}
