#!/usr/bin/perl

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    #~ if ($p == 2) {
        #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 3) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 3;
    #~ }

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

sub arithmetic_derivative {
    my ($n) = @_;

    my @factors = factor($n);

    my $sum = 0;
    foreach my $p (@factors) {
        $sum += divint($n, $p);
    }

    return $sum;
}


sub dynamicPreimage ($N, $L) {

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            foreach my $d (divisors(divint($N, $x))) {
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            }
        }
        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    sort { $a <=> $b } @{$r{$N}};
}

sub cook_sigma ($N, $k) {
    my %L;

    foreach my $d (divisors($N)) {

        next if ($d == 1);

        foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

            my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
            my $t = valuation($q, $p);

            next if ($t <= $k or ($t % $k) or $q != powint($p, $t));

            push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
        }
    }

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    dynamicPreimage($N, cook_sigma($N, $k));
}

sub isok ($n) {

   my $d = arithmetic_derivative($n);

   foreach my $k (inverse_sigma($n)) {
        if ($d == $k) {
            return $k;
        }
   }
   return undef;
}

my @smooth_primes;

foreach my $p (@{primes(1000)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    if (is_smooth($p+1, 3)) {
        push @smooth_primes, $p;
    }
}

my $h = smooth_numbers(1e15, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms\n";

my %table;

foreach my $n (@$h) {

    if (defined(my $k = isok($n))) {
        say "Found: $k -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($k));
    }
}
