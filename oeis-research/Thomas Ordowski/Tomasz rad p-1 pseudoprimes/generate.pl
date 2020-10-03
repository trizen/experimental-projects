#!/usr/bin/perl

# https://oeis.org/draft/A306479

use 5.014;
use ntheory qw(factor_exp vecprod forcomb forprimes vecmin is_square_free is_prime vecall factor);

sub rad {
    my ($n) = @_;
    vecprod(map{$_->[0]}factor_exp($n));
}

my %table;

forprimes {
    push @{$table{rad($_-1)}}, $_;
} 1e7;

say "Done sieving...";

#foreach my $rad (keys %table) {
while (my ($rad, $arr) = each %table) {

    my @v = @$arr;

    @v >= 2 or next;

    forcomb {
        my $prod = vecprod(@v[@_]);

        if (rad($prod-1) == $rad) {
            say $prod;
        }

    } scalar(@v), 2;
}

__END__

6031047559681
763546828801
1525781251
184597450297471
732785991945841

var table = Hash()

for p in (primes(781210)) {
    table{p-1 -> rad} := [] << p
}


for p,v in (table) {

    var t = Num(p)
    var len = v.len

    #say "Testing: #{p} -> #{len}"
    #len = 10 if (len > 10)

    for k in (2..2) {
        combinations(v, k, {|*a|
            if (a.prod - 1 -> rad == t) {
                say a.prod
            }
        })
    }
}

#say table{6510}
