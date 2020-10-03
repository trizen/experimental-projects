#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Terms of A194269 that are not squares of primes.
# https://oeis.org/A307137

# Where A194269 is:
#   Numbers j such that Sum_{i=1..k} d(i)^i = j+1 for some k where d(i) is the sorted list of divisors of j.

#~ Found: 72 -> 63602175290616 -> 2^3 * 3^2 * 231859^1 * 3809917^1
#~ Found: 816 -> 122918945808 -> 2^4 * 3^1 * 17^2 * 8860939^1
#~ Found: 483 -> 107924794257 -> 3^1 * 7^1 * 23^1 * 223446779^1

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::AnyNum qw(sum ipow);
use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(shuffle);

sub check_valuation ($n, $p) {

    #1;

    divisors($n*$p) <= 20;

    #valuation($n, $p) < 3;

    #~ if ($p == 2) {
        #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 3) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ ($n % $p) != 0;

    #valuation($n, $p) < 1;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
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

#
# Example for finding numbers `m` such that:
#     sigma(m) * phi(m) = n^k
# for some `n` and `k`, with `n > 1` and `k > 1`.
#
# See also: https://oeis.org/A306724
#

sub isok ($n) {

    if (is_square($n) and is_prime(sqrtint($n))) {
        return;
    }

    return if length("$n") > 30;
    #return if (scalar(divisors($n)) > 100);

    my @d = divisors($n);

    my $s = 0;
    foreach my $k(0..$#d) {

        $s += $d[$k]**($k+1);

        if ($s == $n+1) {
            return 1;
        }

        if ($s > $n+1) {
            return;
        }
    }

    return;
}

my $h = smooth_numbers(10**14, [ @{primes(100)}]);

say "\nFound: ", scalar(@$h), " terms";

my %table;

sub construct($d) {
    ${sum(map { ipow($d->[$_], $_+1) } 0..$#$d)};
}

# 107924794257

my %seen;
foreach my $n (@$h) {

    #foreach my $d(divisors($n)) {

     #   $d > 3079148398 or next;

my @d = divisors($n);

my $end = $#d;
$end = 12 if ($end > 12);

    foreach my $i(2..$end) {

    my $t = construct([@d[0..$i]]);

    #say $t;

    #next if $t > 1e14;
    #my $p = isok($t-1);

    #if ($p >= 8) {
    #if ($p) {

    #if (abs($t - $n) <= 1) {

    $t > 3079148398 or next;

    if (isok($t-1)) {

        if (!$seen{$t}++) {
            say "Found: $n -> ", $t-1, ' -> ', join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($t-1));
        }
      #  push @{$table{$p}}, $n;
    }
}
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
