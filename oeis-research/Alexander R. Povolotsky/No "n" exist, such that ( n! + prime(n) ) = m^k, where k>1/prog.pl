#!/usr/bin/perl

# Alexander R. Povolotsky's conjecture:
#   No "n" exist, such that ( n! + prime(n) ) = m^k, where k>1

# See also:
#   https://web.archive.org/web/20181017014854/http://www.primepuzzles.net/conjectures/conj_059.htm

# If such a number n exists, then it is greater than 50000.

use 5.014;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my $t = Math::GMPz::Rmpz_init_set_ui(1);
my $z = Math::GMPz::Rmpz_init_set_ui(1);
my $p = 2;

foreach my $n (1..1e9) {

    if ($n % 1e4 == 0) {
        say "Checking: $n";
    }

    Math::GMPz::Rmpz_mul_ui($t, $t, $n);
    Math::GMPz::Rmpz_add_ui($z, $t, $p);

    if (Math::GMPz::Rmpz_perfect_power_p($z)) {
        die "Found counter-example: $n";
    }

    $p = next_prime($p);
}
