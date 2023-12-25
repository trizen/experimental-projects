#!/usr/bin/perl

# Analogue to emirp for Carmichael numbers

# Problem from:
#   https://math.stackexchange.com/questions/4727806/analogue-to-emirp-for-carmichael-numbers

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_fibonacci);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

while(my($key, $value) = each %$carmichael) {
    if (exists $carmichael->{scalar reverse $key}) {
        say $key;
    }
}

__END__

No such number is known > 2^64...
