#!/usr/bin/perl

# Find Carmichael numbers with only odd digits.

# Problem from:
#   https://math.stackexchange.com/questions/4736989/is-there-a-third-carmichael-number-with-only-odd-digits

# Below 2^64, there are only two such numbers:
#   53711113, 3559313513953

# Is there a third Carmichael number with only odd digits?

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_over_psp);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

while(my($key, $value) = each %$carmichael) {

    if ($key =~ tr/02468//) {   # contains an even digit
        next;
    }

    say $key;
}

__END__

No other term is known...
