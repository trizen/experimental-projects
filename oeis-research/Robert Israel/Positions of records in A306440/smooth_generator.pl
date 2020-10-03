#!/usr/bin/perl

# Positions of records in A306440.
# https://oeis.org/A307221

# Where A306440(n) is defined as:
#   Number of different ways of expressing 2*n as (p - 1)*(q - 1), where p < q are primes

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 5;
    }

    if ($p == 3) {
        return valuation($n, $p) < 3;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit) { #and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub decompositions {
    my ($n) = @_;

    #say "N -> $n";

    my $count = 0;
    #my $max = sqrtint($n);

    foreach my $d(divisors($n)) {
        #last if ($d >= $max);
        $d < $n/$d or last;
        if (is_prime($d+1) and is_prime(($n/$d)+1)) {
            #say "$d, ",  $n/$d, ' -> ', $d * ($n/$d);
            ++$count;
        }
    }

    $count;
}

my $h = smooth_numbers(275675400, primes(43));

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    $n > 151351200 or next;

    my $p = decompositions(2*$n);

  #  $p > 32 or next;

    if (not exists $table{$p}) {
        $table{$p} = $n;
    }
    else {
        if ($table{$p} > $n) {
            $table{$p} = $n;
        }
    }

    #if ($p >= 8) {
      #  say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
    # #   push @{$table{$p}}, $n;
  #  }
}

use Data::Dump qw(pp);
pp \%table;
