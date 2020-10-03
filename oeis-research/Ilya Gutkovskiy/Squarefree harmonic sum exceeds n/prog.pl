#!/usr/bin/perl

# a(n) is the smallest squarefree number k such that sum of reciprocals of squarefree numbers up to k (squarefree harmonic sum) exceeds n.
# https://oeis.org/A333004

use 5.014;
use ntheory qw(:all);

my $n   = 0;
my $sum = 0;

forsquarefree {

    $sum += 1/$_;

    if ($sum > $n) {
        say "$_ -> $sum";
        ++$n;
    }

} 1e10;

__END__
1 -> 1
2 -> 1.5
5 -> 2.03333333333333
26 -> 3.03525304954838
130 -> 4.00339872134019
670 -> 5.0008692986074
3466 -> 6.00008699868937
17985 -> 7.00000304117728
93179 -> 8.00000117635247
482762 -> 9.00000110675871
2501013 -> 10.0000002424106
12956855 -> 11.0000000402562
67125243 -> 12.0000000005759
347753857 -> 13.0000000007322
1801596939 -> 14.0000000000735
