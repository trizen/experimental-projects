#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub BPSW_primality_test ($n) {

    $n = Math::GMPz->new("$n");

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

    my $Q = 1;

    for (my $k = 2 ; ; ++$k) {
        my $D = (-1)**$k * (2 * $k + 1);

        if (Math::GMPz::Rmpz_si_kronecker($D, $n) == -1) {
            $Q = (1 - $D) / 4;
            last;
        }
    }

    Math::GMPz::Rmpz_add_ui($d, $d, 2);

    my $s = Math::GMPz::Rmpz_scan1($d, 0);
    Math::GMPz::Rmpz_div_2exp($t, $d, $s + 1);
    my $U1 = Math::GMPz::Rmpz_init_set_ui(1);

    my ($V1, $V2) = (Math::GMPz::Rmpz_init_set_ui(2), Math::GMPz::Rmpz_init_set_ui(1));
    my ($Q1, $Q2) = (Math::GMPz::Rmpz_init_set_ui(1), Math::GMPz::Rmpz_init_set_ui(1));

    foreach my $bit (split(//, Math::GMPz::Rmpz_get_str($t, 2))) {

        Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);
        Math::GMPz::Rmpz_mod($Q1, $Q1, $n);

        if ($bit) {
            Math::GMPz::Rmpz_mul_si($Q2, $Q1, $Q);
            Math::GMPz::Rmpz_mul($U1, $U1, $V2);
            Math::GMPz::Rmpz_mul($V1, $V1, $V2);

            Math::GMPz::Rmpz_powm_ui($V2, $V2, 2, $n);
            Math::GMPz::Rmpz_sub($V1, $V1, $Q1);
            Math::GMPz::Rmpz_submul_ui($V2, $Q2, 2);

            Math::GMPz::Rmpz_mod($V1, $V1, $n);
            Math::GMPz::Rmpz_mod($U1, $U1, $n);
        }
        else {
            Math::GMPz::Rmpz_set($Q2, $Q1);
            Math::GMPz::Rmpz_mul($U1, $U1, $V1);
            Math::GMPz::Rmpz_mul($V2, $V2, $V1);
            Math::GMPz::Rmpz_sub($U1, $U1, $Q1);

            Math::GMPz::Rmpz_powm_ui($V1, $V1, 2, $n);
            Math::GMPz::Rmpz_sub($V2, $V2, $Q1);
            Math::GMPz::Rmpz_submul_ui($V1, $Q2, 2);

            Math::GMPz::Rmpz_mod($V2, $V2, $n);
            Math::GMPz::Rmpz_mod($U1, $U1, $n);
        }
    }

    Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);
    Math::GMPz::Rmpz_mul_si($Q2, $Q1, $Q);
    Math::GMPz::Rmpz_mul($U1, $U1, $V1);
    Math::GMPz::Rmpz_mul($V1, $V1, $V2);
    Math::GMPz::Rmpz_sub($U1, $U1, $Q1);
    Math::GMPz::Rmpz_sub($V1, $V1, $Q1);
    Math::GMPz::Rmpz_mul($Q1, $Q1, $Q2);

    if (Math::GMPz::Rmpz_congruent_ui_p($U1, 0, $n)) {
        return 1;
    }

    if (Math::GMPz::Rmpz_congruent_ui_p($V1, 0, $n)) {
        return 1;
    }

    for (1 .. $s - 1) {

        Math::GMPz::Rmpz_mul($U1, $U1, $V1);
        Math::GMPz::Rmpz_mod($U1, $U1, $n);
        Math::GMPz::Rmpz_powm_ui($V1, $V1, 2, $n);
        Math::GMPz::Rmpz_submul_ui($V1, $Q1, 2);
        Math::GMPz::Rmpz_powm_ui($Q1, $Q1, 2, $n);

        if (Math::GMPz::Rmpz_congruent_ui_p($V1, 0, $n)) {
            return 1;
        }
    }

    return 0;
}

say "Sanity check...";

forprimes {
    if (!BPSW_primality_test($_)) {
        die "Missed prime: $_";
    }
}
1e6;

foroddcomposites {
    if (BPSW_primality_test($_)) {
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

    if (BPSW_primality_test($n)) {
        say "Counter-example: $n";
    }

    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}
