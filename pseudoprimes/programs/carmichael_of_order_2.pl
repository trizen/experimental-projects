#!/usr/bin/perl

# Carmichael numbers of order 2.
# https://oeis.org/A175531

# Known terms:
#   443372888629441, 39671149333495681, 842526563598720001, 2380296518909971201, 3188618003602886401

# See also:
#   https://listserv.nodak.edu/cgi-bin/wa.exe?A2=NMBRTHRY;1d24d4ee.1006

# Interesting Carmichael number, which is also a Chebyshev pseudoprime:
#   122762671289519184001

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use experimental qw(signatures);

sub is_chebyshev_pseudoprime ($n) {

    foreach (1 .. 20) {
        my $p = int(rand(1e6)) + 5;
        my ($u, $v) = lucas_sequence($n, $p, 1, $n);
        $v == $p or return;
    }

    return 1;
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if length($n) <= 20;
    next if length($n) > 40;

    #next if length($n) > 55;

    is_pseudoprime($n, 2) || next;
    is_chebyshev_pseudoprime($n) || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    #is_smooth($n, 1e6) || next;
    is_carmichael($n) || next;

    if (vecall { $n % (Math::GMPz->new($_) * $_ - 1) == 1 } factor($n)) {
        say "Found: $n";
    }
}

__END__
5289317030813845025030136441759313676350437291809581944424604404172556336793009975663443300209602618534779461700271078886792582401
