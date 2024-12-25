#!/usr/bin/perl

# Positive numbers whose squares have at most one digit less than 8.
# https://oeis.org/A378925

# Known terms:
#   1, 2, 3, 7, 9, 17, 83, 2983, 298327

# No terms > 298327 with less than 22 digits. - Michael S. Branicky, Dec 11 2024

use 5.036;
use ntheory                  qw(:all);
use Algorithm::Combinatorics qw(variations_with_repetition);

foreach my $k (1 .. 100) {

    say "k = $k";
    my $iter = variations_with_repetition([8, 9], $k);

    while (my $arr = $iter->next) {
        my $end = $#{$arr};
        foreach my $v (0 .. 7) {
            foreach my $k ((($v == 0) ? 1 : 0) .. $end) {
                my @copy = @$arr;
                splice(@copy, $k, 0, $v);
                if (is_square(join('', @copy))) {
                    say sqrtint(join('', @copy));
                }
            }
        }
    }
}

__END__
k = 1
3
7
k = 2
17
k = 3
83
k = 4
k = 5
k = 6
2983
k = 7
k = 8
k = 9
k = 10
298327
k = 11
k = 12
k = 13
k = 14
k = 15
