#!/usr/bin/perl

# Sequence that need more terms:
#   https://oeis.org/A064252
#   https://oeis.org/A064257
#   https://oeis.org/A064258
#   https://oeis.org/A064260
#   https://oeis.org/A064261
#   https://oeis.org/A065700
#   https://oeis.org/A065699
#   https://oeis.org/A064251

use 5.014;
use ntheory qw(:all);
use Math::GMPz;

# Values of m such that N=(am+1)(bm+1)(cm+1) is a Carmichael number, where a,b,c = 1,2,49.
# https://oeis.org/A064261

#my ($a, $b, $c) = (1, 2, 49);
my ($a, $b) = (1, 2);

for (my $c = 3 ; $c <= 49 ; $c += 2) {

    my $t = Math::GMPz::Rmpz_init();

    my @terms;

    foreach my $m (1 .. 1e9) {
        if (is_prime($a * $m + 1) && is_prime($b * $m + 1) && is_prime($c * $m + 1)) {

            Math::GMPz::Rmpz_set_ui($t, $a * $m + 1);
            Math::GMPz::Rmpz_mul_ui($t, $t, $b * $m + 1);
            Math::GMPz::Rmpz_mul_ui($t, $t, $c * $m + 1);

            if (is_carmichael($t)) {
                push @terms, $m;
                last if @terms == 1000;
            }
        }
    }

    if (@terms) {
        say "\n# Numbers m such that N=(am+1)(bm+1)(cm+1) is a Carmichael number, where a,b,c = 1,2,$c.";
        say "@terms";
    }
}
