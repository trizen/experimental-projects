#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 26 July 2019
# https://github.com/trizen

# Numbers n such that n^4 + 4^n = A001589(n) is a semiprime.
# https://oeis.org/A089485

# a(6) >= 95381

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use POSIX qw(ULONG_MAX);
use ntheory qw(:all);
use experimental qw(signatures declared_refs);

local $| = 1;
prime_precalc(1e7);

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
                say "Found factor <= $k";
                return 0;
            }

            $prev = $primorial;
        }
    }

    return 1;
}

my $two = Math::GMPz->new(2);

local $| = 1;

foreach my $k(1..1000000) {

    # For n = 2*k + 1, n^4 + 4^n = (n^2 + n*2^(k + 1) + 2^n) * (n^2 - n*2^(k + 1) + 2^n)

    my $n = 2*$k + 1;

    next if $n < 95381;

    my $t1 = $n*$n;
    my $t2 = $n*$two**($k+1);
    my $t3 = $two**$n;

    my $x = $t1 + $t2 + $t3;
    my $y = $t1 - $t2 + $t3;

    say "Testing: $n (", length("$x"), " digits)";

    if (primality_pretest($x) and primality_pretest($y) and is_prob_prime($x) and is_prob_prime($y)) {
        #print($n, ", ");
        die "Found: $n";
    }
}
