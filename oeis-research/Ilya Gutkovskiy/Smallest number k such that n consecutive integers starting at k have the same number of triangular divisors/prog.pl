#!/usr/bin/perl

# a(n) is the smallest number k such that n consecutive integers starting at k have the same number of triangular divisors (A007862).
# https://oeis.org/A358044

# Known terms:
#    1, 1, 55, 5402, 2515069

use 5.014;
use ntheory qw(:all);

my $prev = 0;
my $count = 0;

my @table = ();

foreach my $k (1..1e10) {
    my $c = grep { is_polygonal($_, 3) } divisors($k);

    if ($c == $prev) {
        ++$count;
    }
    else {
        $prev = $c;
        $count = 0;
    }

    if (!$table[$count]) {
        say "a(", $count+1, ") = ", $k - $count;
        $table[$count] = $k;
    }
}

__END__
a(1) = 1
a(2) = 1
a(3) = 55
a(4) = 5402
a(5) = 2515069
