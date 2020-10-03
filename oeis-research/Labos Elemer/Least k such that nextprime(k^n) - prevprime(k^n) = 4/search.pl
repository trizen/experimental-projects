#!/usr/bin/perl

# a(n) is the least positive integer such that nextprime(a(n)^n)-prevprime(a(n)^n)=4;.
# https://oeis.org/A090125

# PARI/GP program:
#   f(k,r) = ispseudoprime(k-r) && ispseudoprime(k-r+4);
#   a(n) = for(k=1, oo, my(t=k^n); if((f(t,1) || f(t,2) || f(t,3)) && nextprime(t+1)-precprime(t-1)==4, return(k)));

use 5.020;
use strict;

use ntheory qw(next_prime prev_prime);
use Math::Prime::Util::GMP qw(is_prob_prime);
use Math::AnyNum qw(ipow);
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
    if ($size > 1_000) {

        state %cache;
        state $g = Math::GMPz::Rmpz_init_nobless();

        my @checks = (1e4, 1e5);

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

sub both_primes {
    my ($x, $y) = @_;

    primality_pretest($x) || return;
    primality_pretest($y) || return;

    is_prob_prime("$x") and is_prob_prime("$y");
}

#__END__

my $mpz = Math::GMPz::Rmpz_init();

sub a {
    my ($n) = @_;

    #foreach my $k(2..1e9) {
    #    if (Math::GMPz->new(next_prime(ipow($k, $n))) - Math::GMPz->new(prev_prime(ipow($k, $n))) == 4) {
    #        return $k;
    #    }
    #}

    foreach my $k(2..1e12) {
        #if (is_prob_prime(ipow($k, $n)-3) and is_prob_prime(ipow($k, $n)+1)) {

        #my $t = ipow($k, $n);
        Math::GMPz::Rmpz_ui_pow_ui($mpz, $k, $n);

        if (both_primes($mpz-3, $mpz+1)) {
            if (next_prime($mpz) - prev_prime($mpz) == 4) {
                return $k;
            }
        }

        #if (is_prob_prime(ipow($k, $n)-1) and is_prob_prime(ipow($k, $n) + 3)) {
        if (both_primes($mpz-1, $mpz+3)) {
            if (next_prime($mpz) - prev_prime($mpz) == 4) {
                return $k;
            }
        }

        #if (is_prob_prime(ipow($k, $n)-2) and is_prob_prime(ipow($k, $n) + 2)) {
        if (both_primes($mpz-2, $mpz+2)) {
              if (next_prime($mpz) - prev_prime($mpz) == 4) {
                return $k;
            }
        }
    }
}

foreach my $n(1..100) {
    say "a($n) = ", a($n);
}
