#!/usr/bin/perl

# a(n) is the smallest n-gonal pyramidal number divisible by exactly n n-gonal pyramidal numbers.
# https://oeis.org/A358860

# Known terms:
#   56, 140, 4200, 331800, 611520, 8385930

# New terms:
#   56, 140, 4200, 331800, 611520, 8385930, 1071856800, 41086892000, 78540000, 38102655397426620, 59089382788800, 22241349900, 2326493030400, 7052419469195100, 886638404171520

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
            return $t;
        }
    }
}

foreach my $n (3..100) {
    say "a($n) = ", a($n);
}

__END__
a(3) = 56
a(4) = 140
a(5) = 4200
a(6) = 331800
a(7) = 611520
a(8) = 8385930
a(9) = 1071856800
a(10) = 41086892000
a(11) = 78540000
a(12) = 38102655397426620
a(13) = 59089382788800
a(14) = 22241349900
a(15) = 2326493030400
a(16) = 7052419469195100
a(17) = 886638404171520
