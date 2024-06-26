#!/usr/bin/perl

# Numbers k such that k^2 + 1 is a Fermat pseudoprime to base 3.
# https://oeis.org/A333316

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

my %seen;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    if (is_square($n - 1) and is_pseudoprime($n, 3)) {
        printf("%s^2 + 1 = %s\n", sqrtint($n - 1), $n) if !$seen{$n}++;
    }

#<<<
    #~ my $t = mulint($n, $n) + 1;

    #~ if (is_pseudoprime($t, 3) and !is_prime($t)) {
        #~ say $t if !$seen{$t}++;
    #~ }
#>>>
}

__END__
216^2 + 1 = 46657
660^2 + 1 = 435601
1484^2 + 1 = 2202257
1560^2 + 1 = 2433601
8208^2 + 1 = 67371265
52164^2 + 1 = 2721082897
544320^2 + 1 = 296284262401
592956^2 + 1 = 351596817937
649800^2 + 1 = 422240040001
4321800^2 + 1 = 18677955240001
5103210^2 + 1 = 26042752304101
6182220^2 + 1 = 38219844128401
10621380^2 + 1 = 112813713104401
21415680^2 + 1 = 458631349862401
24471720^2 + 1 = 598865079758401
135307008^2 + 1 = 18307986413912065
359624088^2 + 1 = 129329484669831745
535019100^2 + 1 = 286245437364810001
1071782250^2 + 1 = 1148717191415062501
1113233520^2 + 1 = 1239288870051590401
1227427740^2 + 1 = 1506578856921507601
1527496740^2 + 1 = 2333246290710627601
9462748008^2 + 1 = 89543599862907968065
143935711920^2 + 1 = 20717489165917230086401
22812661872000^2 + 1 = 520417541686202544384000001
