#!/usr/bin/perl

# Smallest prime p such that A005117(k+1) - A005117(k-1) = n, where p = A005117(k) for some k.
# https://oeis.org/A283807

# Known terms:
#   2, 3, 7, 47, 97, 241, 5051, 204329, 217069, 29002021, 190346677, 3568762019, 221167421, 18725346527

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

my $x    = 1;
my $curr = 2;
my $y    = 3;

my @table;

forsquarefree {

    if (!defined($table[$y - $x]) and is_prime($curr)) {
        $table[$y - $x] = 1;
        say "a(", $y - $x, ") = $curr";
    }

    ($x, $curr, $y) = ($curr, $y, $_);
} $y + 1, 1e12;

__END__
a(2) = 2
a(3) = 3
a(4) = 7
a(5) = 47
a(6) = 97
a(7) = 241
a(8) = 5051
a(9) = 204329
a(10) = 217069
a(11) = 29002021
a(12) = 190346677
a(14) = 221167421
