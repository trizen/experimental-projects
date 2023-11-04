#!/usr/bin/perl

# https://oeis.org/A306828
# https://en.wikipedia.org/wiki/Lehmer%27s_totient_problem

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory      qw(:all);
use Math::AnyNum qw(is_smooth);

sub odd_part ($n) {
    $n >> valuation($n, 2);
}

my @nums;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if (length($n) <= 20);

    is_pseudoprime($n, 2) || next;
    is_smooth($n, 1e7)    || next;
    is_carmichael($n)     || next;

    say "Candidate: $n";

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    push @nums, $n;
}

@nums = sort { $a <=> $b } @nums;

say "There are ", scalar(@nums), " total numbers";

foreach my $n (@nums) {
    say "Testing: $n";

    my $phi = euler_phi($n);
    my $nm1 = $n - 1;

    if (odd_part($nm1) == odd_part($phi)) {
        die "[1] Counter-example: $n\n";
    }

    if ($nm1 % $phi == 0) {
        die "[2] Counter-example: $n\n";
    }
}
