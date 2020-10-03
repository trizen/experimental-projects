#!/usr/bin/perl

# Poulet numbers (Fermat pseudoprimes to base 2) k that have an abundancy index sigma(k)/k that is larger than the abundancy index of all smaller Poulet numbers.
# https://oeis.org/A328691

# Known terms:
#   341, 561, 645, 18705, 2113665, 2882265, 81722145, 9234602385, 19154790699045, 43913624518905, 56123513337585, 162522591775545, 221776809518265, 3274782926266545, 4788772759754985

use 5.014;
use strict;
use warnings;

use experimental qw(signatures);
use ntheory qw(forsquarefree forprimes divisor_sum);
use Math::AnyNum;
use Math::Prime::Util::GMP qw(gcd mulint is_pseudoprime divisors);

my $rad = "903653840347639568725149973748479285201766630927341485";
my @divisors = divisors($rad);

my @squarefree;

#forsquarefree {
forprimes {
        #if (gcd($rad, $_) == 1 and $_ > 1) {
            push @squarefree, $_;
        #}
} 1e8;

my %seen;

sub abundancy ($n) {
    (Math::AnyNum->new(divisor_sum($n)) / $n)->float;
}

sub generate ($root, $limit = 1.94) {

    my $abundancy = abundancy($root);
    $abundancy > $limit or return;

    return if $seen{$root}++;

    my @new;

    foreach my $s (@squarefree) {
        my $psp = mulint($s, $root);
        if (is_pseudoprime($psp, 2)) {
            say $psp, "\t-> ", abundancy($psp);
            push @new, $psp;
        }
    }

    if (@new) {
        say "# Found: ", scalar(@new), " new pseudoprimes";
    }

    foreach my $n(grep { abundancy($_) > $abundancy } @new) {
        generate($n, $abundancy);
    }
}

foreach my $d (@divisors) {
    if (is_pseudoprime($d, 2)) {
        say "# Divisor $d";
        generate($d);
    }
}
