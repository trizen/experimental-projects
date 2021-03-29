#!/usr/bin/perl

# Least k such that phi(k) is an n-th power when k is the product of n distinct primes.
# https://oeis.org/A281069

# Upper-bounds:
#   a(11) <= 5703406198237930
#   a(12) <= 178435136773443810
#   a(13) <= 4961806417984478790
#   a(14) <= 1686255045377006404458210
#   a(15) <= 93298412716133272158996030
#   a(16) <= 1390082695873048405486577989005
#   a(17) <= 107958287712130168652012007653865
#   a(18) <= 12494948876051158258450723218329034
#   a(19) <= 1110590345888910601135536079323125130
#   a(20) <= 81073095249890473882894133790588134490

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
    is_power(euler_phi($n));
}

my @smooth_primes;

foreach my $p (@{primes(2e8)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (is_smooth($p-1, 3)) {
        push @smooth_primes, $p;
    }
}

my $multiple = Math::GMPz->new(1);

@smooth_primes = grep { gcd($multiple, $_) == 1 } @smooth_primes;

my %table;

my $v = 17;
my $limit = Math::GMPz->new("936857601305665809803096700000000");

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
