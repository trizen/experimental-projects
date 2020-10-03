#!/usr/bin/perl

# Numbers that are the sum of m = 5 successive primes and also the product of m = 5 (other) successive primes.
# https://oeis.org/A323052

use 5.014;
use strict;
use warnings;

use IO::File;
use Math::GMPz;
use Math::Prime::Util::GMP qw(vecprod vecsum);
use ntheory qw(forprimes next_prime prev_prime is_prime);

open my $fh, '>', 'b.txt';

$fh->autoflush(1);

sub is_sum {
    my ($n) = @_;

    my $k = prev_prime(($n / 5) + 1);

    while (1) {

        my $p     = $k;
        my @terms = $p;

        foreach my $i (1 .. 4) {
            $p = next_prime($p);
            push @terms, $p;
        }

        my $r = Math::GMPz->new(vecsum(@terms));

        if ($r < $n) {
            return 0;
        }

        if ($r == $n) {
            return 1;
        }

        $k = prev_prime($k);
    }
}

my $k = 1;

forprimes {
    my $p      = $_;
    my @factor = ($p);

    foreach my $i (1 .. 4) {
        $p = next_prime($p);
        push @factor, $p;
    }

    my $n = Math::GMPz->new(vecprod(@factor));

    if (is_sum($n)) {
        say $fh "$k $n";
        say "$k $n";
        ++$k;
    }

    if ($k > 10_000) {
        exit;
    }
} 1e9;
