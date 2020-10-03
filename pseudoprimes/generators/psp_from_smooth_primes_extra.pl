#!/usr/bin/perl

# Generate pseudoprimes that are product of primes p such that p-1 and p+1 are both B-smooth, for some small bound B.

use 5.020;
use warnings;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use List::Util qw(shuffle uniq);
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

#~ my @a = (13, 31, 37, 61, 97, 181, 271, 331, 433, 577, 601, 661, 4801);
#~ my @b = (11, 13, 17, 19, 23, 31, 37, 41, 59, 61, 67, 73, 97, 101, 103, 109, 137, 151, 163, 181, 241, 251, 271, 277, 331, 359, 401, 433, 463, 487, 523, 541, 577, 601, 661, 751, 829, 929, 1151, 1153, 1181, 1201, 1297, 1621, 1657, 1783, 1801, 2377, 2593, 3169, 3271, 4049, 4721, 4801, 5779, 6277, 6353, 6661, 6961, 14401, 14779, 16421, 19141, 25057, 25411);

#~ push @a, grep { $_ <= 200 }  @b;

my @a = (5, 11, 17, 23, 29, 47, 59, 71, 83, 107, 167, 179, 359, 419, 431, 599);
my @b = (
         5,   7,   11,  13,  17,  19,  23,  29,  37,  47,  53,  59,   71,   79,   83,   89,  107, 113,
         127, 149, 167, 179, 191, 223, 239, 251, 257, 269, 317, 359,  383,  419,  431,  439, 479, 491,
         499, 503, 557, 593, 599, 601, 647, 811, 881, 971, 977, 1217, 6359, 8179, 9857, 16253
        );

#push @a, grep { $_ <= 200} @b;
#push @a, shuffle(@b);
push @a, grep { $_ % 2 == 1 } grep { is_smooth($_ + 1, 7) and is_smooth($_ - 1, 43) } @{primes(1e6)};

$#a = 30;

@a = shuffle(@a);
@a = uniq(@a);

foreach my $k (7 .. 10) {

    forcomb {
        my $c = Math::Prime::Util::GMP::vecprod(@a[@_]);

        #if (Math::Prime::Util::GMP::is_pseudoprime($c,2)) {
        #if (Math::Prime::Util::GMP::is_carmichael($c)) {
        if (is_lucas_carmichael($c)) {
            say $c;
        }
    } scalar(@a), $k;
}
