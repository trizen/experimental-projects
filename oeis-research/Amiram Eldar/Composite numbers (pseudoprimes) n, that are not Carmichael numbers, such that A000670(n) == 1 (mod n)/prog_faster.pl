#!/usr/bin/perl

# Composite numbers (pseudoprimes) n, that are not Carmichael numbers, such that A000670(n) == 1 (mod n).
# https://oeis.org/A289338

# Known terms:
#   169, 885, 2193, 8905, 22713

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

sub fubini_number {
    my ($n) = @_;

    state $F = [Math::GMPz::Rmpz_init_set_ui(1)];
    state $t = Math::GMPz::Rmpz_init_nobless();

    foreach my $i ($#{$F} + 1 .. $n) {
        my $w = Math::GMPz::Rmpz_init_set_ui(0);
        foreach my $k (0 .. $i - 1) {
            Math::GMPz::Rmpz_bin_uiui($t, $i, $i - $k);
            Math::GMPz::Rmpz_addmul($w, $F->[$k], $t);
        }
        $F->[$i] = $w;
    }

    $F->[$n];
}

my $t = Math::GMPz::Rmpz_init_nobless();

foreach my $n (1..1e6) {

    next if is_prime($n);
    next if is_carmichael($n);

    if (Math::GMPz::Rmpz_mod_ui($t, fubini_number($n), $n) == 1) {
        say "Found term: $n";
    }
}

__END__
Found term: 169
Found term: 885
Found term: 2193
