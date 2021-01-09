#!/usr/bin/perl

# Smallest number m such that the GCD of the x's that satisfy sigma(x)=m is n.
# https://oeis.org/A241625

# a(127) = 4096
# a(151) = 3465904

# a(14) > 1017189995

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

my %easy;
@easy{
    1,   2,   3,   4,   5,   7,   8,   9,   12,  13,  16,  25,  31,  80,  97,  18,  19,  22,  27,  29,  32,  36,
    37,  43,  45,  49,  50,  61,  64,  67,  72,  73,  81,  91,  98,  100, 101, 106, 109, 121, 128, 129, 133, 134,
    137, 146, 148, 149, 152, 157, 162, 163, 169, 171, 173, 192, 193, 197, 199, 200, 202, 211, 217, 218, 219
} = ();

my $count = 0;

foreach my $k (1017189995 .. 1e10) {

    say "Testing: $k" if (++$count % 10000 == 0);

    my $t = gcd(inverse_sigma($k));

    if ($t >= 14 and $t <= 219) {
        say "\na($t) = $k\n" if not exists $easy{$t};
        die "Found: $k" if ($t == 14 or $t == 15);
    }
}
