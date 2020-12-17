#!/usr/bin/perl

# Numbers that are not powers of primes (A024619) whose harmonic mean of their proper unitary divisors is an integer.
# https://oeis.org/A335270

# Known terms:
#   228, 1645, 7725, 88473, 20295895122, 22550994580

# Conjecture: all terms have the form n*(usigma(n)-1) where usigma(n)-1 is prime.
# The conjecture was inspired by the similar conjecture of Chai Wah Wu from A247077.

use utf8;
use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);

sub inverse_usigma ($n) {

    my %r = (1 => [1]);

    foreach my $d (divisors($n)) {

        my $D = subint($d, 1);
        is_prime_power($D) || next;

        my %temp;
        foreach my $k (1 .. valuation($n, $D) + 1) {

            my $v = powint($D, $k);
            my $u = addint($v, 1);

            modint($n, $u) == 0 or next;

            foreach my $f (divisors(divint($n, $u))) {
                if (exists $r{$f}) {
                    push @{$temp{mulint($f, $u)}}, map { mulint($v, $_) }
                      grep { gcd($v, $_) == 1 } @{$r{$f}};
                }
            }
        }

        while (my ($i, $v) = each(%temp)) {
            push @{$r{$i}}, @$v;
        }
    }

    return if not exists $r{$n};
    return sort { $a <=> $b } uniq(@{$r{$n}});
}

sub usigma {
    vecprod(map { powint($_->[0], $_->[1]) + 1 } factor_exp($_[0]));
}

my $count = 0;

forprimes {

    my $p = $_;

    foreach my $k (inverse_usigma($p + 1)) {

        #~ is_smooth($n, 20) || next;
        #~ $n >= 1e7 or next;

        next if ($p == $k);

        my $m = mulint($p, $k);
        my $o = prime_omega($k) + 1;

        if (++$count >= 100000) {
            say "Testing: $k -> $m";
            $count = 0;
        }

        if (modint(mulint($m, ((1 << $o) - 1)), mulint(usigma($k), $p+1) - 1) == 0) {
            say "\tFound: $k -> $m";
        }
    }
} 1, 1e10;

__END__
Found: 12 -> 228
Found: 35 -> 1645
Found: 75 -> 7725
Found: 231 -> 88473
Found: 108558 -> 20295895122
Found: 120620 -> 22550994580
