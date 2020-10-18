#!/usr/bin/perl

# a(n) is the least number such that the n-th prime is the least coprime quadratic nonresidue modulo a(n).
# https://oeis.org/A306493

#b(p, k) = gcd(p, k)==1&&!issquare(Mod(p, k))
#a(n) = my(k=1); while(sum(i=1, n-1, b(prime(i), k))!=0 || !b(prime(n), k), k++); k

use 5.014;
use ntheory qw(:all);

use Math::Sidef;

sub a {
    my ($n) = @_;

    my $p = nth_prime($n);
    my @primes = @{primes($p-1)};

    for(my $k = 1;;++$k) {

        if (!((gcd($p, $k) == 1) && (!Math::Sidef::sqrtmod($p, $k))) ||
        (vecany {
            (gcd($_, $k) == 1) && (!Math::Sidef::sqrtmod($_, $k))
        } @primes)
        ) {

        }
        else {
            return $k;
        }
    }
}

#~ sub b {
    #~ my ($n) = @_;

    #~ my $p = nth_prime($n);
    #~ my @primes = @{primes($p-1)};

    #~ for(my $k = 1;;++$k) {

        #~ if (!((gcd($p, $k) == 1) && !(kronecker($k, $p) == 0)) ||
        #~ (vecany {
            #~ (gcd($_, $k) == 1) && !(kronecker($k, $_) == 0)
        #~ } @primes)
        #~ ) {

        #~ }
        #~ else {
            #~ return $k;
        #~ }
    #~ }
#~ }

#~ say b(5);
#~ __END__
foreach my $n(1..100) {
    say "a($n) = ", a($n);
}

__END__

a(17) = 6924458
a(18) = 13620602

175244281

a(1) = 3
a(2) = 4
a(3) = 6
a(4) = 22
a(5) = 118
a(6) = 479
a(7) = 262
a(8) = 3622
a(9) = 5878
a(10) = 18191
a(11) = 24022
a(12) = 132982
a(13) = 296278
a(14) = 366791
a(15) = 1289738
a(16) = 4539478
a(17) = 6924458
a(18) = 13620602
a(19) = 32290442
a(20) = 175244281
^C
perl v.pl  560.52s user 0.18s system 99% cpu 9:22.30 total

[3, 4, 6, 22, 118, 479, 262, 3622, 5878, 18191, 24022, 132982, 296278, 366791, 1289738, 4539478, 6924458, 13620602, 32290442, 175244281]


# Daniel "Trizen" Șuteu
# Date: 30 October 2017
# https://github.com/trizen

# Find all the solutions to the congruence equation:
#   x^2 = a (mod n)

# Defined for any values of `a` and `n` for which `kronecker(a, n) = 1`.

# When `kronecker(a, n) != 1`, for example:
#
#   a = 472
#   n = 972
#
# which represents:
#   x^2 = 472 (mod 972)
#
# this algorithm is not able to find a solution, although there exist four solutions:
#   x = {38, 448, 524, 934}

# Code inspired from:
#   https://github.com/Magtheridon96/Square-Root-Modulo-N


use ntheory qw(:all);

sub foo {
    my ($n) = @_;

    my $p = nth_prime($n);

    foreach my $k(2..1e5) {
        my @a = sqrt_mod($p, $k);
    }

}

my @a =  sqrt_mod_n(19**2, 118);
say "@a";

#say foo(5);

__END__


my $p = nth_prime(5);
my $k = 118;

foreach my $n(1..$k) {
    my @a = sqrt_mod_n($n**2, $k);
    @a || next;
    say "a($n) = ", join(' ', map{sprintf("[%s, %s]", $_, gcd($_, $p))} @a);
}


__END__
say join(' ', sqrt_mod_n(993, 2048));    #=> 369 1679 655 1393
say join(' ', sqrt_mod_n(441, 920));     #=> 761 481 209 849 531 251 899 619 301 21 669 389 71 711 439 159
say join(' ', sqrt_mod_n(841, 905));     #=> 391 876 29 514
say join(' ', sqrt_mod_n(289, 992));     #=> 417 513 975 79 913 17 479 575

# The algorithm works for arbitrary large integers
say join(' ', sqrt_mod_n(13**18 * 5**7 - 1, 13**18 * 5**7));    #=> 633398078861605286438568 2308322911594648160422943 6477255756527023177780182 8152180589260066051764557
