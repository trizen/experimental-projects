#!/usr/bin/perl

# Composite integers n such that n-1 divided by the binary period of 1/n (=A007733(n)) equals an integral power of 2.
# https://oeis.org/A243050

# Pseudoprimes n such that (n-1)/ord_{n}(2) = 2^k for some k, where ord_{n}(2) = A002326((n-1)/2) is the multiplicative order of 2 mod n. Composite numbers n such that Od(ord_{n}(2)) = Od(n-1), where ord_{n}(2) as above and Od(m) = A000265(m) is the odd part of m. Note that if Od(ord_{n}(2)) = Od(n-1), then ord_{n}(2)|(n-1). - Thomas Ordowski, Mar 13 2019

# Known terms:
#   12801, 348161, 3225601, 104988673, 4294967297, 7816642561, 43796171521, 49413980161, 54745942917121, 51125767490519041, 18314818035992494081, 18446744073709551617

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use experimental qw(signatures);

my %seen;

sub binary_period ($n) {
    znorder(2, $n);
}

my $t = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n < ~0);
    next if length($n) > 30;

    (substr($n, -1) & 1) or next;    # must be odd

    ($n < ((~0) >> 1))
      ? Math::GMPz::Rmpz_set_ui($t, $n)
      : Math::GMPz::Rmpz_set_str($t, "$n", 10);

    my $bp = binary_period($t);

    Math::GMPz::Rmpz_sub_ui($t, $t, 1);
    Math::GMPz::Rmpz_divisible_ui_p($t, $bp) || next;
    Math::GMPz::Rmpz_divexact_ui($t, $t, $bp);

    ($t & ($t - 1)) == 0 or next;

    say $n if !$seen{$n}++;
}
