#!/usr/bin/perl

# The number of terms of A354558 that are <= 10^n.
# https://oeis.org/A354559

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

sub a ($n) {

    my $k = powint(10, $n);

    #my @smooth;
    my $count = 0;
    my @primes;

    foreach my $p (@{primes(sqrtint($k))}) {
        #say "Processing prime $p";
        my $pp = mulint($p, $p);
        push @primes, $p;

        #push @smooth, map {mulint($_, $pp) } @{smooth_numbers(divint($k, $pp), primes($p))};

        foreach my $s (@{smooth_numbers(divint($k, $pp), \@primes)}) {
            my $m = mulint($pp, $s) + 1;
            if (valuation($m, (factor($m))[-1]) >= 2) {
                ++$count;
            }
        }
    }

    return $count;
}

foreach my $n (1 .. 15) {
    say "a($n) = ", a($n);
}

__END__

a(1) = 1
a(2) = 2
a(3) = 5
a(4) = 13
a(5) = 28
a(6) = 79
a(7) = 204
a(8) = 549
a(9) = 1509
a(10) = 4231
a(11) = 12072
a(12) = 36426
