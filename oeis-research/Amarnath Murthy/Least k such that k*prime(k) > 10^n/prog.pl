#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 26 February 2019
# https://github.com/trizen

# Given a positive integer n, find the smallest integer `k` such that `k*prime(k) > 10^n`.

# See also:
#   https://oeis.org/A090977 -- Least k such that k*prime(k) > 10^n.

use 5.010;
use strict;
use warnings;

use Math::Sidef;
use Math::AnyNum qw(:overload min max bsearch_ge);
use ntheory qw(nth_prime_lower nth_prime_upper next_prime prev_prime);

sub nth_prime {
    my ($n) = @_;
    chomp(my $p = `../../primecount -n $n`);
    Math::AnyNum->new($p);
}

sub a {
    my ($n) = @_;

    no warnings 'exiting';

    my $lim = 10**$n;

    my $min_approx = int(sqrt($lim / log($lim+1)));
    my $max_approx = 2*$min_approx;

    my $min = bsearch_ge($min_approx, $max_approx, sub {
        Math::Sidef::nth_prime_upper($_) * $_ <=> $lim
    });

    my $max = bsearch_ge($min, $max_approx, sub {
        Math::Sidef::nth_prime_lower($_) * $_ <=> $lim
    });

    my @checkpoint;

    my $exact = bsearch_ge($min, $max, sub {
        my $p = nth_prime($_);
        say "p($_) = $p";
        $p * $_ <=> $lim;
    });

    return $exact if !@checkpoint;

    my $p = $checkpoint[0];
    my $k = $checkpoint[1];

    if ($p*$k > $lim) {
        #say "prev branch";
        while ($p * $k > $lim){
            $p = prev_prime($p);
            --$k;
        }
        ++$k;
    }
    elsif ($p*$k < $lim) {
        #say "next branch";
        while ($p *$k < $lim){
            $p = next_prime($p);
            ++$k;
        }
    }

    #say "@checkpoint";

    #~ if ($k > $prev) {

        #~ while ($p * $k > $lim){
            #~ $p = prev_prime($p);
            #~ --$k;
        #~ }

        #~ ++$k;
    #~ }
    #~ else {

        #~ while ($p *$k < $lim){
            #~ $p = next_prime($p);
            #~ ++$k;
        #~ }

    #~ }

    #while ($p * $k < $lim) {
    #    say "Checking $k";
    #    $p = next_prime($p);
    #    ++$k;
    #}

    return $k;

    #say $prev;
    #say @checkpoint[1];
}

foreach my $n(1..22) {
    say "a($n) = ", a($n);
}

__END__
a(0) = 1
a(1) = 3
a(2) = 7
a(3) = 17
a(4) = 48
a(5) = 134
a(6) = 382
a(7) = 1115
a(8) = 3287
a(9) = 9786
a(10) = 29296
a(11) = 88181
a(12) = 266694
a(13) = 809599
a(14) = 2465574
a(15) = 7528976
a(16) = 23045352
a(17) = 70684657
a(18) = 217196605
a(19) = 668461874
a(20) = 2060257099
a(21) = 6358076827
a(22) = 19644205359
