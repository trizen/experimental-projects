#!/usr/bin/perl

# Numbers m such that both m and (m-1)/2 are Fermat pseudoprimes base 2 (A001567).
# https://oeis.org/A303448

# Numbers m such that both m and 2m+1 are Fermat pseudoprimes base 2 (A001567).
# https://oeis.org/A303447

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if length($n) > 100;

    if ($n > ((~0) >> 2)) {
        $n = Math::GMPz->new($n);
    }

    my $x = ($n << 1) + 1;
    my $y = ($n - 1) >> 1;

    if (is_pseudoprime($x, 2) and !is_prime($x) and is_pseudoprime($n, 2)) {
        say $n if !$seen{$n}++;
    }

    if (is_pseudoprime($y, 2) and !is_prime($y) and is_pseudoprime($n, 2)) {
        say $y if !$seen{$y}++;
    }
}

__END__
9890881
23456248059221
96076792050570581
1611901092819505566274901
27043212804868893898596335048021
127707961738824071529862252262525765301561593515300181
35946595556200853059556020116026174231516192563387429974804813665621
2470231237062745502369514346852008700869759672866998699508428458835480098985301
