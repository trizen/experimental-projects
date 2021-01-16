#!/usr/bin/perl

# Primes p such that, with q the next prime after p, q > p+2 and q^p == q (mod p+q) and p^q == p (mod p+q).
# https://oeis.org/A340431

# Original terms:
#   13, 211, 421, 523, 154321, 221941, 1556641, 2377201, 3918757, 4359961, 7842511, 9163873, 20446561, 1501102081

# New terms:
#   7578849037, 15724210681, 25522638481

# PARI/GP script:
#   upto(n) = my(p=2); forprime(q = nextprime(p+1), n, if(q-p > 2, if(Mod(p, p+q)^q == p, if(Mod(q, p+q)^p == q, print1(p, ", ")))); p = q);
#   upto(10^11);

use 5.014;
use ntheory qw(:all);

#my $from = 1501102081;
#my $from = prev_prime(1e11);

my $from = 3;
my $prev = $from;

local $| = 1;

forprimes {

    if ($_ - $prev > 2) {
         if (powmod($prev, $_, $_+$prev) == $prev) {
            if (powmod($_, $prev, $_+$prev) == $_) {
                print($prev, ", ");
            }
        }
    }

    $prev = $_;

} $from+1, 1e12;
