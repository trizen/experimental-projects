#!/usr/bin/perl

# Number of positive integers with n digits that are the product of two integers ending with 3.
# https://oeis.org/A346952

# Known terms:
#    1, 3, 37, 398, 4303, 45765, 480740, 5005328, 51770770, 532790460

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub a ($n) {

    my $lim = powint(10, $n-1);
    my $count = 0;

    my %seen;

    foreach my $u (1 .. divint($lim, 10*3)) {

        my $k = $u . '3';

        foreach my $m (divint($lim, 10*$k)..divint($lim, $k)) {
            my $r = mulint($k , $m . '3');
            if (length($r) > $n) {
                #~ say "Above limit for $k -- $m -- gives $r";
                last;
            }
            if (length($r) == $n) {
                ++$count if !$seen{$r}++;
            }
        }
    }

    foreach my $k (3) {
        foreach my $m (divint($lim, 10*$k)..divint($lim, $k)) {
            my $r = mulint($k , $m . '3');
            #~ if (length($r) > $n) {
                #~ say "Above limit $k -- $m -- gives $r";
                #~ last;
            #~ }
            if (length($r) == $n) {
                ++$count if !$seen{$r}++;
            }
        }
    }

    return $count;
}

local $| = 1;
foreach my $n (1..100) {
    print(a($n), ", ");
}
