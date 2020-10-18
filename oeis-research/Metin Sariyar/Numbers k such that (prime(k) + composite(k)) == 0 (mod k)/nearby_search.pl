#!/usr/bin/perl

# Numbers k such that (prime(k)+composite(k))/k is an integer, where prime(k) is the k-th prime.
# https://oeis.org/A329112

# Generate from a given position.

# 24 -> 1148520401
# 25 -> 2992553661
# 26 -> 7810355163
# 27 -> 20417009694
# 28 -> 53450012130
# 29 -> 140117566414
# 30 -> 367781396222
# 31 -> 966501096625
# 33 -> 6696270270399

# New terms found:
#   2992553599, 966501096569, 966501096596, 966501096597, 6696270270022

# p(2992553599) = 71670264959
# c(2992553599) = 3143575016

# p(966501096569) = 28957270703371
# c(966501096569) = 1004263290268

# p(966501096596) = 28957270704179
# c(966501096596) = 1004263290297

# p(966501096597) = 28957270704209
# c(966501096597) = 1004263290298

# p(6696270270022) = 214037416690099
# c(6696270270022) = 6939502220627

use 5.014;
use ntheory qw(:all);

use Math::Sidef qw(composite);

my $k = 966501096625-1e6;
my $p = nth_prime($k);

my $from = composite($k)->numify;

say "From: $from";

local $| = 1;

forcomposites {

    if (($p + $_) % $k == 0) {
        print($k, ", ");
    }

    ++$k;
    $p = next_prime($p);
} $from, $from+1e7;
