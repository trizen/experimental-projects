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

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $table         = retrieve($storable_file);

sub is_chebyshev_pseudoprime ($n) {

    foreach (1 .. 20) {
        my $p = int(rand(1e6)) + 5;
        my ($u, $v) = lucas_sequence($n, $p, 1, $n);
        $v == $p or return;
    }

    return 1;
}

my $n = Math::GMPz::Rmpz_init();
my $p = Math::GMPz::Rmpz_init();

my $one = Math::GMPz::Rmpz_init_set_ui(1);

while (my ($key, $value) = each %$table) {

    Math::GMPz::Rmpz_set_str($n, $key, 10);

    #is_chebyshev_pseudoprime($n) || next;

    if (
        vecall {
            Math::GMPz::Rmpz_set_str($p, $_, 10);
            Math::GMPz::Rmpz_mul($p, $p, $p);
            Math::GMPz::Rmpz_sub_ui($p, $p, 1);
            Math::GMPz::Rmpz_congruent_p($n, $one, $p);
        }
        split(' ', $value)
      ) {
        say $n;
    }
}

__END__
5289317030813845025030136441759313676350437291809581944424604404172556336793009975663443300209602618534779461700271078886792582401
