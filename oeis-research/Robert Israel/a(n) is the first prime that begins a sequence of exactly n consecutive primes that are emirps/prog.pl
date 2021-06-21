#!/usr/bin/perl

# a(n) is the first prime that begins a sequence of exactly n consecutive primes that are emirps.
# https://oeis.org/A345528

# Known terms:
#   97, 13, 71, 733, 3371, 10039, 11897, 334759, 7904639, 1193

# New terms:
#   a(11) = 1477271183
#   a(12) = 9387802769

# Upper-bounds:
#   a(13) <= 15423094826093 (Giovanni Resta)

use 5.014;
use ntheory qw(:all);

my @seen;
my $count = 0;

forprimes {

    if ($_ ne scalar(reverse($_)) and is_prime(scalar reverse($_))) {
        ++$count;
    }
    else {

        if (not $seen[$count]) {
            $seen[$count] = 1;

            my $p = $_;

            for my $n (1..$count) {
                $p = prev_prime($p);
            }

            say "a($count) = $p";
        }

        $count = 0;
    }

} 1e12;

__END__
a(0) = 2
a(2) = 13
a(3) = 71
a(1) = 97
a(4) = 733
a(10) = 1193
a(5) = 3371
a(6) = 10039
a(7) = 11897
a(8) = 334759
a(9) = 7904639
a(11) = 1477271183
a(12) = 9387802769
