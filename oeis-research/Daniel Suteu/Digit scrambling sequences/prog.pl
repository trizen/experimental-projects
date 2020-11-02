#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# License: GPLv3
# https://github.com/trizen

# An interesting text scrambling algorithm, invented by the author in ~2008.

use utf8;
use 5.010;
use strict;
use warnings;

use ntheory qw(:all);

sub double_scramble {
    my ($str) = @_;

    my $i = my $l = length($str);

    $str =~ s/(.{$i})(.)/$2$1/s while (--$i > 0);
    $str =~ s/(.{$i})(.)/$2$1/s while (++$i < $l);

    return $str;
}

sub double_unscramble {
    my ($str) = @_;

    my $i = my $l = length($str);

    $str =~ s/(.)(.{$i})/$2$1/s while (--$i > 0);
    $str =~ s/(.)(.{$i})/$2$1/s while (++$i < $l);

    return $str;
}

sub double_scramble_global {
    my ($str) = @_;

    my $i = my $l = length($str);

    $str =~ s/(.{$i})(.)/$2$1/sg while (--$i > 0);
    $str =~ s/(.{$i})(.)/$2$1/sg while (++$i < $l);

    return $str;
}

sub double_unscramble_global {
    my ($str) = @_;

    my $i = my $l = length($str);

    $str =~ s/(.)(.{$i})/$2$1/sg while (--$i > 0);
    $str =~ s/(.)(.{$i})/$2$1/sg while (++$i < $l);

    return $str;
}

sub scramble {
    my ($str) = @_;

    my $i = length($str);
    $str =~ s/(.{$i})(.)/$2$1/s while (--$i > 0);
    return $str;
}

sub unscramble {
    my ($str) = @_;

    my $i = 0;
    my $l = length($str);
    $str =~ s/(.)(.{$i})/$2$1/s while (++$i < $l);
    return $str;
}

sub scramble_global {
    my ($str) = @_;

    my $i = length($str);
    $str =~ s/(.{$i})(.)/$2$1/sg while (--$i > 0);
    return $str;
}

sub unscramble_global {
    my ($str) = @_;

    my $i = 0;
    my $l = length($str);
    $str =~ s/(.)(.{$i})/$2$1/sg while (++$i < $l);
    return $str;
}

my %encode_fails;
my %decode_fails;

foreach my $n(1..128) {

    my $w = fromdigits(scramble(todigitstring($n, 2)), 2);
    my $x = fromdigits(scramble_global(todigitstring($n, 2)), 2);
    my $y = fromdigits(double_scramble(todigitstring($n, 2)), 2);
    my $z = fromdigits(double_scramble_global(todigitstring($n, 2)), 2);

    my $w_ = fromdigits(unscramble(todigitstring($w, 2)), 2);
    my $x_ = fromdigits(unscramble_global(todigitstring($x, 2)), 2);
    my $y_ = fromdigits(double_unscramble(todigitstring($y, 2)), 2);
    my $z_ = fromdigits(double_unscramble_global(todigitstring($z, 2)), 2);

    ++$decode_fails{w} if ($w_ != $n);
    ++$decode_fails{x} if ($x_ != $n);
    ++$decode_fails{y} if ($y_ != $n);
    ++$decode_fails{z} if ($z_ != $n);

    ++$encode_fails{w} if ($w == $n);
    ++$encode_fails{x} if ($x == $n);
    ++$encode_fails{y} if ($y == $n);
    ++$encode_fails{z} if ($z == $n);

    printf("a(%3d) = (%3d %3d)  (%3d %3d)  (%3d %3d)  (%3d %3d)\n", $n, ($w, $w_), ($x, $x_), ($y, $y_), ($z, $z_));
}

say '';

say "Single scramble non-global encode fails: $encode_fails{w}";
say "Single scramble global encode fails    : $encode_fails{x}";
say "Double scramble non-global encode fails: $encode_fails{y}";
say "Double scramble global encode fails    : $encode_fails{z}";

say '';

say "Single scramble non-global decode fails: $decode_fails{w}";
say "Single scramble global decode fails    : $decode_fails{x}";
say "Double scramble non-global decode fails: $decode_fails{y}";
say "Double scramble global decode fails    : $decode_fails{z}";

__END__

# Single scramble global:
1, 1, 3, 4, 6, 5, 7, 1, 9, 3, 11, 5, 13, 7, 15, 8, 10, 9, 11, 24, 26, 25, 27, 12, 14, 13, 15, 28, 30, 29, 31, 1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31, 33, 49, 41, 57, 37, 53, 45, 61, 35, 51, 43, 59, 39, 55, 47, 63, 64, 66, 65, 67, 96, 98, 97, 99, 80, 82, 81, 83, 112, 114, 113, 115, 72, 74, 73, 75, 104, 106, 105, 107, 88, 90, 89, 91, 120, 122, 121, 123, 68, 70, 69, 71, 100

# Single scramble non-global:
1, 1, 3, 4, 6, 5, 7, 2, 10, 3, 11, 6, 14, 7, 15, 8, 12, 9, 13, 24, 28, 25, 29, 10, 14, 11, 15, 26, 30, 27, 31, 4, 20, 5, 21, 12, 28, 13, 29, 6, 22, 7, 23, 14, 30, 15, 31, 36, 52, 37, 53, 44, 60, 45, 61, 38, 54, 39, 55, 46, 62, 47, 63, 64, 72, 65, 73, 96, 104, 97, 105, 66, 74, 67, 75, 98, 106, 99, 107, 80, 88, 81, 89, 112, 120, 113, 121, 82, 90, 83, 91, 114, 122, 115, 123, 68, 76, 69, 77, 100

# Double scramble global:
1, 2, 3, 1, 3, 5, 7, 4, 5, 12, 13, 6, 7, 14, 15, 2, 6, 18, 22, 3, 7, 19, 23, 10, 14, 26, 30, 11, 15, 27, 31, 32, 34, 48, 50, 36, 38, 52, 54, 40, 42, 56, 58, 44, 46, 60, 62, 33, 35, 49, 51, 37, 39, 53, 55, 41, 43, 57, 59, 45, 47, 61, 63, 1, 33, 65, 97, 3, 35, 67, 99, 17, 49, 81, 113, 19, 51, 83, 115, 5, 37, 69, 101, 7, 39, 71, 103, 21, 53, 85, 117, 23, 55, 87, 119, 9, 41, 73, 105, 11

# Double scramble non-global:
1, 2, 3, 1, 3, 5, 7, 4, 5, 12, 13, 6, 7, 14, 15, 2, 6, 18, 22, 3, 7, 19, 23, 10, 14, 26, 30, 11, 15, 27, 31, 8, 10, 40, 42, 12, 14, 44, 46, 24, 26, 56, 58, 28, 30, 60, 62, 9, 11, 41, 43, 13, 15, 45, 47, 25, 27, 57, 59, 29, 31, 61, 63, 1, 9, 65, 73, 3, 11, 67, 75, 33, 41, 97, 105, 35, 43, 99, 107, 5, 13, 69, 77, 7, 15, 71, 79, 37, 45, 101, 109, 39, 47, 103, 111, 17, 25, 81, 89, 19

Single scramble non-global encode fails: 16
Single scramble global encode fails    : 22
Double scramble non-global encode fails: 13
Double scramble global encode fails    : 19

Single scramble non-global decode fails: 30
Single scramble global decode fails    : 30
Double scramble non-global decode fails: 63
Double scramble global decode fails    : 47
