#!/usr/bin/perl

# Generate pseudoprimes using the prime factors of other pseudoprimes.

use 5.020;
use strict;
use warnings;

use Storable;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";

#my $storable_file = "cache/factors-superpsp.storable";
#my $storable_file = "cache/factors-fermat.storable";

#my $storable_file = "cache/factors-lucas-carmichael.storable";
my $carmichael = retrieve($storable_file);

warn ":: Sieving primes...\n";

my @list;
my %seen;

while (my ($n, $value) = each %$carmichael) {

    my $len = length($n);

    # next if $len > 100;

    my @factors = split(' ', $value);

    push @list, grep { !$seen{$_}++ } grep {

              length($_) < 40
          and modint($_, 8) == 3
          and kronecker(5, $_) == -1

          #and is_square_free(subint($_, 1) >> 1)
          #and is_square_free(addint($_, 1) >> 2)
          #and (vecall { modint($_, 4) == 1 } factor(subint($_, 1) >> 1))
          #and (vecall { modint($_, 4) == 3 } factor(addint($_, 1) >> 2))

    } @factors;

    last if (@list > 1e6);
}

warn ":: Found ", scalar(@list), " primes...\n";
warn ":: Generating fibonacci pseudoprimes...\n";

sub fibonacci_pseudoprimes ($list, $callback) {

    my %common_divisors;

    foreach my $p (@$list) {

        my $k = kronecker(5, $p);

        if (1) {

            foreach my $d (divisors(subint($p, $k))) {

                if (lucasumod(1, -1, $d, $p) == 0) {
                    push @{$common_divisors{$d}}, $p;
                }

                #if (($k == 1) ? (powmod(5, $d, $p) == 1) : (powmod(5, $d, $p) == $d-1)) {
                #    push @{$common_divisors{$d}}, $p;
                #}
            }
        }
    }

    foreach my $arr (values %common_divisors) {

        my $l = $#{$arr} + 1;

        for (my $k = 3 ; $k <= $l ; $k += 2) {
            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);
                $callback->($n);
            }
            $l, $k;
        }
    }
}

sub is_fibonacci_pseudoprime ($n) {
    Math::Prime::Util::GMP::lucasumod(1, -1, $n, $n) eq Math::Prime::Util::GMP::subint($n, 1);
}

fibonacci_pseudoprimes(
    \@list,
    sub ($n) {

        if (is_fibonacci_pseudoprime($n)) {

            say $n;
            warn "Fib: $n\n";

            if (is_euler_pseudoprime($n, 5)) {
                die "Found counter-example: $n";
            }

            if (kronecker(5, $n) == -1) {
                if (is_pseudoprime($n, 2)) {
                    die "Found a special pseudoprime: $n";
                }
            }
        }
    }
);
