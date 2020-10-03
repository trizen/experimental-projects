#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use ntheory qw(forsemiprimes forprimes factor forsquarefree random_prime divisors gcd);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime vecprod divint sqrtint is_carmichael);

# 3274782926266545
# 4788772759754985
# 633708839387221385771985
# 85866492509341408342261785
# 1153582279094600286115568385
# 38049785538164232203093987265
# 9239040473268653691499587195465
# 55428474928216449147566945330865
# 304740732375157335714579744005385

#my $n = "25159846246305";
my $n = vecprod(3, 5, 17, 23, 89, 113, 233, 617, 1409);

forsemiprimes {
    if (is_carmichael(mulint($n, $_))) {
        say mulint($n, $_);
    }
} 1e8;
