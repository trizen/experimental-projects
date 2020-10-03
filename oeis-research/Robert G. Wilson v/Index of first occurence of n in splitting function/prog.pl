#!/usr/bin/perl

# Index of first occurrence of n in A324920.
# https://oeis.org/A324921

# Where A324920(n) is defined as:
#   A324920(n) is the number of iterations of the integer splitting function (A056737) necessary to reach zero.

# Two more terms: a(18) = 57866702, a(19) = 94418279.

# a(20) > 10^9

# Found a(20) = 1888365980

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);

sub f($n) {
    if (is_square($n)) {
        0;
    }
    else {
        my @d = divisors($n);
        $d[(1+$#d)>>1] - $d[($#d)>>1];
    }
}

sub g($n) {

    my $t = f($n);
    my $count = 1;

    while ($t) {
        $t = f($t);
        ++$count;
    }

    $count;
}

#~ foreach my $k(358487, 1877938, 11596979, 57866702, 94418279) {
    #~ say "g($k) = ", g($k);
#~ }

my %seen;
#my $from = 1911068546;
my $from = 94418321*22-100;

foreach my $k($from  .. $from+1e8) {

    my $t = g($k);

    if ($t > 15) {
        say "a($t) = $k";
    }

    if ($t > 20 and not exists $seen{$t}) {
        $seen{$t} = 1;
        die "Found: a($t) = $k";
    }
}

__END__
a(1) = 1
a(2) = 2
a(3) = 3
a(4) = 10
a(5) = 11
a(6) = 26
a(7) = 83
a(8) = 178
a(9) = 179
a(10) = 362
a(11) = 1835
a(12) = 9188
a(13) = 42709
a(14) = 162466
