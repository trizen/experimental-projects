#!/usr/bin/perl

# Smallest number m such that the GCD of the x's that satisfy sigma(x)=m is n.
# https://oeis.org/A241625

# a(127) = 4096
# a(151) = 3465904

# a(14) > 1017189995

use utf8;
use 5.020;
use strict;
use warnings;

use integer;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

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
                    @factors{factor($D[-1] - 1)} = ();
                    [keys %factors];
                };
            }
        }

        foreach my $d (@D) {
            foreach my $p (@{$factor_cache{$d}}) {

                my $r = $d * ($p - 1) + 1;
                my $k = valuation($r, $p) - 1;
                next if ($k < 1);

                my $s = powint($p, $k + 1);
                next if ($r != $s);
                my $z = powint($p, $k);

                my $u   = $n / $d;
                my $arr = __SUB__->($u, $d);

                foreach my $v (@$arr) {
                    if ($v % $p != 0) {
                        push @R, $v * $z;
                    }
                }
            }
        }

        $cache{$key} = \@R;
      }
      ->($n, 3);

    uniq(@$results);
}

my %easy;
@easy{
    1,   2,   3,   4,   5,   7,   8,   9,   12,  13,  16,  25,  31,  80,  97,  18,  19,  22,  27,  29,  32,  36,
    37,  43,  45,  49,  50,  61,  64,  67,  72,  73,  81,  91,  98,  100, 101, 106, 109, 121, 128, 129, 133, 134,
    137, 146, 148, 149, 152, 157, 162, 163, 169, 171, 173, 192, 193, 197, 199, 200, 202, 211, 217, 218, 219
} = ();

my $count = 0;

foreach my $k (1017189995 .. 1e10) {

    say "Testing: $k" if (++$count % 10000 == 0);

    my $t = gcd(inverse_sigma($k));

    if ($t >= 14 and $t <= 219) {
        say "\na($t) = $k\n" if not exists $easy{$t};
        die "Found: $k" if ($t == 14 or $t == 15);
    }
}
