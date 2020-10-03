#!/usr/bin/perl

# Smallest odd number for which Miller-Rabin primality test on bases <= n-th prime does not reveal compositeness.
# https://oeis.org/A014233

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my @terms;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n > ~0;
    #next if (length($n) > 40);

    if (is_strong_pseudoprime($n, 2)) {
        push @terms, $n;
    }
}

@terms = sort { $a <=> $b } @terms;

my $p     = 2;
my @bases = ($p);

foreach my $n (@terms) {
    while (is_strong_pseudoprime($n, @bases)) {
        say "a(", scalar(@bases), ") <= $n";
        $p = next_prime($p);
        unshift @bases, $p;
    }
}

__END__
a(1) <= 2047
a(2) <= 1373653
a(3) <= 25326001
a(4) <= 3215031751
a(5) <= 2152302898747
a(6) <= 3474749660383
a(7) <= 341550071728321
a(8) <= 341550071728321
a(9) <= 3825123056546413051
a(10) <= 3825123056546413051
a(11) <= 3825123056546413051
