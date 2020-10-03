#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 25 March 2019
# https://github.com/trizen

# Generate a visual representation of the Pascal-Fibonacci triangle.

# Definition by Elliott Line, Mar 22 2019:
#   Consider a version of Pascal's Triangle: a triangular array with a single 1 on row 0,
#   with numbers below equal to the sum of the two numbers above it if and only if that sum
#   appears in the Fibonacci sequence. If the sum is not a Fibonacci number, `1` is put in its place.

# OEIS sequence:
#   https://oeis.org/A307069

use 5.010;
use strict;
use warnings;

use ntheory qw(is_square lucasu);
use experimental qw(signatures);

sub is_fibonacci($n) {
    my $m = 5 * $n * $n;
    is_square($m - 4) or is_square($m + 4);
}

my %fib;

foreach my $n (0 .. 100) {
    $fib{lucasu(1, -1, $n)} = $n;
}

my %seen;
my @row = (1);

foreach my $n (1 .. 1e6) {

    if ($n % 10_000 == 0) {
        say "Processing row $n...";
        open my $fh, '>', "row_$n.txt";
        say $fh "$n\n@row";
        close $fh;
    }

    my @t = (
        map {
            my $t = $row[$_] + $row[$_ + 1];

            if (exists($fib{$t})) {

                if (not exists $seen{$t}) {

                    $seen{$t} = 1;
                    say "$t -> $n";

                    open my $fh, '>', "found_$t.txt";
                    say $fh sprintf("%s\n%s", $n - 1, "@row");
                    close $fh;
                }

                $t;
            }
            else {
                1;
            }
          } 0 .. ($n - ($n % 2)) / 2 - 1
    );

    #~ if ($n < 20) {
        #~ say "@row";
    #~ }

    my @u = reverse(@t);

    if ($n % 2 == 0) {
        shift @u;
    }

    @row = (1, @t, @u, 1);
}

__END__
1 -> 1
2 -> 1 1
3 -> 1 2 1
4 -> 1 3 3 1
5 -> 1 1 1 1 1
6 -> 1 2 2 2 2 1
7 -> 1 3 1 1 1 3 1
8 -> 1 1 1 2 2 1 1 1
9 -> 1 2 2 3 1 3 2 2 1
10 -> 1 3 1 5 1 1 5 1 3 1
