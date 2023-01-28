#!/usr/bin/perl

# a(n) is the smallest k such that psi(k) and phi(k) have same distinct prime factors when k is the product of n distinct primes (psi(k) = A001615(k) and phi(k) = A000010(k)), or 0 if no such k exists.
# https://oeis.org/A291138

# Known terms:
#   3, 14, 42, 210, 3570, 43890, 746130, 14804790, 281291010, 8720021310

use 5.020;
use warnings;

use experimental qw(signatures);

use ntheory qw(:all);
use List::Util qw(uniq);

sub check_valuation ($n, $p) {
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

sub isok ($n) {
    my @factors = factor($n);

    my $psi = vecprod(uniq(factor(lcm(map{$_+1}@factors))));
    my $phi = vecprod(uniq(factor(lcm(map{$_-1}@factors))));

    if ($psi == $phi) {
        return scalar(@factors);
    }

    return 0;
}

my @smooth_primes;

foreach my $p (@{primes(4801)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    if ($f1[-1] <= 11 and $f2[-1] <= 11) {
        push @smooth_primes, $p;
    }
}

my $h = smooth_numbers(~0, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    my $p = isok($n);

    if ($p >= 11) {
        if (not exists $table{$p} or $n < $table{$p}) {
            $table{$p} = $n;
            say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        }
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", $table{$k};
}

__END__

# Upper-bounds:

a(11) <= 278196808890
a(12) <= 8624101075590
a(13) <= 353588144099190
a(14) <= 25104758231042490
a(15) <= 2234323482562781610
