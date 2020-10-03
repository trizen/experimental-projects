#!/usr/bin/perl

# It is not known whether any Lucas–Carmichael number is also a Fermat pseudoprime to base-2.

# See also:
#   https://oeis.org/A006972
#   https://en.wikipedia.org/wiki/Lucas%E2%80%93Carmichael_number

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $fermat_file = "cache/factors-fermat.storable";
my $lucas_carmichael_file = "cache/factors-lucas-carmichael.storable";

my $fermat = retrieve($fermat_file);
my $lucas_carmichael = retrieve($lucas_carmichael_file);

foreach my $key (keys %$lucas_carmichael) {
    if (exists $fermat->{$key}) {
        die "Found counter-example: $key";
    }
}

say "No counter-example found...";
