#!/usr/bin/perl

# Generate pseudoprimes that are product of primes p such that p-1 and p+1 are both B-smooth, for some small bound B.

use 5.020;
use warnings;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use List::Util qw(shuffle);
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::AnyNum qw(is_smooth);

sub is_lucas_carmichael ($n) {

    if ($n > ~0) {
        $n = Math::GMPz::Rmpz_init_set_str($n, 10);
    }

    my $t = $n + 1;
    vecall { $t % ($_ + 1) == 0 } Math::Prime::Util::GMP::factor($n);
}

## p+1 and p-1 are both 7-smooth
#my @a = (3, 5, 7, 11, 13, 17, 19, 29, 31, 41, 71, 97, 127, 251, 449, 4801);

## p+1 and p-1 are both 11-smooth
#my @a = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 71, 89, 97, 109, 127, 197, 199, 241, 251, 449, 769, 881, 4801);

## p+1 and p-1 are both 13-smooth
#my @a = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 53, 71, 79, 89, 97, 109, 127, 131, 181, 197, 199, 241, 251, 337, 449, 701, 727, 769, 881, 1249, 4159, 4801, 8191);

## p+1 and p-1 are both 17-smooth
#my @a = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 53, 71, 79, 89, 97, 103, 109, 127, 131, 181, 197, 199, 239, 241, 251, 307, 337, 449, 701, 727, 769, 881, 1249, 1429, 1871, 4159, 4801, 4999, 8191, 388961);

## p+1 is 7-smooth, p-1 is not 7-smooth
my @a = (23, 47, 53, 59, 79, 83, 89, 107, 139, 149, 167, 179, 191, 199, 223, 239, 269, 293, 349, 359, 383, 419, 431, 479, 499, 503, 587, 599, 647, 719, 809, 839, 863, 881, 971);

## p-1 is 7-smooth, p+1 is not 7-smooth
#my @a = (37, 43, 61, 73, 101, 109, 113, 151, 163, 181, 193, 197, 211, 241, 257, 271, 281, 337, 379, 401, 421, 433, 487, 491, 541, 577, 601, 631, 641, 673, 701, 751, 757, 769, 811, 883);

## p-1 is 3-smooth, p+1 is not 7-smooth
#my @a = (37, 73, 109, 163, 193, 257, 433, 487, 577, 769, 1153, 1297, 1459, 2593, 2917, 3457, 3889, 10369, 12289, 17497, 18433, 39367, 52489, 65537);

## p+1 is 3-smooth, p+1 is not 7-smooth
#my @a = (23, 47, 53, 107, 191, 383, 431, 647, 863, 971, 1151, 2591, 4373, 6143, 6911, 8191, 8747, 13121, 15551, 23327, 27647, 62207, 73727);

@a = shuffle(@a);

forcomb {
    my $c = Math::Prime::Util::GMP::vecprod(@a[@_]);

    #if (Math::Prime::Util::GMP::is_pseudoprime($c,2)) {
    #if (Math::Prime::Util::GMP::is_carmichael($c)) {
    if (is_lucas_carmichael($c)) {
        say $c;
    }
} scalar(@a), 6;
