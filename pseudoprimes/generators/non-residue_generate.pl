#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 28 January 2019
# https://github.com/trizen

# A new algorithm for generating Fermat pseudoprimes to base 2.

# See also:
#   https://oeis.org/A050217 -- Super-Poulet numbers: Poulet numbers whose divisors d all satisfy d|2^d-2.
#   https://oeis.org/A214305 -- Fermat pseudoprimes to base 2 with two prime factors.

# See also:
#   https://en.wikipedia.org/wiki/Fermat_pseudoprime
#   https://trizenx.blogspot.com/2018/08/investigating-fibonacci-numbers-modulo-m.html

use 5.020;
use warnings;
use experimental qw(signatures);

use ntheory qw(:all);
use Math::GMPz;
#use Math::AnyNum qw(prod);
use Math::Prime::Util::GMP;

my @primes = @{primes(35)};

sub least_nonresidue_sqrtmod ($n) {    # for any n
    #for (my $p = 2 ; ; $p = next_prime($p)) {
    foreach my $p(@primes) {
        #sqrtmod($p, $n) // return $p;
        if (kronecker($p, $n) == -1) {
            return $p;
        }
    }

    return 97;
}

# 2, 3, 4, 102/25, 11/2, 6, 22/3, 12, 13, 73

my $k = 1;
my $z = 3*5*7;

say "# Generating with k = $k";

forprimes {

    #if (($_-1) % 3 == 0 and is_prime($k*($_-1) + 1)) {

    if (($_-1)%$z == 0) {
    foreach my $j(2..20) {

        next if ($j == $z);
        my $k = $j/$z;

    if (is_prime($k*($_-1) + 1) and least_nonresidue_sqrtmod($_) >= 35 and least_nonresidue_sqrtmod($k*($_-1) + 1) >= 35) {

        my $p = $_;
        my $n = $p * ($k*($p-1) + 1);

        if ($n > ((~0) >> 7)) {
            $n = Math::Prime::Util::GMP::mulint($p, $k*($p-1) + 1);
        }

        say "# Testing: $n with k = $k and p = $p";

        if (is_pseudoprime($n, 2)) {

            #if ($n > ~0) {
            #    $n = Math::GMPz::Rmpz_init_set_str($n, 10);
            #}

            #if (least_nonresidue_sqrtmod($n) >= 20) {
                say $n;
           # }
                }
            }
        }
    }

#} sqrtint(divint((~0)>>8, int($k))), 1e10;
} 1e10, 1e11;
#} sqrtint(divint((~0)>>4, int($k))), 1e11;
#} 66745519681, 1e11;



__END__
#say least_nonresidue_sqrtmod(151110961);
#say least_nonresidue_sqrtmod(302221921);

sub fermat_pseudoprimes ($limit, $callback) {

    my %common_divisors;

    forprimes {
        my $p = $_;
    #foreach my $p(11, 23, 31, 89, 97, 193, 241, 1151, 1201, 1321, 1801, 14951, 18191, 55441, 110881, 332641, 849601, 1327871, 1932841, 3466369, 11597041, 29375641, 96563041, 151110961, 215421361, 302221921, 1158756481) {
        #if ($p >= 3 and least_nonresidue_sqrtmod($p) >= 30) {
        #if ($p > 2) {

        if (least_nonresidue_sqrtmod($p) >= 40) {
            warn "Found: $p\n";
            my $z = znorder(2, $p);
            foreach my $d (divisors($p - 1)) {
                if (gcd($z, $d) == $z) {
                    push @{$common_divisors{$d}}, $p;
                }
            }
        }
        #}
    } 1158756481, 2*1158756481;

    warn "Done...\n";

    my %seen;

    foreach my $arr (values %common_divisors) {

        my $l = $#{$arr} + 1;

        foreach my $k (2 .. $l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                $callback->($n, @{$arr}[@_]) if !$seen{$n}++;
            } $l, $k;
        }
    }
}

sub is_fermat_pseudoprime ($n, $base) {
    powmod($base, $n - 1, $n) == 1;
}

sub is_fibonacci_pseudoprime($n) {
    (lucas_sequence($n, 1, -1, $n - kronecker($n, 5)))[0] == 0;
}

#my @pseudoprimes;

fermat_pseudoprimes(
    11234,
    sub ($n, @f) {

        if ($n >= 45669044917576081 and is_pseudoprime($n, 2)) {
            warn "$n\n";
            say $n;
        }
    }
);
