#!/usr/bin/perl

# Generate new pseudoprimes that are not squarefree.

# The only two known Wieferich primes, are:
#   1093, 3511

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my %seen;

my $t = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    #is_pseudoprime($n, 2) && next;

    ($n < ((~0) >> 1))
      ? Math::GMPz::Rmpz_set_ui($t, $n)
      : Math::GMPz::Rmpz_set_str($t, "$n", 10);

    foreach my $p (1093, 3511) {
        if (Math::GMPz::Rmpz_divisible_ui_p($t, $p)) {
            my $z = $t * $p;
            if (is_pseudoprime($z, 2)) {
                say $z;
            }
        }
        else {
            my $z = $t * ($p * $p);
            if (is_pseudoprime($z, 2)) {
                say $z;
            }
        }
    }
}
