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
use strict;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniqnum);

# a(n) is the smallest odd composite k such that prime(n)^((k-1)/2) == -1 (mod k) and b^((k-1)/2) == 1 (mod k) for every natural b < prime(n).

# a(n) : 3277, 5173601, 2329584217, 188985961, ... Is this sequence infinite?

# I found upper-bounds only for the next 5 terms:

# a(5) <= 32203213602841
# a(6) <= 323346556958041
# a(7) <= 2528509579568281
# a(8) <= 5189206896360728641
# a(9) <= 12155831039329417441

# Notice that the upper-bounds a(5)-a(9) are all semiprimes and are of the form p * (2*(p-1) + 1), for some prime number p.

# I couldn't find an upper-bound for a(10), which may be larger than 2^64 (assuming that it exists).

# More generally, we can look for numbers of the form k = p*q, where p and q are odd primes, such that d|((p-1)/2) and d|((q-1)/2), satisfying:
#   prime(n)^d == -1 (mod p)
#   prime(n)^d == -1 (mod q)

# This can be implemented efficiently by iterating over the odd primes bellow a certain limit and grouping primes together by divisors `d` that satisfy the wanted property.

# When a group has two or more primes, we iterate over all the combinations of two of those primes, say p and q, and generate k = p*q.

# Once we have k = p*q, it's very likely that:
#   prime(n)^((k-1)/2) == -1 (mod k)

# For each such number k, we check if:
#   b^((k-1)/2) == 1 (mod k) for every natural b < prime(n)

# Several more upper-bounds (example), with possible gaps, for each a(2)-a(7):
#   a(2) <= { 5173601, 6787327, 15978007, 314184487, 581618143, 682528687, 717653129, 1536112001, 1854940231, 1860373241, 2693739751, 3344191241, 4916322919, ... }
#   a(3) <= { 2329584217, 4394140633, 18491988217, 71430713857, 146463308377, 306190965697, 542381064457, 662181331897, 1749760817617, 2600044182457, 3420965597017, ... }
#   a(4) <= { 188985961, 922845241, 41610787921, 55165631041, 85103495641, 130173194161, 178420380841, 451403438041, 577255246921, 669094855201, 842611640041, 1038185022241, ... }
#   a(5) <= { 32203213602841, 92223430598881, 181122243848281, 244362410507881, 323731175307121, 359643366744481, 383326325785201, 503561507122801, ... }
#   a(6) <= { 323346556958041, 449287527233161, 871447814622001, 2419909071073201, ... }
#   a(7) <= { 2528509579568281, 51558565269914641, 251985537187183801, ... }

# Let b(n) be the smallest odd composite k such that q^((k-1)/2) == -1 (mod k) for every prime q <= prime(n).

#~ b(1) = 3277
#~ b(2) = 1530787
#~ b(3) <= 3697278427
#~ b(4) <= 118670087467
#~ b(5) <= 2152302898747
#~ b(6) <= 614796634515444067
#~ b(7) <= 614796634515444067

my $N = 5;
my $multiplier = 4;
my $P = nth_prime($N);
my $MAX = ~0;
my $LIMIT = 1e5;

use Math::GMPz;

sub prod {
    my $prod = 1;
    foreach my $n(@_) {
        $prod *= $n;
    }
    $prod;
}

# a(5) = 11530801
# a(7) = 15656266201

my @primes = @{primes(100)};

my @primes_bellow = @{primes($P)};

sub non_residue {
    my ($n) = @_;

    foreach my $p (@primes) {

        #if ($p > $Q) {
       #     return -1;
       # }

        sqrtmod($p, $n) // return $p;
    }

    return -1;
}

#~ #139309114031, a(9) <= 7947339136801, a(10) <= 72054898434289.
#~ say non_residue(139309114031, nth_prime(8));
#~ say non_residue(7947339136801, nth_prime(9));
#~ say non_residue(72054898434289, nth_prime(10));

#~ __END__
#~ say non_residue(72054898434289, nth_prime(10));

#~ __END__

sub isok {
    my ($k) = @_;

    my $t = $k-1;
    my $u = $t>>1;

    vecall { powmod($_, $u, $k) == $t } @primes_bellow;
}

#say isok(614796634515444067);
#say isok(8614572538322761627);

#392044843, 1568179369
#~ foreach my $p(factor(2152302898747)) {

    #~ foreach my $d(divisors(($p-1)>>1)) {
        #~ if (vecall {my $t = powmod($_, $d, $p); ($t == $p-1) } @primes_bellow) {
            #~ say "$p : $d -> ", join(', ', divisors($d));
        #~ }
    #~ }

    #~ say '';
#~ }

# Let a'(n) be the smallest odd prime p such that b^((p-1)/2) == 1 (mod p) for every natural b < prime(n).
# a(n) is the least number such that the n-th prime is the least quadratic nonresidue (not necessarily coprime) modulo a(n).


#~ __END__

#~ forprimes {
    #~ if (is_prime(($_-1)*$multiplier + 1)) {

        #~ my $k = Math::GMPz->new($_)*(($_-1)*$multiplier + 1);

        #~ if (isok($k)) {
            #~ die "a($N) <= $k\n";
        #~ }
    #~ }

#~ } 1e11, 1e12;


#~ __END__
sub fermat_pseudoprimes ($limit, $callback) {

    say "Collecting primes...";

    my %common_divisors;

    forprimes {
        my $p = $_;
        my $common = 0;

        foreach my $d (divisors(($p-1)>>1)) {
            #if (powmod($P, $d, $p) == $p-1 ) {

            if (vecall { powmod($_, $d, $p) == $p-1 } @primes_bellow) {
                #push @{$common_divisors{$d}}, $p;

                foreach my $g (divisors($d)) {
                    if ($g * 1000 >= $d) {
                       push @{$common_divisors{$g}}, $p;
                    }
                }
            }
        }

        #if (@div) {
        #    push @{$common_divisors{"@div"}}, $p;
        #}

        #~ if ($common) {
            #~ foreach my $n(2..100) {
                #~ if (is_prime(($p-1)*$n + 1)) {

                    #~ my $q = ($p-1)*$n + 1;
                    #~ foreach my $d (divisors($q - 1)) {
                        #~ if (powmod($P, $d, $q) == $q-1) {
                            #~ push @{$common_divisors{$d}}, $q;
                        #~ }
                    #~ }
                #~ }
            #~ }
        #~ }
  #  }

    } 3, $limit;

    say "Generating combinations...";

    #~ forprimes {
        #~ my $p = $_;
        #~ foreach my $d (divisors($p - 1)) {
            #~ if (powmod($P, $d, $p) == $p-1) {
                #~ push @{$common_divisors{$d}}, $p;
            #~ }
        #~ }
    #~ } $limit>>1, $limit;

    my %seen;

    foreach my $value (values %common_divisors) {

        my $arr = [uniqnum(@$value)];

        my $l = $#{$arr} + 1;

        if ($l > 100) {
            say "Combinations: $l";
        }

        foreach my $k (2..$l) {
            forcomb {
                my $n = prod(@{$arr}[@_]);
                if ($n <= $MAX) {
                    $callback->($n) #if !$seen{$n}++;
                }
            } $l, $k;
        }
    }
}

#~ sub is_fermat_pseudoprime ($n, $base) {
    #~ powmod($base, $n - 1, $n) == 1;
#~ }

#~ sub is_fibonacci_pseudoprime($n) {
    #~ (lucas_sequence($n, 1, -1, $n - kronecker($n, 5)))[0] == 0;
#~ }

my @values;
my %seen;

fermat_pseudoprimes(
    $LIMIT,
    sub ($k) {

      #  is_fermat_pseudoprime($n, 2) || die "error for n=$n";

        #~ if (kronecker($n, 5) == -1) {
            #~ if (is_fibonacci_pseudoprime($n)) {
                #~ die "Found a special pseudoprime: $n = prod(@f)";
            #~ }
        #~ }

    #~ if (powmod($P, ($k-1)>>1, $k) != $k-1) {
        #~ say "false: $k";
    #~ }

    if (isok($k) and !$seen{$k}++) {
        say "Found: $k";
        push @values, $k;
    }

       # push @pseudoprimes, $n;
    }
);


say "a($N) <= { ", join(', ', sort { $a <=> $b} @values), " }";

say "Min: a($N) <= ", vecmin(@values);
