#!/usr/bin/perl

# Numbers m such that Sum_{k=1..m} omega(k) = sigma(m)
# https://oeis.org/A346423

# Known terms:
#   11, 230, 52830, 160908

# See also:
#   https://oeis.org/A013939

use 5.020;
use strict;
use warnings;

use List::Util qw(uniq);
use experimental qw(signatures);
use ntheory qw(:all);

sub prime_omega_partial_sum ($n) {     # O(sqrt(n)) complexity

    my $total = 0;

    my $s = sqrtint($n);
    my $u = divint($n, $s + 1);

    for my $k (1 .. $s) {
        $total += mulint($k, prime_count(divint($n, $k+1)+1, divint($n,$k)));
    }

    forprimes {
        $total += divint($n,$_);
    } $u;

    return $total;
}

sub prime_omega_partial_sum_2 ($n) {     # O(sqrt(n)) complexity

    my $total = 0;
    my $s = sqrtint($n);

    for my $k (1 .. $s) {
        $total += prime_count(divint($n,$k));
        $total += divint($n,$k) if is_prime($k);
    }

    $total -= mulint($s, prime_count($s));

    return $total;
}

sub isok($n) {
    my $sigma = divisor_sum($n);

    $sigma >= $n*log(log($n)) or return;
    $sigma < $n*(log(log($n)) + 0.261497) or return;

    say "Computing partial sum...";
    prime_omega_partial_sum($n) == $sigma;
}

(vecall { isok($_) } (11, 230, 52830, 160908 ))  || die "error";

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 2;
    }

    if ($p == 3) {
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

my $h = smooth_numbers(10**10, primes(100));

say "Found: ", scalar(@$h), " numbers...";

foreach my $n(@$h) {
    next if ($n < 300000000);
    say "Testing: $n";
    die "Found: $n" if isok($n);
}
