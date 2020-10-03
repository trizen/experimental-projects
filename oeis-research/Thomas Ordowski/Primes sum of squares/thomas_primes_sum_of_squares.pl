#!/usr/bin/perl

use 5.014;
use ntheory qw(is_prob_prime);
use Math::AnyNum qw(ipow);

# Test up to 145

foreach my $k(145..1000) {
    #foreach my $y($x+1..1000) {
    #    if ($x
    #}
    if (is_prob_prime($k*$k + ($k-1)*($k-1))) {
        my $p = $k*$k + ($k-1)*($k-1);

        say "Testing: $k";

        #next if $p <= 19801;

        #if (k^p - (k-1)^p
        if (is_prob_prime(ipow($k, $p) - ipow($k-1, $p))) {
            die "Found: $p\n";
        }
    }
}
