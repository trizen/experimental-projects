#!/usr/bin/perl

# a(n) is the least start of exactly n consecutive numbers k that are sqrt(k)-smooth (A048098), or -1 in no such run exists.
# https://oeis.org/A355434

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);

my @table;
my $count;

for(my $n = 1; ; ++$n) {

    $count = 0;

    while (is_smooth($n, sqrtint($n))) {
        ++$n;
        ++$count;
    }

    if (not $table[$count]) {
        $table[$count] = 1;
        say "a($count) = ", $n-$count;
    }
}

__END__
a(1) = 1
a(0) = 3
a(2) = 8
a(3) = 48
a(4) = 1518
a(5) = 5828
a(6) = 28032
a(8) = 290783
a(7) = 304260
a(9) = 1255500
a(10) = 4325170
a(11) = 11135837
a(12) = 18567909
