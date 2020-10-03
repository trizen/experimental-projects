#!/usr/bin/perl

# Numbers that set a new record for number of Fibonacci divisors.
# https://oeis.org/A129655

#~ a(15) <= 523410559111440
#~ a(16) <= 24076885719126240
#~ a(17) <= 1131613628798933280
#~ a(18) <= 100713612963105061920

# New upper-bounds:
#  a(19) <= 32329069761156724876320
#  a(20) <= 8946490953125585755415520
#  a(21) <= 2871823595953313027488381920

# In general:
#   a(n) <= A035105(n+1).

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

# Exponents:
#   [[2, 3]], [[2, 4], [3, 2]], [[2, 5], [3, 2]], [[5, 2]], [[2, 4], [3, 3]], [[2, 6], [3, 2]], [[7, 2]], [[2, 5], [3, 3]], [[13, 2]], [[2, 7], [3, 2]]]

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 7;
    }

    if ($p == 3) {
        return valuation($n, $p) < 3;
    }

    #~ if ($p == 5) {
        #~ return valuation($n, $p) < 2;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 2;
    #~ }

    #~ if ($p == 13) {
        #~ return valuation($n, $p) < 2;
    #~ }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                if (!ref($n) and $n * $p > ~0) {
                    my $t = Math::GMPz::Rmpz_init_set_ui($n);
                    Math::GMPz::Rmpz_mul_ui($t, $t, $p);
                    push @h, $t;
                }
                else {
                    push @h, $n * $p;
                }
            }
        }
    }

    return \@h;
}

my %fib;
my @fib;
foreach my $n (2 .. 150) {
    my $k = lucasu(1, -1, $n);
    $fib{$k} = 1;
    push @fib, $k;
}

sub isok ($n) {
    my $count = 0;

    foreach my $f(@fib) {

        last if ($f > $n);

        if ($n % $f == 0) {
            ++$count;
        }
    }

    return $count;
    #scalar grep { exists($fib{$_}) } divisors($n);
}

my @smooth_primes;

foreach my $p (@{primes(4801)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    if ($f1[-1] <= 7 and $f2[-1] <= 7) {
        push @smooth_primes, $p;
    }
}

#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 61, 89);
#@smooth_primes = (2, 3, 5, 13, 7, 17, 11, 89, 233, 29, 61, 47, 1597, 19, 37, 113, 41);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 61, 89);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 47, 53, 61, 89, 107, 109, 113);

@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 61, 89, 107, 211, 421);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 29, 37, 41, 47, 61, 89, 113, 233, 1597);

#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 61, 89, 107, 211, 421, 73, 149, 2221);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 47, 53, 61, 89, 107);

# Candidate primes:
#   2, 3, 5, 13, 7, 17, 11, 89, 29, 61, 47, 19, 37, 41, 23, 53, 31, 73, 43, 97, 59, 67, 71, 79, 83

# Factors of smooth Fibonacci numbers:
#   2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 47, 53, 61, 89, 107, 109, 113

#@smooth_primes = (2, 3, 5, 13, 7, 17, 11, 89, 29, 61, 47, 19, 37, 41, 23, 53, 31, 73);
#@smooth_primes = (2, 3, 5, 13, 7, 17, 11, 89, 29, 61, 47, 19, 37, 41, 23, 53, 31);
#@smooth_primes = grep { $_ <= 61 } @smooth_primes;

#@smooth_primes = (2, 3, 5, 13, 7, 17, 11, 89, 29, 61, 47, 19, 37, 41, 23, 53, 31, 73, 43, 97, 59, 67, 71, 79, 83);

my $h = smooth_numbers(2871823595953313027488381920, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;
my $a18 = Math::GMPz->new("100713612963105061920");
my $a19 = Math::GMPz->new("32329069761156724876320");
my $a20 = Math::GMPz->new("8946490953125585755415520");
my $a21 = Math::GMPz->new("2871823595953313027488381920");

foreach my $n (@$h) {

    next if $n < 12732356276640;

    my $p = isok($n);

    if ($p >= 15) {

        if (!exists($table{$p}) or $n < $table{$p}) {
            say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
            $table{$p} = $n;
        }

        if ($p == 15 and $n < 523410559111440) {
            die "NEW: a(15) <= $n";
        }

        if ($p == 16 and $n < 24076885719126240) {
            die "New: a(16) <= $n";
        }

        if ($p == 17 and $n < 1131613628798933280) {
            die "New: a(17) <= $n";
        }

        if ($p == 18 and $n < $a18) {
            die "New: a(18) <= $n";
        }

        if ($p == 19 and $n < $a19) {
            die "New: a(19) <= $n";
        }

        if ($p == 20 and $n < $a20) {
            die "New: a(20) <= $n";
        }

        if ($p == 21 and $n < $a21) {
            die "New: a(21) <= $n";
        }

        if ($p > 21) {
            die "New upper-bound: a($p) <= $n";
        }
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", $table{$k};
}
