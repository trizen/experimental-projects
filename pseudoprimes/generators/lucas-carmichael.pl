#!/usr/bin/perl

# Generate Lucas-Carmichael numbers from a given Lucas-Carmichael number.

use 5.020;
use warnings;
use ntheory qw(:all);

use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use experimental qw(signatures);
use Math::Prime::Util::GMP qw(mulint divint gcd);

sub check_valuation ($n, $p) {
    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my $k = 0;
    my $total = scalar(@$primes);

    my @h = (1);
    foreach my $p (@$primes) {

        say "[", ++$k, " out of $total] Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

#my $m = "120781417471";
#my $m = "46852073639840281125599";
my $m = "199195047359";

my @factors = factor($m);
my %factor_table;
@factor_table{@factors} = ();

sub is_lucas_carmichael ($n) {
    my $t = $n+1;
    return if not vecall { Math::GMPz::Rmpz_divisible_ui_p($t, $_+1)  } @factors;
    vecall { Math::GMPz::Rmpz_divisible_ui_p($t, $_+1) } factor(divint($n, $m));
}

my $B_smooth = 11;
my $t = Math::GMPz::Rmpz_init();
my @primes = grep { is_smooth($_+1, $B_smooth) }grep{not exists $factor_table{$_}} @{primes($factors[-1])};

my $max_primes = 100;

if (@primes > $max_primes) {
    $#primes = $max_primes;
}

do {
    my $p = next_prime($factors[-1]);
    while (@primes < $max_primes) {

        if (is_smooth($p+1, $B_smooth)) {
            push @primes, $p;
        }

        $p = next_prime($p);
    }
};

my $terms = smooth_numbers(1e10, \@primes);

foreach my $n (@$terms) {
    if (gcd($m, $n) == 1) {
        Math::GMPz::Rmpz_set_str($t, mulint($m, $n), 10);

        if (is_lucas_carmichael($t)) {
            say $t;
        }
    }
}
