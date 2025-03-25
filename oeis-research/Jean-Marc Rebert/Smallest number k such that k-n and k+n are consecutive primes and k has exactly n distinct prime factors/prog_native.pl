#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 14 March 2021
# Edit: 25 March 2025
# https://github.com/trizen

# Generate k-omega primes in range [a,b]. (not in sorted order)

# Definition:
#   k-omega primes are numbers n such that omega(n) = k.

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://en.wikipedia.org/wiki/Prime_omega_function

use 5.020;
#use integer;
use ntheory      qw(:all);
use experimental qw(signatures);

sub omega_prime_numbers ($A, $B, $k, $callback) {

    my $diff = $k;
    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k) {

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {

            my $r = next_prime($q);

            for (my $v = $m * $q ; $v <= $B ; $v *= $q) {
                if ($k == 1) {
                    if ($v >= $A) {

                        if (next_prime($v) - $v == $diff and $v - prev_prime($v)  == $diff) {
                            $callback->($v);
                        }
                    }
                    #$callback->($v) if ($v >= $A);
                }
                elsif ($v * $r <= $B) {
                    __SUB__->($v, $r, $k - 1);
                }
            }
        }
    }->(1, (($diff % 2 == 0) ? 3 : 2), $k);
}

my $n = 14;
my $lo = 2;
my $hi = 2*$lo;

while (1) {

    my @terms;
    omega_prime_numbers($lo, $hi, $n, sub ($k) {
            push @terms, $k;
    });

    @terms = sort {$a <=> $b} @terms;

    if (@terms) {
        say "Terms: @terms";
        die "Found new term: a($n) = $terms[0]";
    }

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
Found new term: a(10) = 2313524242029 at x.sf line 67.
perl x.sf  10.06s user 0.12s system 99% cpu 10.211 total
Found new term: a(11) = 1568018377380 at x.sf line 67.
Found new term: a(12) = 5808562826801735 at x.sf line 67.
Found new term: a(13) = 1575649493651310 at x.sf line 67.
Found new term: a(14) = 6177821212870783905 at x.sf line 68.
