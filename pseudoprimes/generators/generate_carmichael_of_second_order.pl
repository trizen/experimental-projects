#!/usr/bin/perl

# Erdos construction method for Carmichael numbers:
#   1. Choose an even integer L with many prime factors.
#   2. Let P be the set of primes d+1, where d|L and d+1 does not divide L.
#   3. Find a subset S of P such that prod(S) == 1 (mod L). Then prod(S) is a Carmichael number.

# Alternatively:
#   3. Find a subset S of P such that prod(S) == prod(P) (mod L). Then prod(P) / prod(S) is a Carmichael number.

# The sequence of Carmichael numbers of order 2:
#   443372888629441, 39671149333495681, 842526563598720001, 2380296518909971201, 3188618003602886401, ...

# OEIS sequence:
#   https://oeis.org/A175531

use 5.020;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::GMPz;
#use Math::AnyNum qw(:overload);

# Modular product of a list of integers
sub vecprodmod ($arr, $mod) {
    my $prod = 1;
    foreach my $k (@$arr) {
        $prod = mulmod($prod, $k, $mod);
    }
    $prod;
}

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    grep { $L % $_ != 0 } grep { $_ > 2 } map { sqrtint($_) } grep { is_square($_) && is_prime(sqrtint($_)) } map { $_ + 1 } divisors($L);
    #grep { $L % $_ != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L);
}

sub method_1 ($L) {     # smallest numbers first

    my @P = lambda_primes($L);

    foreach my $k (3 .. @P) {
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
                say vecprod(@P[@_]);
            }
        } scalar(@P), $k;
    }
}

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

sub method_2($L) {

    my @P = lambda_primes($L);

    return if (vecprod(@P) < ~0);

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e5;
    my $max_k = 10;

    foreach my $k (3 .. @P>>1) {
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

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
                say vecprod(@P[@_]);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == 1) {
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
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = vecprod(@P[@_]);
                say ($T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

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

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 11;
    }

    if ($p == 3) {
        return valuation($n, $p) < 5;
    }

    if ($p == 5) {
        return valuation($n, $p) < 3;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    if ($p == 11) {
        return valuation($n, $p) < 2;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

my $h = smooth_numbers(10**10, [2, 3, 5, 7, 11, 13, 19, 31, 83]);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    valuation($n, 2) >= 6 or next;
    valuation($n, 3) >= 2 or next;
    valuation($n, 5) >= 1 or next;
    valuation($n, 7) >= 1 or next;

    #say "Generating: $n";

    method_2($n);
}
