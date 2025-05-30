#!/usr/bin/perl


use 5.014;
use ntheory qw(:all);

# https://oeis.org/draft/A307217

# Found:
# a(18) = 627699239
# a(19) = 880021141
# a(20) = 1001124539
# a(21) = 1041287603
# a(22) = 1104903617
# a(23) = 1592658611
# a(24) = 1717999139

# Extra:
# a(25) = 8843679683

# New:
# a(26) = 15575602979
# a(27) = 15614760199
# a(28) = 20374337479

my $from = 12027699239;  # incremented

# From: 11027699239 -- To: 12027699239

say "From: $from -- To: ", $from+1e9;

forsemiprimes {

   if (powmod(2, $_+1, $_) == 1) {
        say "Found: $_";
   }

} $from, $from + 1e10;

# 15, 35, 119, 5543, 74447, 90859, 110767, 222179, 389993, 1526849, 2927297, 3626699, 4559939, 24017531, 137051711, 160832099, 229731743, 627699239, 880021141, 1001124539, 1041287603, 1104903617, 1592658611, 1717999139
