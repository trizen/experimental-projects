#!/usr/bin/perl

# a(n) is the index of the smallest square pyramidal number divisible by exactly n square pyramidal numbers.
# https://oeis.org/A359095

# Known terms:
#   1, 2, 4, 7, 24, 77, 27, 87, 220, 104, 1007, 175, 1000, 1287, 6187, 10867, 5967, 13727, 5719, 22847, 18980, 21735, 55912, 245024, 195975, 288144, 196735, 108927

# New terms:
#   a(29) = 1107567
#   a(30) = 5404112
#   a(31) = 3145824
#   a(32) = 3768687
#   a(33) = 5405575
#   a(34) = 1245887
#   a(35) = 521559
#   a(36) = 1101600
#   ...
#   a(40) = 2781999

# Terms a(29)-a(36):
#   1107567, 5404112, 3145824, 3768687, 5405575, 1245887, 521559, 1101600

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub pyramidal ($k, $r) {
    divint(vecprod($k, ($k+1), ($r-2)*$k + (5-$r)), 6);
}

sub is_pyramidal($n, $r) {
    my $k = rootint(divint(mulint($n, 6), $r-2) + rootint($n, 3), 3);
    pyramidal($k, $r) == $n;
}

my %pyramidal;
my %terms;

foreach my $k (1..1e7) {
    my $p = pyramidal($k, 4);
    undef $pyramidal{$p};

    my $count = 0;
    foreach my $d (divisors($p)) {
        if (exists $pyramidal{$d}) {
            ++$count;
        }
    }

    if (not exists $terms{$count}) {
        say "$count $k";
        $terms{$count} = $k;
    }
}
