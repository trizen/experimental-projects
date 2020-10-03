#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 16 May 2019
# https://github.com/trizen

# Generate the smallest extended Chernick-Carmichael number with k prime factors.

# OEIS sequence:
#   https://oeis.org/A318646 -- The least Chernick's "universal form" Carmichael number with n prime factors.

# See also:
#   https://oeis.org/wiki/Carmichael_numbers
#   http://www.ams.org/journals/bull/1939-45-04/S0002-9904-1939-06953-X/home.html

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
#use Math::AnyNum qw(:overload);

# Generate the factors of a Chernick number, given n
# and k, where k is the number of distinct prime factors.
sub chernick_carmichael_factors ($n, $k) {
    (6 * $n + 1, 12 * $n + 1, (map { (1 << $_) * 9 * $n + 1 } 1 .. $k - 2));
}

# Find the smallest Chernick-Carmichael number with k prime factors.
sub extended_chernick_carmichael_number ($k, $callback) {
    #foreach my $m(5..100) {

 #       say "Trying: $m";

    my $multiplier = 1;

    if ($k > 4) {
        $multiplier = 1 << ($k - 4);
    }

    #$multiplier *= 25*2;
    #for (my $n = 1e6 ; ; ++$n) {

    # try n to be smooth

    for my $n(1e7..1e8) {

        if (is_prime(6*$n*$multiplier+1) and is_prime(12*$n*$multiplier+1)) {

            my @f = chernick_carmichael_factors($n * $multiplier, $k);
            next if not vecall { is_prime($_) } @f;
            $callback->(vecprod(@f), @f);
        }
    }
}

foreach my $k (9) {
    extended_chernick_carmichael_number(
        $k,
        sub ($n, @f) {
            say "a($k) = $n";
        }
    );
}

__END__
a(3) = 1729
a(4) = 63973
a(5) = 26641259752490421121
a(6) = 1457836374916028334162241
a(7) = 24541683183872873851606952966798288052977151461406721
a(8) = 53487697914261966820654105730041031613370337776541835775672321
a(9) = 58571442634534443082821160508299574798027946748324125518533225605795841

Trying: 28
Parameter '2.07255127086009e+19' must be an integer at u.pl line 43.

Trying: 24
Parameter '1.94317514610573e+19' must be an integer at u.pl line 47.
