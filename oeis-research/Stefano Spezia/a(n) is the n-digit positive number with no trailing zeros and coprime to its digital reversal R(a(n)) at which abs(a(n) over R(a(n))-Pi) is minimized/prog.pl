#!/usr/bin/perl

# a(n) is the n-digit positive number with no trailing zeros and coprime to its digital reversal R(a(n)) at which abs(a(n)/R(a(n))-Pi) is minimized.
# https://oeis.org/A355622

# Known terms:
#   1, 92, 581, 5471, 52861, 998713, 7774742, 93630892, 422334431

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);

sub a($n) {

    my $pi = Pi();
    my $min = 1e9;
    my $best_k = 0;

    for my $k(powint(10, $n-1) .. powint(10, $n)-1) {
        if ($k % 10 != 0 and abs($k/reverse($k) - $pi) < $min) {
            if (gcd($k, scalar reverse($k)) == 1) {
                #say "a($n) <= $k / " . reverse($k) . " = " . ($k / reverse($k));
                $best_k = $k;
                $min = abs($k/reverse($k) - $pi);
            }
        }
    }

    $best_k;
}

foreach my $n(1..10) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 1
a(2) = 92
a(3) = 581
a(4) = 5471
a(5) = 52861
a(6) = 998713
a(7) = 7774742
a(8) = 93630892
