#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 31 August 2016
# License: GPLv3
# https://github.com/trizen

# Compute the period length of the continued fraction for square root of a given number.

# Algorithm from:
#   http://web.math.princeton.edu/mathlab/jr02fall/Periodicity/mariusjp.pdf

# OEIS sequences:
#   https://oeis.org/A003285 -- Period of continued fraction for square root of n (or 0 if n is a square).
#   https://oeis.org/A059927 -- Period length of the continued fraction for sqrt(2^(2n+1)).
#   https://oeis.org/A064932 -- Period length of the continued fraction for sqrt(3^(2n+1)).
#   https://oeis.org/A067280 -- Terms in continued fraction for sqrt(n), excl. 2nd and higher periods.

# See also:
#   https://en.wikipedia.org/wiki/Continued_fraction
#   http://mathworld.wolfram.com/PeriodicContinuedFraction.html

# TODO:
#   https://oeis.org/A061682     Quotient cycle length in continued fraction expansion of sqrt(2^(2n+1)+1).
#   133093360, 1019300318, 60079334
#    a(29)-a(31) from ~~~~

#   https://oeis.org/A077098     Quotient cycle length in continued fraction expansion of sqrt(-1+n^n).  (no luck)
#   0, 2, 1, 2, 10, 2, 26, 2, 2, 2, 84531, 2, 531160, 2, 4738, 2,

#   https://oeis.org/A077097     Quotient cycle length in continued fraction expansion of sqrt(1+n^n).
#   1, 1, 4, 1, 30, 1, 32, 1, 1, 1, 20554, 1, 23522, 1, 1013500, 1, 29130218, 1,

# Submit new sequence:
#   Quotient cycle length in continued fraction expansion of sqrt(2^(2n+1)-1).
#   4, 8, 12, 20, 12, 164, 40, 40, 1208, 660, 1304, 3056, 2492, 1080, 13004, 10232, 11296, 148736, 56576, 615482, 44448, 64, 2628524, 28219952, 139558, 3067080, 2683626, 90740360,

use 5.010;
use strict;
use warnings;

use Math::GMPz;
use Math::AnyNum qw(prod binomial hyperfactorial superfactorial subfactorial);
use ntheory qw(is_square sqrtint powint divint factorial pn_primorial consecutive_integer_lcm nth_prime factor is_prime);

sub period_length_mpz {
    my ($n) = @_;

    $n = Math::GMPz->new("$n");

    return 0 if Math::GMPz::Rmpz_perfect_square_p($n);

    my $t = Math::GMPz::Rmpz_init();
    my $x = Math::GMPz::Rmpz_init();
    my $y = Math::GMPz::Rmpz_init_set($x);
    my $z = Math::GMPz::Rmpz_init_set_ui(1);

    Math::GMPz::Rmpz_sqrt($x, $n);

    my $period = 0;

    do {
        Math::GMPz::Rmpz_add($t, $x, $y);
        Math::GMPz::Rmpz_div($t, $t, $z);
        Math::GMPz::Rmpz_mul($t, $t, $z);
        Math::GMPz::Rmpz_sub($y, $t, $y);

        Math::GMPz::Rmpz_mul($t, $y, $y);
        Math::GMPz::Rmpz_sub($t, $n, $t);
        Math::GMPz::Rmpz_div($z, $t, $z);

        ++$period;

    } until (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0);

    return $period;
}

sub period_length {
    my ($n, $wanted) = @_;

    if (ref($n) or ref $wanted) {
        die "\nerror\n";
       return period_length_mpz($n);
    }

   # die "\nerror\n" if ref $n;

    my $x = sqrtint($n);
    my $y = $x;
    my $z = 1;

    return 0 if is_square($n);

    my $period = 0;

    do {
        $y = int(($x + $y)/      $z) * $z - $y;
        $z = int(($n - $y * $y)/ $z);
        #say "$y $z -- $n";
        ++$period;

        if ($period > $wanted) {
            return 0;
        }
    } until ($z == 1);

    return ($period == $wanted);
}

local $| = 1;
foreach my $n(1..1e3) {
    my $k =920371;

    for (;;) {
    while (!period_length($k, pn_primorial($n+4))) {
        ++$k;
    }

    #if (period_length($, powint(3, $n))) {
        #say $n;
        #print "$n, ";

        is_prime($k) || die "\nnot prime for n=$n -> $k\n";
        say $k;

        ++$k;
    }
    #}

    #print $k, ", ";
    #say $k, ' -> ', join(', ', factor($k));
}

__END__

local $| = 1;
for my $n (16) {

    #print period_length_mpz(Math::GMPz->new(3)**(2*$n+1)), ", ";
    #print period_length_mpz(Math::GMPz->new(2)**(2*$n+1) + 1), ", ";
    #print period_length_mpz(Math::GMPz->new($n)**$n + 1), ", ";
    #print period_length(powint($n, $n) + 1), ", ";

    #Math::GMPz->new(3)**(2*$n + 1)), ", ";
    #next if is_square($n);
    #say period_length(powint($n, 2 * 7 + 1)) / powint($n, 7);
}

__END__
A064932(1) = 2
A064932(2) = 10
A064932(3) = 30
A064932(4) = 98
A064932(5) = 270
A064932(6) = 818
A064932(7) = 2382
A064932(8) = 7282
A064932(9) = 21818
A064932(10) = 65650
A064932(11) = 196406
A064932(12) = 589982
A064932(13) = 1768938
A064932(14) = 5309294
