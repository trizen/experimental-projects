#!/usr/bin/perl

# Numbers k such that P(k)^2 | k and P(k+1)^3 | (k+1), where P(k) = A006530(k) is the largest prime dividing k.
# https://oeis.org/A354563

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

sub upto ($n, $j1, $j2) {

    my $k = powint(10, $n);
    my $limit = rootint($k, $j2);

    my @smooth;
    my @primes;

    my $i = 0;
    my $pi = prime_count($limit);

    foreach my $p (@{primes($limit)}) {

        ++$i;
        say "[$i / $pi] Processing prime $p";

        my $pj = powint($p, $j2);
        push @primes, $p;

        push @smooth, map { subint($_, 1) } grep {
            #my $m = addint($_, 1);
            my $m = subint($_, 1);
            valuation($m, (factor($m))[-1]) >= $j1;
        } map { mulint($_, $pj) } @{smooth_numbers(divint($k, $pj), \@primes)};
    }

    return sort { $a <=> $b } @smooth;
}

#~ my $n = 9;
#~ say join(', ', upto($n, 2, 3));

#~ __END__
my $n = 15;
my $i = 0;

open my $fh, '>', 'bfile.txt';

foreach my $k (upto($n,2,3)) {
    my $row = sprintf("%s %s\n", ++$i, $k);
    print $row;
    print $fh $row;
}

close $fh;