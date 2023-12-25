#!/usr/bin/perl

# Is there a Fibonacci Number that is also a Carmichael Number?

# Problem from:
#   https://math.stackexchange.com/questions/4827535/is-there-a-fibonacci-number-that-is-also-a-carmichael-number

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

use Math::Sidef qw(is_fibonacci);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

while(my($key, $value) = each %$carmichael) {
    if (is_fibonacci($key)) {
        say $key;
    }
}

__END__

No such number is known...
