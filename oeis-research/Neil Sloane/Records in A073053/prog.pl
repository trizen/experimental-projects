#!/usr/bin/perl

use 5.014;
use ntheory qw(fromdigits);

my $max = 0;

foreach my $i(2..99) {
    my $x = '1' x $i;
    my $y = '10' . ('1' x ($i-2));

    #if ($i % 2 == 0) {
    #    $n = '10' . ('1' x ($i-3));
    #}
    #else {
    #    $n = '1'x($i-2);
    #}


    foreach my $n($y, $x) {

        my @digits = split(//, $n);
        my $k = join('', scalar(grep{$_&1} @digits), scalar(grep{!($_&1)} @digits), scalar(@digits));

   # if ($k > $max) {
   #     $max = $k;
            #say "$k for $n -> ", fromdigits($n, 2);
            say $k;
            #print "$k, ";
        }
  #  }
}

#~ 11, 101, 112, 202, 213, 303, 314, 404, 415, 505, 516, 606, 617, 707, 718, 808, 819, 909, 9110, 10010, 10111, 11011, 11112, 12012, 12113, 13013, 13114, 14014, 14115, 15015, 15116, 16016, 16117, 17017, 17118, 18018, 18119, 19019, 19120, 20020, 20121
