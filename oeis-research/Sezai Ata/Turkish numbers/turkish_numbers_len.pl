#!/usr/bin/perl

use utf8;
use 5.014;
use strict;
use warnings;

# https://oeis.org/A305100

# 3, 1, 4, 0, 14, 18, 21, 24, 28, 68, 124, 128, 168, 224, 228, 268, 468, 868,
# 1168, 1224, 1228, 1268, 1468, 1868, 4868, 8868, 14868, 18868, 21868, 24868,
# 28868, 68868, 124868, 128868, 168868, 224868, 228868, 268868, 468868, 868868

use open IO => ':utf8';
use Encode qw(decode_utf8 encode_utf8);

use Lingua::TR::Numbers qw(num2tr num2tr_ordinal);

foreach my $n (2 .. 100) {
    foreach my $k (0 .. 1e11) {
        if (length(num2tr($k) =~ tr/ -//dr) == $n) {
            say "a($n) = $k -> ", encode_utf8(num2tr($k));
            last;
        }
    }
}
