#!/usr/bin/perl

# Extract Fermat pseudoprimes from other pseudoprimes, having all the prime factors:
#   p == 3 (mod 8)
#   kroncker(5,p) = -1

# Also having an odd number of factors, therefore kronecker(5,n) = -1.
# If n is also a Fibonacci pseudoprime, then it would be a counter-example to the PSW conjecture.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

#my $storable_file = "cache/factors-carmichael.storable";
my $storable_file = "cache/factors-fermat.storable";

#my $storable_file = "cache/factors-lucas-carmichael.storable";

my $table = retrieve($storable_file);

my %seen;
while (my ($key, $value) = each %$table) {

    my @factors = split(' ', $value);
    my $omega   = scalar(@factors);

    $omega > 3 or next;

    #$factors[-1] < ~0 or next;
    @factors = grep {
            ($_ < ~0)
          ? ($_ % 8 == 3 and kronecker(5, $_) == -1)
          : (Math::Prime::Util::GMP::modint($_, 8) == 3 and Math::Prime::Util::GMP::kronecker(5, $_) == -1)
    } @factors;

    my $len = scalar(@factors);

    if ($len >= 3 and $len < $omega) {
        for (my $k = 3 ; $k <= $len ; $k += 2) {

            forcomb {

                my $z = Math::Prime::Util::GMP::vecprod(@factors[@_]);

                if (not exists($seen{$z}) and not exists($table->{$z}) and Math::Prime::Util::GMP::is_pseudoprime($z, 2)) {
                    say $z;
                    $seen{$z} = 1;
                }

            }
            $len, $k;
        }
    }
}
