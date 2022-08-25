#!/usr/bin/perl

# Smallest m such that the m-th Lucas number has exactly n divisors that are also Lucas numbers.
# https://oeis.org/A356666

# Known terms:
#   1, 0, 3, 6, 15, 30, 45, 90, 105, 210, 405

# New terms:
#   1, 0, 3, 6, 15, 30, 45, 90, 105, 210, 405, 810, 315, 630, 3645, 2025, 945, 1890, 1575, 3150, 2835, 5670
#   1, 0, 3, 6, 15, 30, 45, 90, 105, 210, 405, 810, 315, 630, 3645, 2025, 945, 1890, 1575, 3150, 2835, 5670, 36450, 25025, 3465, 6930

# Using the PARI/GP program, finding the first 26 terms, took 5 hours.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

sub count_lucas_divisors($n) {
    my $count = 0;

    my $x = Math::GMPz::Rmpz_init_set_ui(2);
    my $y = Math::GMPz::Rmpz_init_set_ui(1);
    my $t = Math::GMPz::Rmpz_init();

    while (Math::GMPz::Rmpz_cmp($x, $n) <= 0) {
        if (Math::GMPz::Rmpz_divisible_p($n, $x)) {
            ++$count;
        }
        Math::GMPz::Rmpz_set($t, $y);
        Math::GMPz::Rmpz_add($y, $x, $y);
        Math::GMPz::Rmpz_set($x, $t);
    }
    return $count;
}

my $x = Math::GMPz::Rmpz_init_set_ui(2);
my $y = Math::GMPz::Rmpz_init_set_ui(1);
my $t = Math::GMPz::Rmpz_init();

my @table;

for (my $k = 0; ; ++$k) {

    my $c = count_lucas_divisors($x);

    if (!defined($table[$c])) {
        $table[$c] = 1;
        if ($c >= 3) {
            say "a($c) = $k";
        }
    }

    Math::GMPz::Rmpz_set($t, $y);
    Math::GMPz::Rmpz_add($y, $x, $y);
    Math::GMPz::Rmpz_set($x, $t);
}

__END__

# PARI/GP program:

countLd(n) = my(c=0,x=2,y=1); while(x <= n, if(n%x == 0, c++); [x,y]=[y,x+y]); c;
a(n) = if(n==1, return(1)); my(k=0,x=2,y=1); while(1, if(countLd(x) == n, return(k)); [x,y,k]=[y,x+y,k+1]); \\ ~~~~

a(3) = 3
a(4) = 6
a(5) = 15
a(6) = 30
a(7) = 45
a(8) = 90
a(9) = 105
a(10) = 210
a(13) = 315
a(11) = 405
a(14) = 630
a(12) = 810
a(17) = 945
a(19) = 1575
a(18) = 1890
a(16) = 2025
a(21) = 2835
a(20) = 3150
a(25) = 3465
a(15) = 3645
a(22) = 5670
a(26) = 6930
a(33) = 10395
a(28) = 11025
a(31) = 14175
a(37) = 17325
a(34) = 20790
a(29) = 22050
a(24) = 25025
a(32) = 28350
a(41) = 31185
a(38) = 34650
a(23) = 36450
a(49) = 45045
a(30) = 51030

Further terms <= 51030: a(28) = 11025, a(29) = 22050, a(30) = 51030, a(31) = 14175, a(32) = 28350, a(33) = 10395, a(34) = 20790, a(37) = 17325, a(38) = 34650, a(41) = 31185, a(49) = 45045. - ~~~~
