#!/usr/bin/perl

# Generate Carmichael numbers from the divisors of other numbers.

use 5.020;
use strict;
use warnings;

use ntheory qw(divisor_sum);
use Math::Prime::Util::GMP;
use Math::AnyNum qw(is_smooth is_rough);

my %seen;
my $sigma0_limit = 2**17;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n =~ /^[0-9]+\z/ || next;
    $n > ~0 or next;

    #is_smooth($n, 1e6) || next;
    is_rough($n, 1e5) && next;

    if (length($n) > 45) {
        is_smooth($n, 1e7) || next;
    }

    divisor_sum($n, 0) <= $sigma0_limit or next;
    $seen{$n} = 1;

    foreach my $d (Math::Prime::Util::GMP::divisors($n)) {
        $d > ~0 or next;
        next if exists $seen{$d};
        if (Math::Prime::Util::GMP::is_carmichael($d)) {
            say $d if !$seen{$d}++;
        }
    }
}
