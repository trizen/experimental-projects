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
use List::Util qw(uniqnum shuffle);


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

# b(n) is the smallest odd composite k such that prime(n)^((k-1)/2) == 1 (mod k) and q^((k-1)/2) == -1 (mod k) for every prime q < prime(n).

# b(n) : 341, 29341, ?  Is this sequence finite?

# b(3) <= 75350936251        (the actual value is 48354810571)
# b(4) <= 493813961816587
# b(5) <= 32398013051587
# b(6) <= 35141256146761030267
# b(7) <= 4951782572086917319747

# b(3) <= { 75350936251, 142186219181, 183413388211, 187403492251, 244970876021, 247945488451, 405439595861, 1121610731251, 1566655993781, 1990853572901, 2731649128781, 5042919827861, 5792018372251, 5830202612851, 6226129086451, 6664768278451, 7738029492211, 8648900162251, 9425030475451, 9429387401741, 10216085978251, 14804189283451, 15263877377251, 15883263707851, ... }
# b(4) <= { 493813961816587, 655462669313563, 712305136356547, 1012925163368467, 1063809017035267, 1350727530916147, 1406616417615667, 1554737931642307, 1794376822387267, 2167215816099907, 2402921698865827, ... }
# b(5) <= { 32398013051587, 4627853036319787, 7333470436409443, 29645348137369147, 36140749487965627, 44213562255703843, 62804051517546907, 92101327510561027, 94423328872035643, 118469127753064747, ... }

my $N = 3;
my $multiplier = 4;
my $P = nth_prime($N);
my $MAX = ~0;
my $LIMIT = 1e5;

my @primes_bellow = @{primes($P-1)};

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

sub non_residue {
    my ($n) = @_;

    foreach my $p (@primes) {

        #if ($p > $Q) {
       #     return -1;
       # }

        sqrtmod($p, $n) && return $p;
    }

    return -1;
}

#~ say non_residue(32398013051587);
#~ say non_residue(11383849);
#~ say non_residue(2845963);

#~ __END__
#~ #139309114031, a(9) <= 7947339136801, a(10) <= 72054898434289.
#~ say non_residue(139309114031, nth_prime(8));
#~ say non_residue(7947339136801, nth_prime(9));
#~ say non_residue(72054898434289, nth_prime(10));

#~ __END__
#~ say non_residue(72054898434289, nth_prime(10));

#~ __END__

sub isok {
    my ($k) = @_;

    if (powmod($P, ($k-1)>>1, $k) == 1)  {
        return vecall { powmod($_, ($k-1)>>1, $k) == $k-1 } @primes_bellow;
    }

    return;

    #~ my $res;
    #~ my $p = nth_prime($n);

    #~ for(my $k = $A000229[$n-1]*$A000229[$n-1]; ; $k+=2) {

        #~ if (!is_prime($k) and powmod($p, ($k-1)>>1, $k) == $k-1) {
            #~ my $q = non_residue($k, $p);

            #~ if ($p == $q) {
                #~ return $k;
            #~ }
        #~ }
    #~ }

    #~ return $res;
}

#~ die non_residue(11110962);


#~ use Math::AnyNum qw(:overload);

#~ say non_residue(341);
#~ say non_residue(29341);

#~ say non_residue(48354810571);

#~ say '';

#~ say non_residue(331);
#~ say non_residue(2971);
#~ say non_residue(49171);

#~ say '';

#~ say non_residue(48354810571);
#~ say non_residue(245291853691);
#~ say non_residue(1196678873251);
#~ say non_residue(4525783922251);

#~ say '';
#~ say powmod($P, (331-1)/2, 331);
#~ say powmod($P, (2971-1)/2, 2971);
#~ say powmod($P, (49171-1)/2, 49171);

#~ say isok(493813961816587);
#~ say '';

#~ say join(', ', grep{powmod($P, $_, 11110963) == 1} divisors(11110963-1));
#~ say join(', ', grep{powmod($P, $_, 44443849) == 1} divisors(44443849-1));

#~ #say join(', ', grep{ powmod($P, $_, 331) == 1 } divisors(331-1));
#~ #say join(', ', grep{ powmod($P, $_, 2971) == 1 } divisors(2971-1));
#~ #say join(', ', grep{ powmod($P, $_, 49171) == 1 } divisors(49171-1));


#~ exit;
#~ say '';

#~ say non_residue(32398013051587);
#~ say non_residue(35141256146761030267);
#~ say non_residue(4951782572086917319747);

#~ __END__
#~ forprimes {

    #~ if (is_prime(($_-1)*$multiplier+ 1)) {

        #~ my $k = Math::GMPz->new($_)* (($_-1)*$multiplier + 1);

        #~ #(($_-1)*$multiplier + 1);

        #~ if (isok($k)) {
            #~ die "a($N) <= $k\n";
        #~ }
    #~ }

#~ } 1e10,1e11;

sub fermat_pseudoprimes ($limit, $callback) {

    say "Collecting primes...";

    my %common_divisors;

    forprimes {
        my $p = $_;
        my $common = 0;

        #my $non_residue = non_residue($p);
        #if ($non_residue == $P) {
        if (1) {

        foreach my $d (divisors(($p-1)>>1)) {
            my $w = powmod($P, $d, $p);

           # if ((($w == 1) || ($w==$p-1))
           if ($w == 1

           and vecall {
                my $t = powmod($_, $d, $p);
                #($t == 1) || ($t == $p-1)
                $t == ($p-1)
            } @primes_bellow
            ) {

                 foreach my $f(divisors($d)) {
                     if ($f > sqrtint($d)) {
                        push @{$common_divisors{$f}}, $p;
                    }
                 }

                #push @{$common_divisors{non_residue($p)}}, $p;
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

        my $arr = [shuffle(uniqnum(@$value))];

        my $l = $#{$arr} + 1;

        #$l = 100 if ($l > 100);
        #~ if ($l > 200) {
            #~ say "Combinations: $l";
            #~ $l = 200;
        #~ }

        if ($l > 100) {
            say "Combinations: $l";
        }

        foreach my $k (2..($l >= 3 ? 3 : 2)) {
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
my $min = $MAX;

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

    #say $k;

    if (isok($k) and !$seen{$k}++) {
        say "Found: $k";
        push @values, $k;

        if ($k <= $min) {
            say "New min found: $k";
            $min = $k;
        }
    }

       # push @pseudoprimes, $n;
    }
);


say "b($N) <= { ", join(', ', sort { $a <=> $b} @values), " }";

say "Min: b($N) <= ", vecmin(@values);
