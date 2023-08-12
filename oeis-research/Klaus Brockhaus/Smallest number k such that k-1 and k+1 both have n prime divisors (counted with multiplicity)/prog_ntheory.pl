#!/usr/bin/perl

# a(n) = smallest number k such that k-1 and k+1 both have n prime divisors (counted with multiplicity).
# https://oeis.org/A154704

# Known terms:
#   4, 5, 19, 55, 271, 1889, 10529, 59777, 101249, 406783, 6581249, 12164095, 65071999, 652963841, 6548416001, 13858918399, 145046192129, 75389157377, 943344975871, 23114453401601, 108772434771967, 101249475018751, 551785225781249

# Lower-bounds:
#   a(27) > 39762436061412004

# New terms:
#   a(24) = 9740041658826751
#   a(25) = 136182187711004671
#   a(26) = 4560483868737535

use 5.036;
use ntheory qw(:all);

my $n = 27;

my $from = powint(2, $n);
my $upto = 2 * $from;

#$from = 107423801603280716;
#$upto = $from+1;

while (1) {

    say "Sieving range: ($from, $upto)";
    my $arr = almost_primes($n, $from, $upto);

    foreach my $i (0 .. $#{$arr} - 2) {
        my $k = $arr->[$i];
        my $t = $arr->[$i + 1];
        $t = $arr->[$i + 2] if ($t < $k + 2);
        if ($t == $k + 2) {
            printf("a(%s) = %s\n", $n, $k + 1);
            exit;
        }
    }

    $from = $upto - 4;
    $upto = int(1.001 * $from);
}

__END__
Sieving range: (9587566134179864, 9683441795521662)
Sieving range: (9683441795521658, 9780276213476874)
a(24) = 9740041658826751
perl prog_ntheory.pl  1917.62s user 68.93s system 94% cpu 35:02.42 total

Sieving range: (135865354137624828, 136001219491762448)
Sieving range: (136001219491762444, 136137220711254192)
Sieving range: (136137220711254188, 136273357931965424)
a(25) = 136182187711004671
perl prog_ntheory.pl  4676.02s user 138.26s system 98% cpu 1:21:25.00 total

Sieving range: (4547130199899370, 4551677330099269)
Sieving range: (4551677330099265, 4556229007429364)
Sieving range: (4556229007429360, 4560785236436789)
a(26) = 4560483868737535
perl prog_ntheory.pl  377.33s user 2.53s system 99% cpu 6:21.88 total
