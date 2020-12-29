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

        foreach my $f (divisors(divint($n, $d))) {
            if (exists $r{$f}) {
                push @{$temp{mulint($f, $d)}}, map { mulint($D, $_) }
                  grep { gcd($D, $_) == 1 } @{$r{$f}};
            }
        }

        while (my ($key, $value) = each(%temp)) {
            push @{$r{$key}}, @$value;
        }
    }

    return if not exists $r{$n};
    return sort { $a <=> $b } @{$r{$n}};
}

sub usigma {
    vecprod(map { powint($_->[0], $_->[1]) + 1 } factor_exp($_[0]));
}

my $count = 0;

forprimes {

    my $p = 2*$_ + 1;

if (is_prime($p)) {
    foreach my $k (inverse_usigma($p + 1)) {

        #~ is_smooth($n, 20) || next;
        #~ $n >= 1e7 or next;

        next if ($p == $k);

        my $m = mulint($p, $k);
        my $o = prime_omega($k) + 1;

        if (++$count >= 100000) {
            say "Testing: $p -> $k -> $m";
            $count = 0;
        }

        if (modint(mulint($m, ((1 << $o) - 1)), mulint(usigma($k), $p+1) - 1) == 0) {
            say "\tFound: $k -> $m";
        }
    }
}
} 5685054143, 1e10;


# Testing: 2561440319 -> 1207145418 -> 3092030944561308342
# Testing: 11370108287 -> 9939743093 -> 113015955312370311691

# From: 257223167
# From: 3488210431

__END__
Found: 12 -> 228
Found: 35 -> 1645
Found: 75 -> 7725
Found: 231 -> 88473
Found: 108558 -> 20295895122
Found: 120620 -> 22550994580
