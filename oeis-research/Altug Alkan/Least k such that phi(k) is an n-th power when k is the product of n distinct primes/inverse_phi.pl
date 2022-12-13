#!/usr/bin/perl

# Least k such that phi(k) is an n-th power when k is the product of n distinct primes.
# https://oeis.org/A281069

use utf8;
use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

sub a ($n) {

    my @list;

    foreach my $k (2 .. 1e9) {

        is_smooth($k, 3) || next;

        foreach my $v (inverse_totient(powint($k, $n))) {
            if (is_almost_prime($n, $v) and is_square_free($v)) {
                push @list, $v;
            }
        }

        last if @list;
    }

    vecmin(@list);
}

foreach my $n (1 .. 20) {
    say "a($n) <= ", a($n);
}

__END__
a(1) <= 3
a(2) <= 10
a(3) <= 30
a(4) <= 3458
a(5) <= 29526
a(6) <= 5437705
a(7) <= 91604415
a(8) <= 1190857395
a(9) <= 26535163830
a(10) <= 344957129790
a(11) <= 5703406198237930
a(12) <= 178435136773443810
a(13) <= 4961806417984478790
