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
#x =
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);
#use Math::AnyNum qw(:overload);

sub inverse_sigma ($n, $m = 3) {

    return (1) if ($n == 1);

    my @R;
    foreach my $d (grep { $_ >= $m } divisors($n)) {
        foreach my $p (map { $_->[0] } factor_exp($d - 1)) {
            my $P = $d * ($p - 1) + 1;
            my $k = valuation($P, $p) - 1;
            next if (($k < 1) || ($P != $p**($k + 1)));
            push @R, map { $_ * $p**$k } grep { $_ % $p != 0; } __SUB__->($n/$d, $d);
        }
    }

    return uniq(@R);
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
