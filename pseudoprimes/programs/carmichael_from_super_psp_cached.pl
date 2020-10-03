#!/usr/bin/perl

# Generate Carmichael numbers from the divisors of Fermat super-pseudoprimes.
# See also: https://oeis.org/A291637

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use List::Util qw(uniq);
use experimental qw(signatures);

my $superpsp_file = "cache/factors-superpsp.storable";
my $superpsp      = retrieve($superpsp_file);

my %table;

sub my_is_carmichael_fast ($n, $factors) {
    my $nm1 = Math::Prime::Util::GMP::subint($n, 1);
    return if not vecall {
        Math::Prime::Util::GMP::modint($nm1, ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1)) eq '0'
    } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

while (my ($k, $v) = each %$superpsp) {

    my @factors = split(' ', $v);

    scalar(@factors) >= 8 or next;

    foreach my $k (7 .. scalar(@factors) - 1) {
        forcomb {

            my @f = @factors[@_];
            my $n = Math::Prime::Util::GMP::vecprod(@f);

            if (not exists($superpsp->{$n}) and my_is_carmichael_fast($n, \@f)) {
                say $n;
            }

        } scalar(@factors), $k;
    }
}
