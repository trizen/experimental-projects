#!/usr/bin/perl

# Smallest k such that 2^(3*2^n) - k is a safe prime.
# https://oeis.org/A335313

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures declared_refs);

sub primality_pretest ($n) {

    #~ # Must be positive
    (Math::GMPz::Rmpz_sgn($n) > 0) || return;

    # Check for divisibilty by 2
    if (Math::GMPz::Rmpz_even_p($n)) {
        return (Math::GMPz::Rmpz_cmp_ui($n, 2) == 0);
    }

    # Return early if n is too small
    Math::GMPz::Rmpz_cmp_ui($n, 101) > 0 or return 1;

    # Check for very small factors
    Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $n, 16294579238595022365) == 1 or return 0;
    Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $n, 7145393598349078859) == 1  or return 0;

    # Size of n in base-2
    my $size = Math::GMPz::Rmpz_sizeinbase($n, 2);

    # When n is large enough, try to find a small factor (up to 10^8)
    if ($size > 10_000) {

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

sub a ($n) {

    my $t = Math::GMPz::Rmpz_init();
    my $z = Math::GMPz->new(2)**(3 * (1<<$n));

    for (my $k = (($n == 12) ? 785069 : 1); 1; $k += 2) {

        #say "Testing: k = $k";

        Math::GMPz::Rmpz_sub_ui($t, $z, $k);

        if (primality_pretest($t) && primality_pretest(($t-1)>>1)) {

            say "Testing primality for k = $k" if ($n >= 12);

            if (is_prob_prime($t) and is_prob_prime(($t-1)>>1)) {

                if ($n >= 12) {
                    die "\nFound: a($n) = $k\n\n";
                }

                return $k;
            }
        }
    }
}

# Sanity check
say "Sanity check...";
my @list = map {a($_)} 0..8;

if (join(', ', @list) eq '1, 5, 17, 317, 5297, 3449, 41213, 59057, 468857') {
    say "Passed...";
}
else {
    die "Failed...";
}

# Search for a(12)
say "Searching for a(12)";
say a(12);
