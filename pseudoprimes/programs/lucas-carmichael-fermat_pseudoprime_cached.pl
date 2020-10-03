#!/usr/bin/perl

# Try to find a Lucas-Carmichael number that is also a Fermat pseudoprime to some base b >= 2.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use Math::Prime::Util::GMP qw(is_pseudoprime random_prime);
use experimental qw(signatures);

my $storable_file = "cache/factors-lucas-carmichael.storable";
my $table = retrieve($storable_file);

my @primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97);

while (my($key, $value) = each %$table) {
    foreach my $p (@primes) {
        if (is_pseudoprime($key, $p)) {
            say "$key is a Fermat $p-psp";
        }
    }
}

say "No counter-example found...";
