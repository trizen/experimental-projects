#!/usr/bin/perl

use 5.020;
use strict;
use warnings;

use ntheory qw(forprimes foroddcomposites);
use experimental qw(signatures);

use Math::AnyNum qw(
  is_prime is_power is_congruent
  kronecker powmod as_bin bit_scan1
  );

sub findQ($n) {

    # Find first D for which kronecker(D, n) == -1
    for (my $k = 2 ; ; ++$k) {
        my $D = (-1)**$k * (2 * $k + 1);
        if (kronecker($D, $n) == -1) {
            return ((1 - $D) / 4);
        }
    }
}

sub BPSW_primality_test($n) {

    return 0 if $n <= 1;
    return 1 if $n == 2;

    return 0 if !($n & 1);
    return 0 if is_power($n);

    # Fermat base-2 test
    powmod(2, $n - 1, $n) == 1 or return 0;

    # Perform a strong Lucas probable test
    my $Q = findQ($n);
    my $d = $n + 1;
    my $s = bit_scan1($d, 0);
    my $t = $d >> ($s + 1);

    my $U1 = 1;

    my ($V1, $V2) = (2, 1);
    my ($Q1, $Q2) = (1, 1);

    foreach my $bit (split(//, as_bin($t))) {

        $Q1 = ($Q1 * $Q2) % $n;

        if ($bit) {
            $Q2 = ($Q1 * $Q) % $n;
            $U1 = ($U1 * $V2) % $n;
            $V1 = ($V2 * $V1 - $Q1) % $n;
            $V2 = ($V2 * $V2 - 2 * $Q2) % $n;
        }
        else {
            $Q2 = $Q1;
            $U1 = ($U1 * $V1 - $Q1) % $n;
            $V2 = ($V2 * $V1 - $Q1) % $n;
            $V1 = ($V1 * $V1 - 2 * $Q2) % $n;
        }
    }

    $Q1 = ($Q1 * $Q2) % $n;
    $Q2 = ($Q1 * $Q) % $n;
    $U1 = ($U1 * $V1 - $Q1) % $n;
    $V1 = ($V2 * $V1 - $Q1) % $n;
    $Q1 = ($Q1 * $Q2) % $n;

    return 1 if is_congruent($U1, 0, $n);
    return 1 if is_congruent($V1, 0, $n);

    for (1 .. $s - 1) {

        $V1 = ($V1 * $V1 - 2 * $Q1) % $n;
        $Q1 = ($Q1 * $Q1) % $n;

        return 1 if is_congruent($V1, 0, $n);
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
