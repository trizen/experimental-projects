#!/usr/bin/perl

# a(n) is the index of the smallest tetrahedral number with exactly n distinct prime factors.
# https://oeis.org/A359089

# Known terms:
#   1, 2, 3, 7, 18, 34, 90, 259, 988, 2583, 5795, 37960, 101268, 424268, 3344614, 17168723, 74282570, 351200178, 1082950218, 5313193819, 31439710664, 317760710839, 1782400663483

use 5.036;
use ntheory qw(:all);
use List::Util qw(uniq);

my @x = (2);       # 2
my @y = (3);       # 3
my @z = (2, 2);    # 4

my @table;

forfactored {
    @z = @_;

    if ($_ % 2 == 0) {
        shift @z;
    }

    if ($_ % 3 == 0) {
        foreach my $i(0..$#z) {
            if ($z[$i] == 3) {
                splice(@z, $i, 1);
                last;
            }
        }
    }

    my $t = scalar uniq(@x, @y, @z);

    if (!$table[$t]) {
        $table[$t] = 1;
        say $t, " ", $_ - 2;
    }

    @x = @y;
    @y = @z;
} 5, 1e13;

__END__
3 3
2 4
4 18
5 34
6 90
7 259
8 988
9 2583
10 5795
11 37960
12 101268
13 424268
14 3344614
15 17168723
