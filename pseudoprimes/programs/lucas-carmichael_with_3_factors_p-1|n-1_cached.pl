#!/usr/bin/perl

# Lucas-Carmichael numbers m that have at least 2 prime factors p such that p-1 | m-1.
# https://oeis.org/A329948

# It is not known whether any Carmichael number (A002997) is also a Lucas-Carmichael number (A006972).

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $lucas_carmichael_file = "cache/factors-lucas-carmichael.storable";
my $lucas_carmichael      = retrieve($lucas_carmichael_file);

foreach my $key (sort { log($a) <=> log($b) } keys %$lucas_carmichael) {

    my $n = Math::GMPz->new($key);

    my $dec = $n - 1;
    my $k   = scalar grep { Math::GMPz::Rmpz_divisible_p($dec, Math::GMPz->new($_) - 1) } split(' ', $lucas_carmichael->{$key});

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

# Large terms:

81217436657589747783590403599
19606537382720316183704007491759
13187755899968631006858396930369391751
976932952827738409274132503547218215359
1259113029496390502407645846096387191551
30929869681595566326223026143547237768574058684159
