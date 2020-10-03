#!/usr/bin/perl

# Smallest n-digit Carmichael numbers
# https://oeis.org/A048123

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($storable_file);

my %table;

while (my ($key, $value) = each %$carmichael) {

    substr($key, 0, 1) eq '1' or next;

    my $len = length($key);

    next if $len <= 20;
    next if $len > 100;

    my $n = Math::GMPz::Rmpz_init_set_str($key, 10);

    $table{$len} //= $n;

    if ($n < $table{$len}) {
        $table{$len} = $n;
    }
}

foreach my $len (sort { $a <=> $b } grep { $_ > 20 } keys %table) {
    say "$len $table{$len}";
}
