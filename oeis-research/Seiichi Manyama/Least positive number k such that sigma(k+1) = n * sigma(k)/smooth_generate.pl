#!/usr/bin/perl

# Least positive number k such that sigma(k+1) = n * sigma(k).
# https://oeis.org/A340715

# Known terms:
#   14, 5, 1, 37033919, 14182439039

# Related sequences:
#   https://oeis.org/A340713 -- Numbers k such that sigma(k+1) = 4 * sigma(k).
#   https://oeis.org/A058072 -- Numbers n such that sigma(n) divides sigma(n+1), where sigma(n) is sum of positive divisors of n.

use 5.020;
use warnings;

#~ a(4) <= 606523679 for n = 627056640 -> 2^13 * 3^7 * 5^1 * 7^1
#~ a(4) <= 606523679 for n = 2508226560 -> 2^15 * 3^7 * 5^1 * 7^1
#~ a(4) <= 14952625379 for n = 15240960000 -> 2^11 * 3^5 * 5^4 * 7^2
#~ a(5) <= 14182439039 for n = 14182439040 -> 2^7 * 3^4 * 5^1 * 7^1 * 11^2 * 17^1 * 19^1
#~ a(5) <= 14182439039 for n = 70912195200 -> 2^7 * 3^4 * 5^2 * 7^1 * 11^2 * 17^1 * 19^1

#~ 1379454719 4
#~ 14182439039 5
#~ 43861478399 4
#~ 51001180159 3
#~ 153003540479 4
#~ 403031236607 4
#~ 518666803199 5
#~ 275502900594021407 4

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(uniq);

my %valuation = (
    "11" => 2,
    "113" => 1,
    "13" => 2,
    "17" => 1,
    "19" => 2,
    "199" => 1,
    "2" => 15,
    "23" => 1,
    "29" => 1,
    "3" => 7,
    "31" => 2,
    "37" => 1,
    "43" => 1,
    "5" => 4,
    "61" => 1,
    "67" => 1,
    "7" => 3
);

%valuation = (
    2 => 7,
    3 => 4,
    5 => 2,
    7 => 1,
    11 => 2,
    17 => 1,
    19 => 1,
);

sub check_valuation ($n, $p) {

    if (exists $valuation{$p}) {
        return valuation($n, $p) < $valuation{$p};
    }

    #~ if ($p == 2) {
        #~ return valuation($n, $p) < 15;
    #~ }

    #~ if ($p == 3) {
        #~ return valuation($n, $p) < 8;
    #~ }

    #~ if ($p == 5) {
        #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 2;
    #~ }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

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

sub dynamicPreimage ($N, $L) {

    my %r = (1 => [1]);

    foreach my $l (@$L) {
        my %t;

        foreach my $pair (@$l) {
            my ($x, $y) = @$pair;

            foreach my $d (divisors(divint($N, $x))) {
                if (exists $r{$d}) {
                    push @{$t{mulint($x, $d)}}, map { mulint($_, $y) } @{$r{$d}};
                }
            }
        }
        while (my ($k, $v) = each %t) {
            push @{$r{$k}}, @$v;
        }
    }

    return if not exists $r{$N};
    return @{$r{$N}};
}

sub cook_sigma ($N, $k) {
    my %L;

    foreach my $d (divisors($N)) {

        next if ($d == 1);

        foreach my $p (map { $_->[0] } factor_exp(subint($d, 1))) {

            my $q = addint(mulint($d, subint(powint($p, $k), 1)), 1);
            my $t = valuation($q, $p);

            next if ($t <= $k or ($t % $k) or $q != powint($p, $t));

            push @{$L{$p}}, [$d, powint($p, subint(divint($t, $k), 1))];
        }
    }

    [values %L];
}

sub inverse_sigma ($N, $k = 1) {
    ($N == 1) ? (1) : dynamicPreimage($N, cook_sigma($N, $k));
}

sub isok ($n) {

      #~ if (modint(divisor_sum($n+1), divisor_sum($n)) == 0) {
          #~ return ($n, divint(divisor_sum($n+1), divisor_sum($n)));
      #~ }

    foreach my $k (inverse_sigma($n)) {

      if (modint($n, divisor_sum($k-1)) == 0) {
          return ($k-1, divint($n, divisor_sum($k-1)));
      }

      if (modint(divisor_sum($k+1), $n) == 0) {
          return ($k, divint(divisor_sum($k+1), $n));
      }

    }

    return (0, -1);
}

#~ say join ' ', isok(37033919);
#~ say join ' ' , isok(14182439039);

#~ say join ' ', isok(divisor_sum(37033919));
#~ say join ' ' , isok(divisor_sum(14182439039));

#~ say join ' ', isok(divisor_sum(37033919+1));
#~ say join ' ' , isok(divisor_sum(14182439039+1));

#~ foreach my $n(split/\s*,\s*/,"1379454719, 14182439039, 43861478399, 51001180159, 153003540479, 403031236607, 518666803199, 275502900594021407, 69357059049509038079, 1161492388333469337599, 1245087725796543283199, 34384125938411324962897919, 115131961034430181728489308159") {
    #~ say join(' ', isok(divisor_sum(addint($n, 1))));
#~ }

my @smooth_primes;

foreach my $p (@{primes(50)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    #if ($f1[-1] <= 7 and $f2[-1] <= 7) {
    if ($f2[-1] <= 11) {
        push @smooth_primes, $p;
    }
}

#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 59, 61, 67, 79, 89, 97, 103, 131, 149, 167, 307, 467, 503, 569, 659, 719, 811, 971, 1063, 1103, 1429, 1607, 1997, 2239, 2927, 3581, 4127, 5669, 11299, 11351, 284591);
#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 43, 61, 67, 113, 199);
#~ @smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29);
#~ @smooth_primes = (2, 3, 5, 7, 11, 13);

@smooth_primes = (2, 3, 5, 7, 11, 17, 19);

my $h = smooth_numbers(10**13, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %table;

foreach my $n (@$h) {

    next if ($n < 14182439039);

    my ($k, $p) = isok($n);

    if ($p >= 4) {
        say "a($p) <= $k for n = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, $k;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
