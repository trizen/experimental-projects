#!/usr/bin/perl

# Carmichael numbers of order 2.
# https://oeis.org/A175531

# Known terms:
#   443372888629441, 39671149333495681, 842526563598720001, 2380296518909971201, 3188618003602886401

# See also:
#   https://listserv.nodak.edu/cgi-bin/wa.exe?A2=NMBRTHRY;1d24d4ee.1006

# Interesting Carmichael number, which is also a Chebyshev pseudoprime:
#   122762671289519184001

# New term:
#   713211736645623197793013755552001

use 5.036;
use Math::GMPz;
use Math::Sidef qw();
use ntheory     qw(:all);

#use Math::AnyNum qw(is_smooth);
use Math::Prime::Util::GMP qw();

sub is_chebyshev_pseudoprime ($n) {

    foreach (1 .. 20) {
        my $p = int(rand(1e6)) + 5;
        my $v = ($n > ~0) ? Math::Prime::Util::GMP::lucasvmod($p, 1, $n, $n) : lucasvmod($p, 1, $n, $n);
        $v eq $p or return 0;
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

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;
    is_chebyshev_pseudoprime($n)                  || next;

    #is_smooth($n, 1e6) || next;
    Math::Sidef::is_smooth($n, 1e6) || next;
    Math::Sidef::is_carmichael($n)  || next;

    if (vecall { $n % ($_ * $_ - 1) == 1 } Math::Sidef::factor($n)) {
        say "Found: $n";
    }
}

__END__
713211736645623197793013755552001
5289317030813845025030136441759313676350437291809581944424604404172556336793009975663443300209602618534779461700271078886792582401
