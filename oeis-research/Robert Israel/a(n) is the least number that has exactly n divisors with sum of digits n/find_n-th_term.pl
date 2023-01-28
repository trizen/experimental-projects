#!/usr/bin/perl

# a(n) is the least number that has exactly n divisors with sum of digits n.
# https://oeis.org/A359444

use 5.020;
use warnings;

use integer;
use ntheory qw(:all);
use List::Util qw(sum);

my $n = 28;

my $min = 251000000;
my $max = 413736400;

use Time::HiRes qw(tv_interval gettimeofday);

my $t0 = [gettimeofday];

foreach my $k ($min .. $max) {

    if ($k % 1e6 == 0) {
        say "Checking: $k (took ", tv_interval($t0, [gettimeofday]), " seconds)";
        $t0 = [gettimeofday];
    }

    my $count = 0;
    foreach my $d (divisors($k)) {
        if (sum(todigits($d)) == $n) {
            ++$count;
        }
    }

    if ($count == $n) {
        die "a($n) = $k";
    }
}
