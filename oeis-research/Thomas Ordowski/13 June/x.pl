#!/usr/bin/perl

#a'(n) is the smallest odd k > 1 such that n^{(k+1)/2} == n (mod k).
#b'(n) is the smallest odd k > 1 such that n^{(k+1)/2} == -n (mod k).

use 5.014;
use ntheory qw(:all);

sub a {
    my ($n) = @_;

    for (my $k = 3; ; $k+=2) {
        if (powmod($n, ($k+1)>>1, $k) == ($n%$k)) {
            return $k;
        }
    }
}


sub b {
    my ($n) = @_;

    for (my $k = 3; ; $k+=2) {
        if (powmod($n, ($k+1)>>1, $k) == ((-$n)%$k)) {
            return $k;
        }
    }
}

#say join ', ', map{a($_)}0..10;
#say join ', ', map($_)}0..10;

my %powers_of_4;
foreach my $k(0..20) {
    $powers_of_4{4**$k} = 1;
}

my $max = 0;

foreach my $n(1..1e7) {

    if ($powers_of_4{$n}) {
        next;
    }

        my $t = b($n);

        if ($t > $max) {
            $max = $t;
            say "b'($n) = $t";
        }
}

__END__

a(95006567) = 83
a(269607362) = 89
a(515732423) = 103
a(545559467) = 113


__END__
say join', ', sort {$a <=> $b} keys %seen;

__END__

my $max = 0;
foreach my $k(0..1e9){
    my $t = b($k);
    if ($t > $max) {
        $max = $t;
        say "b($k) = $max";
    }
}

__END__
say sqrt(2)
local Num!PREC = 42.numify
say sqrt(2)
