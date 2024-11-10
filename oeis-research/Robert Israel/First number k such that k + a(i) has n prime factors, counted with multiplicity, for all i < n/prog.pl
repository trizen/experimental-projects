#!/usr/bin/perl

# a(n) is the first number k such that k + a(i) has n prime factors, counted with multiplicity, for all i < n; a(0) = 0.
# https://oeis.org/A361228

# Known terms:
#   0, 2, 4, 66, 1012, 14630, 929390, 63798350

# New terms:
#   a(8) = 19371451550

# Lower-bounds:
#   a(9) > 824633720831

use 5.036;
use ntheory qw(:all);

my @terms = (0, 2, 4, 66, 1012, 14630, 929390, 63798350, 19371451550);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(2, $k));

    my $n = $k;

    sub ($m, $p, $k) {

        if ($k == 1) {

            my $v;

            forprimes {

                $v = $m * $_;

                if (    is_almost_prime($n, $v + $terms[-1])
                    and is_almost_prime($n, $v + $terms[-2])
                    and is_almost_prime($n, $v + $terms[-3])
                    and vecall { is_almost_prime($n, $v + $_) } @terms) {
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
my $lo = 2;
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
:: Searching for a(7)

Sieving: [929391, 1858782]
Sieving: [1858783, 3717566]
Sieving: [3717567, 7435134]
Sieving: [7435135, 14870270]
Sieving: [14870271, 29740542]
Sieving: [29740543, 59481086]
Sieving: [59481087, 118962174]
Found upper-bound: a(7) <= 63798350
New term: a(7) = 63798350

:: Searching for a(8)

Sieving: [63798351, 127596702]
Sieving: [127596703, 255193406]
Sieving: [255193407, 510386814]
Sieving: [510386815, 1020773630]
Sieving: [1020773631, 2041547262]
Sieving: [2041547263, 4083094526]
Sieving: [4083094527, 8166189054]
Sieving: [8166189055, 16332378110]
Sieving: [16332378111, 32664756222]
Found upper-bound: a(8) <= 19371451550
New term: a(8) = 19371451550

perl prog.pl  462.44s user 0.42s system 92% cpu 8:18.36 total

Sieving: [206158430207, 412316860414]
Sieving: [412316860415, 824633720830]
Sieving: [824633720831, 1649267441662]
^C
perl prog.pl  13057.94s user 21.68s system 87% cpu 4:09:52.99 total
