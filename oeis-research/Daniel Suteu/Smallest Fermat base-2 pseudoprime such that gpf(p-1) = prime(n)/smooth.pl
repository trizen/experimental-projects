#!/usr/bin/perl

# a(n) is the smallest Fermat pseudoprime to base 2 such that gpf(p-1) = prime(n) for all prime factors p of a(n).

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(uniq);

sub check_valuation ($n, $p) {
    scalar(factor($n)) <= 3 and ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = ((1));
    foreach my $p (@$primes) {

        #say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub isok ($n) {
    is_pseudoprime($n, 2) and !is_prime($n);
}

my @primes = @{primes(198311)};

foreach my $index (1 .. 100) {

    my @smooth_primes;

    my $P = nth_prime($index);

    foreach my $p (@primes) {

        if ($p == 2) {
            next;
        }

        my @f = factor($p - 1);

        #my @d = divisors($p-1);
        #my $count = grep {powmod(2, $_, $p) == 1 } @d;

        #$count >= 4 || next;

        if ($f[-1] == $P) {
            push @smooth_primes, $p;
        }
    }

    my @factors = (3, 7, 11, 13, 19, 31, 41, 61, 73, 101, 127, 137, 211, 251, 271, 331, 577, 757, 1321, 1361, 4733);

    #push @smooth_primes, @factors;
    #push @smooth_primes, grep { $_ < 73 } @factors;

    @smooth_primes = uniq(@smooth_primes);
    @smooth_primes = sort { $a <=> $b } @smooth_primes;

    #@smooth_primes = qw(3 7 11 13 19 31 41 61 73 101 127 137 211 251 271 331 577 757 1321 1361 4733 4801 4861 4951);

    #say "Smooth primes = (@smooth_primes)";

    my $max = 1e10;
    my $h   = smooth_numbers($max, \@smooth_primes);

    #say "\nFound: ", scalar(@$h), " terms";
    my @list;
    my $min = $max;

    foreach my $n (@$h) {

        #if ($n > 1e14 and isok($n)) {
        if ($n < $min and isok($n)) {
            $min = $n;
        }
    }

    if (isok($min)) {
        say "a($index) = $min";
    }
    else {
        say "a($index) = ?";
        last;
    }
}
