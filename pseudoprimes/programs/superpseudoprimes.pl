#!/usr/bin/perl

# a(n) is the smallest super-pseudoprime to all bases <= prime(n).

# Except for a(19) (and possibly other temrs), this sequence is similar with:
# https://oeis.org/A285549

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::Prime::Util::GMP;
use experimental qw(signatures);

sub is_super_pseudoprime ($n, @bases) {

    Math::Prime::Util::GMP::is_pseudoprime($n, @bases) || return 0;

    my @factors = factor($n);
    foreach my $base (@bases) {
        powmod($base, gcd(map { $_ - 1 } @factors), $n) == 1
          or return 0;
    }

    return 1;
}

my @terms;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n > ~0;

    #next if (length($n) > 40);

    if (is_pseudoprime($n, 2)) {

        if ($n > ~0) {
            $n = Math::GMPz->new($n);
        }

        push @terms, $n;
    }
}

@terms = sort { $a <=> $b } @terms;

my $p     = 2;
my @bases = ($p);

foreach my $n (@terms) {
    while (is_super_pseudoprime($n, @bases)) {
        say "a(", scalar(@bases), ") <= $n";
        $p = next_prime($p);
        unshift @bases, $p;
    }
}

__END__
a(1) <= 341
a(2) <= 2701
a(3) <= 721801
a(4) <= 721801
a(5) <= 42702661
a(6) <= 1112103541
a(7) <= 2380603501
a(8) <= 5202153001
a(9) <= 17231383261
a(10) <= 251994268081
a(11) <= 1729579597021
a(12) <= 55181730338101
a(13) <= 142621888086541
a(14) <= 242017633321201
a(15) <= 242017633321201
a(16) <= 242017633321201
a(17) <= 1174858593838021
a(18) <= 1174858593838021
a(19) <= 790489610041255741
a(20) <= 790489610041255741
a(21) <= 790489610041255741
a(22) <= 790489610041255741
