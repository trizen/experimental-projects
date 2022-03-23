#!/usr/bin/perl

# Quasi-narcissistic numbers: k-digit numbers n whose sum of k-th powers of their digits is equal to n +- 1.
# https://oeis.org/A300160

use 5.020;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);
use Algorithm::Combinatorics qw(combinations_with_repetition);

foreach my $k (1 .. 100) {

    my @powers = map { [$_, powint($_, $k)] } 0 .. 9;
    my $iter   = combinations_with_repetition(\@powers, $k);

    while (my $arr = $iter->next) {

        my $t = vecsum(map { $_->[1] } @$arr);
        my $r = fromdigits([sort { $b <=> $a } map { $_->[0] } @$arr]);

        if ($t > 0 and fromdigits([sort { $b <=> $a } todigits(subint($t, 1))]) == $r) {
            say "[-1] Found: ", $t - 1;
        }

        if (fromdigits([sort { $b <=> $a } todigits(addint($t, 1))]) == $r) {
            say "[+1] Found: ", $t + 1;
        }
    }
}

__END__
[+1] Found: 35
[+1] Found: 75
[+1] Found: 715469
[+1] Found: 688722
[+1] Found: 629643
[+1] Found: 528757
[+1] Found: 71419078
[-1] Found: 63645890
[-1] Found: 31672867
[-1] Found: 63645891
[+1] Found: 44936324
[-1] Found: 73495876
[-1] Found: 1136483324
[-1] Found: 310374095702
[+1] Found: 785103993880
[+1] Found: 785103993881
[+1] Found: 989342580966
[+1] Found: 23046269501054
[-1] Found: 50914873393416
[-1] Found: 37434032885798
[+1] Found: 75759895149717
[+1] Found: 4020913800954247
[+1] Found: 4023730658941129
[+1] Found: 4586833243299785
[-1] Found: 303559171720546923
[+1] Found: 303559240439761517
[+1] Found: 186646559608106552
