#!/usr/bin/perl

# Smallest number m such that tau(k) * k = m has exactly n solutions when tau(k) is the number of divisors of k.
# https://oeis.org/A338381

# a(6) <= 1508867287200000
# a(7) <= 33195080318400000
# a(8) <= 12938292961651375718400
# a(8) <= 2544150895374925200000
# a(9) <= 55487699012097891000000

# a(6) <= 1508867287200000, a(8) <= 2544150895374925200000, a(9) <= 55487699012097891000000. - ~~~~

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
#~ use Math::AnyNum qw(:overload);

sub check_valuation ($n, $p) {
1

    #~ if ($p == 2) {
        #~ return valuation($n, $p) < 20;
    #~ }

    #~ if ($p == 3) {
        #~ return valuation($n, $p) < 20;
    #~ }

    #~ if ($p == 5) {
        #~ return valuation($n, $p) < 10;
    #~ }

    #~ if ($p == 7) {
        #~ return valuation($n, $p) < 10;
    #~ }

    #~ if ($p == 11 or $p == 13) {
        #~ return valuation($n, $p) < 10;
    #~ }

    #~ if ($p == 17 or $p == 19) {
        #~ return valuation($n, $p) < 3;
    #~ }

    #~ ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p < $limit and check_valuation($n, $p)) {
                push @h, mulint($n, $p);
            }
        }
    }

    return \@h;
}

#
# Example for finding numbers `m` such that:
#     sigma(m) * phi(m) = n^k
# for some `n` and `k`, with `n > 1` and `k > 1`.
#
# See also: https://oeis.org/A306724
#

sub isok ($n) {
    my $count = 0;
    #map { divisor_sum($_, 0) * $_ ==  } divisors($n)
    foreach my $d(divisors($n)) {
        if (mulint(scalar(divisors($d)), $d) == $n) {
            ++$count;
        }
    }
    $count;
}

my @smooth_primes;

foreach my $p (@{primes(4801)}) {

    if ($p == 2) {
        push @smooth_primes, $p;
        next;
    }

    my @f1 = factor($p - 1);
    my @f2 = factor($p + 1);

    if ($f1[-1] <= 7 and $f2[-1] <= 7) {
        push @smooth_primes, $p;
    }
}

my $h = smooth_numbers((~0)*10, [sort {$a <=> $b} (

#19, 3, 13, 11, 2, 7, 17, 5
#13, 3, 19, 7, 2, 11, 17, 5
#5, 13, 2, 17, 11, 3, 7, 19, 23, 31, 43, 41, 37
@{primes(13)}

)]);

say "\nFound: ", scalar(@$h), " terms";

my %table;

@$h = sort {$a<=> $b} @$h;

foreach my $n(@$h) {

    ($n%2) == 0 or next;

    #valuation($n, 2) >= 5 or next;
    #~ valuation($n, 3) >= 5 or next;

    my $k = mulint($n, scalar(divisors($n)));

    push @{$table{$k}}, $n;

    if (scalar(@{$table{$k}}) >= 6) {

        my $p = isok($k);

        say "[$p] Found: $k";

        if ($p == 6 and $k < 1508867287200000) {
            die "Found a smaller bound for a($p) -> $k";
        }

        if ($p == 7 and $k < 33195080318400000) {
            die "Found a smaller bound for a($p) -> $k";
        }

        if ($p == 8 and $k < "2544150895374925200000") {
            die "Found a smaller bound for a($p) -> $k";
        }

        if ($p == 9 and $k < "55487699012097891000000") {
            die "Found a smaller bound for a($p) -> $k";
        }

        if ($p > 9) {
            die "Found a new upper-bound for a($p) -> $k";
        }
    }
}

__END__
@$h = sort { $a <=> $b } @$h;

foreach my $n (@$h) {

    #next if ($n < 12134385235627200000);
    #next if ($n < 3231993729182400000);

    ($n % 10) == 0 or next;
    #($n % 23) == 0 or next;

    valuation($n, 2) >= 7 or next;
    valuation($n, 3) >= 3 or next;
    valuation($n, 5) >= 3 or next;

    #Math::AnyNum::is_smooth($n, 19) && next;

    #say "Testing: $n";

    my $p = isok($n);

    if ($p >= 6) {

       say "[$p] Testing: $n";

        if ($p >= 8) {
            die "a($p) <= $n";
        }
        #say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        #push @{$table{$p}}, $n;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "a($k) <= ", vecmin(@{$table{$k}});
}
