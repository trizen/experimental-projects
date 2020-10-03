#!/usr/bin/perl

# Carmichael numbers whose index is a power of 2
# https://oeis.org/A306828

# Known terms:
#   7816642561, 49413980161, 32713826587115521

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
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

    next if $n < ~0;
    next if length($n) > 40;

    #~ next if length($n) <= 40;
    #~ next if length($n) > 45;

    #~ next if length($n) <= 45;
    #~ next if length($n) > 50;

    #~ next if length($n) <= 50;
    #~ next if length($n) > 55;

    #~ next if length($n) <= 40;
    #~ next if length($n) >= 55;

    #~ next if length($n) <= 55;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    push @nums, $n;
}

@nums = sort { $a <=> $b } @nums;

say "There are ", scalar(@nums), " total numbers";

foreach my $n (@nums) {

    is_pseudoprime($n, 2)  || next;
    is_smooth($n - 1, 1e5) || next;
    is_carmichael($n)      || next;

    my $odd = odd_part($n - 1);

    say "Testing: $n with $odd";

    if ($odd == odd_part(carmichael_lambda($n))) {

        say "Counter-example found: $n";
        sleep 2;

        if ($n > 32713826587115521) {
            die "New term for A306828: $n";
        }
    }

    if ($odd == odd_part(euler_phi($n))) {
        die "Lehmer's totient conjecture counter-example found: $n";
    }
}
