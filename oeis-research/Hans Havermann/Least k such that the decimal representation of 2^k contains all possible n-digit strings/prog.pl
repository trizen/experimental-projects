#!/usr/bin/perl

# Least k such that the decimal representation of 2^k contains all possible n-digit strings
# https://oeis.org/A360656

# Known terms:
#   68, 975, 16963, 239697, 2994863

# Takes 10 minutes to find a(4).

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use List::Util               qw(all shuffle);
use Algorithm::Combinatorics qw(variations_with_repetition);

sub a ($n) {

    my @v;
    my $iter = variations_with_repetition([0 .. 9], $n);
    while (my $p = $iter->next) {
        push @v, join '', @$p;
    }

    @v = shuffle(@v);   # randomized optimization

    my $z = Math::GMPz::Rmpz_init_set_ui(1);

    for (my $k = 0 ; ; ++$k) {

        my $t = Math::GMPz::Rmpz_get_str($z, 10);

        if (all { index($t, $_) != -1 } @v) {
            return $k;
        }

        Math::GMPz::Rmpz_mul_2exp($z, $z, 1);
    }
}

foreach my $n (1 .. 100) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 68
a(2) = 975
a(3) = 16963
a(4) = 239697
