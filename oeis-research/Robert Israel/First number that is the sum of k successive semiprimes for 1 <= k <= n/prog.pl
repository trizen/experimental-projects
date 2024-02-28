#!/usr/bin/perl

# a(n) is the first number that is the sum of k successive semiprimes for 1 <= k <= n.
# https://oeis.org/A370687

# Requires over 4GB of RAM!

use 5.036;
use ntheory qw(:all);

my %table;

my $k = 7;
my $max = 1e9;
my @list = (4, 6, 9, 10, 14, 15, 21);

forsemiprimes {

    my $sum = 0;
    foreach my $j (@list) {
        $sum += $j;
        last if ($sum > $max);
        ++$table{$sum};
    }

    shift @list;
    push @list, $_;

} $list[-1]+1, $max + 1000;

foreach my $n (sort { $a <=> $b } keys(%table)) {
    if ($table{$n} >= $k) {
        say "a($table{$n}) = $n";
        last;
    }
}
