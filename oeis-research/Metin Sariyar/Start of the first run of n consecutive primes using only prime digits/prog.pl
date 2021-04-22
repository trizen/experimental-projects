#!/usr/bin/perl

# Start of the first run of n consecutive primes using only prime digits.
# https://oeis.org/A343471

# Known terms:
#   2, 2, 2, 2, 2575723, 7533777323, 277535577223

# a(8) > 222222222222222. - Jon E. Schoenfield, Apr 21 2021

# Optimization: for a(n) > 9, the last digit is always 3 or 7.

# Upper-bounds:
#   a(8) <= 22233572337233227

# New terms:
#   a(8) = 5323733533375237

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use Algorithm::Combinatorics qw(variations_with_repetition);

my @data = (2, 3, 5, 7);

sub isok ($k, $n) {

    my $p = $k;
    foreach my $i (1 .. $n - 1) {

        $p = next_prime($p);

        if (($p =~ tr/2357//rd) ne '') {
            return;
        }
    }

    return 1;
}

isok(2575723,           5) or die "false-negative for n = 5";
isok(7533777323,        6) or die "false-negative for n = 6";
isok(277535577223,      7) or die "false-negative for n = 7";
isok(5323733533375237,  8) or die "false-negative for n = 8";
isok(22233572337233227, 8) or die "false-negative for n = 8";

isok(2575723,           6) and die "false-positive for n = 6";
isok(7533777323,        7) and die "false-positive for n = 7";
isok(277535577223,      8) and die "false-positive for n = 8";
isok(5323733533375237,  9) and die "false-positive for n = 9";
isok(22233572337233227, 9) and die "false-positive for n = 9";

sub a ($n, $start_k = 1) {

    foreach my $k ($start_k .. 100) {

        say "Checking k = $k";

        my $iter = variations_with_repetition(\@data, $k);

        while (my $arr = $iter->next) {

            my $t = join('', @$arr);

            foreach my $suffix (3, 7) {

                my $v = $t . $suffix;

                if (is_prime($v) and isok($v, $n)) {
                    return $v;
                }
            }
        }
    }
}

#say a(8, 15);
#say a(8, 16);
say a(9, 17);
#say a(9, 18);

__END__
Checking k = 15
5323733533375237
perl prog.pl  2731.67s user 4.86s system 96% cpu 47:26.69 total
