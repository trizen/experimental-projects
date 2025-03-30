#!/usr/bin/perl

# Numbers k > 0 such that A006218(k) / A018804(k) is an integer.
# https://oeis.org/A382353

# Known terms:
#   1, 2, 3, 4, 8, 10, 15, 43, 63, 6934, 316563, 2428132, 56264126

# No more terms < 10^9.

use 5.036;
use ntheory qw(:all);

my $from = 1e9;

sub sigma0_partial_sum ($n) {

    my $s   = sqrtint($n);
    my $sum = 0;

    foreach my $k (1 .. $s) {
        $sum += 2 * divint($n, $k);
    }

    return ($sum - $s * $s);
}

my $sum = sigma0_partial_sum($from);

my $pillai = 0;
my $sigma0 = 0;

forfactored {

    $sigma0 = 1;
    $pillai = 1;

    while (@_) {
        my $e = 1;
        my $p = shift(@_);

        while (@_ and $_[0] == $p) {
            ++$e;
            shift(@_);
        }

        $pillai *= powint($p, ($e-1)) * (($p-1)*$e+$p);
        $sigma0 *= ($e+1);
    }

    $sum += $sigma0;

    if ($sum % $pillai == 0) {
        say "$_";
    }

} $from+1, 1e11;

__END__
1
2
3
4
8
10
15
43
63
6934
316563
2428132
56264126
