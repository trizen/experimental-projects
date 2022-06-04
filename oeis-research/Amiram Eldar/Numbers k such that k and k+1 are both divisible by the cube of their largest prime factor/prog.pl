#!/usr/bin/perl

# Numbers k such that k and k+1 are both divisible by the cube of their largest prime factor.
# https://oeis.org/A354562

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use experimental qw(signatures);

sub smooth_numbers ($limit, $primes) {

    if ($limit <= $primes->[-1]) {
        return [1 .. $limit];
    }

    if ($limit <= 5e4) {

        my @list;
        my $B = $primes->[-1];

        foreach my $k (1 .. $limit) {
            if (is_smooth($k, $B)) {
                push @list, $k;
            }
        }

        return \@list;
    }

    my @h = (1);
    foreach my $p (@$primes) {
        foreach my $n (@h) {
            if ($n * $p <= $limit) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub upto ($n) {

    my $k = powint(10, $n);
    my $limit = rootint($k, 3);

    my @smooth;
    my @primes;

    my $pi = prime_count($limit);

    #my $count = 0;
    my $i = 0;

    foreach my $p (@{primes($limit)}) {

        ++$i;
        say "[$i / $pi] Processing prime $p";

        my $ppp = powint($p, 3);
        push @primes, $p;

        push @smooth, grep {
            my $m = addint($_, 1);
            valuation($m, (factor($m))[-1]) >= 3;
        } map { mulint($_, $ppp) } @{smooth_numbers(divint($k, $ppp), \@primes)};

#<<<
        #~ foreach my $s (@{smooth_numbers(divint($k, $ppp), \@primes)}) {
            #~ my $m = mulint($ppp, $s)+1;
            #~ if (valuation($m,(factor($m))[-1]) >= 3) {
                #~ ++$count;
            #~ }
        #~ }
#>>>

    }

    #return $count;
    return sort { $a <=> $b } @smooth;
}

my $n = 16;
say join(', ', upto($n));

__END__

Terms <= 10^10 (took 1 second):

6859, 11859210, 18253460

Terms <= 10^11 (took 3 seconds):

6859, 11859210, 18253460, 38331320423, 41807225999, 49335445119, 50788425848, 67479324240

Terms <= 10^12 (took 20 seconds):

6859, 11859210, 18253460, 38331320423, 41807225999, 49335445119, 50788425848, 67479324240, 203534609200, 245934780371, 250355343420, 581146348824, 779369813871

Terms <= 10^13 (took 1 minute, 23 seconds):

6859, 11859210, 18253460, 38331320423, 41807225999, 49335445119, 50788425848, 67479324240, 203534609200, 245934780371, 250355343420, 581146348824, 779369813871, 1378677994836, 2152196307260, 2730426690524, 3616995855087, 5473549133744, 6213312123347, 6371699408179, 8817143116903

Terms <= 10^14 (took 7 minutes, 45 seconds):

6859, 11859210, 18253460, 38331320423, 41807225999, 49335445119, 50788425848, 67479324240, 203534609200, 245934780371, 250355343420, 581146348824, 779369813871, 1378677994836, 2152196307260, 2730426690524, 3616995855087, 5473549133744, 6213312123347, 6371699408179, 8817143116903, 10580976302953, 11472391801871, 13216962548041, 13706893315080, 14290357294080, 15905569798195, 16271530266617, 22461705602181, 23321692115952, 27618965226272, 41874839976255, 41908972638950, 45766487777625, 52180739595561, 55700393481221, 56406122227520, 57332088950954, 63706987551655, 72288227692128, 79600158837990, 81379455889248, 88338240903809, 90975561354964
