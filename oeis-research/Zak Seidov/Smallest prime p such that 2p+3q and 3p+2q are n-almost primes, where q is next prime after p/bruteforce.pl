#!/usr/bin/perl

# a(n) is the smallest prime p such that 2p+3q and 3p+2q are n-almost primes, where q is next prime after p.
# https://oeis.org/A335737

# Known terms:
#   5, 47, 139, 2521, 77269, 631459, 6758117, 33059357, 7607209367, 173030234371, 152129921851

use 5.036;
use ntheory qw(:all);

my $n = 8;
my $p = 2;
my $q;

forprimes {
   $q = $_;

   if (is_almost_prime($n, 3*$p+2*$q) and is_almost_prime($n, 2*$p + 3*$q)) {
       die "a($n) = $p\n";
   }

  $p = $q;
} $p+1, 1e12;
