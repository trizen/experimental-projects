#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use ntheory qw(forsemiprimes forprimes factor forsquarefree random_prime divisors gcd);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime vecprod divint sqrtint);

# 3274782926266545
# 4788772759754985
# 633708839387221385771985
# 85866492509341408342261785
# 1153582279094600286115568385
# 38049785538164232203093987265
# 9239040473268653691499587195465
# 55428474928216449147566945330865
# 304740732375157335714579744005385

my $n = "3470207934739664512679701940114447720865";

forprimes {
    #if ($_ % 80 == 9) {

    #if ($_ % 2 == 1 and $_ > 1) {
            if (is_pseudoprime(mulint($n, $_), 2)) {
                say mulint($n, $_);
            }

            #~ my ($p, $q) = factor($_);
            #~ $n = Math::GMPz->new($n);

            #~ if ($n % $p == 0) {
                #~ if (is_pseudoprime(($n/$p)*$q, 2)) {
                    #~ say (($n/$p)*$q);
                #~ }
            #~ }

            #~ if ($n % $q == 0) {
                #~ if (is_pseudoprime(($n/$q)*$p, 2)) {
                    #~ say (($n/$q)*$p);
                #~ }
            #~ }
  #  }

} 1e8;

__END__
