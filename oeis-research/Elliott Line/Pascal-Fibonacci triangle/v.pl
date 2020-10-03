#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 25 March 2019
# https://github.com/trizen

# Generate the Pascal-Fibonacci triangle.

# Definition by Elliott Line, Mar 22 2019:
#   Consider a version of Pascal's Triangle: a triangular array with a single 1 on row 0,
#   with numbers below equal to the sum of the two numbers above it if and only if that sum
#   appears in the Fibonacci sequence. If the sum is not a Fibonacci number, `1` is put in its place.

# OEIS sequence:
#   https://oeis.org/A307069

use 5.010;
use strict;
use warnings;

use ntheory qw(is_square :all);
use experimental qw(signatures);

sub is_fibonacci($n) {
    my $m = 5 * $n * $n;
    is_square($m - 4) or is_square($m + 4);
}

sub prime_power_count ($n) {
    vecsum(map { prime_count(rootint($n, $_)) } 1 .. logint($n, 2));
}

sub isok($n) {
    is_square($n);
    #is_prime_power($n);
}

my @row  = (1);
my $rows = 40;

my %seen;

my %table;

foreach my $n (1 .. $rows) {

    my @t = (
        map {
            my $t = $row[$_] + $row[$_ + 1];
            isok($t) ? $t : 0;
          } 0 .. ($n - ($n % 2)) / 2 - 1
    );

    my @f = grep{isok($_) and !$seen{$_}++} @t;

    #foreach my $k (@f) {
        #say prime_power_count($k), ' -> ', $k, ' on row ', $n;
    #    $table{prime_power_count($k)} = $n;
    #}

    say "@row";

    # The triangle is symmetric
    # See also: https://photos.app.goo.gl/q3981kei8LJyvzgZ9
    my @u = reverse(@t);

    if ($n % 2 == 0) {
        shift @u;
    }
    @row = (1, @t, @u, 1);
}

use Data::Dump qw(pp);
pp \%table;

__END__
1
1 1
1 2 1
1 3 3 1
1 1 1 1 1
1 2 2 2 2 1
1 3 1 1 1 3 1
1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 3 1
1 1 1 1 1 2 1 1 1 1 1
1 2 2 2 2 3 3 2 2 2 2 1
1 3 1 1 1 5 1 5 1 1 1 3 1
1 1 1 2 2 1 1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 1 5 1 1 5 1 3 1
1 1 1 1 1 2 1 1 2 1 1 2 1 1 1 1 1
1 2 2 2 2 3 3 2 3 3 2 3 3 2 2 2 2 1
1 3 1 1 1 5 1 5 5 1 5 5 1 5 1 1 1 3 1
1 1 1 2 2 1 1 1 1 1 1 1 1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 2 2 2 2 2 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 1 1 1 1 1 1 1 5 1 1 5 1 3 1
1 1 1 1 1 2 1 1 2 2 2 2 2 2 2 1 1 2 1 1 1 1 1
1 2 2 2 2 3 3 2 3 1 1 1 1 1 1 3 2 3 3 2 2 2 2 1
1 3 1 1 1 5 1 5 5 1 2 2 2 2 2 1 5 5 1 5 1 1 1 3 1
1 1 1 2 2 1 1 1 1 1 3 1 1 1 1 3 1 1 1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 2 2 1 1 2 2 2 1 1 2 2 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 1 1 3 2 3 1 1 3 2 3 1 1 1 5 1 1 5 1 3 1
1 1 1 1 1 2 1 1 2 2 1 5 5 1 2 1 5 5 1 2 2 1 1 2 1 1 1 1 1
1 2 2 2 2 3 3 2 3 1 3 1 1 1 3 3 1 1 1 3 1 3 2 3 3 2 2 2 2 1
1 3 1 1 1 5 1 5 5 1 1 1 2 2 1 1 1 2 2 1 1 1 5 5 1 5 1 1 1 3 1
1 1 1 2 2 1 1 1 1 1 2 2 3 1 3 2 2 3 1 3 2 2 1 1 1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 2 2 3 1 5 1 1 5 1 5 1 1 5 1 3 2 2 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 1 1 5 1 1 1 2 1 1 1 1 2 1 1 1 5 1 1 1 5 1 1 5 1 3 1
1 1 1 1 1 2 1 1 2 2 1 1 2 2 3 3 2 2 2 3 3 2 2 1 1 2 2 1 1 2 1 1 1 1 1
1 2 2 2 2 3 3 2 3 1 3 2 3 1 5 1 5 1 1 5 1 5 1 3 2 3 1 3 2 3 3 2 2 2 2 1
1 3 1 1 1 5 1 5 5 1 1 5 5 1 1 1 1 1 2 1 1 1 1 1 5 5 1 1 5 5 1 5 1 1 1 3 1
1 1 1 2 2 1 1 1 1 1 2 1 1 1 2 2 2 2 3 3 2 2 2 2 1 1 1 2 1 1 1 1 1 2 2 1 1 1
1 2 2 3 1 3 2 2 2 2 3 3 2 2 3 1 1 1 5 1 5 1 1 1 3 2 2 3 3 2 2 2 2 3 1 3 2 2 1
1 3 1 5 1 1 5 1 1 1 5 1 5 1 5 1 2 2 1 1 1 1 2 2 1 5 1 5 1 5 1 1 1 5 1 1 5 1 3 1
