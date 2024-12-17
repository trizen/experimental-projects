#!/usr/bin/perl

# Numbers that are a proper substring of the concatenation (with repetition) in increasing order of their prime factors.
# https://oeis.org/A378893

# Known terms:
#   333, 22564, 113113, 210526, 252310, 1143241, 3331233, 3710027, 31373137, 217893044, 433100023, 2263178956

use 5.036;
use ntheory qw(:all);

my $from = 2263178956;

forfactored {
   if (index(join('', @_), $_) != -1 and !is_prime($_)) {
       say $_;
   }

} $from, 1e12;

__END__
333
22564
113113
210526
252310
1143241
3331233
3710027
31373137
217893044
