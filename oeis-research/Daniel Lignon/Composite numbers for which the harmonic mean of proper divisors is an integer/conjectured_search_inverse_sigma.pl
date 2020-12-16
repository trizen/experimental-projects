#!/usr/bin/perl

# Composite numbers for which the harmonic mean of proper divisors is an integer.
# https://oeis.org/A247077

# Known terms:
#   1645, 88473, 63626653506

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
use Math::AnyNum qw(sum);
use List::Util qw(uniq);
use experimental qw(signatures);

binmode(STDOUT, ':utf8');

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

my @mpq;
my $count = 0;

my $FROM = 8e7;
my $TO   = 1e9;

#~ $FROM = 1;
#~ $TO = 1e4;

#use Math::AnyNum qw(:overload);

#foreach my $k ($FROM .. $TO) {

foreach my $x (2 .. 30) {
    foreach my $y (2 .. 30) {

        foreach my $k (grep { $_ < 1e14 } map { mulint(powint($x, $_), $y) } 1 .. 50) {

            # say "Trying: $k";

            foreach my $n (inverse_sigma(divisor_sum($k))) {

                is_smooth($n, 100) || next;

                # $n >= $FROM or next;

                my $u = divisor_sum($n) - 1;

                is_prime($u) || next;

                my $t = mulint($u, $n);
                my @d = divisors($t);

                if (++$count >= 1000) {
                    say "Testing: $n -> $t";
                    $count = 0;
                }

                pop @d;

                foreach my $i (0 .. $#d) {
                    Math::GMPq::Rmpq_set_ui(($mpq[$i] //= Math::GMPq::Rmpq_init()), 1, $d[$i]);
                }

                my $h = sum(@mpq[0 .. $#d]);

                if (Math::GMPq::Rmpq_integer_p(scalar(@d) / $$h)) {
                    say "\nFound: $n -> $t\n";

                    #die "NEW TERM: $n -> $t\n" if ($t > 63626653506);
                }
            }
        }
    }
}
