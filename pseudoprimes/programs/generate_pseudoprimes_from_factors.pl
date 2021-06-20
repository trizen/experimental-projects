#!/usr/bin/perl

# Generate pseudoprimes using the prime factors of other pseudoprimes.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

warn ":: Sieving primes...\n";

my @list;
my %seen;

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    push @list, grep { !$seen{$_}++ } grep {

              #length($_) < 30
            ($_ > 1e8) and  ($_ < 1e15)
          #and modint($_, 8) == 3
          #and modint($_, 8) == 1
          and kronecker(5, $_) == -1
          #and is_square_free(subint($_, 1) >> 1)
          #and is_square_free(addint($_, 1) >> 2)
          #and (vecall { modint($_, 4) == 1 } factor(subint($_, 1) >> 1))
          #and (vecall { modint($_, 4) == 3 } factor(addint($_, 1) >> 2))

    } @factors;

    last if (@list > 2e6);
}

dbmclose(%db);

warn ":: Found ", scalar(@list), " primes...\n";
warn ":: Generating fibonacci pseudoprimes...\n";

sub fibonacci_pseudoprimes ($list, $callback) {

    my %common_divisors;

    foreach my $p (@$list) {

        my $k = kronecker(5, $p);

        #if ($k == -1) {
        if (1) {

            foreach my $d (divisors(subint($p, $k))) {

                if ((lucas_sequence($p, 1, -1, $d))[0] == 0) {
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
            } $l, $k;
        }
    }
}

sub is_fibonacci_pseudoprime ($n) {
    (Math::Prime::Util::GMP::lucas_sequence($n, 1, -1, $n))[0] eq Math::Prime::Util::GMP::subint($n, 1);
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
