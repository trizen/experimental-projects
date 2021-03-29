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

# Other upper-bounds:
#   a(16) <= 141632811895080891394340984730

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub squarefree_almost_primes ($n, $k, $factors, $callback) {

    my $factors_end = $#{$factors};

    if ($k == 0) {
        $callback->(1);
        return;
    }

    if ($k == 1) {
        $callback->($_) for @$factors;
        return;
    }

    sub ($m, $k, $i = 0) {

        if ($k == 1) {

            my $L = divint($n, $m);

            foreach my $j ($i .. $factors_end) {
                my $q = $factors->[$j];
                last if ($q > $L);
                $callback->(mulint($m, $q));
            }

            return;
        }

        my $L = rootint(divint($n, $m), $k);

        foreach my $j ($i .. $factors_end - 1) {
            my $q = $factors->[$j];
            last if ($q > $L);
            __SUB__->(mulint($m, $q), $k - 1, $j + 1);
        }
    }->(1, $k);

    return;
}


sub isok ($n) {
    is_power(divisor_sum($n));
}

my @smooth_primes;

foreach my $p (@{primes(1e7)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (is_smooth($p+1, 3)) {
        push @smooth_primes, $p;
    }
}

#my $multiple = Math::GMPz->new("2817854441107634383138832178030");
#my $multiple = Math::GMPz->new("2134825555146675165390");
my $multiple = Math::GMPz->new("628906709939970");
#my $multiple = Math::GMPz->new("4952021338110");
#my $multiple = Math::GMPz->new("2273753186645632601910");
#my $multiple = Math::GMPz->new("69746779410");
#my $multiple = 1691847628148370;
#my $multiple = 628906709939970;
#my $multiple = 4952021338110;
#my $multiple = "1372725489803517881157331590";

@smooth_primes = grep { gcd($multiple, $_) == 1 } @smooth_primes;

my %table;

my $v = 16;
my $limit = Math::GMPz->new("14163281189508089139434098473000");

$limit /= $multiple;

squarefree_almost_primes($limit, $v - prime_omega($multiple), \@smooth_primes, sub ($k) {

    my $n = $multiple * $k;
    my $p = isok($n);

    if ($p == $v) {
        say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, $n;
    }
});

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
