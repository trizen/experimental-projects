#!/usr/bin/perl

# Numbers k such that the arithmetic mean of the first k squarefree numbers is an integer.
# https://oeis.org/A355544

# Known terms:
#   1, 3, 6, 37, 75, 668, 1075, 37732, 742767, 1811865, 3140083, 8937770, 108268896, 282951249, 633932500, 1275584757

# New term found (it took 7 hours to find it):
#   60455590365

# Proof:
#   the 60455590365-th squarefree number is 99445459943.
#   the sum of all squarefree numbers <= 99445459943, is 3006016997918608257300, which is divisible by 60455590365.

# PARI/GP program:
#   upto(n) = my(s=0,k=0); forsquarefree(m=1, n, s+=m[1]; k+=1; if(s%k == 0, print1(k, ", ")));

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my $k = 1;
my $z = Math::GMPz::Rmpz_init_set_ui(0);

forsquarefree {
    Math::GMPz::Rmpz_add_ui($z, $z, $_);
    if (Math::GMPz::Rmpz_divisible_ui_p($z, $k)) {
        say $k;
    }
    ++$k;
} 1e14;

__END__
1
3
6
37
75
668
1075
37732
742767
1811865
3140083
8937770
108268896
282951249
633932500
1275584757
60455590365
