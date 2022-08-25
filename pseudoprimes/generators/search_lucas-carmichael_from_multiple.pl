#!/usr/bin/perl

# Search for Lucas-Carmichael numbers that contain a given multiple.

use 5.014;
use warnings;
use ntheory qw(:all);

foroddcomposites {
    my $t = 5 * 7 * 11 * 17 * 23 * 31 * 47 * 53 * $_ + 1;

    if ($t % 6 == 0 and $t % 8 == 0 and $t % 12 == 0 and $t % 18 == 0 and $t % 24 == 0 and $t % 32 == 0 and $t % 48 == 0 and $t % 54 == 0) {
        if (is_square_free($t-1) and vecall { $t % ($_+1) == 0 } factor($_)) {
            say $t-1;
        }
    }
} 1e9;

__END__
408598269695
449025949295
517270926095
2028295388735
2286425581055
2447321054255
4095283148495
4518532538135
5598352137455
17757873782495
20203946790335
27074874805055
34128442720295
45373136257295
179854409565215
293225138384255
1321992029616335
3899587287361535
20576473996736735
