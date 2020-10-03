#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use Math::AnyNum qw(fibmod lucasmod);
use ntheory qw(forprimes foroddcomposites is_prime powmod kronecker is_power valuation );
use Math::Prime::Util::GMP qw(lucas_sequence);

use 5.020;
use warnings;

use experimental qw(signatures);

sub BPSW_primality_test ($n) {

    return 0 if ($n <= 1);
    return 1 if ($n == 2);
    return 0 if is_power($n);

    powmod(2, $n - 1, $n) == 1 or return 0;

    my ($P, $Q) = (1, 0);

    for (my $k = 2 ; ; ++$k) {
        my $D = (-1)**$k * (2 * $k + 1);

        if (kronecker($D, $n) == -1) {
            $Q = (1 - $D) / 4;
            last;
        }
    }

    my $d = $n + 1;
    my $s = valuation($d, 2);

    $d >>= $s;

    my ($U) = lucas_sequence($n, $P, $Q, $d);
    return 1 if $U eq '0';

    foreach my $r (0 .. $s - 1) {
        my (undef, $V) = lucas_sequence($n, $P, $Q, $d << ($s - $r - 1));
        return 1 if $V eq '0';
    }

    return 0;
}

say "Sanity check...";

forprimes {
    if (!BPSW_primality_test($_)) {
        die "Missed prime: $_";
    }
} 1e6;

foroddcomposites {
    if (BPSW_primality_test($_)) {
        die "Counter-example: $_";
    }
} 1e6;

say "Done...";
say "Beginning the test...";

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n = Math::GMPz->new("$n");

    if (BPSW_primality_test($n)) {
        say "Counter-example: $n";
    }

    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}
