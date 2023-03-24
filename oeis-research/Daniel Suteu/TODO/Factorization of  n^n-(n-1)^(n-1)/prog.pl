#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

use ntheory qw(factor);

#use Math::GMPz;
use Math::AnyNum qw(ipow);

foreach my $n(64..100) {
    my @f = factor(ipow($n,$n) - ipow($n-1, $n-1));
    say "$n $f[-1]";
}
