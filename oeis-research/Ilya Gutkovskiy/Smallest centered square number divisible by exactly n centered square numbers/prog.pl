#!/usr/bin/perl

# a(n) is the smallest centered square number divisible by exactly n centered square numbers.
# https://oeis.org/A359232

# Known terms:
#   1, 5, 25, 925, 1625, 1105, 47125, 350285, 493025, 3572465, 47074105, 13818025, 4109345825, 171921425, 294346585, 130334225125, 190608050165, 2687125303525, 2406144489125, 5821530534625, 49723952067725, 1500939251825

# New terms found a(23)-a(27):
#   665571884367325, 8362509238504525, 1344402738869125, 49165090920807485, 4384711086003625,

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

# PARI/GP program:
#   a(n) = for(k=0, oo, my(t=2*k*(k+1)+1); if(sumdiv(t, d, issquare(2*d-1)) == n, return(t))); \\ ~~~~

my %seen;
my %table;

my $count;
for(my $k = 0; ; ++$k) {

    #my $t = mulint(2*$k, ($k + 1)) + 1;
    my $t = 2*$k*($k + 1) + 1;

    #undef $table{$t};

    $count = 0;

    foreach my $d (divisors($t)) {
        #if (exists $table{$d}) {
        if (is_square(mulint(2, $d) - 1) and (sqrtint(mulint(2, $d) - 1)-1)%2 == 0) {
            ++$count;
        }
    }

    if (not exists $seen{$count}) {
        say "a($count) = $t";
        $seen{$count} = $t;
    }
}

__END__
a(1) = 1
a(2) = 5
a(3) = 25
a(4) = 925
a(6) = 1105
a(5) = 1625
a(7) = 47125
a(8) = 350285
a(9) = 493025
a(10) = 3572465
a(12) = 13818025
a(11) = 47074105
a(14) = 171921425
a(15) = 294346585
a(13) = 4109345825
a(16) = 130334225125
a(17) = 190608050165
a(22) = 1500939251825
a(19) = 2406144489125
a(18) = 2687125303525
a(20) = 5821530534625
a(21) = 49723952067725
a(23) = 665571884367325
a(25) = 1344402738869125
a(27) = 4384711086003625
a(24) = 8362509238504525
a(30) = 13148945184367525
a(26) = 49165090920807485
