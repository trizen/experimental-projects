#!/usr/bin/perl

# Lucas-Carmichael numbers m that have at least 2 prime factors p such that p-1 | m-1.
# https://oeis.org/A329948

# It is not known whether any Carmichael number (A002997) is also a Lucas-Carmichael number (A006972).

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::AnyNum qw(is_smooth);

sub is_lucas_carmichael ($n) {
    my $t = $n + 1;
    vecall { $t % ($_ + 1) == 0 } factor($n);
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < 1008003203999;
    #next if ($n < ~0);

    is_pseudoprime($n, 2) && next;
    is_smooth($n, 1e5) || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    is_lucas_carmichael($n) || next;
    is_square_free($n) || next;

    my $inc = $n-1;
    my $k = scalar grep { $inc % ($_-1) == 0 } Math::Prime::Util::GMP::factor($n);

    if ($k >= 3) {
        if ($k >= 4) {
            say "New record: $n with $k primes p such that p-1 | m-1";
        }
        else {
            say $n;
        }
    }
}

__END__

# Lucas-Carmichael numbers bellow 10^12 with at least 2 prime factors p such that p-1 | m-1:

58809496031
161513282399
244627234865
254080512449
276741041345
397745596079
482690075759
697522043735
846823631345

# Terms with 3 prime factors p such that p-1 | m-1:

19606537382720316183704007491759
30929869681595566326223026143547237768574058684159
