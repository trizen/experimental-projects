#!/usr/bin/perl

# Five consecutive odd numbers which are primes or strong pseudoprimes(base-2).
# http://www.shyamsundergupta.com/canyoufind.htm

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    next if ($n < ~0);
    (substr($n, -1) & 1) || next;       # must be odd

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    for (my $j = -8; $j <= 8; $j += 2) {

        my $ok = 1;
        my $from = $n+$j;
        my $to = $from+8;

        for (my $k = $from; $k <= $to; $k += 2) {
            if (not is_pseudoprime($k, 2)) {
                $ok = 0;
                last;
            }
        }
        say $from if $ok;
    }
}

__END__

# Smallest of 5 consecutive odd numbers that are primes or pseudoprime (base 2).
# https://oeis.org/A230668

280743771536011781
666787209284980781
1386744766793550161
6558237049521329741
11646802313400102461
