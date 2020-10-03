#!/usr/bin/perl

# https://oeis.org/draft/A306479

use 5.014;
use ntheory qw(factor_exp vecprod forcomb forprimes vecmin is_square_free is_prime vecall factor);

#rad(n) = factorback(factorint(n)[, 1]);
#isok(n) = !isprime(n) && issquarefree(n) && select(x->factor(n-1)) == 1;

sub rad {
    my ($n) = @_;
    vecprod(map{$_->[0]}factor_exp($n));
}

my @files = glob("/home/swampyx/Other/Programare/Fun\\ scripts/Pseudoprimes/*.txt");

use Math::GMPz;

my @nums;
my %seen;

foreach my $file(@files) {
    open my $fh, '<', $file;

        while (<$fh>) {

            /\S/ or next;
            /^#/ and next;

            my ($n) = (split(' '))[-1];
            $n || next;

            length($n) <= 25 or next;
            next if $seen{$n}++;

            push @nums, Math::GMPz->new($n);
    }

    close $fh;
}

say "Sorting...";

@nums = sort { $a <=> $b} @nums;

say "Searching...";

foreach my $n(@nums) {

    is_prime($n) && next;
    is_square_free($n) || next;

    my $rad = rad($n-1);

    if (vecall { rad($_-1) == $rad } factor($n)) {
        say $n;
    }
}
