#!/usr/bin/perl

# a(n) is the smallest number that is (zeroless) pandigital in all bases 2 <= k <= n.
# https://oeis.org/A351426

# Known terms:
#   1, 5, 45, 198, 4820, 37923, 1021300, 6546092, 514236897, 3166978245, 543912789629, 26110433895907, 1398152692127214

use 5.010;
use strict;
use warnings;

use List::Util qw(uniq all);
use ntheory qw(todigits fromdigits);
use Algorithm::Combinatorics qw(variations);

foreach my $base (2 .. 100) {

    my @digits     = (1 .. $base - 1);
    my @bases      = reverse(2 .. $base - 1);
    my %base_table = map { $_ => join(' ', 1 .. $_ - 1) } @bases;

    my $iter = variations(\@digits, $base - 1);

    while (defined(my $t = $iter->next)) {

        my $d = fromdigits($t, $base);

        if (
            all {
                my @dg = sort { $a <=> $b } uniq(todigits($d, $_));
                shift(@dg) if ($dg[0] == 0);
                join(' ', @dg) eq $base_table{$_}
            } @bases
          ) {
            say "a($base) = $d";
            last;
        }
    }
}

__END__
a(2) = 1
a(3) = 5
a(4) = 45
a(5) = 198
a(6) = 4820
a(7) = 37923
a(8) = 1021300
a(9) = 6546092
a(10) = 514236897
a(11) = 3166978245
a(12) = 543912789629
