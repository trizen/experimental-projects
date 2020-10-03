#!/usr/bin/perl

# Least number k > 1 such that A062354(k) is an n-th power, where A062354 is the product of sigma (A000203) and phi (A000010).
# https://oeis.org/A306724

# Found values:
#   9043253832732
#   9224036735340

use 5.014;
use Math::GMPz;
use ntheory qw(:all is_power);

my @smooth_primes;

forprimes {
    if ($_ == 2) {
        #say $_;
        push @smooth_primes, $_;
    }
    else {
        if ((factor($_-1))[-1] <= 7 and (factor($_+1))[-1] <= 7) {
            #say $_;
            push @smooth_primes, $_;
        }
    }
} 4801;

push @smooth_primes, 8749;

say "@smooth_primes";

use 5.020;
use warnings;
use Math::GMPz;
use experimental qw(signatures);
use ntheory qw(divisors vecsum primes divisor_sum valuation);

sub check_valuation($n, $p) {

    if ($p == 2) {
        return (valuation($n, $p) < 20);
    }

    #~ if ($p == 3) {
        #~ return ($n % ($p*$p*$p*$p*$p*$p) != 0);
    #~ }

    #if ($p == 7) {
    #    return (valuation($n, $p) < 4);
    #}
    if ($p <= 7) {
        return valuation($n, $p) < 3;
    }

    #if ($p <= 11) {
    #    return (valuation($n, $p) < 3);
    #}

    ($n % $p) != 0;

    #($n % ($p*$p)) != 0;
}

sub hamming_numbers ($limit, $primes) {

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

sub isok {
    my ($n) = @_;
    my $t = Math::GMPz->new(divisor_sum($n)) * Math::GMPz->new(euler_phi($n));
    is_power($t);
}

my $h = hamming_numbers(10**13, \@smooth_primes);

say "Found: ", scalar(@$h), " terms";

my @hello;

my %table;

foreach my $n(@$h) {

    my $p = isok($n);

    if ($p >= 6) {
        say "a($p) = $n -> ", join(' * ', map{"$_->[0]^$_->[1]"}factor_exp($n));
        #@push @hello, $n;
        push @{$table{$p}}, $n;
    }

    #foreach my $k(0..30) {
    #    my $t = ($n * 2**$k);
     #   if (isok($t)) {
      #      say $t;
     #   }
    #}
}

# 498892319051
#say vecmin(@hello);#
# a(9) <= 14467877252479.

say '';

foreach my $k(sort {$a <=>$b}keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}


__END__

a(6) <= 592922491
a(7) <= 17194752239
a(8) <= 498892319051


a(8) <= 498892319051
a(9) <= 14467877252479
a(10) <= 421652049419104

a(8) <= 498892319051
a(9) <= 14467877252479
a(10) <= 421652049419104
a(11) <= 12227909433154016

a(8) <= 498892319051
a(9) <= 14467877252479
a(10) <= 421652049419104
a(11) <= 12227909433154016

sub foo {
my ($n) = @_;

my $t = Math::GMPz::Rmpz_init();

foreach my $k(2..1e12) {

    Math::GMPz::Rmpz_set_ui($t, divisor_sum($k));
    Math::GMPz::Rmpz_mul_ui($t, $t, euler_phi($k));

    if (Math::GMPz::Rmpz_perfect_power_p($t) and is_power($t, $n)) {
        return $k;
    }

    #if (divisor_sum($k) *
}

}

foreach my $n(1..10) {
    say "a($n) = ", foo($n);
}
