#!/usr/bin/perl

# Smallest "non-residue" pseudoprime to base prime(n).
# https://oeis.org/A307809

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

use Math::GMPz;
use IO::Uncompress::Bunzip2;

my $file = "/home/swampyx/Other/Programare/experimental-projects/pseudoprimes/psps-below-2-to-64.txt.bz2";
my $z    = IO::Uncompress::Bunzip2->new($file);

sub least_nonresidue_odd ($n) {    # for odd n

    my @factors = map { $_->[0] } factor_exp($n);

    for (my $p = 2 ; ; $p = next_prime($p)) {
        (vecall { kronecker($p, $_) == 1 } @factors) || return $p;
    }
}

sub least_nonresidue_sqrtmod ($n) {    # for any n
    for (my $p = 2 ; ; $p = next_prime($p)) {
        sqrtmod($p, $n) // return $p;
    }
}

my %table;

while (1) {
    chomp(my $n = $z->getline // last);

    my $q = least_nonresidue_sqrtmod($n);

    if (exists $table{$q}) {
        next if ($table{$q} < $n);
    }

    if (powmod($q, ($n-1)>>1, $n) == $n-1) {
        $table{$q} = $n;
        my $k = prime_count($q);
        say "a($k) <= $n";
    }
}

say "\nFinal results:";

foreach my $k(sort {$a <=> $b} keys %table) {
    my $n = prime_count($k);
    printf("a(%2d) <= %s\n", $n, $table{$k});
}

__END__
a( 1) <= 3277
a( 4) <= 721801
a( 3) <= 1809697
a( 2) <= 5173601
a( 5) <= 162776041
a( 6) <= 512330281
a( 7) <= 103029806881
a( 8) <= 17654641646041
a( 9) <= 271560615258241
a(12) <= 17676352761153241
a(10) <= 54510129886406041
a(11) <= 210599929853885881
