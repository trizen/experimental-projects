#!/usr/bin/perl

# Lesser of 2 consecutive Fermat pseudoprimes to base 2 with no prime numbers in between them.
# https://oeis.org/A335326

# Known terms:
#    4369, 13741, 31609, 6973057, 208969201

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use Math::Prime::Util::GMP qw(is_pseudoprime next_prime);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    next if ($n < ~0);
    next if length($n) > 100;
    #next if ($n > ~0);

    is_pseudoprime($n, 2) || next;

    $n = Math::GMPz->new($n);

    my $p = Math::GMPz->new(next_prime($n));

    for(my $k = $n+2; $k < $p; $k+=2) {
        if (is_pseudoprime($k, 2)) {
            say "Found: $n";
        }
    }
}

__END__
4369
13741
31609
6973057
208969201
