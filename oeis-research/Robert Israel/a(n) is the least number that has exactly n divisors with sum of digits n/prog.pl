#!/usr/bin/perl

# a(n) is the least number that has exactly n divisors with sum of digits n.
# https://oeis.org/A359444

# Known terms:
#   1, 20, 60, 440, 1400, 420, 11200, 11440, 324, 58520, 180880, 18480, 585200, 523600, 114240, 1133440, 2420600, 17820

# New terms (a(19)-a(27)):
#   9634240, 9529520, 1659840, 33353320, 71380400, 4748100, 178890320, 228388160, 671328

use 5.020;
use ntheory qw(:all);

my @table;

foreach my $n (1..1e13) {

    my %sums;
    foreach my $d (divisors($n)) {
        $sums{vecsum(todigits($d))}++;
    }

    foreach my $s (keys %sums) {
        if ($s == $sums{$s} and not $table[$s]) {
            $table[$s] = 1;
            say "$sums{$s} $n";
        }
    }
}

__END__
1 1
2 20
3 60
9 324
6 420
4 440
5 1400
7 11200
8 11440
18 17820
12 18480
10 58520
15 114240
11 180880
14 523600
13 585200
27 671328
16 1133440
21 1659840
17 2420600
24 4748100
20 9529520
19 9634240
36 12598740
22 33353320
23 71380400
30 73670520
25 178890320
26 228388160
