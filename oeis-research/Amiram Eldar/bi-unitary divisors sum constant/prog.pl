#!/usr/bin/perl

# Decimal expansion of the constant c in the asymptotic formula for the partial sums of the bi-unitary divisors sum function, A307159(k) ~ c*k^2.
# https://oeis.org/A307160

# 0.752838741002294311801556197690282913198572814948
# 0.752838741002294311572374955376000133818337852677
# 0.752838741002294311555548926599819789478084421742
# 0.752838741002294311551120791965465252262943489011
# 0.752838741002294311548876231316823899297951999561
# 0.752838741002294311547545121955305818925329236541
# 0.752838741002294311547055129027092424491079871979        # up to 144900000 (10^8)

# 0.999999999999999999999998000000010000000099999999
# 0.99999999999999999999

use 5.014;
use ntheory qw(:all);

use Math::MPFR;
use Math::GMPz;
use Math::GMPq;

my $prod = Math::MPFR::Rmpfr_init2(192);
my $t = Math::MPFR::Rmpfr_init2(192);

Math::MPFR::Rmpfr_set_ui($prod, 1, 0);

my $p = Math::GMPz->new(1);
my $q = Math::GMPq->new(1);

my $k = 0;

forprimes {

    # ((p - 1) (p^5 + p^4 + p^3 - p^2 + 1))/p^6

    Math::GMPz::Rmpz_set_ui($p, $_);

    my $z1 = ($p-1) * ($p**5 + $p**4 + $p**3 - $p**2 + 1);
    my $z2 = $p**6;

    Math::GMPq::Rmpq_set_num($q, $z1);
    Math::GMPq::Rmpq_set_den($q, $z2);
    Math::GMPq::Rmpq_canonicalize($q);

    Math::MPFR::Rmpfr_mul_q($prod, $prod, $q, 0);

    if (++$k % 1e5 == 0) {
        say $prod;
    }

    #Math::MPFR::Rmpfr_set_ui(
    #(1 - 2/p^3 + 1/p^4 + 1/p^5 - 1/p^6)

} 1e8;
