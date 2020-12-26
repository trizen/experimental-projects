#!/usr/bin/perl

# a(n) is the largest n-digit pseudoprime (to base 2).
# https://oeis.org/A067845

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-fermat.storable";
my $fermat        = retrieve($storable_file);

my %table;

foreach my $n (sort { $b <=> $a } map { Math::GMPz->new($_) } keys %$fermat) {

    my $len = length("$n");

    next if $len > 100;
    next if (exists $table{$len});

    $table{$len} //= $n;
    if ($n > $table{$len}) {
        $table{$len} = $n;
    }
}

foreach my $len (sort { $a <=> $b } keys %table) {
    say "$len $table{$len}";
}
