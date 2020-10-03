#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 02 August 2020
# https://github.com/trizen

# Generate Fermat pseudoprimes, using primes of the form z*k + 1, for some small z and k.

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::AnyNum qw(is_smooth binomial);
use ntheory qw(forcomb forprimes kronecker divisors lucas_sequence powmod is_pseudoprime is_prime);
use Math::Prime::Util::GMP qw(vecprod);
use List::Util qw(uniq);

sub fermat_pseudoprimes {

    my %common_divisors;

    foreach my $n (1 .. 1e3) {

        my $z = 2 * $n;

        foreach my $k (1 .. 1e2) {

            my $p = $z * $k + 1;

            is_prime($p) || next;
            kronecker(5, $p) == -1 or next;
            is_smooth($p + 1, 1e4) || next;

            foreach my $d (divisors($p - 1)) {
                if ($d % $z == 0) {
                    push @{$common_divisors{$d}}, $p;
                }
            }
        }
    }

    foreach my $arr (values %common_divisors) {

        @$arr = uniq(@$arr);
        my $l = scalar(@$arr);

        foreach my $k (2 .. $l) {

            binomial($l, $k) < 1e5 or next;

            forcomb {
                my $n = vecprod(@{$arr}[@_]);
                if ($n > ~0 and is_pseudoprime($n, 2)) {
                    say $n;
                }
            } $l, $k;
        }
    }
}

fermat_pseudoprimes();

__END__
var table = Hash()

for n in (1..10, 2e3..1e4) {

    var z = 2*n

    for k in (1 .. 1e2) {
        if (z*k + 1 -> is_prime) {
            var p = (z*k + 1)
            #var z2 = znorder(2, p)

            kronecker(5, p) == -1 || next
            p.inc.is_smooth(1e4) || next

            for d in (divisors(p - 1)) {
                if (d % z == 0) {
                    table{d} := [] << p
                }
            }
        }
    }
}


        table.each_v { |a|

            a.uniq!
            var L = a.len
            L > 1 || next

            for k in (2..L) {

                next if (binomial(L,k) > 1e3)

                a.combinations(k, {|*t|
                    #var z = t.prod
                    with (t.prod) {|z|
                        if (z > 2**64) {
                            say z if z.is_pseudoprime
                        }
                    }
                })
            }
        }
