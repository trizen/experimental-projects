#!/usr/bin/perl

# Semi-unitary perfect numbers: numbers n such that susigma(n) = 2n, where susigma(n) is the sum of the semi-unitary divisors of n (A322485).
# https://oeis.org/A322486

use 5.010;
use strict;
use warnings;

use Math::GMPz;
#use Math::AnyNum qw(:overload);
use ntheory qw(vecprod vecsum factor_exp primes random_prime urandomm shuffle);

#~ foreach my $n(1846273228800..10*1846273228800) {
    #~ my $prod = vecprod(map {
            #~ my ($p, $e) = @$_;
            #~ ($p**int(($e+1)/2) - 1) / ($p-1) + $p**$e
        #~ } factor_exp($n)
    #~ );

    #~ if ($prod == 2*$n) {
        #~ say "Found: ", $n;
    #~ }
#~ }

#~ __END__
my @primes = @{primes(19)};

my $limit = Math::GMPz->new(2)**100;

my @h = (Math::GMPz->new(1));
foreach my $p (@primes) {
    say "Prime: $p";
    foreach my $n (@h) {

        if ($p <= 7 or $n%$p != 0) {

            if ($p==3 and $n%3**6==0) {
                next;
            }

            if ($p > 3 and $n%$p**2 == 0) {
                next;
            }

            if ($p == 2 and $n%2**32 == 0) {
                next;
            }

        if ($n * $p <= $limit) {
            push @h, $n * $p;
        }
    }
    }
}

#@h = shuffle(@h);
say "Hamming numbers: ", $#h;

my %seen;
my @terms =  (@{primes(2,10000)});

my $t = Math::GMPz::Rmpz_init();

foreach my $h(@h) {



    #~ @f >= 6 or next;
    #~ $f[0][0] == 2 or next;
    #~ $f[0][1] >= 5 or next;
    #~ vecsum(map{$_->[1]} @f) >= 10 or next;

    #say $h;

    #for (1..10) {
        #my $k = random_prime(30, 10_000);
       # foreach my $k(1..1e6) {
        #~ my $n = $h*$k;

        #~ if ($n >= 23253135360) {

        #~ if ($n > 2**60) {
            #~ Math::GMPz::Rmpz_set_ui($t, $h);
            #~ Math::GMPz::Rmpz_mul_ui($t, $t, $k);
            #~ $n = $t;
        #~ }

foreach my $k(@terms) {
        my $n = $h*$k;
        #my @f = factor_exp($h);

    my $prod = vecprod(map {
            my ($p, $e) = @$_;
            ($p**int(($e+1)/2) - 1) / ($p-1) + $p**$e
        } factor_exp($n)
    );

    if ($prod == 2*$n) {
        say "Found: ", $n;
        }
    }
}
#}
#}

__END__
# New term: 1846273228800

use 5.014;
use ntheory qw(factor_exp vecprod primes);

my @bases = (
    #~ [2,16],
    #~ [3,1],
    #~ #[5,1],
    #~ [7,1],
    #~ [11,1],
    #~ [13,1],
    #[17,1],
    #[19,1],

   # [2, 13], [3, 1], [5, 2], [7, 1], [11, 1],[19,5],
   [2, 14],  [5, 1], [7, 1], [11, 1],  [17,1]
);

my $bases_prod = vecprod(map{$_->[0]**$_->[1]}@bases);
my @primes = @{primes(1e4)};
my @small_primes = @{primes(100)};

#for my $k(1..1e6) {
foreach my $k(@primes) {

    foreach my $p(@primes) {

        foreach my $q (@small_primes) {

            my $n = $p*$k;

        while (1) {

            last if ($n*$bases_prod > 2**64);

    my $prod = vecprod(map {
            my ($p, $e) = @$_;
            ($p**int(($e+1)/2) - 1) / ($p-1) + $p**$e
        } factor_exp($bases_prod*$n)
    );

    if ($prod == 2*$n*$bases_prod) {
        say "Found: ", $n*$bases_prod;
        }

        $n*=$q;
    }
}
}
}
