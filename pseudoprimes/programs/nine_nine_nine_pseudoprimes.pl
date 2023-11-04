#!/usr/bin/perl

# Find new Fibonacci / Lucas pseudoprimes, by appending a run of 9's at the end of other pseudoprimes.

# Curious example:
#   430479503           # is a Fibonacci/Lucas pseudoprime
#   43047950399         # is a Fibonacci/Lucas pseudoprime
#   4304795039999       # is a Pell pseudoprime

# Also:
#   430479503     = 20747   * 20749
#   43047950399   = 207479  * 207481
#   4304795039999 = 2074799 * 2074801

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use Math::Prime::Util::GMP qw(is_prob_prime is_pseudoprime is_lucas_pseudoprime is_extra_strong_lucas_pseudoprime is_almost_extra_strong_lucas_pseudoprime);

sub is_fibonacci_pseudoprime ($n) {
    Math::Prime::Util::GMP::lucasumod(1, -1, Math::Prime::Util::GMP::subint($n, kronecker($n, 5)), $n) eq '0';
}

sub is_lucas_carmichael ($n) {
    my $t = Math::GMPz->new($n) + 1;
    vecall { $t % ($_ + 1) == 0 } factor($n);
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    #next if ($n <= 6479);
    #next if ($n > ((~0)>>1));

#<<<
    #~ while (substr($n, -1) eq '9') {
        #~ chop $n;
        #~ $n eq '' and last;
        #~ (substr($n, -1) & 1) || last;
        #~ is_prob_prime($n) && next;
        #~ if (is_lucas_pseudoprime($n)) {
            #~ say $n;
        #~ }
        #~ elsif (is_fibonacci_pseudoprime($n)) {
            #~ say $n;
        #~ }
    #~ }
#>>>

    next if length($n) > 100;

    is_pseudoprime($n, 2) && next;

    if (   is_lucas_pseudoprime($n)
        or is_extra_strong_lucas_pseudoprime($n)
        or is_almost_extra_strong_lucas_pseudoprime($n)) {

        #if (1) {

        foreach my $k (1 .. 9) {
            my $t = $n . ('9' x $k);
            is_prob_prime($t) && next;
            if (   is_lucas_pseudoprime($t)
                or is_extra_strong_lucas_pseudoprime($t)
                or is_almost_extra_strong_lucas_pseudoprime($t)) {
                say $t;
            }

            #elsif (is_fibonacci_pseudoprime($t)) {
            #    say $t;
            #}
        }
    }
}
