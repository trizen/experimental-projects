#!/usr/bin/perl

# Let k = A000396(n) be the n-th perfect number, a(n) is the least number m such that k*d*m - 1 is prime for all of the proper divisors d of k so their product is a Lucas-Carmichael number.

# Lucas-Carmichael version of:
#   https://oeis.org/A319008

# Known terms:
#   1, 219, 10405375365

# Inspired by the PARI program by David A. Corneth from OEIS A372238.

# See also:
#   https://oeis.org/A372238/a372238.gp.txt

# Lower-bounds:
#   a(4) > 427378360631775

# Very close terms:
# m = 456970979241285 with count = 11
# m = 457161022238415 with count = 12
# m = 479116382906850 with count = 12
# m = 487154131073910 with count = 12
# m = 520102641846450 with count = 12
# m = 604772181177255 with count = 12
# m = 606519755364075 with count = 12
# m = 608918796114240 with count = 12
# m = 609560323577355 with count = 12
# m = 634187491355355 with count = 12
# m = 635071285281180 with count = 12
# m = 636414993983145 with count = 12
# m = 648706659116505 with count = 12
# m = 653767594125660 with count = 12
# m = 676935716137695 with count = 12
# m = 685773615106275 with count = 12
# m = 687577274690775 with count = 12
# m = 1233704444559810 with count = 12
# m = 1239845812928385 with count = 12
# m = 1247623475226960 with count = 12
# m = 1285276783396620 with count = 12
# m = 1296313352470260 with count = 12
# m = 1329771512226450 with count = 12
# m = 1340570940390645 with count = 12
# m = 1358981461461195 with count = 12
# m = 1374699628324575 with count = 12
# m = 1392529941110055 with count = 12
# m = 1410364920228960 with count = 12
# m = 1420453043765745 with count = 12

use 5.036;
#use integer;
use ntheory                qw(:all);
use Time::HiRes            qw (time);
use List::Util             qw(all any);
use Math::Prime::Util::GMP qw();

if (!defined(&ntheory::subint) or !defined(&ntheory::sub1int)) {

    warn "If possible, please install the GitHub version of Math::Prime::Util\n";
    warn "From: https://github.com/danaj/math-prime-util\n\n";

    *ntheory::subint = sub ($x, $y) {
        no integer;
        $x - $y;
    };

    *ntheory::sub1int = sub ($x, $y) {
        no integer;
        $x - 1;
    };

    *ntheory::modint = sub ($x, $y) {
        no integer;
        $x % $y;
    };
}

my $PERFECT_N;
my @DIVISORS;

sub isrem($m, $p, $n) {
    all { modint(sub1int(vecprod($PERFECT_N, $m, $_)), $p) != 0 } @DIVISORS;
}

sub remaindersmodp($p, $n) {
    grep { isrem($_, $p, $n) } (0 .. $p - 1);
}

sub remainders_for_primes($n, $primes) {

    my $res = [[0, 1]];

    foreach my $p (@$primes) {

        my @rems = remaindersmodp($p, $n);

        my @nres;
        foreach my $r (@$res) {
            foreach my $rem (@rems) {
                push @nres, [chinese($r, [$rem, $p]), lcm($p, $r->[1])];
            }
        }
        $res = \@nres;
    }

    sort { $a <=> $b } map { $_->[0] } @$res;
}

sub deltas ($integers) {

    my @deltas;
    my $prev = 0;

    foreach my $n (@$integers) {
        push @deltas, $n - $prev;
        $prev = $n;
    }

    return \@deltas;
}

sub generate($n) {

    my $maxp = 11;

    $maxp = 23 if ($n >= 3);
    $maxp = 29 if ($n >= 4);

    #$maxp = 17 if ($n >= 8);
    #$maxp = 29 if ($n >= 10);
    #$maxp = 31 if ($n >= 12);

    my @primes = @{primes($maxp)};

    #@primes = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31);   # needs lots of RAM
    #@primes = (3, 5, 7, 11, 13, 17, 19, 23, 29);
    #@primes = (7, 11, 13, 17, 19, 31, 23, 29, 47);     # also needs lots of RAM
    #@primes = (7, 11, 13, 17, 19, 31, 23, 29);
    #@primes = (7, 11, 13, 17, 19, 23, 29, 31, 37);
    #@primes = (7, 11, 13, 17, 19, 23, 29, 31);         # needs over 3GB of RAM
    #@primes = (7, 11, 13, 17, 19, 23, 29);

    my @r = remainders_for_primes($n, \@primes);
    my @d = @{deltas(\@r)};
    my $s = vecprod(@primes);

    while ($d[0] == 0) {
        shift @d;
    }

    push @d, $r[0] + $s - $r[-1];

    my $j      = 0;
    my $m      = $r[0];
    my $d_len  = scalar(@d);
    my $t0     = time;

    #my $min_m = 1116642267975;
    #my $min_m = 362350376931675;
    #my $min_m = 362317534199115;

    #$j = 350000000;
    #$m = 1149484727625;

    #$j = 11032*1e7;

    #$j = 110320000000;
    #$m = 362317534199115;

    #$j = 160280000000;     # wrong computation (integer overflow, due to 'use integer')
    #$m = 526398244939035;  # wrong computation (integer overflow, due to 'use integer')

    $j = 215090000000;
    $m = 706407527875140;

    my $prev_m = $m;
    #~ my $t;

    for (; ; ++$j) {

        #~ if (vecall { is_prime(vecprod($m, $PERFECT_N, $_) - 1) } @DIVISORS) {
            #~ return $m;
        #~ }

#<<<
        #~ if (
                #~ is_prime(sub1int(mulint($m, $PERFECT_N)))
            #~ and is_prime(sub1int(vecprod($m, $PERFECT_N, $DIVISORS[1])))
            #~ and is_prime(sub1int(vecprod($m, $PERFECT_N, $DIVISORS[2])))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[3]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[4]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[5]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[6]), 1))
        #~ ) {
            #~ if (vecall { Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $_), 1)) } reverse @DIVISORS) {
                #~ warn "Found new term: $m\n";
                #~ return $m;
            #~ }
            #~ say "Almost: $m";
        #~ }
#>>>

        #~ if (
                #~ is_prime(mulint($m, $PERFECT_N)-1)
            #~ and is_prime(vecprod($m, $PERFECT_N, $DIVISORS[1])-1)
            #~ and is_prime(vecprod($m, $PERFECT_N, $DIVISORS[2])-1)
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[3]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[4]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[5]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[6]), 1))
        #~ ) {
            #~ if (vecall { Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $_), 1)) } reverse @DIVISORS) {
                #~ warn "Found new term: $m\n";
                #~ return $m;
            #~ }
            #~ say "Almost: $m";
        #~ }

        if (
                is_prime(mulint($m, $PERFECT_N)-1)
            and is_prime(vecprod($m, $PERFECT_N, $DIVISORS[1])-1)
            and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[2]), 1))
            and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[3]), 1))
            and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[4]), 1))
            and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[5]), 1))
            and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[6]), 1))
        ) {
            if (vecall { Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $_), 1)) } reverse @DIVISORS) {
                warn "Found new term: $m\n";
                return $m;
            }
            say "Almost: $m";
        }

        #~ $t = mulint($m, $PERFECT_N);

        #~ if (
                #~ is_prime($t-1)
            #~ and is_prime(mulint($t, $DIVISORS[1])-1)
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $DIVISORS[2]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $DIVISORS[3]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $DIVISORS[4]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $DIVISORS[5]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $DIVISORS[6]), 1))
        #~ ) {
            #~ if (vecall { Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::mulint($t, $_), 1)) } reverse @DIVISORS) {
                #~ warn "Found new term: $m\n";
                #~ return $m;
            #~ }
            #~ say "Almost: $m";
        #~ }

        #~ if (
                #~ is_prime(mulint($m, $PERFECT_N) - 1)
            #~ and is_prime(vecprod($m, $PERFECT_N, $DIVISORS[1]) - 1)
            #~ and is_prime(vecprod($m, $PERFECT_N, $DIVISORS[2]) - 1)
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[3]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[4]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[5]), 1))
            #~ and Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $DIVISORS[6]), 1))
        #~ ) {
            #~ if (vecall { Math::Prime::Util::GMP::is_prob_prime(Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::vecprod($m, $PERFECT_N, $_), 1)) } reverse @DIVISORS) {
                #~ warn "Found new term: $m\n";
                #~ return $m;
            #~ }
            #~ say "Almost: $m";
        #~ }

        if (!($j % 10000000)) {
            #no integer;
            my $tdelta = time - $t0;
            say "[$j] Searching for a($n) with m = $m";
            say "Performance: ", (($m - $prev_m) / 1e9) / $tdelta, " * 10^9 terms per second";
            $t0     = time;
            $prev_m = $m;
        }

        $m += $d[$j % $d_len];
    }
}

my @perfect_numbers = (6, 28, 496, 8128, 33550336, 8589869056, 137438691328, 2305843008139952128);

#foreach my $n (1 .. $#perfect_numbers) {
foreach my $n (4) {

    $PERFECT_N = $perfect_numbers[$n - 1];
    @DIVISORS  = grep { $_ < $PERFECT_N } divisors($PERFECT_N);

    say "a($n) = ", generate($n);
}

__END__
a(1) = 4
a(2) = 219
a(3) = 10405375365
Searching for a(4) with m = 32842303065
Performance: 1.5614861010746 * 10^9 terms per second
Searching for a(4) with m = 65684651175
Performance: 1.56154555876966 * 10^9 terms per second
Searching for a(4) with m = 98527241490
Performance: 1.5464539801719 * 10^9 terms per second
...
Searching for a(4) with m = 1050957172305
Performance: 1.71428564915388 * 10^9 terms per second
Searching for a(4) with m = 1083799848120
Performance: 1.72325209900448 * 10^9 terms per second
Searching for a(4) with m = 1116642267975
Performance: 1.70541482388418 * 10^9 terms per second
Parameter '1.86717023421774e+19' must be an integer at lucas-carmichael_sieve.pl line 85.
perl lucas-carmichael_sieve.pl  601.73s user 0.80s system 98% cpu 10:14.61 total

[350000000] Searching for a(4) with m = 1149484727625
Performance: 0 * 10^9 terms per second
[360000000] Searching for a(4) with m = 1182327251640
Performance: 1.66056755731864 * 10^9 terms per second
[370000000] Searching for a(4) with m = 1215169614270
Performance: 1.65895620649441 * 10^9 terms per second

Performance: 1.4175953681182 * 10^9 terms per second
Searching for a(4) with m = 350625634267065
Performance: 1.41803784474121 * 10^9 terms per second
Searching for a(4) with m = 350658476706915
Performance: 1.40602032071008 * 10^9 terms per second
Searching for a(4) with m = 350691319250415
Performance: 1.40442087323069 * 10^9 terms per second

Searching for a(4) with m = 362251849668555
Performance: 1.4192216865402 * 10^9 terms per second
Searching for a(4) with m = 362284692198495
Performance: 1.41473921738723 * 10^9 terms per second
Searching for a(4) with m = 362317534199115
Performance: 1.41040733045594 * 10^9 terms per second
Searching for a(4) with m = 362350376931675
Performance: 1.41373105497306 * 10^9 terms per second

[110320000000] Searching for a(4) with m = 362317534199115
Performance: 0 * 10^9 terms per second
[110330000000] Searching for a(4) with m = 362350376931675
Performance: 1.40461039787894 * 10^9 terms per second

[110320000000] Searching for a(4) with m = 362317534199115
Performance: 0 * 10^9 terms per second
[110330000000] Searching for a(4) with m = 362350376931675
Performance: 1.70983694221175 * 10^9 terms per second

[121180000000] Searching for a(4) with m = 397984398300555
Performance: 1.68525617171433 * 10^9 terms per second
[121190000000] Searching for a(4) with m = 398017240726185
Performance: 1.47424455387561 * 10^9 terms per second
[121200000000] Searching for a(4) with m = 398050083001560
Performance: 1.47310970428375 * 10^9 terms per second
[121210000000] Searching for a(4) with m = 398082925353270
Performance: 1.61055986938184 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  21122.32s user 20.95s system 97% cpu 5:59:43.73 total

[121870000000] Searching for a(4) with m = 400250524984350
Performance: 3.10328813863351 * 10^9 terms per second
[121880000000] Searching for a(4) with m = 400283367300780
Performance: 3.10010817292662 * 10^9 terms per second
[121890000000] Searching for a(4) with m = 400316209946070
Performance: 3.09432086099216 * 10^9 terms per second
[121900000000] Searching for a(4) with m = 400349052279165
Performance: 3.08248558125358 * 10^9 terms per second

[130070000000] Searching for a(4) with m = 427181306103585
Performance: 3.07898963641806 * 10^9 terms per second
[130080000000] Searching for a(4) with m = 427214148532860
Performance: 3.09791102836351 * 10^9 terms per second
[130090000000] Searching for a(4) with m = 427246990886925
Performance: 3.10067011497207 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  8873.81s user 1.73s system 99% cpu 2:28:16.48 total

[133950000000] Searching for a(4) with m = 439924163611485
Performance: 3.01957964910555 * 10^9 terms per second
[133960000000] Searching for a(4) with m = 439957006081725
Performance: 3.0755344853796 * 10^9 terms per second
[133970000000] Searching for a(4) with m = 439989848578815
Performance: 2.95290669064271 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  4187.84s user 2.13s system 99% cpu 1:10:08.69 total

[160270000000] Searching for a(4) with m = 526365402542265
Performance: 2.96650641996435 * 10^9 terms per second
[160280000000] Searching for a(4) with m = 526398244939035
Performance: 3.16577542153858 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  26869.18s user 7.59s system 99% cpu 7:31:02.61 total

[111590000000] Searching for a(4) with m = 366488521444125
Performance: 2.8832954718655 * 10^9 terms per second
[111600000000] Searching for a(4) with m = 366521363781690
Performance: 2.87280423938577 * 10^9 terms per second

[113220000000] Searching for a(4) with m = 371841834917685
Performance: 2.88318273060244 * 10^9 terms per second
[113230000000] Searching for a(4) with m = 371874677531910
Performance: 2.86219972334546 * 10^9 terms per second

[118340000000] Searching for a(4) with m = 388657152165945
Performance: 2.80590453396676 * 10^9 terms per second
[118350000000] Searching for a(4) with m = 388689994195620
Performance: 2.80519173767827 * 10^9 terms per second
[118360000000] Searching for a(4) with m = 388722836977170
Performance: 2.77736958720161 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  8991.83s user 15.31s system 97% cpu 2:33:26.49 total

[132320000000] Searching for a(4) with m = 434570849619870
Performance: 2.76760626145931 * 10^9 terms per second
Almost: 434573273120565
Almost: 434574510728820
Almost: 434575018599645
Almost: 434575695350265
Almost: 434577433675425
Almost: 434586566415690
Almost: 434586994863600
Almost: 434588872201575
Almost: 434592719946465
Almost: 434594474646255
Almost: 434594714750775
Almost: 434596810380285
Almost: 434597403735645
Almost: 434602533896025
[132330000000] Searching for a(4) with m = 434603692384095
Performance: 2.8747204734859 * 10^9 terms per second
Almost: 434611427328210
^C
perl lucas-carmichael_sieve_a4.pl  16125.67s user 13.77s system 99% cpu 4:30:34.81 total

[133430000000] Searching for a(4) with m = 438216357791355
Performance: 2.90467960657089830572985027622812 * 10^9 terms per second

[137580000000] Searching for a(4) with m = 451845960766500
Performance: 2.88912964130762103307627157356286 * 10^9 terms per second
Almost: 451849778144310
Almost: 451855562001000
Almost: 451864642486290
Almost: 451867788477600
^[[A
Almost: 451873874732430
^C
perl lucas-carmichael_sieve_a4.pl  5978.77s user 3.48s system 98% cpu 1:41:01.59 total

[143530000000] Searching for a(4) with m = 471387198410700
Performance: 2.91957014460405014616862830898186 * 10^9 terms per second
Almost: 471388841346360
Almost: 471389185689000
Almost: 471393260135955
Almost: 471393475015125
Almost: 471394789890720
Almost: 471412761138150
[143540000000] Searching for a(4) with m = 471420040830570
Performance: 2.90583486442200344406729948743589 * 10^9 terms per second
Almost: 471423868291365
Almost: 471424504902585
^C
perl lucas-carmichael_sieve_a4.pl  6756.92s user 5.73s system 97% cpu 1:56:00.68 total

Performance: 2.90140065591889390500977423580485 * 10^9 terms per second
Almost: 481208569038420
Almost: 481209075004665
Almost: 481209307178295
Almost: 481210436631015
Almost: 481211003604345
Almost: 481219102203840
Almost: 481225957300920
Almost: 481226083458615
Almost: 481226879478840
Almost: 481232309515635
Almost: 481235207016135
[146530000000] Searching for a(4) with m = 481239922934070
Performance: 2.85680376414766246038496846299744 * 10^9 terms per second
Almost: 481240080515025
Almost: 481244054059380
^C
perl lucas-carmichael_sieve_a4.pl  3290.16s user 5.56s system 94% cpu 57:54.82 total

[152180000000] Searching for a(4) with m = 499795888004805
Performance: 2.9350811523863173806411759050734 * 10^9 terms per second
Almost: 499800080428935
Almost: 499801135902900

[153790000000] Searching for a(4) with m = 505083517169700
Performance: 2.94726499939512437380270117952514 * 10^9 terms per second
Almost: 505087487736975
Almost: 505089553781490
Almost: 505089714737355

[158600000000] Searching for a(4) with m = 520880719313955
Performance: 3.02349979589377295592118535009768 * 10^9 terms per second
Almost: 520881385170135
Almost: 520882901001210
Almost: 520884209325630
Almost: 520884602970765
^C
perl lucas-carmichael_sieve_a4.pl  12693.38s user 12.83s system 97% cpu 3:36:10.65 total

[162460000000] Searching for a(4) with m = 533557891923525
Performance: 1.70133785053312764836258652926472 * 10^9 terms per second
Almost: 533558224775565
Almost: 533561587151340
Almost: 533562588517350
Almost: 533563049348160
Almost: 533569358998170
Almost: 533571196420815
Almost: 533572039212630
Almost: 533572811165940
Almost: 533581793492880
Almost: 533583080068170
Almost: 533584056659115
Almost: 533588653350045
Almost: 533589175009905
Almost: 533589194137545
^C
perl lucas-carmichael_sieve_a4.pl  4246.76s user 6.08s system 88% cpu 1:19:49.95 total

[170230000000] Searching for a(4) with m = 559076449471125
Performance: 2.88805049270999229709202592308107 * 10^9 terms per second
Almost: 559076557883235
Almost: 559076953487715
Almost: 559078852806540
Almost: 559078906374120
Almost: 559080302605110
Almost: 559081403906325
Almost: 559091694687060
Almost: 559094595698925
Almost: 559095941732265
Almost: 559097076976185
Almost: 559104389055960

[172770000000] Searching for a(4) with m = 567418422616650
Performance: 0.977967883818918429183148517300625 * 10^9 terms per second
Almost: 567422354655735
Almost: 567424156737555
Almost: 567429153181425
Almost: 567431486175165
Almost: 567431488236990
Almost: 567431644404705
Almost: 567434648223105
Almost: 567436006616310
Almost: 567444790277970
Almost: 567444985894020
Almost: 567446432308290
[172780000000] Searching for a(4) with m = 567451265214210
Performance: 0.980588872785445148804351020134812 * 10^9 terms per second
^C
perl lucas-carmichael_sieve_a4.pl  11496.49s user 16.46s system 96% cpu 3:19:38.90 total

[181360000000] Searching for a(4) with m = 595630058024235
Performance: 2.75619232810554454276334698827083 * 10^9 terms per second
Almost: 595631729891355
Almost: 595634955171270
Almost: 595636855591455

[182110000000] Searching for a(4) with m = 598093239297645
Performance: 2.21748413441381620770995251609054 * 10^9 terms per second
Almost: 598095700532025
Almost: 598098038523135
Almost: 598099482407265
Almost: 598099949930640
Almost: 598100522932575
Almost: 598102842165675
Almost: 598105277214525
Almost: 598107986157975
Almost: 598115606244735
Almost: 598117785114930
Almost: 598119054166920
Almost: 598119248212995
^C
perl lucas-carmichael_sieve_a4.pl  10876.26s user 12.78s system 97% cpu 3:06:53.75 total

[193100000000] Searching for a(4) with m = 634187054622810
Performance: 2.42511821792149745405536853228315 * 10^9 terms per second
Almost: 634187433020610
Almost: 634187491355355
Almost: 634200503677275
Almost: 634201108957995
Almost: 634205475692880
Almost: 634206670826820
^C
perl lucas-carmichael_sieve_a4.pl  13395.97s user 31.09s system 95% cpu 3:55:00.43 total

[215080000000] Searching for a(4) with m = 706374685242915
Performance: 2.73880942690597 * 10^9 terms per second
Almost: 706375023324465
Almost: 706378475620935
Almost: 706379483914170
Almost: 706383138499500
Almost: 706384539244230
Almost: 706391184005925
Almost: 706399280749305
Almost: 706400711826960
Almost: 706403273537925
Almost: 706403561364255
Almost: 706406614976025
[215090000000] Searching for a(4) with m = 706407527875140
Performance: 2.73558343885642 * 10^9 terms per second
Almost: 706408270100925
^C
perl lucas-carmichael_sieve_a4.pl  26441.44s user 11.77s system 99% cpu 7:24:59.11 total
