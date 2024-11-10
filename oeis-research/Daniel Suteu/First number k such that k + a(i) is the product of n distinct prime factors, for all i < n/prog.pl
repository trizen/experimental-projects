#!/usr/bin/perl

# a(n) is the first number k such that k + a(i) is the product of n distinct prime factors, for all i < n; a(0) = 0.
# https://oeis.org/A??????

# Known terms:
#   0, 2, 33, 1309, 55165, 13386021, 2239003921

# Lower-bounds:
#   a(7) > 1649267441663, if it exists.

use 5.036;
use ntheory qw(:all);

my @terms = (0, 2, 33, 1309, 55165, 13386021, 2239003921);

sub squarefree_almost_prime_numbers ($A, $B, $k, $callback) {

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
                    and is_square_free($v + $terms[-1])
                    and is_square_free($v + $terms[-2])
                    and is_square_free($v + $terms[-3])
                    and vecall { is_almost_prime($n, $v + $_) and is_square_free($v + $_) } @terms) {
                    $callback->($v);
                    $B = $v if ($v < $B);
                    lastfor;
                }

            } vecmax($p, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {
            __SUB__->($m * $q, $q+1, $k - 1);
        }
      }
      ->(1, 2, $k);
}

my $n  = 7;
my $lo = 2;
my $hi = 2 * $lo;

say "\n:: Searching for a($n)\n";

while (1) {

    say "Sieving: [$lo, $hi]";

    my @terms;
    squarefree_almost_prime_numbers(
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

Sieving: [805306367, 1610612734]
Sieving: [1610612735, 3221225470]
Found upper-bound: a(6) <= 2239003921
New term: a(6) = 2239003921

perl prog.pl  28.40s user 0.04s system 92% cpu 30.751 total

Sieving: [824633720831, 1649267441662]
Sieving: [1649267441663, 3298534883326]
^C
perl prog.pl  6250.60s user 14.21s system 84% cpu 2:03:41.07 total
