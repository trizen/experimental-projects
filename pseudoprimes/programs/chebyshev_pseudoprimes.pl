#!/usr/bin/perl

# Pseudoprime Chebyshev numbers: odd composite integers n such that T_n(a) == a (mod n) for all integers a, where T(x) is Chebyshev polynomial of first kind.
# https://oeis.org/A175530

# Odd composite integer n is a pseudoprime Chebyshev number iff the n-th term of Lucas sequence satisfies the congruence V_n(P,1) == P (mod n) for any integer P.

# See also:
#   https://oeis.org/A299799

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use experimental qw(signatures);

sub is_chebyshev_pseudoprime ($n) {

    foreach (1 .. 20) {
        my $p = int(rand(1e6)) + 5;
        my ($u, $v) = lucas_sequence($n, $p, 1, $n);
        $v == $p or return 0;
    }

    return 1;
}

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if (is_chebyshev_pseudoprime($n)) {
        say $n;
    }
}

__END__

# Terms < 10^20:

7056721
79397009999
443372888629441
582920080863121
2491924062668039
14522256850701599
39671149333495681
242208715337316001
729921147126771599
842526563598720001
1881405190466524799
2380296518909971201
3188618003602886401
33711266676317630401
54764632857801026161
55470688965343048319
72631455338727028799

# Extra terms:

122762671289519184001
361266866679292635601
5289317030813845025030136441759313676350437291809581944424604404172556336793009975663443300209602618534779461700271078886792582401
