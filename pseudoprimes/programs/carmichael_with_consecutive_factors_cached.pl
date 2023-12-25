#!/usr/bin/perl

# Can a carmichael number have consecutive prime factors?

# Problem from:
#   https://math.stackexchange.com/questions/1478840/can-a-carmichael-number-have-consecutive-prime-factors

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

my $t = Math::GMPz::Rmpz_init();

while(my($key, $value) = each %$carmichael) {

    my @factors = split(' ', $value);

    my $ok = 1;
    foreach my $i (0..$#factors-1) {

        my $p = $factors[$i];
        my $q = Math::Prime::Util::GMP::next_prime($p);

        if ($q ne $factors[$i+1]) {
            $ok = 0;
            last;
        }
    }

    say $key if $ok;
}

__END__

# No such number is known...
