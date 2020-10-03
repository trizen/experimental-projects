#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use ntheory qw(forsemiprimes forprimes factor forsquarefree random_prime divisors gcd next_prime);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime vecprod divint sqrtint vecprod is_carmichael);

#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 269);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257, 2689);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257, 2689, 13553);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 257, 2731, 24007);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257, 2689, 13553);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257, 2689, 13553, 192193, 1921921, 2434433);
#my $k = vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257, 353, 397, 449, 617, 1093, 1499);
#my $k = vecprod(3, 5, 17, 23, 29, 53, 89);
#my $k = vecprod(3, 5, 17, 23, 89, 113, 149);
#my $k = vecprod(3, 5, 17, 23, 89, 113, 149, 3257);
#my $k = vecprod(3, 5, 17, 23, 89, 113, 149, 3557);
my $k = vecprod(3, 5, 17, 23, 29, 197, 617, 1217);

forsquarefree {
    if ($_ & 1) {
        if (gcd($_, $k) == 1 and is_carmichael(mulint($k, $_))) {
            say mulint($k, $_);
        }
    }
} 1e8;

__END__
#my $k = "44914889889994250085";
#my $k = "127237648413581445";
my $k = "77728835801292945";
#my $k = "20909056830547802205";

my $from = (factor($k))[-1];
my $limit = 25000;

my @factors;
for(my $p1 = next_prime($from); $p1 <= $limit; $p1 = next_prime($p1)) {
    for(my $p2 = next_prime(int($p1*10)); $p2 <= $limit; $p2 = next_prime($p2)) {
        for(my $p3 = next_prime(int($p2*7)); $p3 <= $limit; $p3 = next_prime($p3)) {
            my $factor = $p1*$p2*$p3;
            if (is_pseudoprime(mulint($k, $factor), 2)) {
                say mulint($k, $factor);
            }
        }
    }
}

__END__
say $count;

my $from = 1e8+1e7+1e7+1e7+1e7;

forsquarefree {

    if ($_ % 2 == 1) {
        if (is_pseudoprime(mulint($k, $_), 2)) {
            say mulint($k, $_);
        }
    }

} $from,$from+1e7;
