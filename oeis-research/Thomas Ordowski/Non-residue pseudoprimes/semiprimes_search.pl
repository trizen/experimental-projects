#!/usr/bin/perl

# Smallest "non-residue" pseudoprime to base prime(n).
# https://oeis.org/A307809

# Conjecture: all terms are semiprimes.

use 5.020;
use ntheory qw(:all);
use warnings;
use experimental qw(signatures);

sub a($n) {

    my $q = nth_prime($n);
    my $found = undef;

    forsemiprimes {
        if (powmod($q, ($_-1)>>1, $_) == $_-1) {
            if (qnr($_) == $q) {
                $found = $_;
                lastfor;
            }
        }
    } ~0;

    return $found;
}

foreach my $n(1..20) {
    say "a($n) <= ", a($n);
}

__END__
a(1) <= 3277
a(2) <= 3281
a(3) <= 121463
a(4) <= 491209
a(5) <= 11530801
a(6) <= 512330281
a(7) <= 15656266201
