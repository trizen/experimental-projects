#!/usr/bin/perl

# Is there a Carmichael-number divisible by 3×5×17=255?

# Problem from:
#   https://math.stackexchange.com/questions/1513625/is-there-a-carmichael-number-divisible-by-3-times-5-times-17-255

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_fibonacci);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);
#use List::Util qw(uniq);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

my $t = Math::GMPz::Rmpz_init();

while(my($key, $value) = each %$carmichael) {

    if (substr($value, 0, 2) eq '3 ') {
        if (index($value, " 5 ") != -1 and index($value, " 17 ") != -1) {
            say $key;
        }
    }
}

__END__
1886616373665
158353658932305
881715504450705
3193231538989185
6128613921672705
11947816523586945
16057190782234785
26708253318968145
31454143858820145
45466829089086945
101817952350880305
121719617715279585
162137886575734785
171800042106877185
180950795673242145
184882434303977985
220629545178715905
224811969542371905
462937246809774465
781506906921758865
916541202603455265
947087538769733505
