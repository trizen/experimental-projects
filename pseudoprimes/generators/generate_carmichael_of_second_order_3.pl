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
use experimental qw(signatures);

use Math::GMPz;

# Modular product of a list of integers
sub vecprodmod ($arr, $mod) {
    my $prod = 1;
    foreach my $k (@$arr) {
        $prod = mulmod($prod, $k, $mod);
    }
    $prod;
}

#p^2 - 1 | n-1

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    grep { $L % $_ != 0 } grep { $_ > 2 and is_prime($_) } map { sqrtint($_) } grep { is_square($_) } map { $_ + 1 } divisors($L);
    #grep { $L % $_ != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L2);
}

#~ # Primes p such that p-1 divides L and p does not divide L
#~ sub lambda_primes ($L) {
    #~ #grep { $L % $_ != 0 } grep { $_ > 2 } map { sqrtint($_) } grep { is_square($_) && is_prime(sqrtint($_)) } map { $_ + 1 } divisors($L);
    #~ grep { $L % $_ != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L);
#~ }

#~ sub method_2 ($L) {     # largest numbers first

    #~ my @P = lambda_primes($L);
    #~ my $B = vecprodmod(\@P, $L);
    #~ my $T = vecprod(@P);

    #~ #say "@P";

    #~ foreach my $k (1 .. (@P-3)) {
        #~ #say "Testing: $k -- ", binomial(scalar(@P), $k);
        #~ my $count = 0;
        #~ forcomb {
            #~ if (vecprodmod([@P[@_]], $L) == $B) {
                #~ my $S = vecprod(@P[@_]);
                #~ say ($T / $S) if ($T != $S);
            #~ }
            #~ lastfor if (++$count > 1e6);
        #~ } scalar(@P), $k;
    #~ }
#~ }

sub method_1 ($L) {     # smallest numbers first

    my @P = lambda_primes($L);

    @P = grep {$_ >= 17 and $_ <= 1000 } @P;

    foreach my $k (3 .. @P) {
        say "k = $k";
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
                say vecprod(@P[@_]);
            }
        } scalar(@P), $k;
    }
}

sub method_2($L, $L2) {

    #my @P = grep { ($_ < 5e5) and ($_ >= 3) } lambda_primes($L2);
    my @P = grep { ($_ < 1e3) and ($_ >= 17) } lambda_primes($L2);

    #say "@P";

    return if (vecprod(@P) < ~0);

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e5;
    my $max_k = 10;

    foreach my $k (7 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        next if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        #~ @P = reverse(@P);

        #~ $count = 0;
        #~ forcomb {
            #~ if (vecprodmod([@P[@_]], $L) == 1) {
                #~ say vecprod(@P[@_]);
            #~ }
            #~ lastfor if (++$count > $max);
        #~ } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }

    my $B = vecprodmod(\@P, $L);
    my $T = Math::GMPz->new(vecprod(@P));

    foreach my $k (1 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        last if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        #~ @P = reverse(@P);

        #~ $count = 0;
        #~ forcomb {
            #~ if (vecprodmod([@P[@_]], $L) == $B) {
                #~ my $S = vecprod(@P[@_]);
                #~ say ($T / $S) if ($T != $S);
            #~ }
            #~ lastfor if (++$count > $max);
        #~ } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }
}

#method_1(720);
#method_2(720);

foreach my $L(

#60720, 221760, 831600, 2489760, 3067680, 3160080, 5544000, 15477000, 38427480, 64162560, 74646000, 79944480, 96238800, 149385600, 212186520, 273873600, 357033600, 910435680, 3749786040, 5069705760

#221760, 2489760, 3067680, 64162560, 149385600
#128842560, 137491200, 298771200, 766846080, 5004679680
#4007520, 128842560, 137491200, 155232000, 278586000, 298771200, 547747200, 766846080, 848746080, 1690809120, 1820871360, 2090088000, 5004679680, 5756002560, 6035752800, 6857373600, 62747697600, 67496148720, 1298888236800, 1449935847360
#1440, 1680, 2016, 5040, 6720, 10080, 18480, 20160, 95760, 106560, 134640, 142800, 166320, 186480, 191520, 208320, 364320, 376992, 536256, 929880, 1177488, 1484280, 3800160, 4426800, 4553280, 11040960, 16703280, 23173920, 38641680, 46060560, 72913680, 171004680
#276480, 1161216, 2903040, 5806080, 7741440, 42577920, 77552640, 107412480, 245514240, 854945280, 1625702400, 2162184192, 2712932352, 3357573120, 3971358720, 5573836800, 9870336000, 13348177920, 15467397120, 26266705920, 28798156800, 34488115200, 63745920000, 74132029440, 86589803520, 98498695680, 111288038400, 114653822976, 158989824000, 167993118720, 192819916800, 238777943040, 262268928000
#128842560, 137491200, 155232000, 298771200, 547747200, 766846080, 848746080, 1690809120, 5004679680, 6857373600
#50227322745600
#59192848915200
#24404583472315200
#3286483200
#[821620800, 3286483200]
[221760, 137491200], [2489760, 766846080], [3067680, 128842560], [64162560, 5004679680], [149385600, 298771200],
#[60720, 4007520], [221760, 137491200], [831600, 6035752800], [2489760, 766846080], [3067680, 128842560], [3160080, 6857373600], [5544000, 155232000], [15477000, 278586000], [38427480, 1690809120], [64162560, 5004679680], [74646000, 2090088000], [79944480, 5756002560], [96238800, 62747697600], [149385600, 298771200], [212186520, 848746080], [273873600, 547747200], [357033600, 1298888236800], [910435680, 1820871360], [3749786040, 67496148720], [5069705760, 1449935847360],
#[36, 5040], [36, 95760], [48, 2016], [60, 6720], [60, 208320], [72, 186480], [80, 1440], [108, 166320], [112, 10080], [112, 191520], [120, 1680], [180, 1484280], [198, 134640], [216, 16703280], [240, 20160], [288, 536256], [300, 142800], [360, 106560], [360, 46060560], [420, 11040960], [504, 186480], [528, 376992], [540, 4553280], [600, 4426800], [720, 23173920], [1224, 1177488], [1320, 18480], [1980, 171004680], [2024, 364320], [2268, 929880], [2320, 3800160], [6120, 72913680], [8568, 38641680]
) {

    #foreach my $k(2..100) {
        method_2($L->[0], $L->[1]);
    #}
    #method_1($L);
}
