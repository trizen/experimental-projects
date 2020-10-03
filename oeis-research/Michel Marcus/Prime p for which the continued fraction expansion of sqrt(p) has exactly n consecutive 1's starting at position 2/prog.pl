#!/usr/bin/perl

# a(n) is the least prime p for which the continued fraction expansion of sqrt(p) has exactly n consecutive 1's starting at position 2.
# https://oeis.org/A307453

# a(30) = 326757090818617

# Algorithm from:
#   http://web.math.princeton.edu/mathlab/jr02fall/Periodicity/mariusjp.pdf

use 5.010;
use strict;
use warnings;

use ntheory qw(is_prime);
use Math::GMPz;

sub isok {
    my ($n, $want) = @_;

    $n = Math::GMPz->new("$n");

    my $x = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_sqrt($x, $n);

    return ($x) if Math::GMPz::Rmpz_perfect_square_p($n);

    my $y = Math::GMPz::Rmpz_init_set($x);
    my $z = Math::GMPz::Rmpz_init_set_ui(1);
    my $r = Math::GMPz::Rmpz_init();

    my @cfrac = ($x);

    Math::GMPz::Rmpz_add($r, $x, $x);    # r = x+x

    my $count = 0;

    do {
        my $t = Math::GMPz::Rmpz_init();

        # y = (r*z - y)
        Math::GMPz::Rmpz_submul($y, $r, $z);    # y = y - t*z
        Math::GMPz::Rmpz_neg($y, $y);           # y = -y

        # z = floor((n - y*y) / z)
        Math::GMPz::Rmpz_mul($t, $y, $y);       # t = y*y
        Math::GMPz::Rmpz_sub($t, $n, $t);       # t = n-t
        Math::GMPz::Rmpz_divexact($z, $t, $z);  # z = t/z

        # t = floor((x + y) / z)
        Math::GMPz::Rmpz_add($t, $x, $y);       # t = x+y
        Math::GMPz::Rmpz_tdiv_q($t, $t, $z);    # t = floor(t/z)

        $r = $t;
        #push @cfrac, $t;

        ++$count;

        if ($count <= $want) {
            Math::GMPz::Rmpz_cmp_ui($t, 1) == 0 or return 0;
        }
        elsif ($count == $want+1) {
            return (Math::GMPz::Rmpz_cmp_ui($t, 1) != 0);
        }

    } until (Math::GMPz::Rmpz_cmp_ui($z, 1) == 0);

    return 0;
}

# Limit_{n->infinity} (sqrt(a(n)) - floor(sqrt(a(n)))) = A094214.

use Math::AnyNum qw(phi round floor PREC 1024);

my $k = 1;
my $want = 3;

local $| = 1;

while (1) {

    ++$k;

    my $n = round(($k + phi - 1)**2);

    is_prime($n) || next;

    if (isok($n, $want)) {
        print "$n, ";
        $k = 1;
        ++$want;
    }
}

# 7, 13, 3797, 5273, 4987, 90371, 79873, 2081, 111301, 1258027, 5325101, 12564317, 9477889, 47370431, 709669249, 1529640443, 2196104969, 392143681, 8216809361, 30739072339, 200758317433,
# 7, 13, 3797, 5273, 4987, 90371, 79873, 2081, 111301, 1258027, 5325101, 12564317, 9477889, 47370431, 709669249, 1529640443, 2196104969, 392143681
# 7, 13, 3797, 5273, 4987, 90371, 79873, 2081, 111301, 1258027, 5325101, 12564317, 9477889, 47370431, 709669249, 1529640443, 2196104969, 392143681

#my @arr = ( 3, 31, 7, 13, 3797, 5273, 4987, 90371, 79873, 2081, 111301, 1258027, 5325101, 12564317, 9477889, 47370431, 709669249, 1529640443, 2196104969, 392143681);
#foreach my $k(0..$#arr) {
#    say isok($arr[$k], $k+1);
#}

__END__

7, 13, 3797, 5273, 4987, 90371, 79873, 2081, 111301, 1258027, 5325101, 12564317, 9477889, 47370431, 709669249, 1529640443, 2196104969, 392143681, 8216809361, 30739072339, 200758317433, 370949963971, 161356959383, 1788677860531, 7049166342469, 4484287435283, 3690992602753, ^C
perl r.pl  286.67s user 0.16s system 99% cpu 4:48.23 total

sqrt(1) = [1]
sqrt(2) = [1, 2]
sqrt(3) = [1, 1, 2]
sqrt(4) = [2]
sqrt(5) = [2, 4]
sqrt(6) = [2, 2, 4]
sqrt(7) = [2, 1, 1, 1, 4]
sqrt(8) = [2, 1, 4]
sqrt(9) = [3]
sqrt(10) = [3, 6]
sqrt(11) = [3, 3, 6]
sqrt(12) = [3, 2, 6]
sqrt(13) = [3, 1, 1, 1, 1, 6]
sqrt(14) = [3, 1, 2, 1, 6]
sqrt(15) = [3, 1, 6]
sqrt(16) = [4]
sqrt(17) = [4, 8]
sqrt(18) = [4, 4, 8]
sqrt(19) = [4, 2, 1, 3, 1, 2, 8]
sqrt(20) = [4, 2, 8]
