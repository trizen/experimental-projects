#!/usr/bin/perl

# Numbers k such that P(k)^2 | k and P(k+1)^3 | (k+1), where P(k) = A006530(k) is the largest prime dividing k.
# https://oeis.org/A354563

# Known terms:
#   1, 2, 5, 13, 28, 79, 204, 549, 1509, 4231, 12072, 36426

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub smooth_numbers ($limit, $primes) {

    if ($limit <= $primes->[-1]) {
        return [1 .. $limit];
    }

    if ($limit <= 5e4) {

        my @list;
        my $B = $primes->[-1];

        foreach my $k (1 .. $limit) {
            if (is_smooth($k, $B)) {
                push @list, $k;
            }
        }

        return \@list;
    }

    my @h = (1);
    foreach my $p (@$primes) {
        foreach my $n (@h) {
            if ($n * $p <= $limit) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub upto ($k, $j) {

    my $limit = rootint($k, $j);

    my @smooth;
    my @primes;

    my $i = 0;
    my $pi = prime_count($limit);

    foreach my $p (@{primes($limit)}) {

        ++$i;
        say "[$i / $pi] Processing prime $p";

        my $pj = powint($p, $j);
        push @primes, $p;

        push @smooth, grep {
            my $m = addint($_, 1);
            valuation($m, (factor($m))[-1]) >= $j;
        } map { mulint($_, $pj) } @{smooth_numbers(divint($k, $pj), \@primes)};
    }

    return sort { $a <=> $b } @smooth;
}

#~ my $n = 7;
#~ say join(', ', upto($n, 2));

#~ __END__

my $n = 13;
my $i = 0;

open my $fh, '>', 'bfile.txt';

foreach my $k (upto(powint(10, $n), 2)) {
    my $row = sprintf("%s %s\n", ++$i, $k);
    print $row;
    print $fh $row;
}

close $fh;
