#!/usr/bin/perl

# Find the smallest Carmichael number that is a multiple of a cyclic number.
# See also: https://www.numericana.com/data/crump.htm

use 5.020;
use ntheory qw(:all);

my @list = (753);

foreach my $p(grep { gcd($_, $list[0]) == 1 } @{primes(5000)}) {

    my @new = @list;

    say "[$#new] Prime: $p";
    foreach my $n(@list) {
        my $t = $n*$p;
        if ($t <= 7281824001) {
            if (gcd(euler_phi($t), $t) == 1) {
                push @new, $t;

                if (is_carmichael($t)) {
                    die "Found: $t";
                }
            }
        }
    }

    @list = @new;
}
