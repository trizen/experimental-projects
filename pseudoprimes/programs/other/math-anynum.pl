#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(is_prime);

my $t = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($n < ~0) {
        Math::GMPz::Rmpz_set_ui($t, $n);
    }
    else {
        Math::GMPz::Rmpz_set_str($t, $n, 10);
    }

    #if (Math::GMPz::Rmpz_probab_prime_p($t, 1)) {

    if (is_prime($t, 1)) {
        say "Counter-example: $n";
    }

    #ntheory::is_provable_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_prob_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 10) && die "error: $n\n";
}
