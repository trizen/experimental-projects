#!/usr/bin/perl

# a(n) is the index of the smallest tetrahedral number with exactly n prime factors (counted with multiplicity), or -1 if no such number exists.
# https://oeis.org/A359090

# New terms found:
#   a(39) = 1073741822
#   a(40) = 7516192768
#   a(41) = 1073741823

use 5.036;
use ntheory qw(:all);

my $x = 1;    # 2
my $y = 1;    # 3
my $z = 2;    # 4

my @table;

forfactored {
    $z = scalar(@_);

    if (!$table[$x + $y + $z - 2]) {
        $table[$x + $y + $z - 2] = 1;
        say $x+ $y + $z - 2, " ", $_ - 2;
    }

    ($x, $y) = ($y, $z);
} 5, 1e13;

__END__
1 3
2 4
4 6
5 8
3 9
6 14
7 30
8 48
9 62
10 126
11 160
12 350
13 510
14 1022
16 1024
15 2046
18 4094
17 4095
19 13310
20 28672
21 32768
22 65534
23 180224
24 262142
26 262143
25 360448
30 2097150
27 2097151
28 3276800
29 4194302
32 16777214
34 33554430
31 33554432
33 66715648
36 134217728
35 184549374
37 536870910
39 1073741822
41 1073741823
38 1073741824
40 7516192768
^C
perl prog_2.pl  4826.11s user 14.66s system 94% cpu 1:25:06.37 total
