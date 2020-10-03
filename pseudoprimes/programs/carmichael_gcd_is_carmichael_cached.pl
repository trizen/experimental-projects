#!/usr/bin/perl

# Generate new Carmichael numbers of the form gcd(a,b),
# where a,b are both B-smooth Carmichael numbers, for some small B.

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

my @c = grep { (split(' ', $carmichael->{$_}))[-1] <= 6e2 } keys %$carmichael;
#~ my @c = grep { (split(' ', $carmichael->{$_}))[0] > 1e9 } keys %$carmichael;
#~ my @c = grep { (split(' ', $carmichael->{$_}))[1] <= 11 } keys %$carmichael;

say "# ", scalar @c;
say "# ", binomial(scalar(@c), 2);

#~ exit;

forcomb {

    my $c = Math::Prime::Util::GMP::gcd(@c[@_]);

    if ($c > ~0 and not exists $carmichael->{$c} and Math::Prime::Util::GMP::is_carmichael($c)) {
        say $c;
        $carmichael->{$c} = 1;
    }
} scalar(@c), 2;
