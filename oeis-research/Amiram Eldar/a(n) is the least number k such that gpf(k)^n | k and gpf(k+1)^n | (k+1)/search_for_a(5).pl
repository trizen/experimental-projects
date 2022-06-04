#!/usr/bin/perl

# a(n) is the least number k such that P(k)^n | k and P(k+1)^n | (k+1), where P(k) = A006530(k) is the largest prime dividing k, or -1 if no such k exists.
# https://oeis.org/A354567

# Known terms:
#   1, 8, 6859, 11859210

# Known upper-bounds:
#   a(5) <= 437489361912143559513287483711091603378 (De Koninck, 2009).

# Lower-bounds:
#  a(5) > 10^18
#  a(6) > 10^19

# Search for numbers k such that gpf(k)^5 | k and gpf(k+1)^5 | (k+1).

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

my $n = powint(10, 19);
#say join(', ', upto($n, 5));
say join(', ', upto(~0, 5));
