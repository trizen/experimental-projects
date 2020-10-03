#!/usr/bin/perl


# Data:
#   3, 5, 7, 11, 17, 19, 29, 41, 71, 181, 239, 379, 449, 701, 881, 1429, 1871, 2729, 3079, 4159, 10529, 11969, 23561, 40699, 51679, 90271, 104651, 146719, 226799, 244529, 252449, 388961, 403649, 825551, 906751, 1276001, 2408561, 2648449, 3807649, 4058209, 4406401, 12227489, 14579839, 16780609, 23779601, 38313001, 57762431, 74850049, 166676399, 384988031,

use ntheory qw(:all);

use 5.014;
local $| = 1;

my $k = 1;

my $n = 384988031;
my $m = divisors($n+1)*divisors($n-1)/divisors($n)**2;

--$n;
--$m;

#for (my ($n, $m) = (2, -1) ; ; ++$n) {
for (;;++$n) {

    #my $d = (divisors($n-1) / divisors($n)) + (divisors($n+1) / divisors($n));
    #tau(n+1)*tau(n-1)/tau(n)^2

    my $d = divisors($n+1) * divisors($n-1) / divisors($n)**2;

    if ($m < $d) {

        $m = $d;

        print "$n, ";
       # print "$d, ";
       #say "$k $n";
       ++$k;
    }

}

# upto(n) = my(m=-1); for(k=2, n, my(d=numdiv(k+1)*numdiv(k-1)/numdiv(k)^2); if (d>m, m=d; print1(k, ", ")));
