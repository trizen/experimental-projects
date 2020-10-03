#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use Math::AnyNum qw(fibmod lucasmod);
use ntheory qw(foroddcomposites forprimes is_prime powmod kronecker is_power valuation);
use Math::Prime::Util::GMP qw(lucas_sequence);

use 5.020;
use warnings;

use experimental qw(signatures);

sub PSW_primality_test ($n) {

    if (ref($n) ne 'Math::GMPz') {
        $n = Math::GMPz->new("$n");
    }

    return 0 if Math::GMPz::Rmpz_cmp_ui($n, 1) <= 0;
    return 1 if Math::GMPz::Rmpz_cmp_ui($n, 2) == 0;

    return 0 if Math::GMPz::Rmpz_even_p($n);
    return 0 if Math::GMPz::Rmpz_perfect_power_p($n);

    my $d = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init_set_ui(2);

    # Fermat base-2 test
    Math::GMPz::Rmpz_sub_ui($d, $n, 1);
    Math::GMPz::Rmpz_powm($t, $t, $d, $n);
    Math::GMPz::Rmpz_cmp_ui($t, 1) and return 0;

    # In general, we find P such that kronecker(P^2 + 4, n) = -1.
    my $P;
    for (my $k = 1 ; ; ++$k) {
        if (Math::GMPz::Rmpz_ui_kronecker($k * $k + 4, $n) == -1) {
            $P = $k;
            last;
        }
    }

    # If LucasU(P, -1, n+1) = 0 (mod n), then n is probably prime.
    (lucas_sequence($n, $P, -1, $n + 1))[0] == 0;
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
    $n = Math::GMPz->new("$n");

    if (PSW_primality_test($n)) {
        say "Counter-example: $n";
    }

    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}
