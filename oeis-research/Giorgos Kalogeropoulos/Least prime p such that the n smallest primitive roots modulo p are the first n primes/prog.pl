#!/usr/bin/perl

# Least prime p such that the n smallest primitive roots modulo p are the first n primes.
# https://oeis.org/A355016

# Known terms:
#    3, 5, 53, 173, 2083, 188323, 350443, 350443, 1014787, 29861203, 154363267

use 5.036;
use ntheory qw(:all);
no warnings 'uninitialized';

my @primes = (2);

sub isok($p) {
    foreach my $q (@primes) {
        #znorder($q, $p) == $p-1
        is_primitive_root($q, $p)
            or return;
    }
    foreach my $c (4..$primes[-1]-1) {
        is_prime($c) && next;
        #znorder($c, $p) == $p-1
        is_primitive_root($c, $p)
            and return;
    }
    return 1;
}

my $n = 1;

forprimes {

    while (isok($_)) {
        say "a($n) = $_";
        ++$n;
        push @primes, next_prime($primes[-1]);
    }

} 3, 1e12;

__END__
a(1) = 3
a(2) = 5
a(3) = 53
a(4) = 173
a(5) = 2083
a(6) = 188323
a(7) = 350443
a(8) = 350443
a(9) = 1014787
a(10) = 29861203
a(11) = 154363267
