#!/usr/bin/perl

# Even numbers k such that k^2 - 1 is a powerful number.
# https://oeis.org/A365983

# k^2 - 1 = (k-1)*(k+1), therefore both k-1 and k+1 must be odd powerful numbers.

# Known terms:
#   26, 70226, 130576328, 189750626, 512706121226, 13837575261124, 99612037019890, 1385331749802026

use 5.036;
use ntheory qw(:all);

sub divceil ($x, $y) {    # ceil(x/y)
    (($x % $y == 0) ? 0 : 1) + divint($x, $y);
}

sub odd_powerful_numbers ($A, $B, $k = 2) {

    my @odd_powerful;

    sub ($m, $r) {

        if ($r < $k) {
            push @odd_powerful, $m;
            return;
        }

        my $from = 1;
        my $upto = rootint(divint($B, $m), $r);

        if ($r <= $k and $A > $m) {
            $from = rootint(divceil($A, $m), $r);
        }

        foreach my $v ($from .. $upto) {

            next if ($v % 2 == 0);

            if ($r > $k) {
                gcd($m, $v) == 1   or next;
                is_square_free($v) or next;
            }

            my $t = mulint($m, powint($v, $r));

            if ($r <= $k and $t < $A) {
                next;
            }

            __SUB__->($t, $r - 1);
        }
    }->(1, 2 * $k - 1);

    [sort { $a <=> $b } @odd_powerful];
}

my $lo = 2;
my $hi = 10*$lo;

while (1) {
    my $arr = odd_powerful_numbers($lo - 2, $hi + 2, 2);

    my ($x, $y) = ($arr->[0], $arr->[1]);

    foreach my $v (@$arr) {
        if (($v-2 == $x) or ($v-2 == $y)) {
            say $v-1;
        }
        ($x, $y) = ($y, $v);
    }

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
26
70226
130576328
189750626
512706121226
13837575261124
99612037019890
1385331749802026
