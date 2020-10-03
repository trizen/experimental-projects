#!/usr/bin/perl

use 5.014;
use warnings;

use Math::GMPz;

my @list;

while (<>) {
    if (/^(\d+)\s+(\d+)/) {
        my ($n, $k) = ($1, $2);
        $k = Math::GMPz->new($k);
        push @list, [$n, $k];
    }
}

@list = sort { $a->[1] <=> $b->[1] } @list;

my $omega = 8;

foreach my $pair (@list) {
    my ($n, $k) = @$pair;
    if ($n == $omega) {
        say "a($omega) <= $k";
        ++$omega;
    }
}
