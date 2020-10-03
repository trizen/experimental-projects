#!/usr/bin/perl

# Indices of highly composite numbers A002182 which are between a twin prime pair.
# https://oeis.org/A321995

# Known terms:
#   3, 4, 5, 9, 11, 12, 20, 28, 30, 84, 108, 118, 143, 149, 208, 330, 362, 1002, 2395, 3160, 10535

use 5.014;
use Math::GMPz;
use POSIX qw(ULONG_MAX);
use ntheory qw(:all);

local $| = 1;
prime_precalc(1e7);

# 10535 corresponds to A108951(52900585920).

# a(22) > 107372

sub primality_pretest {
    my ($n) = @_;

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
    if ($size > 15_000) {

        state %cache;
        state $g = Math::GMPz::Rmpz_init_nobless();

        my @checks = (1e4, 1e6);

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

# "HCN.bz2" is available at http://wwwhomes.uni-bielefeld.de/achim/HCN.bz2
#my $z = IO::Uncompress::Bunzip2->new("HCN.bz2");

#while (defined(my $line = $z->getline())) {
while (<>) {

    chomp(my $line = $_);

    next if ($. < 107372);

    my @fields = split(' ', $line);
    my $omega  = shift(@fields);

    my @primes = (($omega > 0) ? @{primes(nth_prime($omega))} : ());
    my $prod   = Math::GMPz->new(1);

    while (@primes) {
        my $k = shift(@fields) // die "error: $_";

        my $e = 1;
        if ($k =~ /^(\d+)\^(\d+)\z/) {
            $k = $1;
            $e = $2;
        }

        for (1 .. $e) {
            my $p = shift(@primes);

            if ($k > 1) {
                $prod *= Math::GMPz->new($p)**$k;
            }
            else {
                $prod *= $p;
            }
        }
    }

    say "Testing: $.";

    if (    primality_pretest($prod - 1)
        and primality_pretest($prod + 1)
        and is_prob_prime($prod + 1)
        and is_prob_prime($prod - 1)) {

        #print $., ", ";
        say "Found: $.";

        if ($. > 10535) {
            die "New term found: $.\n";
        }
    }
}
