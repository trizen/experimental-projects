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

use Imager qw();
use ntheory qw(is_square :all);
use experimental qw(signatures);
use Math::GMPz;

sub is_fibonacci($n) {
    my $m = 5 * $n * $n;
    is_square($m - 4) or is_square($m + 4);
}

my $size = 500;                                          # the size of the triangle
my $img  = Imager->new(xsize => $size, ysize => $size);

my $black = Imager::Color->new('#000000');
my $red   = Imager::Color->new('#ff00000');

$img->box(filled => 1, color => $black);

sub pascal_prime_power_triangle {
    my ($rows) = @_;

    my $ONE = Math::GMPz->new(1);
    my $TWO = Math::GMPz->new(2);

    my @row = ($ONE);

    foreach my $n (1 .. $rows - 1) {

        my $i      = 0;
        my $offset = ($rows - $n) / 2;

        foreach my $elem (@row) {

            my $ln = (1+log(sprintf('%s', 1+abs($elem))));

            $img->setpixel(
                           x     => $offset + $i++,
                           y     => $n,
                           color => {
                                     hsv => [$elem <= 1 ? 0 : (360 / $ln), 1, 1 - 1 / $ln]
                                    }
                          );
        }

        last if grep{length("$_") > 70} @row;

        if ($n < 40) {
            say "@row";
        }

#<<<
        @row = ($ONE, (map {
            my $t = $row[$_] + $row[$_ + 1];
            (!is_square_free($t) ) ? $t : $TWO;
        } 0 .. $n - 2), $ONE);
#>>>
    }
}

pascal_prime_power_triangle($size);

$img->write(file => "squarefree2.png");
