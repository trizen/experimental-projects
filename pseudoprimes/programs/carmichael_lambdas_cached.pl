#!/usr/bin/perl

# Generate lambda values of Carmichael numbers.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

my %table;

sub my_carmichael_lambda($factors) {
    Math::Prime::Util::GMP::lcm(map{ Math::Prime::Util::GMP::subint($_, 1) } @$factors);
}

my %seen;

foreach my $n (keys %$carmichael) {

    #length($n) > 100 or next;

    my @factors = split(' ', $carmichael->{$n});
    my $lambda = my_carmichael_lambda(\@factors);

    #~ next if ($lambda < 1e10);
    #~ next if ($lambda > ~0);
    next if $seen{$lambda}++;

    say $lambda;
}
