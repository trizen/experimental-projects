#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# These are numbers n such that sigma(n)-1 divides n*(tau(n)-1).

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

# New term:
#   3662109375 -> 22351741783447265625

use utf8;
use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub dynamicPreimage ($N, $L) {

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            foreach my $d (divisors(divint($N, $x))) {
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            }
        }
        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    sort { $a <=> $b } @{$r{$N}};
}

sub cook_sigma ($N, $k) {
    my %L;

    foreach my $d (divisors($N)) {

        next if ($d == 1);

        foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

            my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
            my $t = valuation($q, $p);

            next if ($t <= $k or ($t % $k) or $q != powint($p, $t));

            push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
        }
    }

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    ($N == 1) ? (1) : dynamicPreimage($N, cook_sigma($N, $k));
}

my $count = 0;

forprimes {

    my $p = $_;

    foreach my $n (inverse_sigma($p + 1)) {

        #~ is_smooth($n, 20) || next;
        #~ $n >= 1e7 or next;

        next if ($p == $n);

        my $m = mulint($p, $n);

        if (++$count >= 10000) {
            say "Testing: $n -> $m";
            $count = 0;
        }

        if (modint(mulint($m, divisor_sum($m, 0) - 1), mulint(divisor_sum($n), ($p+1)) - 1) == 0) {
            say "\tFound: $p -> $m";
        }
    }
} 1, 1e10;
