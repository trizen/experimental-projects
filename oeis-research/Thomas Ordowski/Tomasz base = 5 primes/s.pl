#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Generalized algorithm for generating numbers that are smooth over a set A of primes, bellow a given limit.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    ($n*$p)%2 == 0 or return 0;

    #~ if ($p > 13) {
        #~ return ( ($n % $p) != 0);
    #~ }

    1;
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

#
# Example for finding numbers `m` such that:
#     sigma(m) * phi(m) = n^k
# for some `n` and `k`, with `n > 1` and `k > 1`.
#
# See also: https://oeis.org/A306724
#

my $t = 282669887501;
my $base = 5;

sub isok ($n) {
    #is_power(Math::GMPz->new(divisor_sum($n)) * euler_phi($n));
    my $k = $n+1;
    if ($k < $t) {
        return 0;
    }

    powmod($base, $k - 1, Math::GMPz->new($t) * $k) == 1;
}

my $h = smooth_numbers(2402694043751, primes(63));

say "\nFound: ", scalar(@$h), " terms";


my @list;

foreach my $n (@$h) {

    my $p = isok($n);

    #if ($p >= 8) {
    if ($p) {
        say "Found: ", $n+1, " -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n)), ' -> ', is_prime($n+1) ? 'prime' : 'NOT PRIME';
        #push @{$table{$p}}, $n;
        #say "Found: ", $n+1;
        push @list, $n+1;
    }
}

say vecmin(@list);

__END__
a(29) = 282669887501
