#!/usr/bin/perl

# Generate new Lucas-Carmichael numbers of the form gcd(a,b),
# where a,b are both B-smooth Lucas-Carmichael numbers, for some small B.

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
my $lucas_carmichael      = retrieve($lucas_carmichael_file);

my %table;

sub my_lucas_carmichael_lambda ($factors) {
    Math::Prime::Util::GMP::lcm(map { Math::Prime::Util::GMP::addint($_, 1) } @$factors);
}

sub is_lucas_carmichael ($n, $factors) {
    scalar(@$factors) >= 3 or return;
    my $np1 = Math::GMPz->new($n) + 1;
    return if not vecall { Math::GMPz::Rmpz_divisible_p($np1, Math::GMPz->new($_) + 1) } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

my $min = 1e12;
my @c   = grep { (split(' ', $lucas_carmichael->{$_}))[-1] <= 1e3 } keys %$lucas_carmichael;

#~ my @c = grep { (split(' ', $lucas_carmichael->{$_}))[0] > 1e9 } keys %$lucas_carmichael;
#~ my @c = grep { (split(' ', $lucas_carmichael->{$_}))[1] <= 11 } keys %$lucas_carmichael;

say "# ", scalar @c;
say "# ", binomial(scalar(@c), 2);

#~ exit;

forcomb {

    my $c = Math::Prime::Util::GMP::gcd(@c[@_]);

    if ($c > $min and not exists $lucas_carmichael->{$c} and is_lucas_carmichael($c, [factor($c)])) {
        say $c;
        $lucas_carmichael->{$c} = 1;
    }
}
scalar(@c), 2;
