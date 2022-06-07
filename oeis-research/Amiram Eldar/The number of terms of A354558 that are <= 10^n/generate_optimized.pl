#!/usr/bin/perl

# The number of terms of A354558 that are <= 10^n.
# https://oeis.org/A354559

# Known terms:
#   1, 2, 5, 13, 28, 79, 204, 549, 1509, 4231, 12072, 36426, 112589

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub smooth_numbers ($prev_smooth, $limit, $primes) {

    if ($limit <= $primes->[-1]) {
        return [1 .. $limit];
    }

    #if (0 and $limit <= 5e4) {
    if ($limit < scalar(@$prev_smooth)) {

        my @list;
        my $B = $primes->[-1];

        foreach my $k (1 .. $limit) {
            if (is_smooth($k, $B)) {
                push @list, $k;
            }
        }

        return \@list;
    }

    my @h = grep { $_ <= $limit } @$prev_smooth;

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

    my $i = 0;
    my $pi = prime_count($limit);

    my $prev_smooth = [1];

    foreach my $p (@{primes($limit)}) {

        ++$i;
        say "[$i / $pi] Processing prime $p";

        my $pj = powint($p, $j);
        my $smooth_limit = divint($k, $pj);

        $prev_smooth = smooth_numbers($prev_smooth, $smooth_limit, [$p]);

        push @smooth, grep {
            my $m = addint($_, 1);
            valuation($m, (factor($m))[-1]) >= $j;
        } map { mulint($_, $pj) } @$prev_smooth;
    }

    return sort { $a <=> $b } @smooth;
}

#~ my $n = 7;
#~ say join(', ', upto($n, 2));

#~ __END__

my $n = 13;
my $i = 0;

open my $fh, '>', 'bfile2.txt';

foreach my $k (upto(powint(10, $n), 2)) {
    my $row = sprintf("%s %s\n", ++$i, $k);
    print $row;
    print $fh $row;
}

close $fh;
