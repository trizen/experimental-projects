#!/usr/bin/perl

# a(n) is the least integer such that sigma(sigma(k)) >= n*k where sigma is A000203, the sum of divisors.
# https://oeis.org/A327630

# New terms:
#   a(23) = 109549440
#   a(24) = 438197760

# Upper-bounds for other terms:
#   a(25) <= 766846080
#   a(26) <= 3834230400
#   a(27) <= 9081072000
#   a(28) <= 32974381440
#   a(29) <= 147516969600
#   a(30) <= 880887047040
#   a(31) <= 2802822422400
#   a(32) <= 14814918518400
#   a(33) <= 64464915715200
#   a(34) <= 709114072867200
#   a(35) <= 9881550651772800
#   a(36) <= 76648784785372800
#   a(37) <= 2376112328346556800

# See also:
#   https://oeis.org/A098221

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 10;
    }

    if ($p == 3) {
        return valuation($n, $p) < 4;
    }

    if ($p == 5) {
        return valuation($n, $p) < 4;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    if ($p == 11) {
        return valuation($n, $p) < 3;
    }

    if ($p == 13) {
        return valuation($n, $p) < 2;
    }

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

my $h = smooth_numbers(10**17, primes(57));

say "\nFound: ", scalar(@$h), " terms";

@$h = sort { $a <=> $b } @$h;

my $n = 20;

foreach my $k (@$h) {

    next if ($k < 360360);

    while (divisor_sum(divisor_sum($k, 1)) >= $k * $n) {
        say "a($n) <= $k";
        ++$n;
    }
}
