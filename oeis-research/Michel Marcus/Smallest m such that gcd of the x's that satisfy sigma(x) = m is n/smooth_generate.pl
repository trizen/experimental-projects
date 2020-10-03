#!/usr/bin/perl

# Smallest number m such that the GCD of the x's that satisfy sigma(x)=m is n.
# https://oeis.org/A241625

# Known terms:
#   1, 3, 4, 7, 6, 6187272, 8, 15, 13, 196602, 8105688, 28, 14

# Upper-bounds for a(144):
#   a(144) <= {5334186182, 6653667020, 15812165226, 26999284026, 28752564542, 31717503246, 51526204158, 68240139110, 71641633206, 73884376566, 320692161764, 404350986572, 724592550812, 921030858722, 1138698021812, 7340065485194, 10562405788532, 405101345685452, 1058995989058904, 1293672253540082, 1991013491138282, 2643933035123354, 15645437418062582}

# Other upper-bounds:
#   a(127) <= {4096, 1000153088, 1006583808}

# Lower-bound for a(13):
#   a(13) > 1005756000

# Upper-bounds for larger terms:
# a(1444)     <= 2667
# a(4096)     <= 8191
# a(36100)    <= 82677
# a(94633984) <= 199753347

use 5.014;
use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use ntheory qw(:all);
use Memoize qw(memoize);
use List::Util qw(uniq);
use experimental qw(signatures);

memoize('max_power');

my @smooth_primes;

sub is_smooth_for_e {
    my ($p, $e) = @_;
    is_smooth(Math::GMPz->new($p)**($e - 1), 7)
      and is_smooth(Math::GMPz->new($p)**($e + 1) - 1, 7);
}

sub p_is_smooth {
    my ($p) = @_;
    vecany {
        is_smooth_for_e($p, $_);
    }
    1 .. 20;
}

sub max_power {
    my ($p) = @_;

    for (my $e = 20 ; $e >= 1 ; --$e) {
        if (is_smooth_for_e($p, $e)) {
            return $e;
        }
    }
}

forprimes {
    if ($_ == 2) {
        push @smooth_primes, $_;
    }
    else {
        if (p_is_smooth($_)) {
            push @smooth_primes, $_;
        }
    }
} 4801;

say "@smooth_primes";

push @smooth_primes, (2, 13, 23, 29, 31, 41, 83, 127, 269, 1153);
push @smooth_primes, (2, 3, 7, 11, 13, 31, 71, 151, 1009, 2833);

@smooth_primes = uniq(@smooth_primes);
@smooth_primes = sort { $a <=> $b } @smooth_primes;

foreach my $p (@smooth_primes) {
    say "a($p) = ", max_power($p);
}

sub check_valuation ($n, $p) {
    $n % ($p * $p) != 0;
}

sub hamming_numbers ($limit, $primes) {

    my @h = (1);
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

sub isok {
    my ($n) = @_;
    my $t = Math::GMPz->new(divisor_sum($n)) * Math::GMPz->new(euler_phi($n));
    is_power($t);
}

#use 5.016;
#use Math::AnyNum qw(:overload);
#die join ' ', inverse_sigma(19594645850);

my $h = hamming_numbers(1e12, \@smooth_primes);

say "Found: ", scalar(@$h), " terms";

my %table;

use utf8;
use 5.020;
use strict;
use warnings;

use integer;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

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

                #~ if (@$arr == 1 and is_prime($arr->[0])) {
                    #~ return [];
                #~ }

                #~ if (@$arr > 1) {
                    #~ my $g = gcd(@$arr);
                    #~ return ($cache{$key} = []) if ($g < 14);
                #~ }

                foreach my $v (@$arr) {
                    if ($v % $p != 0) {
                        push @R, $v * $z;

                        #~ if (uniq(@R) > 1) {
                            #~ my $g = gcd(@R);
                            #~ return ($cache{$key} = []) if ($g < 14);
                        #~ }
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

@$h = sort { $a <=> $b } @$h;

#~ foreach my $n(@$h) {
    #~ if ($n == 5334186182) {
        #~ say "OK";
        #~ last;
    #~ }
#~ }

#~ say gcd(inverse_sigma(5334186182));
#~ exit;

foreach my $k (@$h) {
    say "Testing: $k" if (++$count % 1000 == 0);

    $k > 1e9 or next;

    my $t = gcd(inverse_sigma($k));

    if ($t >= 14 and $t <= 200) {
        say "\na($t) = $k\n" if not exists $easy{$t};
        if ($t == 14 or $t == 15) {
            say "Found: a($t) = $k";
        }
    }
}
