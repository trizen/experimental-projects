#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 24 November 2018
# https://github.com/trizen

# A new algorithm for computing the partial-sums of the prime omega function `ω(k)`, for `1 <= k <= n`:
#   a(n) = Sum_{k=1..n} ω(k)

# Based on the formula:
#   Sum_{k=1..n} ω(k) = Sum_{p prime <= n} floor(n/p)

# Example:
#    a(10^1) = 11
#    a(10^2) = 171
#    a(10^3) = 2126
#    a(10^4) = 24300
#    a(10^5) = 266400
#    a(10^6) = 2853708
#    a(10^7) = 30130317
#    a(10^8) = 315037281
#    a(10^9) = 3271067968
#    a(10^10) = 33787242719
#    a(10^11) = 347589015681
#    a(10^12) = 3564432632541

# Example for `m=0` (A064182):
#    A_0(10^1)  = 11
#    A_0(10^2)  = 171
#    A_0(10^3)  = 2126
#    A_0(10^4)  = 24300
#    A_0(10^5)  = 266400
#    A_0(10^6)  = 2853708
#    A_0(10^7)  = 30130317
#    A_0(10^8)  = 315037281
#    A_0(10^9)  = 3271067968
#    A_0(10^10) = 33787242719
#    A_0(10^11) = 347589015681
#    A_0(10^12) = 3564432632541

# Example for `m=1`:
#    A_1(10^1)  = 25
#    A_1(10^2)  = 2298
#    A_1(10^3)  = 226342
#    A_1(10^4)  = 22616110
#    A_1(10^5)  = 2261266482
#    A_1(10^6)  = 226124236118
#    A_1(10^7)  = 22612374197143
#    A_1(10^8)  = 2261237139656553
#    A_1(10^9)  = 226123710243814636
#    A_1(10^10) = 22612371006991736766
#    A_1(10^11) = 2261237100241987653515
#    A_1(10^12) = 226123710021083492369813
#    A_1(10^13) = 22612371002056432695022703
#    A_1(10^14) = 2261237100205367824451036203

# Example for `m=2`:
#    A_2(10^1)  = 75
#    A_2(10^2)  = 59962
#    A_2(10^3)  = 58403906
#    A_2(10^4)  = 58270913442
#    A_2(10^5)  = 58255785988898
#    A_2(10^6)  = 58254390385024132
#    A_2(10^7)  = 58254229074894448703
#    A_2(10^8)  = 58254214780225801032503
#    A_2(10^9)  = 58254213248247357411667320
#    A_2(10^10) = 58254213116747777047390609694
#    A_2(10^11) = 58254213101385832019517484266265
#    A_2(10^12) = 58254213099991292350208499967189227
#    A_2(10^13) = 58254213099830361065330294973944269431

# See also:
#   https://oeis.org/A013939
#   https://oeis.org/A064182
#   https://en.wikipedia.org/wiki/Prime_omega_function
#   https://en.wikipedia.org/wiki/Prime-counting_function
#   https://trizenx.blogspot.com/2018/08/interesting-formulas-and-exercises-in.html

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use Math::GMPz;
#use Math::AnyNum qw(:overload faulhaber_sum float zeta pi);
use ntheory qw(forprimes sqrtint factorial);
#use POSIX qw(ULONG_MAX);

my $tmp = Math::GMPz->new;

my $prev_n = 0;
my $prev_m = 0;
my $prev_pi_n = 0;
my $prev_pi_m = 0;

sub prime_count ($n, $m) {

    if ($m-$n <= 10**8) {
        return ntheory::prime_count($n+1, $m)
    }

    my ($from, $to);

    if ($n == $prev_n) {
        $from = $prev_pi_n;
    }
    else {
        chomp($from = `../primecount $n`);
    }

    if ($m == $prev_m) {
        $to = $prev_pi_m;
    } else {
        chomp($to = `../primecount $m`);
    }

    $prev_n = $n;
    $prev_pi_n = $from;

    $prev_m = $m;
    $prev_pi_m = $to;

    $to - $from;
}

sub prime_omega_partial_sum ($n) {     # O(sqrt(n)) complexity

    my $total = Math::GMPz->new(0);

    my $s = sqrtint($n);
    my $u = int($n / ($s + 1));

    my $t = Math::GMPz->new();

    for my $k (1 .. $s) {

        Math::GMPz::Rmpz_set_ui($t, prime_count(int($n/($k+1)), int($n/$k)));
        Math::GMPz::Rmpz_mul_ui($t, $t, $k+1);
        Math::GMPz::Rmpz_addmul_ui($total, $t, $k);

        #$total += $k*($k+1) *;
    }

    forprimes {
        #$total += int($n/$_);
        Math::GMPz::Rmpz_set_ui($t, int($n/$_));
        #Math::GMPz::Rmpz_mul_ui($t, $t, 1+int($n/$_));
        #Math::GMPz::Rmpz_set_ui($t, int($n/$_));
        Math::GMPz::Rmpz_addmul_ui($total, $t, 1+int($n/$_));
    } $u;

    Math::GMPz::Rmpz_divexact_ui($total, $total, 2);

    return $total;
}

sub prime_omega_partial_sum_test ($n) {    # just for testing
    my $total = 0;

    forprimes {
        $total += int($n/$_);
    } $n;

    return $total;
}

for my $n(1..10) {
    say "a(10^$n) = ", prime_omega_partial_sum(10**$n);
    #say prime_omega_partial_sum(factorial(14));
}

__END__
for my $m (1 .. 10) {

    my $n = int rand 100000;

    my $t1 = prime_omega_partial_sum($n);
    my $t2 = prime_omega_partial_sum_test($n);

    die "error: $t1 != $t2" if ($t1 != $t2);

    say "Sum_{k=1..$n} omega(k) = $t1";
}

__END__
Sum_{k=1..62429} omega(k) = 163587
Sum_{k=1..80890} omega(k) = 213922
Sum_{k=1..82192} omega(k) = 217486
Sum_{k=1..97784} omega(k) = 260299
Sum_{k=1..16940} omega(k) = 42156
Sum_{k=1..42413} omega(k) = 109555
Sum_{k=1..18647} omega(k) = 46596
Sum_{k=1..18716} omega(k) = 46776
Sum_{k=1..56593} omega(k) = 147768
Sum_{k=1..65034} omega(k) = 170664
