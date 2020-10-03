#!/usr/bin/perl

# https://oeis.org/draft/A306479

use 5.014;
use List::Util qw(uniq);
use ntheory qw(factor_exp vecprod forcomb forprimes vecmin is_square_free is_prime vecall factor);

sub rad {
    my ($n) = @_;
    vecprod(map{$_->[0]}factor_exp($n));
}

my %table;


forprimes {

    push @{$table{rad($_-1)}}, $_;

    foreach my $k(2..50) {
        my $q = ($_-1)*$k + 1;

        if (is_prime($q)) {
            my $rad = rad($q-1);
            push @{$table{$rad}}, $q;
            @{$table{$rad}} = uniq(@{$table{$rad}});
        }
    }

} 5*1e7;

say "Done sieving...";

my %seen;

#foreach my $rad (keys %table) {
while (my ($rad, $arr) = each %table) {

    my @v = uniq(@$arr);

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

1525781251
732785991945841
6031047559681
763546828801
184597450297471

1525781251
732785991945841
184597450297471
6031047559681
763546828801
55212580317094201

763546828801
184597450297471
732785991945841
18641350656000001
55212580317094201
6031047559681
1525781251

763546828801, 6031047559681, 184597450297471, 732785991945841, 18641350656000001, 55212580317094201

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
