#!/usr/bin/perl

# Least k such that k is the product of n distinct primes and sigma(k) is an n-th power.
# https://oeis.org/A281140

# Upper-bounds:
#   a(14) <= 94467020965716904490370
#   a(15) <= 4580445736068712946096430
#   a(16) <= 141311309335130749342934551530
#   a(17) <= 10169116890203767594625736157410
#   a(18) <= 731312404512157569544472914562370
#   a(19) <= 52507616174768624974050943593733290
#   a(20) <= 4158174301964222147630825552166917040182116672890
#   a(21) <= 1196127298855626104920642437466924227877144680373830
#   a(22) <= 344100691665770856008544786824542288001446196936764290
#   a(23) <= 99012734365544803811101937791098899762797053402104550270

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {
    ($n % $p) != 0;
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

sub isok ($n) {
    is_power(divisor_sum($n));
}

my @smooth_primes;

foreach my $p (@{primes(292968749)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (is_smooth($p+1, 3)) {
        push @smooth_primes, $p;
    }
}

my $multiple = 69746779410;
#my $multiple = 1691847628148370;
#my $multiple = 628906709939970;
#my $multiple = 4952021338110;
#my $multiple = "1372725489803517881157331590";

@smooth_primes = grep { gcd($multiple, $_) == 1 } @smooth_primes;

my $h = smooth_numbers(1e25, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $k (@$h) {

    my $n = mulint($k, $multiple);
    my $p = isok($n);

    if ($p >= 14 and prime_omega($n) == $p) {
        say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, $n;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
