#!/usr/bin/perl

# a(n) is the smallest number k such that n consecutive integers starting at k have the same number of nonprime divisors (A033273).
# https://oeis.org/A324594

# Terms of the form 2^k * p - r
#   2^6 * 4603 - 2 has a score of 6
#   2^6 * 84631 - 2 has a score of 6
#   2^6 * 259781 - 2 has a score of 6
#   2^6 * 309019 - 2 has a score of 6
#   2^6 * 407137 - 3 has a score of 6
#   2^6 * 645979 - 3 has a score of 6
#   2^6 * 740713 - 2 has a score of 6
#   2^6 * 795703 - 2 has a score of 6
#   2^6 * 932567 - 3 has a score of 6
#   2^6 * 1192153 - 2 has a score of 6
#   2^6 * 1256161 - 3 has a score of 6
#   2^6 * 1328521 - 2 has a score of 6
#   2^6 * 1339069 - 2 has a score of 6
#   2^6 * 1608611 - 3 has a score of 6

# Terms of the form 3^k * p - r
#   3^6 * 196439 - 1 has a score of 6
#   3^6 * 1153367 - 1 has a score of 6
#   3^6 * 1447639 - 1 has a score of 6
#   3^6 * 2218967 - 2 has a score of 6
#   3^6 * 2289193 - 4 has a score of 6
#   3^6 * 3032279 - 1 has a score of 6
#   3^6 * 3111721 - 4 has a score of 6
#   3^6 * 3214423 - 2 has a score of 6
#   3^6 * 3704653 - 7 has a score of 6
#   3^6 * 4276567 - 1 has a score of 6
#   3^6 * 6230359 - 1 has a score of 6
#   3^6 * 7166167 - 1 has a score of 6
#   3^6 * 7652521 - 4 has a score of 6
#   3^6 * 8124247 - 1 has a score of 6
#   3^6 * 8124247 - 2 has a score of 7
#   3^6 * 8666153 - 4 has a score of 6
#   3^6 * 9008599 - 2 has a score of 6
#   3^6 * 9171497 - 3 has a score of 6
#   3^6 * 9231401 - 3 has a score of 6
#   3^6 * 9422761 - 3 has a score of 6
#   3^6 * 9422761 - 4 has a score of 7

# Terms of the form 3^k * c - r, for c composite
#   3^6 * 196439 - 1 has a score of 6
#   3^6 * 1153367 - 1 has a score of 6
#   3^6 * 1447639 - 1 has a score of 6
#   3^6 * 2218967 - 2 has a score of 6
#   3^6 * 2289193 - 4 has a score of 6
#   3^6 * 3032279 - 1 has a score of 6
#   3^6 * 3111721 - 4 has a score of 6
#   3^6 * 3214423 - 2 has a score of 6
#   3^6 * 4276567 - 1 has a score of 6
#   3^6 * 6230359 - 1 has a score of 6
#   3^6 * 7166167 - 1 has a score of 6
#   3^6 * 7652521 - 4 has a score of 6
#   3^6 * 8124247 - 1 has a score of 6
#   3^6 * 8124247 - 2 has a score of 7
#   3^6 * 8666153 - 4 has a score of 6
#   3^6 * 9008599 - 2 has a score of 6

# Terms of the form 5^k * p - r
#   5^6 * 1305607 - 2 has a score of 6
#   5^6 * 2990983 - 1 has a score of 6
#   5^6 * 2990983 - 2 has a score of 7
#   5^6 * 4659449 - 3 has a score of 6
#   5^6 * 4659449 - 4 has a score of 7
#   5^6 * 8747527 - 2 has a score of 6
#   5^6 * 10925177 - 4 has a score of 6
#   5^6 * 11025031 - 2 has a score of 6
#   5^6 * 13041401 - 4 has a score of 6
#   5^6 * 15048967 - 1 has a score of 6
#   5^6 * 16120697 - 3 has a score of 6

# Scores of 7:
#   5^6 * 2990983 - 2 has a score of 7
#   5^6 * 4659449 - 4 has a score of 7
#   3^6 * 29597353 - 4 has a score of 7
#   3^6 * 51533527 - 2 has a score of 7
#   3^6 * 59263273 - 4 has a score of 7
#   3^6 * 69951703 - 2 has a score of 7
#   3^6 * 90200233 - 4 has a score of 7
#   3^6 * 93846359 - 2 has a score of 7

# 3^6 * 1375200041 - 4 = 1002520829885 has a score of 7
# 3^6 * 1395258793 - 4 = 1017143660093 has a score of 7
# 3^6 * 1410896041 - 4 = 1028543213885 has a score of 7
# 3^6 * 1441850327 - 2 = 1051108888381 has a score of 7
# 3^6 * 1446760873 - 4 = 1054688676413 has a score of 7
# 3^6 * 1450313897 - 4 = 1057278830909 has a score of 7
# 3^6 * 1455787433 - 4 = 1061269038653 has a score of 7

# 3^6 * 16269510953 - 4 = 11860473484733 has a score of 7
# 3^6 * 16270051753 - 4 = 11860867727933 has a score of 7
# 3^6 * 16309914793 - 4 = 11889927884093 has a score of 7
# 3^6 * 16320385321 - 4 = 11897560899005 has a score of 7
# 3^6 * 16347211561 - 4 = 11917117227965 has a score of 7

# 3^6 * 16579478359 - 2 = 12086439723709 has a score of 7
# 3^6 * 16594579927 - 2 = 12097448766781 has a score of 7
# 3^6 * 16957944407 - 2 = 12362341472701 has a score of 7
# 3^6 * 16975847639 - 2 = 12375392928829 has a score of 7
# 3^6 * 16998570839 - 2 = 12391958141629 has a score of 7
# 3^6 * 17037039959 - 2 = 12420002130109 has a score of 7
# 3^6 * 17039658967 - 2 = 12421911386941 has a score of 7
# 3^6 * 17042953559 - 2 = 12424313144509 has a score of 7
# 3^6 * 17043988183 - 2 = 12425067385405 has a score of 7
# 3^6 * 17064215383 - 2 = 12439813014205 has a score of 7
# 3^6 * 17068602839 - 2 = 12443011469629 has a score of 7

# 2^6 * 18173732117 - 3 = 1163118855485 has a score of 7
# 2^6 * 18174084287 - 3 = 1163141394365 has a score of 7
# 2^6 * 18175036963 - 3 = 1163202365629 has a score of 7
# 2^6 * 18175449433 - 3 = 1163228763709 has a score of 7
# 2^6 * 18175597079 - 3 = 1163238213053 has a score of 7
# 2^6 * 18175990037 - 3 = 1163263362365 has a score of 7
# 2^6 * 18176702953 - 3 = 1163308988989 has a score of 7

# Known terms:
#   1, 1, 1, 19940, 204323, 294590

# a(7) <= 3^6 * 8124247 - 2
# a(7) = 310042685

#~ nonpd(n) = numdiv(n) - omega(n);
#~ score(n) = my(t=nonpd(n)); for(k=1, oo, if(nonpd(n+k) != t, return(k)));
#~ upto(nn) = my(n=1); for(k=1, nn, while(score(k) >= n, print1(k, ", "); n++));

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub count ($n) {
    divisor_sum($n, 0) - scalar(factor_exp($n));
}

sub score ($n) {
    my $t = count($n);

    for my $k (1..100) {
        if (count($n+$k) != $t) {
            return $k;
        }
    }
}

#~ foreach my $k(int(1e12/2**6).. 1e12) {

    #~ foreach my $r(1,2,3,4) {
        #~ my $s = score(2**6*$k - $r);

        #~ if ($s >= 6) {
            #~ say "2^7 * $k - $r has a score of $s -- ", is_prime($k);
        #~ }
    #~ }
#~ }

#~ __END__
forprimes {

    my $n = 2**6*$_ - 3;
    my $s = score($n);

    if ($s >= 7) {

        say "2^6 * $_ - 3 = $n has a score of $s";
        my $m = $n-1;

        if (score($m) >= 8) {
            die "Upper-bound for a(8) = $m\n";
        }
    }
} 18176702953, 1e11;

#~ foreach my $k(17897363753..1e13) {
    #~ my $n = 2**6*$k - 3;
    #~ my $s = score($n);

    #~ if ($s >= 7) {
        #~ say "2^6 * $k - 3 = $n has a score of $s -- ", is_prime($k);
        #~ my $m = $n - 1;
        #~ if (score($m) >= 8) {
            #~ die "Upper-bound for a(8) = $m\n";
        #~ }
    #~ }
#~ }

__END__

forprimes {

    my $n = 2**7*$_ - 3;
    my $s = score($n);

    if ($s >= 5) {

        say "2^5 * $_ - 3 = $n has a score of $s";
        my $m = 2**5 * $_ - 4;

        if (score($m) >= 8) {
            die "Upper-bound for a(8) = $m\n";
        }
    }

} 1e9, 1e10;

__END__

my $n = 6;
local $| = 1;

foreach my $k(1e8..1e9) {
    while (score($k) >= $n) {
        print($k, ", ");
        ++$n;
    }
}

__END__

func both_prime(n) {
    primality_pretest(n-2) && primality_pretest(n+2) && is_prob_prime(n-2) && is_prob_prime(n+2)
}

func a(n) {
    for k in (1..1e12) {
        if (both_prime(k**n)) { #&& (next_prime(k**n) - prev_prime(k**n) == 4)) {
            return k
        }
    }
}

for n in (1..50) {
    print(a(n), ", ")
    #say "a(#{n}) = #{a(n)}"
}

__END__
a(1) = 5
a(2) = 3
a(3) = 129
a(4) = 3
a(5) = 411
a(6) = 195
a(7) = 99
a(8) = 1023
a(9) = 141
a(10) = 105
a(11) = 1161
a(12) = 909
a(13) = 69
a(14) = 3243
a(15) = 171
a(16) = 2229
a(17) = 1659
a(18) = 165
a(19) = 26289
a(20) = 1065
