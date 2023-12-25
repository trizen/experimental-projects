#!/usr/bin/perl

# List Carmichael numbers in a given range.

# Problem from:
#   https://math.stackexchange.com/questions/4734978/how-can-we-find-a-carmichael-number-near-a-huge-given-number

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_over_psp);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

my $min = "9999999999999999999999999999796847326318726073975133650980786082646990292703172311852106037044385201";
my $max = "10000000000000000000000000000090165987523064535571479173405047627125202459134286779355757424137024721";

#my $min = "9999999999999999999999999995194780645298842465772438047052058885837645928421429394846343577780058169";
#my $max = "10000000000000000000000000000405929367865700162694655745350302085810080768959837103297359653235421369";

while(my($key, $value) = each %$carmichael) {
    if (
        Math::Prime::Util::GMP::cmpint($key, $min) > 0 and
        Math::Prime::Util::GMP::cmpint($key, $max) < 0
    ) {
        say $key;
    }
}

__END__
