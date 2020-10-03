#!/usr/bin/perl

# a = 27 n + 24, b = 8 n + 7, n element Z

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub excess ($n) {
    scalar(factor($n)) - scalar(factor_exp($n));
}

sub score ($n) {
    my $t = excess($n);
    foreach my $k(1..100) {
        if (excess($k + $n) != $t) {
            return $k;
        }
    }
}

# 254023231417746

foreach my $n(1176033478785-1e6..1176033478785) {

    # a = 27 n + 24, b = 8 n + 7, n element Z

    # (2^3*a-6) = (3^3 *b - 3)
    # a = 27 n + 3, b = 8 n + 1, n element Z

    my $x = 27*$n + 24;
    my $y = 8*$n + 7;

    #say join(' ', factor(2**3 * $x + 6)), ' -- ', join(' ', factor(3**3 *$y + 3));

    #say $x, ' -> ', join(' ', factor($x));
    #say $y, ' -> ', join(' ', factor($y));

    #say '';
    #say 2**3*$x - 6, ' -> ', join(' ', factor(2**3*$x - 6));

    if (is_semiprime($x) and is_semiprime($y)) {

        #my $m = 2**4 * 3**2 * $x - 2;
        my $m = 2**3*$x - 6;
        my $s = score($m);

        if ($s >= 5) {

            say "For x = $x --> $m has a score of $s with n = $n";

            foreach my $k(1..4) {

                my $m = $n-$k;
                my $s = score($m);

                if ($s >= 9) {

                    say "For y = $y --> $m has a score of $s";

                    if ($s >= 10) {
                        die "Upper-bound for a(10) = $m\n";
                    }
                }
            }
        }

    }

    # (2^3*x - 6) = (3^3*y - 3)

    #if (excess($x) == excess($y)) {
    #if (2**3*$x + 6
    #}
}
