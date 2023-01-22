#!/usr/bin/perl

# a(n) is the least number that has exactly n divisors with sum of digits n.
# https://oeis.org/A359444

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 7;
    }

    if ($p == 3) {
        return valuation($n, $p) < 4;
    }

    if ($p == 5) {
        return valuation($n, $p) < 3;
    }

    if ($p == 7) {
        return valuation($n, $p) < 3;
    }

    if ($p == 11) {
        return valuation($n, $p) < 2;
    }

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

sub isok ($n, $k) {
    my $count = 0;
    foreach my $d(divisors($n)) {
        if (vecsum(todigits($d)) == $k) {
            ++$count;
        }
    }
    $count == $k;
}

my @smooth_primes = @{primes(101)};

my $h = smooth_numbers(14803438640, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my $max = 'inf';
my $k   = 35;

foreach my $n (@$h) {
    if ($n % 2 == 0 and $n < $max and isok($n, $k)) {
        $max = $n;
        say "a($k) <= $n";
    }
}

__END__
a(28) <= 413736400
a(29) <= 1081662400
a(30) = 73670520
a(31) <= 3301916800
a(32) <= 2325202880
a(33) <= 407578080
a(34) <= 4803438640
a(35) <= 14456653120
a(36) = 12598740
