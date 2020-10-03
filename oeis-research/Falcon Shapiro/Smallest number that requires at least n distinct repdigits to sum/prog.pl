#!/usr/bin/perl

# a(n) is the smallest number that requires at least n distinct repdigits to sum.
# https://oeis.org/A336759

# Known terms:
#   1, 10, 21, 309, 2108, 21996

# Conjecture:
#   a(7) = 220884  = 1 + 9 + 99 + 777 + 8888 + 99999 + 111111
#   a(8) = 2111105 = 1 + 9 + 99 + 999 + 9999 + 99999 + 888888 + 1111111

use 5.014;
use warnings;
use ntheory qw(:all);
use List::Util qw(uniq);

#my $n = 8;
#my $limit = 21996*11;
#my $limit = 220884*11;

my $n     = 8;
my $limit = 2111105;

my @arr;

for my $k (1 .. 9) {
    for my $j (1 .. length($limit)) {
        push @arr, "$k" x $j;
    }
}

@arr = sort { $a <=> $b } uniq(grep { $_ < $limit } @arr);

say "Repdigits: ", join(', ', @arr);
say "Length of array: ", scalar(@arr);
say "Total number of steps required: ", vecsum(map { binomial(scalar(@arr), $_) } 1..$n);

my %seen;

for my $k (1 .. $n) {

    say "[$k] Requires ", binomial(scalar(@arr), $k), " steps";

    my $local_min = ~0;

    forcomb {

        my $t = vecsum(@arr[@_]);

        if (not exists $seen{$t}) {

            if ($k == $n and $t < $local_min) {
                say "a($n) <= $t = ", join(' + ', @arr[@_]);
                $local_min = $t;
            }

            $seen{$t} = $k;
        }
    } scalar(@arr), $k;
}

my $min = ~0;

while (my ($key, $value) = each %seen) {
    if ($value == $n) {
        if ($key < $min) {
            $min = $key;
        }
    }
}

say "Final result: a($n) >= $min";
