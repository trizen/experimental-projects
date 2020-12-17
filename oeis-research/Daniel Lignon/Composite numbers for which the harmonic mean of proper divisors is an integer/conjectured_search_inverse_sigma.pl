#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

# These are numbers n such that sigma(n)-1 divides n*(tau(n)-1).

# Conjecture: all terms are of the form n*(sigma(n)-1) where sigma(n)-1 is prime. - Chai Wah Wu, Dec 15 2020

# If the above conjecture is true, then a(4) > 10^14.

# This program assumes that the above conjecture is true.

# New term:
#   3662109375 -> 22351741783447265625

use utf8;
use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);

sub inverse_sigma {
    my ($n) = @_;

    my %cache;
    my %factor_cache;
    my %divisor_cache;

    my $results = sub ($n, $m) {

        return [1] if ($n == 1);

        my $key = "$n $m";
        if (exists $cache{$key}) {
            return $cache{$key};
        }

        my (@R, @D);
        $divisor_cache{$n} //= [divisors($n)];

        foreach my $d (@{$divisor_cache{$n}}) {
            if ($d >= $m) {

                push @D, $d;

                $factor_cache{$d} //= do {
                    my %factors;
                    @factors{factor(subint($D[-1], 1))} = ();
                    [keys %factors];
                };
            }
        }

        foreach my $d (@D) {
            foreach my $p (@{$factor_cache{$d}}) {

                my $r = addint(mulint($d, subint($p, 1)), 1);
                my $k = valuation($r, $p) - 1;
                next if ($k < 1);

                my $s = powint($p, $k + 1);
                next if ("$r" ne "$s");
                my $z = powint($p, $k);

                my $u   = divint($n, $d);
                my $arr = __SUB__->($u, $d);

                foreach my $v (@$arr) {
                    if (modint($v, $p) != 0) {
                        push @R, mulint($v, $z);
                    }
                }
            }
        }

        $cache{$key} = \@R;
      }
      ->($n, 3);

    uniq(@$results);
}

my $count = 0;

forprimes {

    my $p = $_;

    foreach my $n (inverse_sigma($p + 1)) {

        #~ is_smooth($n, 20) || next;
        #~ $n >= 1e7 or next;

        next if ($p == $n);

        my $m = mulint($p, $n);

        if (++$count >= 10000) {
            say "Testing: $n -> $m";
            $count = 0;
        }

        if (modint(mulint($m, divisor_sum($m, 0) - 1), mulint(divisor_sum($n), ($p+1)) - 1) == 0) {
            say "\tFound: $p -> $m";
        }
    }
} 1, 1e10;
