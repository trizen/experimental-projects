#!/usr/bin/perl

# Least positive number k such that sigma(k) = n * sigma(k+1).
# https://oeis.org/A340720

# Known terms:
#   14, 12, 180, 25908120

# a(5) > 53117846646, based on data from A058073.

# Related sequences:
#   https://oeis.org/A340582 -- Numbers k such that sigma(k) = 4 * sigma(k+1).
#   https://oeis.org/A058073 -- Numbers n such that sigma(n+1) divides sigma(n), where sigma(n) is sum of positive divisors of n.

use 5.020;
use strict;
use warnings;

#~ a(4) <= 25908120 for n = 25908120 -> 2^3 * 3^3 * 5^1 * 7^1 * 23^1 * 149^1
#~ a(4) <= 171430560 for n = 171430560 -> 2^5 * 3^3 * 5^1 * 7^1 * 5669^1
#~ a(4) <= 825473880 for n = 825473880 -> 2^3 * 3^2 * 5^1 * 7^1 * 11^1 * 97^1 * 307^1
#~ a(4) <= 70335767880 for n = 287400960000 -> 2^13 * 3^6 * 5^4 * 7^1 * 11^1
#~ a(4) <= 1435055809320 for n = 5901299712000 -> 2^15 * 3^5 * 5^3 * 7^2 * 11^2

# 4 -> 25908120
# 4 -> 171430560
# 4 -> 1435055809320

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(uniq);

my %valuation = (
    "103" => 1,
    "1063" => 1,
    "11" => 2,
    "1103" => 1,
    "11299" => 1,
    "11351" => 1,
    "13" => 1,
    "131" => 1,
    "1429" => 1,
    "149" => 1,
    "1607" => 1,
    "167" => 1,
    "17" => 1,
    "19" => 1,
    "1997" => 1,
    "2" => 7,
    "2239" => 1,
    "23" => 1,
    "2927" => 1,
    "3" => 5,
    "307" => 1,
    "31" => 1,
    "3581" => 1,
    "37" => 1,
    "41" => 1,
    "4127" => 1,
    "43" => 1,
    "467" => 1,
    "47" => 1,
    "5" => 5,
    "503" => 1,
    "5669" => 1,
    "569" => 1,
    "59" => 1,
    "61" => 1,
    "659" => 1,
    "67" => 1,
    "7" => 3,
    "719" => 1,
    "79" => 1,
    "811" => 1,
    "89" => 1,
    "97" => 1,
    "971" => 1
);

%valuation = (
    "11" => 2,
    "113" => 1,
    "13" => 2,
    "17" => 1,
    "19" => 2,
    "199" => 1,
    "2" => 15,
    "23" => 1,
    "29" => 1,
    "3" => 7,
    "31" => 2,
    "37" => 1,
    "43" => 1,
    "5" => 4,
    "61" => 1,
    "67" => 1,
    "7" => 3
);

sub check_valuation ($n, $p) {

    if (exists $valuation{$p}) {
        #~ return valuation($n, $p) < (($valuation{$p} > 1) ? ($valuation{$p}+1) : $valuation{$p});
        return valuation($n, $p) < $valuation{$p};
    }

    #~ if ($p == 2) {
        #~ return valuation($n, $p) < 15;
    #~ }

    #~ if ($p == 3) {
        #~ return valuation($n, $p) < 8;
    #~ }

    #~ if ($p == 5) {
        #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 2;
    #~ }

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
    return @{$r{$N}};
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

sub isok ($n) {

    #divisor_sum($n, 0) > 500 and return (0, -1);

      #~ if (modint(divisor_sum($n), divisor_sum($n+1)) == 0) {
          #~ return ($n, divint(divisor_sum($n), divisor_sum($n+1)));
      #~ }

    foreach my $k(inverse_sigma($n)) {

      if (modint($n, divisor_sum($k+1)) == 0) {
          return ($k, divint($n, divisor_sum($k+1)));
      }

      if (modint(divisor_sum($k-1), $n) == 0) {
          return ($k-1, divint(divisor_sum($k-1), $n));
      }
    }

    return (0, -1);
}

my @smooth_primes;

foreach my $p (@{primes(50)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    #if ($f1[-1] <= 7 and $f2[-1] <= 7) {
    if ($f2[-1] <= 11) {
        push @smooth_primes, $p;
    }
}

push @smooth_primes, (2, 3, 5, 7, 23, 149, 11, 97, 307, 2, 7, 3, 5, 23, 149, 5669, 2, 2, 2, 3, 3, 3, 5, 7, 23, 29, 284591);
@smooth_primes = sort {$a <=> $b}uniq(@smooth_primes);
@smooth_primes = @{primes(13)};

#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 59, 61, 67, 79, 89, 97, 103, 131, 149, 167, 307, 467, 503, 569, 659, 719, 811, 971, 1063, 1103, 1429, 1607, 1997, 2239, 2927, 3581, 4127, 5669, 11299, 11351, 284591);
#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 43, 61, 67, 113, 199);
#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29);
@smooth_primes = (2, 3, 5, 7, 11);

my $h = smooth_numbers(10**13, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (sort { $a <=> $b} @$h) {

    #next if ($n < 4*25908120);
    next if ($n < 4*53117846646);

    my ($k, $p) = isok($n);

    if ($p >= 4) {
        say "a($p) <= $k for n = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, $k;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
