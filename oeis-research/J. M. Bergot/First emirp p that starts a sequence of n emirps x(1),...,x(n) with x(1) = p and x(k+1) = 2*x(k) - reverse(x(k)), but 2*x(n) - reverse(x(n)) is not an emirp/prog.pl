#!/usr/bin/perl

# a(n) is the first emirp p that starts a sequence of n emirps x(1),...,x(n) with x(1) = p and x(k+1) = 2*x(k) - reverse(x(k)), but 2*x(n) - reverse(x(n)) is not an emirp.
# https://oeis.org/A358983

# Known terms:
#   13, 941, 1471, 120511, 368631127

use 5.020;
use ntheory qw(:all);

my @seen;

forprimes {

    if (is_prime(scalar(reverse($_))) and $_ ne reverse($_)) {

        my $q = 2*$_ - reverse($_);

        my $count = 1;
        while (is_prime($q) and is_prime(scalar(reverse($q))) and $q ne reverse($q)) {
            $q = 2*$q - reverse($q);
            ++$count;
        }

        if (not $seen[$count]) {
            say "a($count) = $_";
            $seen[$count] = 1;
        }
    }
} 1e13;

__END__
a(1) = 13
a(2) = 941
a(3) = 1471
a(4) = 120511
a(5) = 368631127
