#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 08 July 2019
# https://github.com/trizen

use 5.010;
use strict;
use warnings;

use ntheory qw(:all);
no warnings qw(recursion);
use experimental qw(signatures);
use Math::GMPz;

#use Math::AnyNum qw(:overload);

my %bounds;
prime_precalc(1e6);

my @primes = @{primes(10000)};

sub f($n) {

    my $count = -1;

    while (is_semiprime($n) && !is_square($n)) {
        my ($x, $y) = factor($n);
        $n = ($y - $x);
        ++$count;
    }

    $count;
}

sub change ($t, $pos) {

    # (is_semiprime($t) and !is_square($t)) || return;

    my $count = f($t);

    if ($count > 40) {
        return;
    }

    if (exists($bounds{$count})) {
        if ($t < $bounds{$count}) {
            say "a($count) <= $t";
            $bounds{$count} = $t;
        }
    }
    elsif ($count > 0) {
        say "a($count) <= $t";
        $bounds{$count} = $t;
    }

    if ($pos > $#primes) {
        return;
    }

    my $w = $primes[$pos] * ($t + $primes[$pos]);

    if (is_semiprime($w) and !is_square($w)) {
        change($w, 0);
    }

    change($t, $pos + 1);
}

foreach my $n (Math::GMPz->new("25319195035106666")) {
    say "Trying: $n";
    change(Math::GMPz->new($n), 0);
}
