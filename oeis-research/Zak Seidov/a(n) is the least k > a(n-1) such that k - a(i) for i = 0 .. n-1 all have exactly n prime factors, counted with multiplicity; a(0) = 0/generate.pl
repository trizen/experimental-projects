#!/usr/bin/perl

# a(n) is the least k > a(n-1) such that k - a(i) for i = 0 .. n-1 all have exactly n prime factors, counted with multiplicity; a(0) = 0.
# https://oeis.org/A374816

# Known terms:
#   0, 2, 6, 116, 350, 14130, 6626906, 998632866

use 5.036;
use ntheory qw(:all);

my @terms = (2, 6, 116, 350, 14130, 6626906, 998632866, 150811201250);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(2, $k));

    my $n = $k;

    sub ($m, $p, $k) {

        if ($k == 1) {

            my $v;

            forprimes {

                $v = $m * $_;

                if (    is_almost_prime($n, $v - $terms[-1])
                    and is_almost_prime($n, $v - $terms[-2])
                    and is_almost_prime($n, $v - $terms[-3])
                    and vecall { is_almost_prime($n, $v - $_) } @terms) {
                    $callback->($v);
                    $B = $v if ($v < $B);
                    lastfor;
                }

            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q, $k - 1);
        }
      }
      ->(1, 2, $k);
}

my $n  = 9;
my $lo = $terms[-1] + 1;
my $hi = 2 * $lo;

say "\n:: Searching for a($n)\n";

while (1) {

    say "Sieving: [$lo, $hi]";

    my @terms;
    almost_prime_numbers(
        $lo, $hi, $n,
        sub($k) {
            say "Found upper-bound: a($n) <= $k";
            push @terms, $k;
        }
    );

    @terms = sort { $a <=> $b } @terms;

    if (@terms) {
        say "New term: a($n) = $terms[0]\n";
        last;
    }

    $lo = $hi + 1;
    $hi = 2 * $lo;
}

__END__
Sieving: [6626907, 13253814]
Sieving: [13253815, 26507630]
Sieving: [26507631, 53015262]
Sieving: [53015263, 106030526]
Sieving: [106030527, 212061054]
Sieving: [212061055, 424122110]
Sieving: [424122111, 848244222]
Sieving: [848244223, 1696488446]
Found upper-bound: a(7) <= 998632866
New term: a(7) = 998632866

perl generate.pl  39.39s user 0.03s system 99% cpu 39.495 total

Sieving: [15978125887, 31956251774]
Sieving: [31956251775, 63912503550]
Sieving: [63912503551, 127825007102]
Sieving: [127825007103, 255650014206]
Found upper-bound: a(8) <= 231847757946
Found upper-bound: a(8) <= 218568781250
Found upper-bound: a(8) <= 150811201250
New term: a(8) = 150811201250

perl generate.pl  4905.30s user 11.17s system 96% cpu 1:24:41.59 total
