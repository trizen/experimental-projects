#!/usr/bin/perl

# Numbers that are a proper substring of the concatenation (with repetition) in decreasing order of their prime factors.
# https://oeis.org/A378950

# Known terms:
#   95, 132, 995, 9995, 73332, 85713, 93115, 131131, 197591, 632812, 999995, 4285713, 8691315, 58730137, 99999995, 131373333, 507107133, 4870313015

use 5.036;
use ntheory qw(:all);

my $from = 4870313015;

forfactored {
   if (index(join('', reverse @_), $_) != -1 and !is_prime($_)) {
       say $_;
   }

} $from, 1e11;

__END__
95
132
995
9995
73332
85713
93115
131131
197591
632812
999995
4285713
8691315
