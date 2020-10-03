#!/usr/bin/perl

# Erdos construction method for Carmichael numbers:
#   1. Choose an even integer L with many prime factors.
#   2. Let P be the set of primes d+1, where d|L and d+1 does not divide L.
#   3. Find a subset S of P such that prod(S) == 1 (mod L). Then prod(S) is a Carmichael number.

# Alternatively:
#   3. Find a subset S of P such that prod(S) == prod(P) (mod L). Then prod(P) / prod(S) is a Carmichael number.

use 5.020;
use warnings;
use ntheory qw(:all);
use List::Util qw(shuffle);
use experimental qw(signatures);

# Modular product of a list of integers
sub vecprodmod ($arr, $mod) {

    if ($mod > ~0) {
        my $prod = Math::GMPz->new(1);
        foreach my $k (@$arr) {
            $prod = ($prod * $k) % $mod;
        }
        return $prod;
    }

    my $prod = 1;
    foreach my $k (@$arr) {
        $prod = mulmod($prod, $k, $mod);
    }
    $prod;
}

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    my @divisors = divisors($L);
    if (ref $L) {
        @divisors = map{Math::GMPz->new($_)} @divisors;
    }
    grep { ($L % $_) != 0 } grep { $_ > 2 and is_prime($_) } map { $_ - 1 }  @divisors;
}

sub method_1 ($L) {     # smallest numbers first

    my @P = lambda_primes($L);
    my $n = scalar(@P);
    my @orig = @P;

    my $max = 5e2;
    my $max_k = @P>>1;

    foreach my $k (3 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        next if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }

    my $B = Math::GMPz->new(vecprodmod(\@P, $L));
    my $T = Math::GMPz->new(vecprod(@P));

    foreach my $k (1 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        last if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }
}

use Math::GMPz;

my %seen;
my $count = 0;

while (<>) {
    chomp(my $n = $_);

    #next if rand() < 0.95;

    #$n *= 210;
    $n *= 271;
    #$n = lcm($n, 10080);

    next if ($n < 1e3);
    #next if ($n < 829447240860);
    next if (length($n) > 45);

    #~ if (++$count % 100 == 0) {
        #~ say "# Testing: $n";
        #~ $count = 0 ;
    #~ }

    #say "Testing: $n";

    if ($n > ~0) {
        $n = Math::GMPz->new($n);
    }

    next if $seen{$n}++;
    method_1($n);
}
