#!/usr/bin/perl

# a(n) is the number of Carmichael numbers whose largest prime factor is prime(n).
# https://oeis.org/A283715

=for comment

# The corresponding Carmichael numbers:

1 -> []
2 -> []
3 -> []
4 -> []
5 -> []
6 -> []
7 -> [561, 1105]
8 -> [1729]
9 -> []
10 -> [2465]
11 -> [2821, 75361]
12 -> [63973, 1050985]
13 -> [6601, 41041]
14 -> []
15 -> []
16 -> []
17 -> []
18 -> [29341, 172081, 852841, 552721, 10877581, 1256855041]
19 -> [8911, 340561, 15182481601]
20 -> [72720130561]
21 -> [10585, 15841, 126217, 2433601, 825265, 672389641, 496050841, 5394826801, 24465723528961]
22 -> [1074363265, 24172484701]
23 -> []
24 -> [62745, 2806205689, 22541365441]
25 -> [46657, 2113921, 6436473121, 6557296321, 13402361281, 26242929505, 65320532641, 143873352001, 105083995864811041]

=cut

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub carmichael_numbers ($n, $k, $callback) {

    my $max_p = nth_prime($n);

    my $u = Math::GMPz::Rmpz_init();

    sub ($m, $L, $lo, $k) {

        if ($lo > $max_p) {
            return;
        }

        if ($k == 1) {

            Math::GMPz::Rmpz_sub_ui($u, $m, 1);
            if (Math::GMPz::Rmpz_divisible_p($u, $L)) {
                $callback->(Math::GMPz::Rmpz_init_set($m));
            }

            return;
        }

        my $z   = Math::GMPz::Rmpz_init();
        my $lcm = Math::GMPz::Rmpz_init();

        foreach my $p (@{primes($lo, $max_p-1)}) {

            Math::GMPz::Rmpz_gcd_ui($Math::GMPz::NULL, $m, $p - 1) == 1 or next;
            Math::GMPz::Rmpz_lcm_ui($lcm, $L, $p - 1);
            Math::GMPz::Rmpz_mul_ui($z, $m, $p);

            __SUB__->($z, $lcm, $p + 1, $k - 1);
        }
      }
      ->(Math::GMPz->new($max_p), Math::GMPz->new($max_p-1), 3, $k-1);
}

sub a($n) {

    my $count = 0;
    foreach my $k (3..$n) {
        carmichael_numbers($n, $k, sub ($n) { ++$count });
    }

    return $count;
}

foreach my $n(1..100) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 0
a(2) = 0
a(3) = 0
a(4) = 0
a(5) = 0
a(6) = 0
a(7) = 2
a(8) = 1
a(9) = 0
a(10) = 1
a(11) = 2
a(12) = 2
a(13) = 2
a(14) = 0
a(15) = 0
a(16) = 0
a(17) = 0
a(18) = 6
a(19) = 3
a(20) = 1
a(21) = 9
a(22) = 2
a(23) = 0
a(24) = 3
a(25) = 9
a(26) = 7
a(27) = 3
