#!/usr/bin/perl

use 5.020;
use ntheory qw(:all);
use IO::Uncompress::Bunzip2;

my $z = IO::Uncompress::Bunzip2->new("psps-below-2-to-64.txt.bz2");

my %fermat;
my %carmichael;

while (defined(my $line = $z->getline())) {

    if ($. % 100_000 == 0) {
        say "[$. of 118968378] Processing: ", sprintf('%.2f', ($. / 118968378) * 100), "% done";
    }

    chomp($line);

    my @f = factor($line);
    my $p = (factor($f[0] - 1))[-1];

    next if ($p > 104729);

    if (not exists $fermat{$p}) {
        if ((vecall { ($_-1) % $p == 0 } @f) and (vecall { (factor($_ - 1))[-1] == $p } @f)) {
            $fermat{$p} = $line;
        }
    }

    if (not exists $carmichael{$p} and scalar(@f) >= 3 and (vecall { ($_-1) % $p == 0 and ($line - 1) % ($_ - 1) == 0 } @f) and is_carmichael($line)) {
        if (vecall { (factor($_ - 1))[-1] == $p } @f) {
            $carmichael{$p} = $line;
        }
    }

    last if ($. >= 300000);
}

open my $all_fer, '>', 'all_fermat.txt';
open my $all_car, '>', 'all_carmichael.txt';

open my $nogap_fer, '>', 'nogaps_fermat.txt';
open my $nogap_car, '>', 'nogaps_carmichael.txt';

foreach my $p (sort { $a <=> $b } keys %fermat) {
    my $n = prime_count($p);
    say {$all_fer} "$n $fermat{$p}";
}

foreach my $p (sort { $a <=> $b } keys %carmichael) {
    my $n = prime_count($p);
    say {$all_car} "$n $carmichael{$p}";
}

{
    my $prev = 0;
    foreach my $p (sort { $a <=> $b } keys %fermat) {
        my $n = prime_count($p);
        $n == $prev + 1 or last;
        say {$nogap_fer} "$n $fermat{$p}";
        $prev = $n;
    }
}

{
    my $prev = 1;
    foreach my $p (sort { $a <=> $b } keys %carmichael) {
        my $n = prime_count($p);
        $n == $prev + 1 or last;
        say {$nogap_car} "$n $carmichael{$p}";
        $prev = $n;
    }
}

close $all_car;
close $all_fer;
close $nogap_car;
close $nogap_fer;
