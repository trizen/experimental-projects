#!/usr/bin/perl

# a(n) is the minimum number of distinct numbers with exactly n prime factors (counted with multiplicity) whose sum of reciprocals exceeds 1.
# https://oeis.org/A374231

# Known terms:
#   3, 13, 96, 1772, 108336, 35181993

use 5.036;
use ntheory qw(:all);

my $n = 7;
my $sum = 0;
my $index = 1;

foralmostprimes {

    $sum += 1/$_;

    if ($index % 1e7 == 0) {
        say "[$index | $_] sum = $sum";
    }

    if ($sum > 1) {
        die "Found: $index (sum = $sum)";
    }

    ++$index;

} $n, 1, ~0;

__END__
sum = 0.846524877737090592677330489673074
sum = 0.846584110949018502846100517596571
sum = 0.846643287378808079866941405886191
sum = 0.846702407133082953728639844137568
sum = 0.846761470325090899821824159996903
^C
perl prog.pl  5301.53s user 111.64s system 97% cpu 1:32:10.01 total
