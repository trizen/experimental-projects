#!/usr/bin/perl

# Carmichael numbers (A002997) that are super-Poulet numbers (A050217).
# https://oeis.org/A291637

# Terms:
#   294409, 1299963601, 4215885697, 4562359201, 7629221377, 13079177569, 19742849041, 45983665729, 65700513721, 147523256371, 168003672409, 227959335001, 459814831561, 582561482161, 1042789205881, 1297472175451, 1544001719761, 2718557844481, 3253891093249, 4116931056001, 4226818060921, 4406163138721, 4764162536641, 4790779641001, 5419967134849, 7298963852041, 8470346587201

# Let a(n) be the smallest Carmichael number with n prime factors that is also a super-Poulet to base 2.

# See also:
#   https://oeis.org/A178997

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $lucas_carmichael_file = "cache/factors-lucas-carmichael.storable";
my $lucas_carmichael = retrieve($lucas_carmichael_file);

my %table;

sub my_lucas_carmichael_lambda($factors) {
    lcm(map{Math::GMPz->new($_)+1} @$factors);
}

my %seen;

foreach my $n (sort {$a <=> $b } map{Math::GMPz->new($_)}  keys %$lucas_carmichael) {

    my @factors = split(' ', $lucas_carmichael->{$n});
    my $lambda = my_lucas_carmichael_lambda(\@factors);

    #~ next if ($lambda < 1e10);
    #~ next if ($lambda > ~0);
    next if $seen{$lambda}++;

    say $lambda;
}
