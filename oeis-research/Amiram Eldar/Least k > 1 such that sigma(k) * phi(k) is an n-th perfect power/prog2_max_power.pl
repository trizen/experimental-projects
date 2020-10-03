#!/usr/bin/perl

# Least number k > 1 such that A062354(k) is an n-th power, where A062354 is the product of sigma (A000203) and phi (A000010).
# https://oeis.org/A306724

# Found values:
#   9043253832732
#   9224036735340

use 5.014;
use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use ntheory qw(:all is_power);
use Memoize qw(memoize);

memoize('max_power');

my @smooth_primes;

sub is_smooth_for_e {
    my ($p, $e) = @_;

        is_smooth(Math::GMPz->new($p)**($e-1), 7)
    and is_smooth(Math::GMPz->new($p)**($e+1)-1, 7)
}

sub p_is_smooth {
    my ($p) = @_;
    vecany {
            is_smooth_for_e($p, $_);
    } 1..20;
}

sub max_power {
    my ($p) = @_;

    for(my $e = 20; $e >= 1; --$e) {
        if (is_smooth_for_e($p, $e)) {
            return $e;
        }
    }
}

forprimes {
    if ($_ == 2) {
        push @smooth_primes, $_;
    }
    else {
        if (p_is_smooth($_)) {
            push @smooth_primes, $_;
        }
    }
} 4801;

say "@smooth_primes";

foreach my $p(@smooth_primes) {
    say "a($p) = ", max_power($p);
}

use 5.020;
use warnings;
use Math::GMPz;
use experimental qw(signatures);
use ntheory qw(divisors vecsum primes divisor_sum valuation);

sub check_valuation($n, $p) {

    return valuation($n, $p) < max_power($p);

    #~ if ($p == 2) {
        #~ return (valuation($n, $p) < 10);
    #~ }

    #~ if ($p == 3) {
        #~ return ($n % ($p*$p*$p*$p*$p*$p) != 0);
    #~ }

    #if ($p == 7) {
    #    return (valuation($n, $p) < 4);
    #}
    #~ if ($p <= 7) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #if ($p <= 11) {
    #    return (valuation($n, $p) < 3);
    #}

    #~ ($n % $p) != 0;

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

my $h = hamming_numbers(~0, \@smooth_primes);

say "Found: ", scalar(@$h), " terms";

my %table;

foreach my $n(@$h) {

    my $p = isok($n);

    if ($p >= 8) {
        say "a($p) = $n -> ", join(' * ', map{"$_->[0]^$_->[1]"}factor_exp($n));
        push @{$table{$p}}, $n;
    }
}

# 498892319051
#say vecmin(@hello);#
# a(9) <= 14467877252479.

say '';

foreach my $k(sort {$a <=>$b}keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}


__END__

a(8) <= 498892319051
a(9) <= 14467877252479
a(10) <= 421652049419104
a(11) <= 12227909433154016
a(12) <= 377536703748630244
a(13) <= 926952707565364023467

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
