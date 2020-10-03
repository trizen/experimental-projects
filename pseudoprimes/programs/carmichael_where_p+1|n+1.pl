#!/usr/bin/perl

# Find Carmichael numbers m that have at least one prime factor p such that p+1 | m+1.

# a(n) is the least Carmichael number m such that p+1 | m+1 for exactly n prime factors p of m.

# It is not known whether any Carmichael number (A002997) is also Lucas-Carmichael number (A006972).

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::GMPz;

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n < ~0);
    next if length($n) > 30;
    Math::Prime::Util::GMP::is_carmichael($n) || next;
    $n = Math::GMPz->new($n);

    my $inc = $n+1;
    my $k = scalar grep { $inc % ($_+1) == 0 } factor($n);

    if (not exists $table{$k}) {
        say "a($k) <= $n";
        $table{$k} = $n;
    }
    elsif ($n < $table{$k}) {
        say "a($k) <= $n";
        $table{$k} = $n;
    }
}

__END__
0 561
1 1105
2 2465
3 9857524690572481

# Upper-bounds:

a(0) <= 18447025366781051329
a(1) <= 18734162714176896001
a(2) <= 30847156600639170961
a(3) <= 290511032565049956001
