#!/usr/bin/perl

# a(n) is the smallest number with exactly n divisors that are n-gonal numbers.
# https://oeis.org/A358539

# Known terms:
#   6, 36, 210, 1260, 6426, 3360, 351000, 207900, 3749460, 1153152, 15036840

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub a($n) {

    my $count;
    for(my $k = 2; ; ++$k) {
        $count = 0;
        foreach my $d (divisors($k)) {
            if (is_polygonal($d, $n)) {
                ++$count;
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
a(4) = 36
a(5) = 210
a(6) = 1260
a(7) = 6426
a(8) = 3360
a(9) = 351000
a(10) = 207900
a(11) = 3749460
a(12) = 1153152
a(13) = 15036840
a(14) = 204204000
a(15) = 213825150
a(16) = 11737440
