#!/usr/bin/perl

# Smallest Euler-Jacobi pseudoprime to all natural bases up to prime(n) - 1 that is not a base prime(n) Euler-Jacobi pseudoprime.
# https://oeis.org/A354692

# First few terms:
#   9, 561, 10585, 1729, 488881, 399001, 2433601, 1857241, 6189121, 549538081, 50201089, 14469841

# Terms < 2^64:
#   9, 561, 10585, 1729, 488881, 399001, 2433601, 1857241, 6189121, 549538081, 50201089, 14469841, 86566959361, 311963097601, 369838909441, 31929487861441, 6389476833601, 8493512837546881, 31585234281457921, 10120721237827201, 289980482095624321, 525025434548260801, 91230634325542321

# Are all terms > 9 Carmichael numbers?

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);

open my $fh, '<', '../../../pseudoprimes/psps-below-2-to-64.txt' or die "error: $!";

sub check {
    my ($n) = @_;

    my $p = 2;
    my $count = 0;

    while (is_euler_pseudoprime($n, $p)) {
        $p = next_prime($p);
        ++$count;
    }

    return $count;
}

my @table = (9);

while (defined(my $k = <$fh>)) {
    chomp($k);
    my $v = check($k);
    if (not defined $table[$v]) {
        $table[$v] = $k;
        say "$v $k";
    }
}

__END__

# Terms < 2^64:

1 561
3 1729
2 10585
5 399001
4 488881
7 1857241
6 2433601
8 6189121
11 14469841
10 50201089
9 549538081
12 86566959361
13 311963097601
14 369838909441
16 6389476833601
15 31929487861441
17 8493512837546881
19 10120721237827201
18 31585234281457921
22 91230634325542321
20 289980482095624321
21 525025434548260801
