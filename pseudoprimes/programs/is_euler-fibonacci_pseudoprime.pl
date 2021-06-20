#!/usr/bin/perl

# Try to find a composite n such that F(n) == 5^{(n-1)/2} == -1 (mod n).

# No such number is known below 3*10^9. - Amiram Eldar
# No such number is known below 4*10^9. - Giovanni Resta (via A094395)

# No counter-example found...

# See also:
#   https://oeis.org/A094395

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use ntheory qw(is_euler_pseudoprime);
use Math::Prime::Util::GMP qw(lucas_sequence subint);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < 4e9;

    if (is_euler_pseudoprime($n, 5)) {

        my ($U, $V) = lucas_sequence($n, 1, -1, $n);

        if ($U eq subint($n, 1)) {
            die "\nCounter-example: $n\n";
        }
    }
}

say "No counter-example found...";
