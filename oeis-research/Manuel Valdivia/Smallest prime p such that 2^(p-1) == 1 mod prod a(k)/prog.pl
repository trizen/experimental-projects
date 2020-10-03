#!/usr/bin/perl

# a(n) is the smallest prime p such that 2^(p-1) == 1 (mod a(0)*...*a(n-1)*p), with a(0) = 1.
# https://oeis.org/A175257

# Daniel Suteu: p-1 seems to be very smooth. Based on this observation, I conjecture that the next few terms, after a(26), are:
#   481461926401, 722192889601, 2888771558401, 7944121785601, 55608852499201, 111217704998401, 889741639987201, 1779483279974401, 3114095739955201.

# a(27) = 481461926401 was confirmed by Hans Havermann (Mar 29 2019).

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::AnyNum qw(prod);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 13;
    }

    if ($p == 3) {
        return valuation($n, $p) < 12;
    }

    if ($p == 5) {
        return valuation($n, $p) < 5;
    }

    if ($p == 7) {
        return valuation($n, $p) < 5;
    }

    if ($p == 11) {
        return valuation($n, $p) < 3;
    }

    if ($p == 13) {
        return valuation($n, $p) < 5;
    }

    if ($p == 17) {
        return valuation($n, $p) < 3;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit) { #and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

my $mod = prod(3, 5, 13, 37, 73, 109, 181, 541, 1621, 4861, 9721, 19441, 58321, 87481, 379081, 408241, 2041201, 2449441, 7348321, 14696641, 22044961, 95528161, 382112641, 2292675841, 8024365441, 40121827201, 481461926401, 722192889601, 2888771558401, 7944121785601, 55608852499201, 111217704998401, 889741639987201, 1779483279974401, 3114095739955201);

sub isok ($n) {

   if (is_prime($n+1)) {
        return powmod(2, $n, ($n+1)*$mod) == 1
    }

    return 0;
}

# 481461926401

my $h = smooth_numbers(3114095739955201, primes(23));

say "\nFound: ", scalar(@$h), " terms";

my @list;

foreach my $n (@$h) {

    my $p = isok($n);

    if ($p) {
        say "a($p) = ", $n+1, " -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @list, $n+1;
    }
}

say vecmin(@list);
