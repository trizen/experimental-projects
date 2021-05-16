#!/usr/bin/perl

# Primes p such that gcd(ord_p(2), ord_p(3)) = 1.
# https://oeis.org/A344202

# Known terms:
#    683, 599479, 108390409, 149817457, 666591179, 2000634731, 4562284561, 14764460089, 24040333283

# Terms found:
#   24040333283    (took 1 hour and 2 minutes)

use 5.014;
use ntheory qw(:all);

forprimes {

   if (gcd(znorder(2, $_), znorder(3, $_)) == 1) {
       say $_;
   }

} 24040333283, 1e13;
