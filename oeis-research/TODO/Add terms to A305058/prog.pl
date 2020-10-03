#!/usr/bin/perl
use strict;
use 5.014;
use ntheory qw(:all);

my $k = 1;
#foreach my $n(1..10**6) {
for (my $n=1; ;++$n) {
    if (inverse_totient($n) == divisor_sum($n, 0)) {
        #say $n;
        say "$k $n";
       # ++$k;
        last if $k == 1811;
        ++$k;
    }
}

__END__
for n in (1..100000) {
    if (inverse_euler_phi(n).len == n.sigma0) {
        say n
    }
}
