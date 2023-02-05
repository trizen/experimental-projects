#!/usr/bin/perl

# Smallest k such that n, k and n+k have the same prime signature (canonical form), or 0 if no such number exists.
# https://oeis.org/A085080

# Here is a temporary list of integers <= 1000 for which a(n) is unknown (greater than a(48) or 0): 72, 200, 288, 432, 500, 648, 800, 864, 968, 972. - Michel Marcus, David A. Corneth, Mar 08 2019

# Try to find upper-bounds, using the Chinese remainder theorem.

use 5.020;
use strict;
use warnings;

use ntheory qw(factor_exp forcomb);
use Math::Prime::Util::GMP qw(:all);
use experimental qw(signatures);

my $n = 72;
my $sig = join ' ', sort {$a <=> $b} map {$_->[1]}  factor_exp($n);

sub isok($k) {
    $sig eq join(' ', sort {$a <=> $b} map {$_->[1] } factor_exp($k));
}

for(my $p = next_prime(2); $p <= 1e5; $p = next_prime($p)) {

    say "Checking: p = $p";

     my $pp = powint($p, 3);

    my $count = 0;
    for(my $q = next_prime(sqrtint($pp)); ++$count < 1000; $q = next_prime($q)) {

        my $qq = powint($q, 2);
        my $m = lcm($pp, $qq);

    #foreach my $r (chinese([0, $pp], [-$n, $qq]), chinese([0, $qq], [-$n, $pp])) {
    foreach my $r (chinese([0, $pp], [-$n, $qq])) {

        $r || next;

        foreach my $k (0..100) {
            my $t = addint(mulint($m, $k), $r);
            #my $t = $r;

            #if ($sig eq join(' ', sort {$a <=> $b} map{$_->[1]} factor_exp($t))) {
            #if (is_square(divint($t, $pp)) and is_prime_power(divint($t, $pp))) {
            if (ntheory::is_prime_power(divint($t, $pp)) and isok($t)) {
                say "[$k, $t]";
                if (isok(addint($t, $n))) {
                    die "Found: a($n) <= $t\n";
                }
            }
        }
    }

}
}

__END__

# Almost for n=72:

[5, 2006617624313776019597]
[9, 20083543747801182379667]
[7, 10707920738720581]
[5, 237874397787427]
[4, 18836086568383]
