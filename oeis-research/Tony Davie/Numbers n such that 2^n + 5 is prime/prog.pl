#!/usr/bin/perl

# Primality test for primes of the form 2^n + 5.

# First few exponents of such primes, are:
#   1, 3, 5, 11, 47, 53, 141, 143, 191, 273, 341, 16541, 34001, 34763, 42167, ...

# The primality test was derived from the Lucas-Lehmer primality test for Mersenne primes.

# See also:
#   https://oeis.org/A059242

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use POSIX qw(ULONG_MAX);
use experimental qw(signatures);

sub primality_pretest ($n) {

    # Must be positive
    (Math::GMPz::Rmpz_sgn($n) > 0) || return;

    # Check for divisibilty by 2
    if (Math::GMPz::Rmpz_even_p($n)) {
        return (Math::GMPz::Rmpz_cmp_ui($n, 2) == 0);
    }

    # Return early if n is too small
    Math::GMPz::Rmpz_cmp_ui($n, 101) > 0 or return 1;

    # Check for very small factors
    if (ULONG_MAX >= 18446744073709551615) {
        Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $n, 16294579238595022365) == 1 or return 0;
        Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $n, 7145393598349078859) == 1  or return 0;
    }
    else {
        Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $n, 3234846615) == 1 or return 0;
    }

    # Size of n in base-2
    my $size = Math::GMPz::Rmpz_sizeinbase($n, 2);

    # When n is large enough, try to find a small factor (up to 10^8)
    if ($size > 5_000) {

        state %cache;
        state $g = Math::GMPz::Rmpz_init_nobless();

        my @checks = (1e4);

        push(@checks, 1e6) if ($size > 15_000);
        push(@checks, 1e7) if ($size > 20_000);
        push(@checks, 1e8) if ($size > 30_000);

        my $prev;

        foreach my $k (@checks) {

            my $primorial = (
                $cache{$k} //= do {
                    my $z = Math::GMPz::Rmpz_init_nobless();
                    Math::GMPz::Rmpz_primorial_ui($z, $k);
                    Math::GMPz::Rmpz_divexact($z, $z, $prev) if defined($prev);
                    $z;
                }
            );

            Math::GMPz::Rmpz_gcd($g, $primorial, $n);

            if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
                return 0;
            }

            $prev = $primorial;
        }
    }

    return 1;
}

sub isok($n) {

    my $M = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_setbit($M, $n);
    Math::GMPz::Rmpz_add_ui($M, $M, 5);

    if (Math::GMPz::Rmpz_divisible_ui_p($M, 3)) {
        return 0;
    }

    primality_pretest($M) || return 0;

    # Ideally, this code should be executed in parallel
    if ($n > 1e4) {

        my $res = eval {
            local $SIG{ALRM} = sub { die "alarm\n" };
            alarm 30;
            chomp(my $test = `$^X -MMath::GMPz -MMath::Prime::Util::GMP=is_prob_prime -E 'say is_prob_prime((Math::GMPz->new(1) << $n) + 5)'`);
            alarm 0;
            return $test;
        };

        if ($@ eq "alarm\n") {
            `pkill -P $$`;
        }

        return $res if defined($res);
    }

    my $S = Math::GMPz::Rmpz_init_set_ui(4);

    foreach my $i (1 .. $n) {
        Math::GMPz::Rmpz_powm_ui($S, $S, 2, $M);
        Math::GMPz::Rmpz_sub_ui($S, $S, 2);
    }

    Math::GMPz::Rmpz_cmp_ui($S, 194) == 0;
}

foreach my $n (1 .. 400) {
    say $n if isok($n);
}

# Find more primes of the form: 2^n + 5
# A059242(18) > 5*10^5. - Robert Price, Aug 23 2015
if (0) {
    foreach my $n (5 * 10**5 .. 1e6) {
        say "Testing: $n";
        if (isok($n)) {
            die "Found: $n";
        }
    }
}
