#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

use ntheory qw(factor is_prime);

#use Math::GMPz;
use Math::AnyNum qw(ipow);

while (<>) {
    /^#/ and next;
    my ($n, $p) = split(' ');
    $n < 111 and next;
    $p = Math::AnyNum->new($p);
    say "Checking a($n)";
    is_prime($p) || die "error: a($n) = $p";
    (ipow($n, $n) + ipow($n+1, $n+1)) % $p == 0 or die "error a($n) = $p -- not a divisor";

    my $rem =  (ipow($n, $n) + ipow($n+1, $n+1)) / $p;

    my @f = factor($rem);
    say "@f";
    $f[-1] <= $p or die "error for a($n) = $p";
}

say "** Test passed!"
