#!/usr/bin/perl

# Carmichael numbers n such that n-1 is a perfect power.
# https://oeis.org/A265328

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

    if (is_power($n - 1) and is_carmichael($n)) {
        say $n if !$seen{$n}++;
    }

#<<<
    #~ my $t = Math::GMPz->new($n)**4 + 1;

    #~ if (is_carmichael($t)) {
        #~ say $t if !$seen{$t}++;
    #~ }
#>>>
}

__END__
1729
46657
2433601
2628073
19683001
67371265
110592000001
351596817937
422240040001
432081216001
2116874304001
3176523000001
18677955240001
458631349862401
286245437364810001
312328165704192001
12062716067698821000001
20717489165917230086401
211215936967181638848001
411354705193473163968001
14295706553536348081491001
32490089562753934948660824001
782293837499544845175052968001
611009032634107957276386802479001
