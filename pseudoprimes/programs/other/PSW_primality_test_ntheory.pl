#!/usr/bin/perl

# The PSW primality test, named after Carl Pomerance, John Selfridge, and Samuel Wagstaff.

# No counter-examples are known to this test.

# Algorithm: given an odd integer n, that is not a perfect power:
#   1. Perform a (strong) base-2 Fermat test.
#   2. Find the first P>0 such that kronecker(P^2 + 4, n) = -1.
#   3. If the Lucas U sequence: U(P, -1, n+1) = 0 (mod n), then n is probably prime.

# See also:
#   https://en.wikipedia.org/wiki/Lucas_pseudoprime
#   https://en.wikipedia.org/wiki/Baillie%E2%80%93PSW_primality_test

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(forprimes foroddcomposites is_prime is_power lucas_sequence kronecker powmod);

sub findP($n) {

    # Find P such that kronecker(P^2 + 4, n) = -1.
    for (my $k = 1 ; ; ++$k) {
        if (kronecker($k * $k + 4, $n) == -1) {
            return $k;
        }
    }
}

sub PSW_primality_test ($n) {

    return 0 if $n <= 1;
    return 1 if $n == 2;

    return 0 if !($n & 1);
    return 0 if is_power($n);

    # Fermat base-2 test
    powmod(2, $n - 1, $n) == 1 or return 0;

    my $P = findP($n);
    my $Q = -1;

    # If LucasU(P, -1, n+1) = 0 (mod n), then n is probably prime.
    (lucas_sequence($n, $P, $Q, $n + 1))[0] == 0;
}

say "Sanity check...";

forprimes {
    if (!PSW_primality_test($_)) {
        die "Missed prime: $_";
    }
}
1e6;

foroddcomposites {
    if (PSW_primality_test($_)) {
        die "Counter-example: $_";
    }
}
1e6;

say "Done...";
say "Beginning the test...";

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($n > ((~0)>>1)) {
        $n = Math::GMPz->new("$n");
    }

    if (PSW_primality_test($n)) {
        say "Counter-example: $n";
    }

    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}
