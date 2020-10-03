#!/usr/bin/perl

# Search for a larger empirp, using a fast primality pretest.

# See also:
#   https://en.wikipedia.org/wiki/Emirp
#   http://mathworld.wolfram.com/Emirp.html
#   https://www.primepuzzles.net/puzzles/puzz_020.htm

# The largest known emirp is 10^10006+941992101×10^4999+1 (which has 10007 digits), found by Jens Kruse Andersen in October 2007.

# 10^10006+941992101*10^4999+1
# 10^10006+101299149*10^4999+1

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use POSIX qw(ULONG_MAX);
use ntheory qw(:all);
use IO::Uncompress::Bunzip2;
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

my $z = Math::GMPz->new();

my $e = '9';        # end digits
my $d = '1';        # near end digits
my $k = 5005;

my %seen;

foreach my $n (1 .. 1e10) {

    next if ($n eq reverse($n));

    if (exists $seen{reverse $n}) {
        next;
    }

    $seen{$n} = 1;

    my $p = $e . ($d x $k) . $n . ($d x $k) . $e;

    say "Testing: $n (length: ", length($p), ")";

    Math::GMPz::Rmpz_set_str($z, $p, 10);
    primality_pretest($z) || next;
    Math::GMPz::Rmpz_set_str($z, scalar(reverse($p)), 10);
    primality_pretest($z) || next;

    say "Strong candidate: $n";

    if (is_prob_prime($p) and is_prob_prime(scalar reverse($p))) {
        die "Found: $e . ($d x $k) . $n . ($d x $k) . $e";
    }
}
