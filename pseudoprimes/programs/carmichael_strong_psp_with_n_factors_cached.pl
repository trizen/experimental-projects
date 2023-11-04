#!/usr/bin/perl

# Carmichael numbers which are also base-2 strong pseudoprimes.
# https://oeis.org/A063847

# Let a(n) be the smallest Carmichael number with n prime factors that is also a strong pseudoprime to base 2.

# First few terms:
#   15841, 5310721, 440707345, 10761055201, 5478598723585, 713808066913201, 1022751992545146865, 5993318051893040401

# New terms found (24 September 2022):
#   a(11) = 120459489697022624089201
#   a(12) = 27146803388402594456683201
#   a(13) = 14889929431153115006659489681

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

while (my ($key, $value) = each %$carmichael) {

    my @factors = split(' ', $value);
    my $count   = scalar(@factors);

    next if ($count <= 10);

    if (exists $table{$count}) {
        next if ($table{$count} < $key);
    }

    Math::Prime::Util::GMP::is_strong_pseudoprime($key, 2) || next;

    $table{$count} = $key;
}

foreach my $count (sort { $a <=> $b } keys %table) {
    say "a($count) <= $table{$count}";
}

__END__

a(11) <= 120459489697022624089201
a(12) <= 27146803388402594456683201
a(13) <= 14889929431153115006659489681
a(14) <= 12119528395859597855693434006201
a(15) <= 8445045464974686705830286862791601
a(16) <= 431963846549014459308449974667236801
a(17) <= 467214942206286886822015370137826526001
a(18) <= 1249878762341814636782407094268125017522801
a(19) <= 4590172857833958394304163760489663619756066401
a(20) <= 179969791023878308369431665851191959700006574801
a(21) <= 107735170264024836555220903560040388670030679315201
a(27) <= 7043155715130173703570458476044409843679195526432194529835594986452175531142548938830450109251
