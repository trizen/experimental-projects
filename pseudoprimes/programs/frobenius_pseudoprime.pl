#!/usr/bin/perl

# Try to find a Frobenius pseudoprime `n` to polynomial `x^2 + 5x + 5`, with `legendre(n,5) = -1`.
# The reward for such pseudoprime is $6.20.

# Very close counter-example:
#   18458188757107538603

# Frobenius pseudoprime, but with `legendre(n,5) = 1`:
#   318665857834031151167461

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::Prime::Util::GMP qw(is_frobenius_pseudoprime lucas_sequence divrem);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;

    #say $. if $. % 10000 == 0;

    my $r = divrem($n, 5);
    ($r == 2) or ($r == 3) or next;

    say "[$.] Testing: $n";

    if (is_frobenius_pseudoprime($n, -5, 5)) {
        die "\nCounter-example: $n\n";
    }

    #~ my ($U,$V) = (lucas_sequence($n, -5, 5, $n + 1));

    #~ if ($U == 0 or $V == 1) {
    #~ say "Almost counter-example: $n";
    #~ }
}

say "No counter-example found...";
