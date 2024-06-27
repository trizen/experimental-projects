#!/usr/bin/perl

# Let k = A000396(n) be the n-th perfect number, a(n) is the least number m such that k*d*m - 1 is prime for all of the proper divisors d of k so their product is a Lucas-Carmichael number.

# Lucas-Carmichael version of:
#   https://oeis.org/A319008

# Known terms:
#   1, 219, 10405375365

# Inspired by the PARI program by David A. Corneth from OEIS A372238.

# See also:
#   https://oeis.org/A372238/a372238.gp.txt

# Lower-bounds:
#   a(4) > 1116642267975

use 5.036;
use ntheory     qw(:all);
use Time::HiRes qw (time);
use List::Util  qw(all any);

my $PERFECT_N;
my @DIVISORS;

sub isrem($m, $p, $n) {
    vecall { (vecprod($PERFECT_N, $m, $_) - 1) % $p != 0 } @DIVISORS;
}

sub remaindersmodp($p, $n) {
    grep { isrem($_, $p, $n) } (0 .. $p - 1);
}

sub remainders_for_primes($n, $primes) {

    my $res = [[0, 1]];

    foreach my $p (@$primes) {

        my @rems = remaindersmodp($p, $n);

        my @nres;
        foreach my $r (@$res) {
            foreach my $rem (@rems) {
                push @nres, [chinese($r, [$rem, $p]), lcm($p, $r->[1])];
            }
        }
        $res = \@nres;
    }

    sort { $a <=> $b } map { $_->[0] } @$res;
}

sub deltas ($integers) {

    my @deltas;
    my $prev = 0;

    foreach my $n (@$integers) {
        push @deltas, $n - $prev;
        $prev = $n;
    }

    return \@deltas;
}

sub generate($n) {

    my $maxp = 11;

    $maxp = 23 if ($n >= 3);
    $maxp = 29 if ($n >= 4);

    my @primes = @{primes($maxp)};

    my @r = remainders_for_primes($n, \@primes);
    my @d = @{deltas(\@r)};
    my $s = vecprod(@primes);

    while ($d[0] == 0) {
        shift @d;
    }

    push @d, $r[0] + $s - $r[-1];

    my $m      = $r[0];
    my $d_len  = scalar(@d);
    my $t0     = time;
    my $prev_m = $m;

    for (my $j = 0 ; ; ++$j) {

        if (vecall { is_prime(vecprod($m, $PERFECT_N, $_) - 1) } @DIVISORS) {
            return $m;
        }

        if ($j % 1e7 == 0 and $j > 0) {
            my $tdelta = time - $t0;
            say "[$j] Searching for a($n) with m = $m";
            say "Performance: ", (($m - $prev_m) / 1e9) / $tdelta, " * 10^9 terms per second";
            $t0     = time;
            $prev_m = $m;
        }

        $m += $d[$j % $d_len];
    }
}

my @perfect_numbers = (6, 28, 496, 8128, 33550336, 8589869056, 137438691328, 2305843008139952128);

foreach my $n (1 .. $#perfect_numbers) {

    $PERFECT_N = $perfect_numbers[$n - 1];
    @DIVISORS  = grep { $_ < $PERFECT_N } divisors($PERFECT_N);

    say "a($n) = ", generate($n);
}

__END__
a(1) = 4
a(2) = 219
a(3) = 10405375365
Searching for a(4) with m = 32842303065
Performance: 1.5614861010746 * 10^9 terms per second
Searching for a(4) with m = 65684651175
Performance: 1.56154555876966 * 10^9 terms per second
Searching for a(4) with m = 98527241490
Performance: 1.5464539801719 * 10^9 terms per second
