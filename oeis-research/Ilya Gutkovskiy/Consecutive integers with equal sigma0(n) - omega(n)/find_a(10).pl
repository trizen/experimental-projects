#!/usr/bin/perl

# a(n) is the smallest number k such that n consecutive integers starting at k have the same number of nonprime divisors (A033273).
# https://oeis.org/A324594

# a(9) = a(10) = 2587701932494, discovered by Giovanni Resta on Sep 04 2019.

# Notice that:
#   2587701932494 + 2 = 2^4 * 3^2 * 17970152309
#   2587701932494 + 6 = 2^2 * 5^4 * 1035080773

# By looking for special numbers of the form 2^a * 3^b * p, we may find upper-bounds for the next terms.

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub count ($n) {
    divisor_sum($n, 0) - scalar(factor_exp($n));
}

sub score ($n) {
    my $t = count($n);

    for my $k (1..100) {
        if (count($n+$k) != $t) {
            return $k;
        }
    }
}

foreach my $n (8311077681..1e11) {

    # p = 625 n + 434, q = 36 n + 25, n element Z

    my $p = 625 * $n + 434;
    my $q = 36*$n + 25;

    if (is_prime($q) and is_prime($p)) {
        # ( 2^4 * 3^2 * p - 2) = (2^2 * 5^4 * q - 6)

        my $m = 2**4 * 3**2 * $p - 2;
        my $s = score($m);

        if ($s >= 8) {

            say "For p = $q --> $m has a score of $s with n = $n";

            foreach my $k(1..4) {

                my $m = $n-$k;
                my $s = score($m);

                if ($s >= 9) {

                    say "For q = $q --> $m has a score of $s";

                    if ($s >= 10) {
                        die "Upper-bound for a(10) = $m\n";
                    }
                }
            }
        }
    }
}

__END__

forprimes {

    my $n = 2**2 * 5**4 * $_ - 6;

    if ((($n+2) % (2**4 * 3**2) == 0 and is_prime(($n+2) / (2**4 * 3**2)))) {

        my $s = score($n);

        if ($s >= 8) {

            say "For p = $_ --> $n has a score of $s";

            foreach my $k(1..4) {

                my $m = $n-$k;
                my $s = score($m);

                if ($s >= 9) {

                    say "For p = $_ --> $m has a score of $s";

                    if ($s >= 10) {
                        die "Upper-bound for a(10) = $m\n";
                    }
                }
            }
        }
    }

} 372522098053, 1e12;

#~ forprimes {

    #~ my $n = 2**4 * 3**2 * $_ - 1;

    #~ if ((($n+5) % (2**2 * 5**4) == 0 and is_prime(($n+5) / (2**2 * 5**4)))) {

        #~ my $s = score($n);

        #~ if ($s >= 8) {

            #~ say "For p = $_ --> $n has a score of $s";

            #~ foreach my $k(1..4) {

                #~ my $m = $n-$k;
                #~ my $s = score($m);

                #~ if ($s >= 9) {

                    #~ say "For p = $_ --> $m has a score of $s";

                    #~ if ($s >= 10) {
                        #~ die "Upper-bound for a(10) = $m\n";
                    #~ }
                #~ }
            #~ }
        #~ }
    #~ }

#~ } 17970152309, 1e12;

__END__
For p = 561889429 --> 1404723572494 has a score of 7
For p = 1035080773 --> 2587701932494 has a score of 9
For p = 1302098029 --> 3255245072494 has a score of 7
For p = 1935566197 --> 4838915492494 has a score of 7

For p = 1035080773 --> 2587701932494 has a score of 9
For p = 18239128333 --> 45597820832494 has a score of 8
For p = 19723897789 --> 49309744472494 has a score of 8
For p = 25877506021 --> 64693765052494 has a score of 8
For p = 28232914597 --> 70582286492494 has a score of 8
For p = 42086368141 --> 105215920352494 has a score of 8
For p = 54130664149 --> 135326660372494 has a score of 8
For p = 55260657637 --> 138151644092494 has a score of 8
For p = 55262128309 --> 138155320772494 has a score of 8
For p = 57622809373 --> 144057023432493 has a score of 8
For p = 61983345301 --> 154958363252493 has a score of 8
For p = 63164144437 --> 157910361092494 has a score of 8
For p = 72522098053 --> 181305245132494 has a score of 9
For p = 96189817237 --> 240474543092494 has a score of 9
For p = 100553807077 --> 251384517692494 has a score of 9
For p = 105864885493 --> 264662213732494 has a score of 8
For p = 106405795789 --> 266014489472494 has a score of 9
For p = 110041035397 --> 275102588492494 has a score of 8
For p = 113739238933 --> 284348097332494 has a score of 8
For p = 121050305197 --> 302625762992494 has a score of 8
For p = 123282435013 --> 308206087532494 has a score of 8
For p = 125876453893 --> 314691134732494 has a score of 9
For p = 129396961861 --> 323492404652494 has a score of 8
For p = 141361196461 --> 353402991152494 has a score of 8
For p = 150178310701 --> 375445776752494 has a score of 8 with n = 4171619741
For p = 151094205709 --> 377735514272494 has a score of 8 with n = 4197061269
For p = 156310948069 --> 390777370172494 has a score of 8 with n = 4341970779
For p = 159538376941 --> 398845942352494 has a score of 8 with n = 4431621581
For p = 160385248717 --> 400963121792494 has a score of 8 with n = 4455145797
For p = 192844580893 --> 482111452232494 has a score of 9 with n = 5356793913
For p = 193846276357 --> 484615690892494 has a score of 8 with n = 5384618787
For p = 198253207357 --> 495633018392494 has a score of 8 with n = 5507033537
For p = 205856273437 --> 514640683592494 has a score of 8 with n = 5718229817
For p = 206835717013 --> 517089292532494 has a score of 8 with n = 5745436583
For p = 215253787741 --> 538134469352494 has a score of 8 with n = 5979271881
For p = 215661722389 --> 539154305972494 has a score of 8 with n = 5990603399
For p = 223318321477 --> 558295803692494 has a score of 8 with n = 6203286707
For p = 223653338341 --> 559133345852494 has a score of 9 with n = 6212592731
For p = 225804906493 --> 564512266232494 has a score of 9 with n = 6272358513
For p = 228099619933 --> 570249049832494 has a score of 8 with n = 6336100553
For p = 232454185477 --> 581135463692494 has a score of 8 with n = 6457060707
For p = 233938339837 --> 584845849592494 has a score of 8 with n = 6498287217
For p = 234711721429 --> 586779303572494 has a score of 8 with n = 6519770039
For p = 235027434949 --> 587568587372494 has a score of 8 with n = 6528539859
For p = 242484828109 --> 606212070272494 has a score of 8 with n = 6735689669
For p = 247949575117 --> 619873937792494 has a score of 8 with n = 6887488197
For p = 254395377421 --> 635988443552494 has a score of 8 with n = 7066538261
For p = 266683117093 --> 666707792732494 has a score of 8 with n = 7407864363
For p = 275754225949 --> 689385564872494 has a score of 8 with n = 7659839609
For p = 277299391381 --> 693248478452494 has a score of 8 with n = 7702760871
For p = 284390002933 --> 710975007332494 has a score of 9 with n = 7899722303
For p = 286488763909 --> 716221909772494 has a score of 8 with n = 7958021219
For p = 289553761573 --> 723884403932494 has a score of 8 with n = 8043160043
For p = 289642662637 --> 724106656592494 has a score of 8 with n = 8045629517
For p = 295787783293 --> 739469458232494 has a score of 8 with n = 8216327313
For p = 297051950149 --> 742629875372494 has a score of 9 with n = 8251443059
For p = 299198796541 --> 747996991352494 has a score of 8 with n = 8311077681
