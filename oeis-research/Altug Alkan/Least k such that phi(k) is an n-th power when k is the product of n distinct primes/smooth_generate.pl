#!/usr/bin/perl

# Least k such that phi(k) is an n-th power when k is the product of n distinct primes.
# https://oeis.org/A281069

# Upper-bounds:
#   a(11) <= 5703406198237930
#   a(12) <= 178435136773443810
#   a(13) <= 4961806417984478790
#   a(14) <= 1686255045377006404458210
#   a(15) <= 93685760130566580980309670

# Other upper-bounds:
#   a(11) < 7829180118279030 < 7862926281269430
#   a(12) < 202848252169827810 < 771632451121296274230
#   a(13) < 4976768607520456110
#   a(14) < 1920340956699420394773270
#   a(15) < 35141760969505011678479285910

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
    is_power(euler_phi($n));
}

my @smooth_primes;

foreach my $p (@{primes(1e8)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (is_smooth($p-1, 3)) {
        push @smooth_primes, $p;
    }
}

my $multiple = 1254855;
#my $multiple = 26535163830;
#my $multiple = 7474975358110;
#my $multiple = 1637019603426090;

@smooth_primes = grep { gcd($multiple, $_) == 1 } @smooth_primes;

my $h = smooth_numbers(~0, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $k (@$h) {

    my $n = mulint($k, $multiple);
    my $p = isok($n);

    if ($p >= 11 and prime_omega($n) == $p) {
        say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, $n;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
