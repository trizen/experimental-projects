#!/usr/bin/perl

# Numbers n such that both their ternary and Zeckendorf representations are palindromic.
# https://oeis.org/A329459

# The first 32 terms:
#   0, 1, 4, 56, 80, 203, 572, 847, 1402, 93496, 128180, 431060, 467852, 1465676, 7742920, 8727388, 8923840, 9582707, 18245944, 18304588, 25154692, 27262924, 115404434, 209060644, 763786258, 860973806, 2042328148, 4719261289, 5236838932, 18202403140, 42897493894, 77310551669

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

#use Math::AnyNum qw(:overload);

my @fib;

sub fib ($n) {
    return 1 if $n < 2;
    $fib[$n] //= fib($n - 1) + fib($n - 2);
}

sub next_palindrome ($n, $base = 10) {

    my @d = todigits($n, $base);
    my $l = $#d;
    my $i = ((scalar(@d) + 1) >> 1) - 1;

    while ($i >= 0 and $d[$i] == $base - 1) {
        $d[$i] = 0;
        $d[$l - $i] = 0;
        $i--;
    }

    if ($i >= 0) {
        $d[$i]++;
        $d[$l - $i] = $d[$i];
    }
    else {
        @d     = (0) x (scalar(@d) + 1);
        $d[0]  = 1;
        $d[-1] = 1;
    }

    fromdigits(\@d, $base);
}

sub zeckendorf ($n) {
    $n || return "0";
    my $i = 1;
    $i++ while fib($i) <= $n;
    my $z = '';
    while (--$i) {
        $z .= "0", next if fib($i) > $n;
        $z .= "1";
        $n -= fib($i);
    }
    return $z;
}

sub is_palindrome ($str) {
    $str eq reverse($str);
}

my %data = qw(
  1 0
  2 1
  3 4
  4 56
  5 80
  6 203
  7 572
  8 847
  9 1402
  10 93496
  11 128180
  12 431060
  13 467852
  14 1465676
  15 7742920
  16 8727388
  17 8923840
  18 9582707
  19 18245944
  20 18304588
  21 25154692
  22 27262924
  23 115404434
  24 209060644
  25 763786258
  26 860973806
  27 2042328148
  28 4719261289
  29 5236838932
  30 18202403140
  31 42897493894
  32 77310551669
  33 245677165880
  34 515278168027
  35 946875048544
  36 3292614573724
  37 5067945861253
  38 6454819689719
  39 11903063838880
  40 24983407285273
  41 47861480178434
  42 112154983037572
  43 235536470381278
  );

foreach my $v (values %data) {
    require Math::AnyNum;
    my $n  = Math::AnyNum->new($v);
    my $zk = zeckendorf($n);
    if (not is_palindrome($zk)) {
        die "error for $zk -> not a Zeckendorf palindrome";
    }

    if (not is_palindrome($n->base(3))) {
        die "error for $n -> not a base-3 palindrome";
    }
}

local $| = 1;

my $base = 3;
my $n    = 1;
my $k    = 2;

while (1) {

    if (is_palindrome(zeckendorf($n))) {
        ##print($n, ", ");
        say "$k $n";
        ++$k;
    }

    $n = next_palindrome($n, $base);
}
