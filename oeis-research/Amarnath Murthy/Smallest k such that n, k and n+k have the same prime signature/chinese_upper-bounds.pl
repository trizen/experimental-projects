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

my @primes = (@{primes(1e2)}, @{primes(1e4 + 5*1e3, 1e4 + 10*1e3)});

forcomb {
    my ($p, $q) = @primes[@_];

    my $pp = powint($p, 3);
    my $qq = powint($q, 3);

    my $m = lcm($pp, $qq);

    foreach my $r (chinese([0, $pp], [-$n, $qq]), chinese([0, $qq], [-$n, $pp])) {

        $r || next;

        foreach my $k (0..10) {
            my $t = addint(mulint($m, $k), $r);

            #if ($sig eq join(' ', sort {$a <=> $b} map{$_->[1]} factor_exp($t))) {
            if (ntheory::is_prime_power(divint($t, $pp)) and isok($t)) {
                say "[$k, $t]";
                if (isok(addint($t, $n))) {
                    die "Found: a($n) <= $t\n";
                }
            }
        }
    }

} scalar(@primes), 2;

__END__

# Almost for n=72:

[5, 2006617624313776019597]
[9, 20083543747801182379667]
[7, 10707920738720581]
[5, 237874397787427]
[4, 18836086568383]
[7, 15427761623271461]
[2, 171779496305992199]

[3, 17499086666340943]
[6, 31601819240477257]
[9, 910166741127464147]
[9, 861194402252725727]
[6, 22962663155150479]
[0, 8521204873151591]
[0, 27454604113603357]
[0, 73400248524545321]
[0, 14482255720806529]
[1, 150037455978915889]
[0, 22645778349990161]

[89, 11941003054088963]
[26, 237727945949544179]
[85, 246594917957674459]
[11, 166281176862690517]
[6, 31601819240477257]
[85, 7345971104683320583]

[12, 192961355674524251]
[3, 872812427813239]
[0, 1504441941746307679]

[53, 72073773860413]
[45, 972739810433]
[0, 31055359831]
[0, 129924347116072337]
[0, 9568381550029667879]
[0, 13423176751897651021]
[59, 8467410790321759]
[13, 683889260869303]
[61, 17664067495497257]
[0, 4379865161415417587]
[4, 18836086568383]
[28, 2654000284802339]
[203, 56522517968849111]
[2406, 306201095803]
