#!/usr/bin/perl

# Number of different terms in a period of continued fraction for square root of n-th repunit.
# https://oeis.org/A096488

# a(n) = {2, 3, 2, 8, 2, 37, 2, 76, 2, 217, 2, 870, 2, 583, 2, 5034, 2, 28494, 2, 10058, 2, ...}

#~ a(2) = 2
#~ a(3) = 3
#~ a(4) = 2
#~ a(5) = 8
#~ a(6) = 2
#~ a(7) = 37
#~ a(8) = 2
#~ a(9) = 76
#~ a(10) = 2
#~ a(11) = 217
#~ a(12) = 2
#~ a(13) = 870
#~ a(14) = 2
#~ a(15) = 583
#~ a(16) = 2
#~ a(17) = 5034
#~ a(18) = 2
#~ a(19) = 28494
#~ a(20) = 2
#~ a(21) = 10058
#~ a(22) = 2

# See also: https://oeis.org/A096485

use 5.014;
use strict;
use warnings;

use Math::GMPz;

sub period_length_mpz {
    my ($n) = @_;

    $n = Math::GMPz->new("$n");

    my $x = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_sqrt($x, $n);

    return ($x) if Math::GMPz::Rmpz_perfect_square_p($n);

    my $t = Math::GMPz::Rmpz_init();
    my $y = Math::GMPz::Rmpz_init_set($x);
    my $z = Math::GMPz::Rmpz_init_set_ui(1);
    my $r = Math::GMPz::Rmpz_init();

    my %seen;
    my $count = 0;

    Math::GMPz::Rmpz_add($r, $x, $x);    # r = x+x

    do {

        # y = (r*z - y)
        Math::GMPz::Rmpz_submul($y, $r, $z);    # y = y - t*z
        Math::GMPz::Rmpz_neg($y, $y);           # y = -y

        # z = ((n - y*y) / z)
        Math::GMPz::Rmpz_mul($t, $y, $y);       # t = y*y
        Math::GMPz::Rmpz_sub($t, $n, $t);       # t = n-t
        Math::GMPz::Rmpz_divexact($z, $t, $z);  # z = t/z

        # t = floor((x + y) / z)
        Math::GMPz::Rmpz_add($t, $x, $y);       # t = x+y
        Math::GMPz::Rmpz_tdiv_q($t, $t, $z);    # t = floor(t/z)

        $r = $t;

        ++$count
          if !$seen{
              Math::GMPz::Rmpz_fits_ulong_p($r)
            ? Math::GMPz::Rmpz_get_ui($r)
            : Math::GMPz::Rmpz_get_str($r, 10)
          }++;

    } until (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0);

    return $count;
}

foreach my $n (2 .. 30) {
    say "a($n) = ", period_length_mpz('1' x $n);
}
