#!/usr/bin/perl

# Try to generate a base-2 pseudoprime from combinations of primes.

use 5.014;
use warnings;

use ntheory qw(:all);
use List::Util qw(shuffle);

my @primes;

while (<>) {
    next if /%#/;
    /\d/ or next;
    chomp;

    my $n = (split(' ', $_))[-1];

    is_prime($n) || next;

    modint($n, 8) == 3 or next;
    kronecker(5, $n) == -1 or next;

    push @primes, $n;
}

my $n = scalar(@primes);

say ":: Found $n primes...";

for(my $k = 3; $k <= $n; $k += 2) {

    @primes = shuffle(@primes);
    my $nok = binomial($n, $k);

    say ":: Testing: $k -- tries: 10^", log("$nok")/log(10);

    my $tries = 0;

    forcomb {
        my $psp = vecprod(@primes[@_]);
        if ($psp > ~0 and is_pseudoprime($psp, 2)) {
            say "Found: $psp";
        }
        lastfor if (++$tries > 1e6);
    } $n, $k;
}
