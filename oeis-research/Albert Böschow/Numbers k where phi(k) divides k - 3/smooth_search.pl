#!/usr/bin/perl

# Numbers k where phi(k) divides k - 3.
# https://oeis.org/A350777

# Known terms:
#   1, 2, 3, 9, 195, 5187

# Conjecture: 5187 is the largest term in this sequence.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 1000;
    }

    if ($p == 3) {
        return valuation($n, $p) < 1000;
    }

    if ($p == 5) {
        return valuation($n, $p) < 100;
    }

    if ($p == 7) {
        return valuation($n, $p) < 100;
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

my $h = smooth_numbers(Math::GMPz->new(10)**30, [2,3,5]);
#my $h = smooth_numbers(~0, [2,3,5,7]);

say "\nFound: ", scalar(@$h), " terms";

my $multiple = 2;
say "Searching with multiple = $multiple";

foreach my $n (sort {$a <=> $b} @$h) {

    #~ foreach my $k (inverse_totient($n)) {
        #~ if (($k-3) % $n == 0) {
            #~ say $k;
        #~ }
    #~ }

    my $v = addint(mulint($multiple, $n), 3);

    if (euler_phi($v) == $n) {
        say $v;
    }
}
