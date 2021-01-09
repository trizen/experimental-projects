#!/usr/bin/perl

# Given a positive integer `n`, this algorithm finds all the numbers k
# such that sigma(k) = n, where `sigma(k)` is the sum of divisors of `k`.

# Based on "invphi.gp" code by Max Alekseyev.

# See also:
#   https://home.gwu.edu/~maxal/gpscripts/

# 1, 2, 3, 4, 5, 7, 333, 17571, 1757571, 1787871, 5136315, 518686815, 541626145, 17575757571, 5136813186315, 5136868686315, 5806270726085, 172757272757271, 513636363636315, 17275787578757271, 17578787578787571, 17878787578787871, 51363636363636315, 51363681318636315, 51363686868636315, 51368136363186315, 51368631313686315, 51818186868181815
# 1, 2, 3, 4, 5, 7, 333, 17571, 1757571, 1787871, 5136315, 518686815, 541626145, 17575757571, 5136813186315, 5136868686315, 5806270726085, 172757272757271, 513636363636315

# a(n) ={my(d, i, r); r=vector(#digits(n-10^(#digits(n\11)))+#digits(n\11)); n=n-10^(#digits(n\11)); d=digits(n); for(i=1, #d, r[i]=d[i]; r[#r+1-i]=d[i]); sum(i=1, #r, 10^(#r-i)*r[i])}

# See also:
#   https://oeis.org/A028986 -- Palindromes whose sum of divisors is palindromic.
#   https://oeis.org/A327324 -- Palindromes whose number and sum of divisors are both also palindromic.

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
#use Math::AnyNum qw(:overload);

sub dynamicPreimage ($N, $L) {

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            foreach my $d (divisors(divint($N, $x))) {
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            }
        }
        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    sort { $a <=> $b } @{$r{$N}};
}

sub cook_sigma ($N, $k) {
    my %L;

    foreach my $d (divisors($N)) {

        next if ($d == 1);

        foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

            my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
            my $t = valuation($q, $p);

            next if ($t <= $k or ($t % $k) or $q != powint($p, $t));

            push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
        }
    }

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    ($N == 1) ? (1) : dynamicPreimage($N, cook_sigma($N, $k));
}

sub next_palindrome ($n) {

    my @d = split(//, $n);
    my $i = (scalar(@d) + 1)>>1;

    while ($i > 0 and $d[$i-1] == 9) {
        $d[$i-1] = 0;
        $d[$#d+1-$i] = 0;
        $i--;
    }

    if ($i > 0) {
        $d[$i-1]++;
        $d[$#d+1-$i] = $d[$i-1];
    }
    else {
        @d = (0)x(scalar(@d) + 1);
        $d[0] = 1;
        $d[-1] = 1;
    }

    fromdigits(\@d);
}

#say next_palindrome(821818181818128);
my $n = 1;

$| = 1;
my %seen;

for my $k (2..1e12) {
    #say "$k $n";

    my $t = divisor_sum($n);

    if ($t eq scalar(reverse($t))) {
        my $d = divisor_sum($n, 0);
        if ($d <= 9 or $d eq scalar(reverse($d))) {
            print($n, ", ");
        }
    }

        $n = next_palindrome($n);


    #~ my @d = inverse_sigma($n);

    #~ foreach my $d(@d) {
        #~ if ($d eq scalar(reverse($d)) and !$seen{$d}++) {
            #~ my $t = divisor_sum($d, 0);
            #~ if ($t <= 9 or $t eq scalar(reverse($t))) {
                #~ print($d, ", ");
            #~ }
        #~ }
    #~ }

    #~ my $t = divisor_sum($n, 0);

    #~ if ($t <= 9 or $t eq scalar(reverse($t))) {
        #~ my @d = inverse_sigma($n);

        #~ if (vecany { }
    #~ }
}

# {my(d=digits(n)); i=(#d+1)\2; while(i&&d[i]==9, d[i]=0; d[#d+1-i]=0; i--); if(i, d[i]++; d[#d+1-i]=d[i], d=vector(#d+1); d[1]=d[#d]=1); sum(i=1, #d, 10^(#d-i)*d[i])}


#say for inverse_sigma(821818181818128);
