#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 16 May 2019
# https://github.com/trizen

# Generate the smallest extended Chernick-Carmichael number with n prime factors.

# OEIS sequence:
#   https://oeis.org/A318646 -- The least Chernick's "universal form" Carmichael number with n prime factors.

# See also:
#   https://oeis.org/wiki/Carmichael_numbers
#   http://www.ams.org/journals/bull/1939-45-04/S0002-9904-1939-06953-X/home.html

use 5.020;
use warnings;
use ntheory qw(:all);
use experimental qw(signatures);

# Generate the factors of a Chernick-Carmichael number
sub chernick_carmichael_factors ($n, $m) {
    (6*$m + 1, 12*$m + 1, (map { (1 << $_) * 9*$m + 1 } 1 .. $n-2));
}

# Check the conditions for an extended Chernick-Carmichael number
sub is_chernick_carmichael ($n, $m) {
    ($n == 2) ? (is_prime(6*$m + 1) && is_prime(12*$m + 1))
              : (is_prime((1 << ($n-2)) * 9*$m + 1) && __SUB__->($n-1, $m));
}

# Find the smallest Chernick-Carmichael number with n prime factors.
sub chernick_carmichael_number ($n, $callback) {

    my $multiplier = ($n > 4) ? 5*(1 << ($n-4)) : 1;

    # 10026206862
    # 48474353315

    # k = 24237176657 (for n = 12)

    # m = 31023586121600        (for n = 11)
    # m = 3208386195840         (for n = 10)

    for (my $k = 40237176657 - 1e7; $k <= 40237176657 ; ++$k) {
        if (is_chernick_carmichael($n, $k * $multiplier)) {
            $callback->(chernick_carmichael_factors($n, $k * $multiplier));
            last;
        }
    }
}

foreach my $n (12) {
    chernick_carmichael_number($n, sub (@f) { say "a($n) = ", vecprod(@f) });
}

__END__
a(3) = 1729
a(4) = 63973
a(5) = 26641259752490421121
a(6) = 1457836374916028334162241
a(7) = 24541683183872873851606952966798288052977151461406721
a(8) = 53487697914261966820654105730041031613370337776541835775672321
a(9) = 58571442634534443082821160508299574798027946748324125518533225605795841
