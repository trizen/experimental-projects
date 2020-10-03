#!/usr/bin/perl

# Find the smallest prime factor of 2^(2^prime(n) - 1) - 1.
# https://oeis.org/A309130

# Known terms:
#   7, 127, 2147483647, 170141183460469231731687303715884105727, 47, 338193759479, 231733529, 62914441, 2351, 1399, 295257526626031, 18287, 106937, 863, 4703, 138863, 22590223644617

use 5.014;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use List::Util qw(uniq);
use experimental qw(signatures);

sub validate_factors ($n, @factors) {

    if (ref($n) ne 'Math::GMPz') {
        $n = Math::GMPz->new("$n");
    }

    @factors || return;
    @factors = map  { (ref($_) eq 'Math::GMPz') ? $_ : Math::GMPz::Rmpz_init_set_str("$_", 10) } @factors;
    @factors = grep { ($_ > 1) and ($_ < $n) } @factors;
    @factors || return;

    uniq(sort { $a <=> $b } grep { $n % $_ == 0 } @factors);
}

sub parse_yafu_output ($n, $output) {
    my @factors;
    while ($output =~ /^[CP]\d+\s*=\s*(\d+)/mg) {
        push @factors, Math::GMPz->new($1);
    }
    return validate_factors($n, @factors);
}

sub parse_mpu_output ($n, $output) {
    my @factors;
    while ($output =~ /^(\d+)/mg) {
        push @factors, Math::GMPz->new($1);
    }
    return validate_factors($n, @factors);
}

sub trial_division ($n, $k = 1e5) {    # trial division, using cached primorials + GCD

    state %cache;

    # Clear the cache when there are too many values cached
    if (scalar(keys(%cache)) > 100) {
        Math::GMPz::Rmpz_clear($_) for values(%cache);
        undef %cache;
    }

    my $B = (
        $cache{$k} //= do {
            my $t = Math::GMPz::Rmpz_init_nobless();
            Math::GMPz::Rmpz_primorial_ui($t, $k);
            $t;
        }
    );

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_gcd($g, $n, $B);

    if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_set($t, $n);

        my %factor;
        foreach my $f (Math::Prime::Util::GMP::factor(Math::GMPz::Rmpz_get_str($g, 10))) {
            Math::GMPz::Rmpz_set_ui($g, $f);
            $factor{$f} = Math::GMPz::Rmpz_remove($t, $t, $g);
        }

        my @factors = keys %factor;

        if (Math::GMPz::Rmpz_cmp_ui($t, 1) > 0) {
            push @factors, Math::GMPz::Rmpz_init_set($t);
        }

        return validate_factors($n, @factors);
    }

    return;
}

sub ecm_one_factor ($n) {

    my @f = trial_division($n, 1e8);

    foreach my $f (@f) {
        while ($n % $f == 0) {
            $n /= $f;
        }
    }

    my @factors = @f;

    my $timeout     = 10;
    my $prefer_yafu = 0;    # true to prefer YAFU's ECM implementation

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm $timeout;

        if ($prefer_yafu) {
            my $curves = $timeout >> 1;
            my $output = qx(yafu 'ecm($n, $curves)' -B1ecm 500000);
            push @factors, parse_yafu_output($n, $output);
        }

        my $output = `$^X -MMath::Prime::Util::GMP=ecm_factor -E 'say for ecm_factor("$n")'`;
        ## my $output = `$^X -MMath::Prime::Util=factor -E 'say for factor("$n")'`;
        push @factors, parse_mpu_output($n, $output);

        alarm 0;
    };

    if ($@ eq "alarm\n") {
        `pkill -P $$`;
    }

    return grep { length("$_") < 200 } uniq(@factors);
}

my $two = Math::GMPz->new(2);

my $n = 18;                     # search for a(18)
my $p = nth_prime($n);
my $e = $two**$p - 1;
my $r = znorder(2, $e);

foreach my $i (1 .. 1e7) {

    my $k = ($i * $r + 1);
    is_prime($k) || next;

    if ($n == 18 and $k <= 50387) {      # already searched this range
        next;
    }

    my @F = ecm_one_factor($two**$k - 1);

    say "[$k] Factors: @F";

    foreach my $f (@F) {
        my $t = powmod(2, $e, $f);

        if ($t == 1) {
            die "\n[$k] Found: $f is a factor of 2^(2^prime($n)-1)-1\n\n";
        }
    }
}
