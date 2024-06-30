#!/usr/bin/perl

# a(n) is the least start of a run of exactly n successive powerful numbers that are pairwise coprime, or -1 if no such run exists.
# https://oeis.org/A373705

# Known terms:
#   72, 1, 9, 289, 702464, 7827111875, 1321223037317, 1795433547131287

# Lower-bounds:
#   a(9) > 11372840445825665285

use 5.036;
use ntheory qw(:all);

my $n = 9;

#my $lo = 1;
#my $hi = 2;

my $multiplier = 1.01;
my $lo = 11372840445825665285;
my $hi = int($multiplier*$lo);

while (1) {

    say "Sieving range: [$lo, $hi]";
    my $ref = powerful_numbers($lo, $hi);

    my @run = splice(@$ref, 0, $n);

    if (scalar(@run) == $n) {
        foreach my $k (@$ref) {

            if (gcd($run[0], $run[1]) == 1 and gcd($run[0], $run[2]) == 1 and gcd($run[0], $run[-1]) == 1 and gcd($run[1], $run[-1]) == 1) {

                my $ok = 1;
                foreach my $i (0 .. $#run) {
                    foreach my $j ($i + 1 .. $#run) {
                        if (gcd($run[$i], $run[$j]) != 1) {
                            $ok = 0;
                            last;
                        }
                    }
                    $ok || last;
                }

                if ($ok) {
                    say "a($n) = $run[0]";
                    exit;
                }
            }

            push @run, $k;
            shift @run;
        }
    }

    $lo = $run[0] + 1;
    $hi = int($multiplier * $lo);
}

__END__
Sieving range: [562949953421311, 1125899906842622]
Sieving range: [1125899906842623, 2251799813685246]
a(8) = 1795433547131287
perl x.sf  94.95s user 1.90s system 99% cpu 1:37.23 total

Sieving range: [11859295483380873, 23718590966761746]
Sieving range: [23718589832716849, 47437179665433698]
[1]    6420 terminated  perl x.sf
perl x.sf  373.37s user 9.39s system 90% cpu 7:01.38 total

Sieving range: [148830599172111369, 193479778923744768]
Sieving range: [193479775953828126, 251523708739976576]
[1]    8353 killed     perl generate.pl
perl generate.pl  716.20s user 14.29s system 97% cpu 12:31.56 total

Sieving range: [977937583353549976, 1075731341688905088]
Sieving range: [1075731333427897345, 1183304466770687232]
[1]    9352 killed     perl generate.pl
perl generate.pl  1489.81s user 24.70s system 92% cpu 27:10.61 total
