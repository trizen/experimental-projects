#!/usr/bin/perl

# Generate new Lucas-Carmichael numbers of the form n*p,
# where n is a Lucas-Carmichael number and p = LucasLambda(n)+1 is prime,
# where LucasLambda(n) = lcm(p_1+1, p_2+1, ..., p_k+1).

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util qw(uniq);

my $lucas_carmichael_file = "cache/factors-lucas-carmichael.storable";
my $lucas_carmichael = retrieve($lucas_carmichael_file);

my %table;

sub my_lucas_carmichael_lambda($factors) {
    Math::Prime::Util::GMP::lcm(map{ Math::Prime::Util::GMP::addint($_, 1) } @$factors);
}

sub is_lucas_carmichael ($n, $factors) {
    my $np1 = Math::GMPz->new($n)+1;
    return if not vecall { Math::GMPz::Rmpz_divisible_p($np1, Math::GMPz->new($_)+1) } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

my %seen;

foreach my $n (keys %$lucas_carmichael) {

    #length($n) > 100 or next;

    my @factors = split(' ', $lucas_carmichael->{$n});
    my $lambda = my_lucas_carmichael_lambda(\@factors);
    my $p = Math::Prime::Util::GMP::addint($lambda, 1);

    #if (Math::Prime::Util::GMP::modint($n,$p) > 0 and is_prime($p)) {
    if (Math::Prime::Util::GMP::gcd($n, $p) == 1) {
        my $lc = Math::Prime::Util::GMP::mulint($n, $p);
        if (not exists $lucas_carmichael->{$lc} and is_lucas_carmichael($lc, [@factors, factor($p)])) {
            say $lc;
        }
    }

    #~ next if ($lambda < 1e10);
    #~ next if ($lambda > ~0);
    #~ next if $seen{$lambda}++;

    #~ say $lambda;
}
