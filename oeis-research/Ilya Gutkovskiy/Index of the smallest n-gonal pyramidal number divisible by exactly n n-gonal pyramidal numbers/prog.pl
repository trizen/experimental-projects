#!/usr/bin/perl

# a(n) is the index of the smallest n-gonal pyramidal number divisible by exactly n n-gonal pyramidal numbers.
# https://oeis.org/A358059

# Known terms:
#   6, 7, 20, 79, 90, 203, 972, 3135, 374, 283815, 31824, 2232, 10240, 144584, 70784

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub pyramidal ($k, $r) {
    divint(vecprod($k, ($k+1), ($r-2)*$k + (5-$r)), 6);
}

sub a($n) {

    my %table;

    for(my $k = 1; ; ++$k) {
        my $t = pyramidal($k, $n);

        undef $table{$t};

        my $count = 0;
        foreach my $d (divisors($t)) {
            if (exists $table{$d}) {
                ++$count;
                last if ($count > $n);
            }
        }

        if ($count == $n) {
            return $k;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 6
a(4) = 7
a(5) = 20
a(6) = 79
a(7) = 90
a(8) = 203
a(9) = 972
a(10) = 3135
a(11) = 374
a(12) = 283815
a(13) = 31824
a(14) = 2232
a(15) = 10240
a(16) = 144584
a(17) = 70784
