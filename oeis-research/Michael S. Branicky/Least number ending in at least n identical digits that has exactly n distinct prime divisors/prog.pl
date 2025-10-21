#!/usr/bin/perl

# a(n) is the least number ending in at least n identical digits that has exactly n distinct prime divisors.
# https://oeis.org/A389187

# Known terms:
#   2, 22, 222, 6666, 111111, 222222, 462222222, 58422222222, 11523666666666, 1141362222222222, 42481455555555555, 1173711888888888888

use 5.036;
use strict;
use warnings;
use ntheory qw(:all);

sub a($n) {
    my $Rn    = divint((powint(10, $n) - 1), 9);
    my $pow10 = powint(10, $n);

    for (my $d = 0 ; ; $d++) {
        my $start = $d ? powint(10, ($d - 1)) : 0;
        my $end   = powint(10, $d);

        say "Testing: $d -- ", $start * $pow10 + $Rn;

        for (my $r = $start ; $r < $end ; $r++) {
            for my $m (1 .. 9) {
                my $t = addint(mulint($r, $pow10), mulint($m, $Rn));
                if (is_omega_prime($n, $t)) {
                    return $t;
                }
            }
        }
    }
}

foreach my $n (1 .. 10) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 2
a(2) = 22
a(3) = 222
a(4) = 6666
a(5) = 111111
a(6) = 222222
a(7) = 462222222
a(8) = 58422222222
a(9) = 11523666666666
a(10) = 1141362222222222
a(11) = 42481455555555555
a(12) = 1173711888888888888
