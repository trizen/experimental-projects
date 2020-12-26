#!/usr/bin/perl

# Smallest odd number for which Miller-Rabin primality test on bases <= n-th prime does not reveal compositeness.
# https://oeis.org/A014233

# Version with terms > 2^64.

# Interesting Carmichael number that is also strong psp to the first 7 prime bases:
#   129713907272647698631

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $fermat_file = "cache/factors-fermat.storable";
my $fermat      = retrieve($fermat_file);

my @terms;

while (my ($n) = each %$fermat) {

    next if length($n) > 100;

    if (is_strong_pseudoprime($n, 2)) {
        push @terms, Math::GMPz->new($n);
    }
}

@terms = sort { $a <=> $b } @terms;

my $p     = 2;
my @bases = ($p);

foreach my $n (@terms) {
    while (is_strong_pseudoprime($n, @bases)) {
        printf("a(%2d) <= %s\n", scalar(@bases), $n);
        $p = next_prime($p);
        unshift @bases, $p;
    }
}

__END__
a( 1) <= 18446744073709551617
a( 2) <= 18446839241310879961
a( 3) <= 18512248848925882051
a( 4) <= 18777113938866264451
a( 5) <= 20315155777788649051
a( 6) <= 20315155777788649051
a( 7) <= 41234316135705689041
a( 8) <= 41234316135705689041
a( 9) <= 41234316135705689041
a(10) <= 318665857834031151167461
a(11) <= 318665857834031151167461
a(12) <= 318665857834031151167461
a(13) <= 3317044064679887385961981
a(14) <= 6003094289670105800312596501
a(15) <= 59276361075595573263446330101
a(16) <= 564132928021909221014087501701
a(17) <= 564132928021909221014087501701
a(18) <= 1543267864443420616877677640751301
a(19) <= 1543267864443420616877677640751301
