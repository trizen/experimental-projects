#!/usr/bin/perl

# a(n) is the least k such that k^2 + 1 is a semiprime p*q, p < q, and (q - p)/2^n is prime.
# https://oeis.org/A258780

use 5.014;
use ntheory qw(:all);

sub f {
    my ($n) = @_;

    my $pow = powint(2, $n);
    my $ret;

    my $from = 1;
    my $to   = 1e7;
    my $step = 1e7;

    my %seen;

    while (1) {

        forsemiprimes {
            if (is_square($_ - 1) and !is_square($_)) {

                my @f = factor($_);

                #if (modint($f[1]-$f[0], $pow) == 0 and is_prime(divint($f[1]-$f[0], $pow))) {

                my $v = valuation($f[1] - $f[0], 2);

                if (not exists $seen{$v} and is_prime(divint($f[1] - $f[0], powint(2, $v)))) {
                    $seen{$v} = 1;
                    say "a($v) = ", sqrtint($_ - 1);

                    #$ret = sqrtint($_-1);
                    #lastfor;
                }
            }
        }
        $from, $to;

        $from += $step;
        $to   += $step;

        last if defined($ret);

    }

    $ret;
}

foreach my $n (2 .. 100) {
    say "a($n) = ", f($n);
}
