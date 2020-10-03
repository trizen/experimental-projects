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

    #~ if ($mod > ~0) {
        #~ my $prod = Math::GMPz->new(1);
        #~ foreach my $k(@$arr) {
            #~ $prod = ($prod * $k) % $mod;
        #~ }
        #~ return $prod;
    #~ }

    if ($mod < ~0) {
        my $prod = 1;
        foreach my $k(@$arr) {
            $prod = mulmod($prod, $k, $mod);
        }
        return $prod;
    }

    my $prod = 1;

    foreach my $k (@$arr) {
        $prod = Math::Prime::Util::GMP::mulmod($prod, $k, $mod);
    }

    Math::GMPz->new($prod);
}

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    #grep { ($L % $_) != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L);
     grep { ($_ > 2) and (($L % $_) != 0) and is_prime($_) } map { ($_ >= ~0) ? (Math::GMPz->new($_)+1) : ($_ + 1) } divisors($L);
}

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89);
#my @prefix = (3,5,17,23, 29);

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 353, 617, 2003, 2549);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 353, 617);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 419, 449, 617);

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003);

#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 257, 353, 617, 1409, 2003, 2549, 3137, 9857, 10193, 16073, 68993, 202049, 275969, 1500929, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2297, 2549, 3137, 9857, 10193, 68993, 88397, 93809, 5850209, 8044037, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2549, 3137, 4019, 4289, 10193, 16073, 21977, 38459, 50513, 52529, 76649, 93809, 97553]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2549, 8009, 9857, 23297, 50513, 68993, 275969, 375233, 1500929, 3232769, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2297, 2549, 3329, 8009, 10193, 16073, 23297, 50177, 93809, 202049, 275969, 656657, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019, 7547, 9857, 10193, 16073, 17837, 23297, 68993, 88397, 93809, 202049, 896897, 1500929, 2475089, 8044037, 18386369]

my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019);
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2297, 2549, 3137, 9857, 10193, 68993, 88397, 93809, 5850209, 8044037, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2549, 3137, 4019, 4289, 10193, 16073, 21977, 38459, 50513, 52529, 76649, 93809, 97553]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2549, 8009, 9857, 23297, 50513, 68993, 275969, 375233, 1500929, 3232769, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2297, 2549, 3329, 8009, 10193, 16073, 23297, 50177, 93809, 202049, 275969, 656657, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019, 7547, 9857, 10193, 16073, 17837, 23297, 68993, 88397, 93809, 202049, 896897, 1500929, 2475089, 8044037, 18386369]

#my @prefix = (3, 5, 17, 23, 29);
my $prefix_prod = Math::GMPz->new(vecprod(@prefix));

sub method_1 ($L) {     # smallest numbers first

    (vecall { ($L % ($_-1)) == 0 } @prefix) or return;

    my @P = lambda_primes($L);

    @P = grep {
        (($prefix_prod % $_) == 0)
            ? 1
            : Math::Prime::Util::GMP::gcd(Math::Prime::Util::GMP::totient(Math::Prime::Util::GMP::mulint($prefix_prod, $_)), Math::Prime::Util::GMP::mulint($prefix_prod, $_)) eq '1'
    } @P;

    #vecprodmod(@P, 3*5*17*23) == 0 or return;
    #vecprodmod(\@P, 3*5*17*23*29) == 0 or return;
    if (@prefix) {
        vecprodmod(\@P, $prefix_prod) == 0 or return;
    }
    #return if (vecprod(@P) < ~0);

    @P = grep { $_ > $prefix[-1] } @P;
    #@P = grep { gcd($prefix_prod, $_) == 1 } @P;

    say "# Testing: $L -- ", scalar(@P);

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e6;
    my $max_k = scalar(@P);

    my $L_rem = invmod($prefix_prod, $L);

    foreach my $k (1 .. @P) {
        #next if (binomial($n, $k) > 1e6);

        next if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }

    my $B = vecprodmod([@P, $prefix_prod], $L);
    my $T = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P));

    foreach my $k (1 .. @P) {
        #next if (binomial($n, $k) > 1e6);

        last if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
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

    #$n > 1e5 or next;

    #$n *= 656656;
    #$n *= 78848;
    #$n *= 1232;

    #$n = lcm($n, 29586292736);
    #$n = lcm($n, 1232);
    #$n = lcm($n, 5789168, 147090944);
    #$n = lcm($n, 78848);
    #$n = lcm($n, 656656);
    #$n = lcm($n, 9193184);

    #$n = lcm($n, 10506496);
    #$n = lcm($n, 36772736);

    #~ next if ($n < 707981814540);
    #~ next if ($n > 44351949725003712);

    #next if ($n < 1e6);

    #next if ($n < 1e8);
    #next if ($n < 7813080);        # for 2^64

    #next if ($n < ~0);

    #next if ($n < 17125441200);
    #next if (length($n) > 45);

   # if (++$count % 1000 == 0) {
        #say "Testing: $n";
       # $count = 0 ;
   # }

    #say "Testing: $n";

    if ($n > ~0) {
        $n = Math::GMPz->new($n);
    }

    next if $seen{$n}++;
    method_1($n);
}
